import UIKit
import Combine

final class MatchDetailsViewController: UIViewController {
    private let viewModel: MatchDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.large
        stack.alignment = .fill
        return stack
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: MatchDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        viewModel.loadMatchDetails()
    }

    private func setupUI() {
        title = StringConstants.Titles.matchDetails
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.Spacing.large),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Spacing.large),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.Spacing.large),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Spacing.large),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$match
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] match in
                self?.updateMatchInfo(match)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }

    private func updateMatchInfo(_ match: Match) {

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let matchInfoView = createMatchInfoView(match)
        stackView.addArrangedSubview(matchInfoView)
    }

    private func createMatchInfoView(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.large
        stack.alignment = .fill

        let tournamentView = createTournamentInfoView(match)
        stack.addArrangedSubview(tournamentView)

        let scoreView = createTennisScoreView(match)
        stack.addArrangedSubview(scoreView)

        if match.isLive, let gameResult = match.gameResult, !gameResult.isEmpty {
            let currentGameView = createCurrentGameView(match)
            stack.addArrangedSubview(currentGameView)
        }

        let detailsView = createMatchDetailsView(match)
        stack.addArrangedSubview(detailsView)

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.large),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.large),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.large),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.large)
        ])

        return containerView
    }

    private func createTournamentInfoView(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .fill

        let tournamentLabel = UILabel()
        tournamentLabel.text = match.tournament.name
        tournamentLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
        tournamentLabel.numberOfLines = 0
        stack.addArrangedSubview(tournamentLabel)

        if let round = match.round {
            let roundLabel = UILabel()
            roundLabel.text = round
            roundLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            roundLabel.textColor = .secondaryLabel
            stack.addArrangedSubview(roundLabel)
        }

        let dateLabel = UILabel()
        dateLabel.text = "\(match.date) • \(match.time)"
        dateLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        dateLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(dateLabel)

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.medium),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.medium)
        ])

        return containerView
    }

    private func createTennisScoreView(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let playersStack = UIStackView()
        playersStack.translatesAutoresizingMaskIntoConstraints = false
        playersStack.axis = .horizontal
        playersStack.distribution = .fillEqually
        playersStack.spacing = UIConstants.Spacing.large
        playersStack.alignment = .center

        let player1Container = createPlayerContainer(
            name: match.firstPlayer.name,
            logoURL: match.firstPlayer.logoURL,
            alignment: .left,
            player: match.firstPlayer
        )
        playersStack.addArrangedSubview(player1Container)

        let versusLabel = UILabel()
        versusLabel.text = "VS"
        versusLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        versusLabel.textColor = .secondaryLabel
        versusLabel.textAlignment = .center
        playersStack.addArrangedSubview(versusLabel)

        let player2Container = createPlayerContainer(
            name: match.secondPlayer.name,
            logoURL: match.secondPlayer.logoURL,
            alignment: .right,
            player: match.secondPlayer
        )
        playersStack.addArrangedSubview(player2Container)

        let scoreTableView = createScoreTable(match)

        let mainStack = UIStackView()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = UIConstants.Spacing.medium
        mainStack.alignment = .fill

        mainStack.addArrangedSubview(playersStack)
        mainStack.addArrangedSubview(scoreTableView)

        containerView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.medium),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.medium),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.medium)
        ])

        return containerView
    }

    private func createPlayerContainer(name: String, logoURL: String?, alignment: NSTextAlignment, player: PlayerInfo) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = alignment == .left ? .leading : .trailing

        let photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.cornerRadius = UIConstants.CornerRadius.medium
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .tertiarySystemBackground

        if let logoURL = logoURL, let url = URL(string: logoURL) {
            Task { [weak self] in
                guard let self = self else { return }

                if let image = await self.viewModel.imageCache.getImage(from: url) {
                    await MainActor.run {
                        photoImageView.image = image
                        photoImageView.tintColor = nil
                    }
                } else {
                    await MainActor.run {
                        photoImageView.image = UIImage(systemName: ImageConstants.SystemIcons.person2Fill)
                        photoImageView.tintColor = .secondaryLabel
                    }
                }
            }
        } else {
            photoImageView.image = UIImage(systemName: ImageConstants.SystemIcons.person2Fill)
            photoImageView.tintColor = .secondaryLabel
        }

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.medium)
        nameLabel.textAlignment = alignment
        nameLabel.numberOfLines = 2

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = Int(player.key) ?? 0 // Store player key in tag
        container.accessibilityIdentifier = player.key

        stack.addArrangedSubview(photoImageView)
        stack.addArrangedSubview(nameLabel)

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalToConstant: 80),
            photoImageView.heightAnchor.constraint(equalToConstant: 80),

            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    @objc private func playerTapped(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view,
              let playerKey = container.accessibilityIdentifier else {
            return
        }

        guard let match = viewModel.match else { return }

        let player: Player
        if match.firstPlayer.key == playerKey {
            player = Player(
                key: match.firstPlayer.key,
                name: match.firstPlayer.name,
                fullName: nil,
                country: nil,
                countryCode: nil,
                birthday: nil,
                logoURL: match.firstPlayer.logoURL,
                stats: nil
            )
        } else if match.secondPlayer.key == playerKey {
            player = Player(
                key: match.secondPlayer.key,
                name: match.secondPlayer.name,
                fullName: nil,
                country: nil,
                countryCode: nil,
                birthday: nil,
                logoURL: match.secondPlayer.logoURL,
                stats: nil
            )
        } else {
            return
        }

        viewModel.didSelectPlayer(player: player)
    }

    private func createScoreTable(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let setsToDisplay = !match.sets.isEmpty ? match.sets : match.scores.map { score in
            TennisSet(
                number: score.setNumber,
                firstPlayerGames: Int(score.firstPlayerScore) ?? 0,
                secondPlayerGames: Int(score.secondPlayerScore) ?? 0,
                games: [],
                isCompleted: true
            )
        }

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .fill

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.distribution = .fillEqually
        headerStack.spacing = UIConstants.Spacing.small

        let setHeader = UILabel()
        setHeader.text = "SET"
        setHeader.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        setHeader.textAlignment = .center
        setHeader.textColor = .secondaryLabel

        let player1Header = UILabel()
        player1Header.text = match.firstPlayer.name.components(separatedBy: " ").last ?? ""
        player1Header.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        player1Header.textAlignment = .center
        player1Header.textColor = .secondaryLabel

        let player2Header = UILabel()
        player2Header.text = match.secondPlayer.name.components(separatedBy: " ").last ?? ""
        player2Header.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        player2Header.textAlignment = .center
        player2Header.textColor = .secondaryLabel

        headerStack.addArrangedSubview(setHeader)
        headerStack.addArrangedSubview(player1Header)
        headerStack.addArrangedSubview(player2Header)

        stack.addArrangedSubview(headerStack)

        for (index, set) in setsToDisplay.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = UIConstants.Spacing.small

            let setLabel = UILabel()
            setLabel.text = set.number
            setLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            setLabel.textAlignment = .center

            let score1Label = UILabel()
            score1Label.text = "\(set.firstPlayerGames)"
            score1Label.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
            score1Label.textAlignment = .center

            let score2Label = UILabel()
            score2Label.text = "\(set.secondPlayerGames)"
            score2Label.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
            score2Label.textAlignment = .center

            if !set.isCompleted && index == setsToDisplay.count - 1 {
                score1Label.textColor = .systemBlue
                score2Label.textColor = .systemBlue
                setLabel.textColor = .systemBlue
            }

            rowStack.addArrangedSubview(setLabel)
            rowStack.addArrangedSubview(score1Label)
            rowStack.addArrangedSubview(score2Label)

            stack.addArrangedSubview(rowStack)

            if !set.games.isEmpty {
                let gamesView = createGamesDetailView(
                    set.games,
                    firstPlayerName: match.firstPlayer.name,
                    secondPlayerName: match.secondPlayer.name,
                    setNumber: set.number,
                    isCurrentSet: !set.isCompleted && index == setsToDisplay.count - 1
                )
                stack.addArrangedSubview(gamesView)
            }
        }

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createGamesDetailView(
        _ games: [Game],
        firstPlayerName: String,
        secondPlayerName: String,
        setNumber: String,
        isCurrentSet: Bool
    ) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.small

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "Games in Set \(setNumber)\(isCurrentSet ? " (Current)" : "")"
        titleLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        titleLabel.textColor = isCurrentSet ? .systemBlue : .secondaryLabel
        stack.addArrangedSubview(titleLabel)

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.distribution = .fillEqually
        headerStack.spacing = UIConstants.Spacing.small

        let gameHeader = UILabel()
        gameHeader.text = "Game"
        gameHeader.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        gameHeader.textAlignment = .center
        gameHeader.textColor = .secondaryLabel

        let player1Header = UILabel()
        player1Header.text = firstPlayerName.components(separatedBy: " ").last ?? ""
        player1Header.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        player1Header.textAlignment = .center
        player1Header.textColor = .secondaryLabel

        let player2Header = UILabel()
        player2Header.text = secondPlayerName.components(separatedBy: " ").last ?? ""
        player2Header.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        player2Header.textAlignment = .center
        player2Header.textColor = .secondaryLabel

        headerStack.addArrangedSubview(gameHeader)
        headerStack.addArrangedSubview(player1Header)
        headerStack.addArrangedSubview(player2Header)
        stack.addArrangedSubview(headerStack)

        for game in games.suffix(10) { // Show last 10 games
            let gameStack = UIStackView()
            gameStack.axis = .horizontal
            gameStack.distribution = .fillEqually
            gameStack.spacing = UIConstants.Spacing.small

            let gameLabel = UILabel()
            gameLabel.text = "G\(game.number)"
            gameLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
            gameLabel.textAlignment = .center
            gameLabel.textColor = .secondaryLabel

            let points1Label = UILabel()
            points1Label.text = game.firstPlayerPoints.isEmpty ? "0" : game.firstPlayerPoints
            points1Label.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            points1Label.textAlignment = .center

            let points2Label = UILabel()
            points2Label.text = game.secondPlayerPoints.isEmpty ? "0" : game.secondPlayerPoints
            points2Label.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            points2Label.textAlignment = .center

            if let server = game.server {
                if server.contains("First") {
                    points1Label.text = "\(points1Label.text ?? "") 🎾"
                } else if server.contains("Second") {
                    points2Label.text = "\(points2Label.text ?? "") 🎾"
                }
            }

            gameStack.addArrangedSubview(gameLabel)
            gameStack.addArrangedSubview(points1Label)
            gameStack.addArrangedSubview(points2Label)

            stack.addArrangedSubview(gameStack)

            if !game.points.isEmpty {
                let pointsView = createPointsDetailView(game.points, gameNumber: game.number)
                stack.addArrangedSubview(pointsView)
            }
        }

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.small),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.small),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.small),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.small)
        ])

        return containerView
    }

    private func createPointsDetailView(_ points: [TennisPoint], gameNumber: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .quaternarySystemFill
        containerView.layer.cornerRadius = UIConstants.CornerRadius.small

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "Points in Game \(gameNumber)"
        titleLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        titleLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(titleLabel)

        for point in points.suffix(10) {
            let pointLabel = UILabel()
            var pointText = "Point \(point.number): \(point.score)"

            if point.isBreakPoint {
                pointText += " [BP]"
            }
            if point.isSetPoint {
                pointText += " [SP]"
            }
            if point.isMatchPoint {
                pointText += " [MP]"
            }

            pointLabel.text = pointText
            pointLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
            pointLabel.textColor = .secondaryLabel
            stack.addArrangedSubview(pointLabel)
        }

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.small),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.small)
        ])

        return containerView
    }

    private func createCurrentGameView(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .center

        let titleLabel = UILabel()
        titleLabel.text = "CURRENT GAME"
        titleLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
        titleLabel.textColor = .systemBlue
        stack.addArrangedSubview(titleLabel)

        let scoreLabel = UILabel()
        scoreLabel.text = match.gameResult
        scoreLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
        scoreLabel.textColor = .systemBlue
        stack.addArrangedSubview(scoreLabel)

        if let serve = match.serve {
            let serveLabel = UILabel()
            serveLabel.text = "Serving: \(serve)"
            serveLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
            serveLabel.textColor = .secondaryLabel
            stack.addArrangedSubview(serveLabel)
        }

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.medium),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.medium)
        ])

        return containerView
    }

    private func makeMatchStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.medium
        stack.alignment = .fill
        return stack
    }

    private func makeMatchTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Match Information"
        titleLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
        return titleLabel
    }

    private func makeMatchKeyLabel(for match: Match) -> UILabel {
        let matchKeyLabel = UILabel()
        matchKeyLabel.text = "Match ID: \(match.key)"
        matchKeyLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        matchKeyLabel.textColor = .secondaryLabel
        return matchKeyLabel
    }

    private func makeMatchStatusStack() -> UIStackView {
        let statusStack = UIStackView()
        statusStack.axis = .horizontal
        statusStack.spacing = UIConstants.Spacing.small
        statusStack.alignment = .center
        return statusStack
    }

    private func makeMatchStatusLabel(for match: Match) -> UILabel {
        let statusLabel = UILabel()
        statusLabel.text = "Status: \(match.status)"
        statusLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
        return statusLabel
    }

    private func createMatchDetailsView(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let stack = makeMatchStackView()

        let titleLabel = makeMatchTitleLabel()
        stack.addArrangedSubview(titleLabel)

        let matchKeyLabel = makeMatchKeyLabel(for: match)
        stack.addArrangedSubview(matchKeyLabel)

        let statusStack = makeMatchStatusStack()

        let statusLabel = makeMatchStatusLabel(for: match)
        statusStack.addArrangedSubview(statusLabel)

        if match.isLive {
            let liveIndicator = UIView()
            liveIndicator.backgroundColor = .systemRed
            liveIndicator.layer.cornerRadius = 4
            liveIndicator.translatesAutoresizingMaskIntoConstraints = false

            let liveLabel = UILabel()
            liveLabel.text = "LIVE"
            liveLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.small)
            liveLabel.textColor = .white
            liveLabel.textAlignment = .center

            liveIndicator.addSubview(liveLabel)
            NSLayoutConstraint.activate([
                liveIndicator.widthAnchor.constraint(equalToConstant: 50),
                liveIndicator.heightAnchor.constraint(equalToConstant: 20),
                liveLabel.centerXAnchor.constraint(equalTo: liveIndicator.centerXAnchor),
                liveLabel.centerYAnchor.constraint(equalTo: liveIndicator.centerYAnchor)
            ])

            statusStack.addArrangedSubview(liveIndicator)
        }

        stack.addArrangedSubview(statusStack)

        let eventTypeLabel = UILabel()
        eventTypeLabel.text = "Event Type: \(match.eventType)"
        eventTypeLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
        eventTypeLabel.numberOfLines = 0
        stack.addArrangedSubview(eventTypeLabel)

        let seasonLabel = UILabel()
        seasonLabel.text = "Season: \(match.season)"
        seasonLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
        stack.addArrangedSubview(seasonLabel)

        if match.isQualification {
            let qualificationLabel = UILabel()
            qualificationLabel.text = "Qualification Match"
            qualificationLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            qualificationLabel.textColor = .systemOrange
            stack.addArrangedSubview(qualificationLabel)
        }

        if match.isLive, let serve = match.serve, !serve.isEmpty {
            let serveLabel = UILabel()
            serveLabel.text = "Serving: \(serve)"
            serveLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            serveLabel.textColor = .systemBlue
            stack.addArrangedSubview(serveLabel)
        }

        if let winner = match.winner, !winner.isEmpty {
            let winnerStack = UIStackView()
            winnerStack.axis = .horizontal
            winnerStack.spacing = UIConstants.Spacing.small
            winnerStack.alignment = .center

            let winnerIcon = UIImageView(image: UIImage(systemName: "trophy.fill"))
            winnerIcon.tintColor = .systemYellow
            winnerIcon.contentMode = .scaleAspectFit

            let winnerLabel = UILabel()
            winnerLabel.text = "Winner: \(winner)"
            winnerLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.medium)
            winnerLabel.textColor = .systemGreen

            winnerStack.addArrangedSubview(winnerIcon)
            winnerStack.addArrangedSubview(winnerLabel)

            NSLayoutConstraint.activate([
                winnerIcon.widthAnchor.constraint(equalToConstant: 20),
                winnerIcon.heightAnchor.constraint(equalToConstant: 20)
            ])

            stack.addArrangedSubview(winnerStack)
        }

        if let finalResult = match.finalResult, !finalResult.isEmpty {
            let finalResultLabel = UILabel()
            finalResultLabel.text = "Final Result: \(finalResult)"
            finalResultLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.medium)
            finalResultLabel.textColor = .label
            stack.addArrangedSubview(finalResultLabel)
        }

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.medium),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.medium)
        ])

        return containerView
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: StringConstants.Alert.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: StringConstants.Alert.okButton, style: .default))
        present(alert, animated: true)
    }
}
