import UIKit
import Combine

final class FavouritesViewController: UIViewController {
    private let viewModel: FavouritesViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Matches", "Players"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: StringConstants.CellIdentifiers.matchCell)
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.separatorColor = .separator
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: UIConstants.FontSize.large)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    init(viewModel: FavouritesViewModel) {
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

        viewModel.loadFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.loadFavorites()
    }

    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground

        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.Spacing.medium),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Spacing.medium),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Spacing.medium),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: UIConstants.Spacing.medium),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.$favoriteMatches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.viewModel.selectedSegment == .matches {
                    self?.updateEmptyState()
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)

        viewModel.$favoritePlayers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.viewModel.selectedSegment == .players {
                    self?.updateEmptyState()
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)

        viewModel.$selectedSegment
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateEmptyState()
                self?.tableView.reloadData()
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

    private func updateEmptyState() {
        let isEmpty: Bool
        switch viewModel.selectedSegment {
        case .matches:
            isEmpty = viewModel.favoriteMatches.isEmpty
        case .players:
            isEmpty = viewModel.favoritePlayers.isEmpty
        }
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    @objc private func segmentChanged() {
        guard let segment = FavouritesSegment(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        viewModel.selectedSegment = segment

        viewModel.loadFavorites()
    }

    @objc private func refreshData() {
        viewModel.loadFavorites()
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: StringConstants.Titles.error,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: StringConstants.Buttons.ok, style: .default))
        present(alert, animated: true)
    }
}

extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.selectedSegment {
        case .matches:
            return viewModel.favoriteMatches.count
        case .players:
            return viewModel.favoritePlayers.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.selectedSegment {
        case .matches:
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: StringConstants.CellIdentifiers.matchCell,
                    for: indexPath
                ) as? MatchTableViewCell
            else {
                return UITableViewCell()
            }

            guard indexPath.row < viewModel.favoriteMatches.count else {
                return UITableViewCell()
            }

            let match = viewModel.favoriteMatches[indexPath.row]

            Task { [weak cell, weak self] in
                guard let cell = cell, let self = self else { return }

                async let player1Image = self.loadImage(from: match.firstPlayer.logoURL)
                async let player2Image = self.loadImage(from: match.secondPlayer.logoURL)

                let (loadedPlayer1Image, loadedPlayer2Image) = await (player1Image, player2Image)

                await MainActor.run {
                    cell.configure(
                        with: match,
                        isFavorite: true,
                        showLiveIndicator: true,
                        player1Image: loadedPlayer1Image,
                        player2Image: loadedPlayer2Image
                    )
                }
            }

            cell.configure(with: match, isFavorite: true, showLiveIndicator: true)
            cell.delegate = self
            return cell

        case .players:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as? RankingTableViewCell else {
                return UITableViewCell()
            }
            guard indexPath.row < viewModel.favoritePlayers.count else {
                return UITableViewCell()
            }
            let player = viewModel.favoritePlayers[indexPath.row]
            let ranking = PlayerRanking(
                player: player,
                rank: nil,
                points: nil,
                tournamentsPlayed: nil
            )
            cell.configure(with: ranking)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch viewModel.selectedSegment {
        case .matches:
            guard indexPath.row < viewModel.favoriteMatches.count else { return }

            let match = viewModel.favoriteMatches[indexPath.row]
            viewModel.didSelectMatch(matchKey: match.key)

        case .players:
            guard indexPath.row < viewModel.favoritePlayers.count else { return }

            let player = viewModel.favoritePlayers[indexPath.row]
            viewModel.didSelectPlayer(player: player)
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            switch self.viewModel.selectedSegment {
            case .matches:
                guard indexPath.row < self.viewModel.favoriteMatches.count else {
                    completion(false)
                    return
                }
                let match = self.viewModel.favoriteMatches[indexPath.row]
                self.viewModel.removeFavoriteMatch(match.key)
                completion(true)

            case .players:
                guard indexPath.row < self.viewModel.favoritePlayers.count else {
                    completion(false)
                    return
                }
                let player = self.viewModel.favoritePlayers[indexPath.row]
                self.viewModel.removeFavoritePlayer(player.key)
                completion(true)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FavouritesViewController: MatchTableViewCellDelegate {
    func matchCell(_ cell: MatchTableViewCell, didTapPlayer playerInfo: PlayerInfo) {
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

    private func loadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return nil
        }

        return await viewModel.imageCache.getImage(from: url)
    }
}
