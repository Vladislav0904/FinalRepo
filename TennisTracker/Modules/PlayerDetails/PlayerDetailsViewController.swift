import UIKit
import Combine

final class PlayerDetailsViewController: UIViewController {
    private let viewModel: PlayerDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

    init(viewModel: PlayerDetailsViewModel) {
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

        updatePlayerInfo(viewModel.player)

        viewModel.loadPlayerDetails()
    }

    private func setupUI() {
        title = "Player Details"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: viewModel.isFavorite() ? ImageConstants.SystemIcons.starFill : "star"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )

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

        viewModel.$player
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                self?.updatePlayerInfo(player)
            }
            .store(in: &cancellables)

        viewModel.$recentMatches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.updateRecentMatches(matches)
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

    private func updatePlayerInfo(_ player: Player) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let playerInfoView = createPlayerInfoView(player)
        stackView.addArrangedSubview(playerInfoView)

        if let stats = player.stats, !stats.isEmpty {
            let statsView = createStatsView(stats)
            stackView.addArrangedSubview(statsView)
        }
    }

    private func updateRecentMatches(_ matches: [Match]) {
        if !matches.isEmpty {
            let matchesView = createMatchesView(matches)
            stackView.addArrangedSubview(matchesView)
        }
    }

    private func createPlayerInfoView(_ player: Player) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.large
        stack.alignment = .center

        let playerImageView = UIImageView()
        playerImageView.translatesAutoresizingMaskIntoConstraints = false
        playerImageView.contentMode = .scaleAspectFit
        playerImageView.layer.cornerRadius = UIConstants.CornerRadius.medium
        playerImageView.clipsToBounds = true
        playerImageView.backgroundColor = .tertiarySystemBackground

        if let logoURL = player.logoURL, !logoURL.isEmpty, let url = URL(string: logoURL) {
            Task { [weak self, weak playerImageView] in
                guard let self = self, let playerImageView = playerImageView else {
                    return
                }
                if let image = await self.viewModel.imageCache.getImage(from: url) {
                    await MainActor.run {
                        playerImageView.image = image
                        playerImageView.tintColor = nil
                    }
                } else {
                    await MainActor.run {
                        playerImageView.image = UIImage(systemName: ImageConstants.SystemIcons.person2Fill)
                        playerImageView.tintColor = .secondaryLabel
                    }
                }
            }
        } else {
            playerImageView.image = UIImage(systemName: ImageConstants.SystemIcons.person2Fill)
            playerImageView.tintColor = .secondaryLabel
        }

        stack.addArrangedSubview(playerImageView)

        let nameLabel = UILabel()
        let displayName = player.fullName ?? player.name
        nameLabel.text = displayName.isEmpty ? "Unknown Player" : displayName
        nameLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.extraLarge)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label
        stack.addArrangedSubview(nameLabel)

        let keyLabel = UILabel()
        keyLabel.text = "ID: \(player.key)"
        keyLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        keyLabel.textColor = .tertiaryLabel
        keyLabel.textAlignment = .center
        stack.addArrangedSubview(keyLabel)

        let countryLabel = UILabel()
        countryLabel.text = player.country ?? "Country: N/A"
        countryLabel.font = .systemFont(ofSize: UIConstants.FontSize.large)
        countryLabel.textColor = player.country != nil ? .secondaryLabel : .tertiaryLabel
        countryLabel.textAlignment = .center
        stack.addArrangedSubview(countryLabel)

        if let countryCode = player.countryCode, !countryCode.isEmpty {
            let countryCodeLabel = UILabel()
            countryCodeLabel.text = countryCode
            countryCodeLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
            countryCodeLabel.textColor = .tertiaryLabel
            countryCodeLabel.textAlignment = .center
            stack.addArrangedSubview(countryCodeLabel)
        }

        let birthdayLabel = UILabel()
        if let birthday = player.birthday {
            birthdayLabel.text = "Born: \(birthday)"
        } else {
            birthdayLabel.text = "Birthday: N/A"
        }
        birthdayLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium)
        birthdayLabel.textColor = player.birthday != nil ? .secondaryLabel : .tertiaryLabel
        birthdayLabel.textAlignment = .center
        stack.addArrangedSubview(birthdayLabel)

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            playerImageView.widthAnchor.constraint(equalToConstant: 250),
            playerImageView.heightAnchor.constraint(equalToConstant: 250),

            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.large),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.medium)
        ])

        return containerView
    }

    private func createStatsView(_ stats: [PlayerStat]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.medium
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "Statistics"
        titleLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
        titleLabel.textColor = .label
        stack.addArrangedSubview(titleLabel)

        let groupedStats = Dictionary(grouping: stats) { $0.type ?? "Unknown" }

        for (type, typeStats) in groupedStats.sorted(by: { $0.key < $1.key }) {
            let typeLabel = UILabel()
            typeLabel.text = type.capitalized
            typeLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.medium)
            typeLabel.textColor = .label
            stack.addArrangedSubview(typeLabel)

            let sortedStats = typeStats.sorted { stat1, stat2 -> Bool in
                let season1 = stat1.season ?? ""
                let season2 = stat2.season ?? ""
                return season1 > season2
            }

            for stat in sortedStats {
                let statView = createStatRowView(stat)
                stack.addArrangedSubview(statView)
            }
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

    private func createStatRowView(_ stat: PlayerStat) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.small

        let mainStack = UIStackView()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = UIConstants.Spacing.small
        mainStack.alignment = .fill

        if let season = stat.season {
            let seasonLabel = UILabel()
            seasonLabel.text = "Season \(season)"
            seasonLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.medium)
            seasonLabel.textColor = .label
            mainStack.addArrangedSubview(seasonLabel)
        }

        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.spacing = UIConstants.Spacing.small

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = UIConstants.Spacing.small

        if let rank = stat.rank, !rank.isEmpty {
            topRow.addArrangedSubview(createStatItem(title: "Rank", value: rank))
        }
        if let titles = stat.titles, !titles.isEmpty {
            topRow.addArrangedSubview(createStatItem(title: "Titles", value: titles))
        }

        if !topRow.arrangedSubviews.isEmpty {
            statsStack.addArrangedSubview(topRow)
        }

        if let won = stat.matchesWon, let lost = stat.matchesLost, !won.isEmpty || !lost.isEmpty {
            let matchesText = "\(won.isEmpty ? "0" : won) - \(lost.isEmpty ? "0" : lost)"
            statsStack.addArrangedSubview(createStatItem(title: "Matches (W-L)", value: matchesText))
        }

        let surfaceStack = UIStackView()
        surfaceStack.axis = .horizontal
        surfaceStack.distribution = .fillEqually
        surfaceStack.spacing = UIConstants.Spacing.small

        var hasSurfaceStats = false

        if let hardWon = stat.hardWon, let hardLost = stat.hardLost, !hardWon.isEmpty || !hardLost.isEmpty {
            let hardText = "\(hardWon.isEmpty ? "0" : hardWon)-\(hardLost.isEmpty ? "0" : hardLost)"
            surfaceStack.addArrangedSubview(createStatItem(title: "Hard", value: hardText))
            hasSurfaceStats = true
        }

        if let clayWon = stat.clayWon, let clayLost = stat.clayLost, !clayWon.isEmpty || !clayLost.isEmpty {
            let clayText = "\(clayWon.isEmpty ? "0" : clayWon)-\(clayLost.isEmpty ? "0" : clayLost)"
            surfaceStack.addArrangedSubview(createStatItem(title: "Clay", value: clayText))
            hasSurfaceStats = true
        }

        if let grassWon = stat.grassWon, let grassLost = stat.grassLost, !grassWon.isEmpty || !grassLost.isEmpty {
            let grassText = "\(grassWon.isEmpty ? "0" : grassWon)-\(grassLost.isEmpty ? "0" : grassLost)"
            surfaceStack.addArrangedSubview(createStatItem(title: "Grass", value: grassText))
            hasSurfaceStats = true
        }

        if hasSurfaceStats {
            statsStack.addArrangedSubview(surfaceStack)
        }

        mainStack.addArrangedSubview(statsStack)

        containerView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.Spacing.small),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.Spacing.small),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.Spacing.small),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.Spacing.small)
        ])

        return containerView
    }

    private func createStatItem(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.medium)
        valueLabel.textColor = .label

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createMatchesView(_ matches: [Match]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = UIConstants.CornerRadius.medium

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.medium
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "Recent Matches"
        titleLabel.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
        stack.addArrangedSubview(titleLabel)

        for match in matches.prefix(10) {
            let matchView = createMatchRowView(match)
            stack.addArrangedSubview(matchView)
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

    private func createMatchRowView(_ match: Match) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = UIConstants.Spacing.small
        stack.alignment = .center

        let player1Label = UILabel()
        player1Label.text = match.firstPlayer.name
        player1Label.font = .systemFont(ofSize: UIConstants.FontSize.small, weight: .medium)
        player1Label.textColor = .systemBlue
        player1Label.isUserInteractionEnabled = true
        let player1Tap = UITapGestureRecognizer(target: self, action: #selector(playerInMatchTapped(_:)))
        player1Label.addGestureRecognizer(player1Tap)
        player1Label.accessibilityIdentifier = match.firstPlayer.key
        stack.addArrangedSubview(player1Label)

        let versusLabel = UILabel()
        versusLabel.text = "vs"
        versusLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        versusLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(versusLabel)

        let player2Label = UILabel()
        player2Label.text = match.secondPlayer.name
        player2Label.font = .systemFont(ofSize: UIConstants.FontSize.small, weight: .medium)
        player2Label.textColor = .systemBlue
        player2Label.isUserInteractionEnabled = true
        let player2Tap = UITapGestureRecognizer(target: self, action: #selector(playerInMatchTapped(_:)))
        player2Label.addGestureRecognizer(player2Tap)
        player2Label.accessibilityIdentifier = match.secondPlayer.key
        stack.addArrangedSubview(player2Label)

        let infoLabel = UILabel()
        infoLabel.text = " - \(match.tournament.name) - \(match.date)"
        infoLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        infoLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(infoLabel)

        containerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        containerView.accessibilityIdentifier = match.key

        let matchTapGesture = UITapGestureRecognizer(target: self, action: #selector(matchTapped(_:)))
        containerView.addGestureRecognizer(matchTapGesture)
        containerView.isUserInteractionEnabled = true

        return containerView
    }

    @objc private func playerInMatchTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let playerKey = label.accessibilityIdentifier else {
            return
        }

        guard let matchView = label.superview?.superview,
              let matchKey = matchView.accessibilityIdentifier,
              let match = viewModel.recentMatches.first(where: { $0.key == matchKey }) else {
            return
        }

        let playerInfo: PlayerInfo
        if match.firstPlayer.key == playerKey {
            playerInfo = match.firstPlayer
        } else if match.secondPlayer.key == playerKey {
            playerInfo = match.secondPlayer
        } else {
            return
        }

        let player = Player(
            key: playerInfo.key,
            name: playerInfo.name,
            fullName: nil,
            country: nil,
            countryCode: nil,
            birthday: nil,
            logoURL: playerInfo.logoURL,
            stats: nil
        )

        viewModel.didSelectPlayer(player: player)
    }

    @objc private func matchTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let matchKey = view.accessibilityIdentifier else {
            return
        }

        viewModel.didSelectMatch(matchKey: matchKey)
    }

    @objc private func toggleFavorite() {
        viewModel.toggleFavorite()
        navigationItem.rightBarButtonItem?.image = UIImage(
            systemName: viewModel.isFavorite() ? ImageConstants.SystemIcons.starFill : "star"
        )
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
