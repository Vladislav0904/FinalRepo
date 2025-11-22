import UIKit
import Combine

final class RankingsViewController: UIViewController {
    private let viewModel: RankingsViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = .systemBackground
        tableView.separatorColor = .separator
        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search players"
        return controller
    }()

    private lazy var rankingTypeSegmentedControl: UISegmentedControl = {
        let items = RankingType.allCases.map { $0.displayName }
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(rankingTypeChanged), for: .valueChanged)
        return control
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: RankingsViewModel) {
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
        viewModel.loadRankings()
    }

    private func setupUI() {
        title = "Rankings"
        view.backgroundColor = .systemBackground

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(rankingTypeSegmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            rankingTypeSegmentedControl.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.Spacing.medium),
            rankingTypeSegmentedControl.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: UIConstants.Spacing.medium),
            rankingTypeSegmentedControl.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Spacing.medium),

            tableView.topAnchor
                .constraint(equalTo: rankingTypeSegmentedControl.bottomAnchor, constant: UIConstants.Spacing.medium),
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
                }
            }
            .store(in: &cancellables)

        viewModel.$filteredRankings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$selectedRankingType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                let index = RankingType.allCases.firstIndex(of: type) ?? 0
                self?.rankingTypeSegmentedControl.selectedSegmentIndex = index
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

    @objc private func rankingTypeChanged() {
        let selectedIndex = rankingTypeSegmentedControl.selectedSegmentIndex
        guard selectedIndex < RankingType.allCases.count else { return }

        let selectedType = RankingType.allCases[selectedIndex]
        viewModel.selectRankingType(selectedType)
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

extension RankingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredRankings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RankingTableViewCell.identifier, for: indexPath
            ) as? RankingTableViewCell
        else {
            return UITableViewCell()
        }

        guard indexPath.row < viewModel.filteredRankings.count else {
            return UITableViewCell()
        }

        let ranking = viewModel.filteredRankings[indexPath.row]
        cell.configure(with: ranking)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < viewModel.filteredRankings.count else { return }

        let ranking = viewModel.filteredRankings[indexPath.row]
        viewModel.didSelectPlayer(player: ranking.player)
    }
}

extension RankingsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}
