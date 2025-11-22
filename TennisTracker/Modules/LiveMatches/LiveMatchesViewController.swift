import UIKit
import Combine

final class LiveMatchesViewController: UIViewController {
    private let viewModel: LiveMatchesViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: StringConstants.CellIdentifiers.matchCell)
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

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: LiveMatchesViewModel) {
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
        viewModel.loadLiveMatches()
    }

    private func setupUI() {
        title = StringConstants.Titles.liveMatches
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

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
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.$filteredMatches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
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

    @objc private func refreshData() {
        viewModel.loadLiveMatches()
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

    private func loadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return nil
        }

        return await viewModel.imageCache.getImage(from: url)
    }
}

extension LiveMatchesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredMatches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StringConstants.CellIdentifiers.matchCell,
                for: indexPath
            ) as? MatchTableViewCell
        else {
            return UITableViewCell()
        }

        let match = viewModel.filteredMatches[indexPath.row]

        Task { [weak cell, weak self] in
            guard let cell = cell, let self = self else { return }

            async let player1Image = self.loadImage(from: match.firstPlayer.logoURL)
            async let player2Image = self.loadImage(from: match.secondPlayer.logoURL)

            let (loadedPlayer1Image, loadedPlayer2Image) = await (player1Image, player2Image)

            await MainActor.run {
                cell.configure(
                    with: match,
                    isFavorite: self.viewModel.isFavorite(matchKey: match.key),
                    player1Image: loadedPlayer1Image,
                    player2Image: loadedPlayer2Image
                )
            }
        }

        cell.configure(with: match, isFavorite: viewModel.isFavorite(matchKey: match.key))
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row < viewModel.filteredMatches.count else { return }

        let match = viewModel.filteredMatches[indexPath.row]
        viewModel.didSelectMatch(matchKey: match.key)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let match = viewModel.filteredMatches[indexPath.row]
        let favoriteAction = UIContextualAction(
            style: .normal,
            title: viewModel.isFavorite(matchKey: match.key) ? StringConstants.Buttons.remove : StringConstants.Buttons.add
        ) { [weak self] _, _, completion in
            self?.viewModel.toggleFavorite(matchKey: match.key)
            tableView.reloadRows(at: [indexPath], with: .none)
            completion(true)
        }
        favoriteAction.backgroundColor = ColorConstants.swipeActionBackground
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
}

extension LiveMatchesViewController: MatchTableViewCellDelegate {
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
}
