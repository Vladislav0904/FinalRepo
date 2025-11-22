import Foundation
import Combine

@MainActor
final class RankingsViewModel: BaseViewModel {
    @Published var rankings: [PlayerRanking] = []
    @Published var filteredRankings: [PlayerRanking] = []
    @Published var selectedRankingType: RankingType = .atp
    @Published var searchText: String = ""

    private let repository: TennisRepositoryProtocol
    private var searchCancellable: AnyCancellable?

    private var atpEventType: String? = "ATP" // Default ATP
    private var wtaEventType: String? = "WTA" // Default WTA

    init(
        repository: TennisRepositoryProtocol,
        imageCache: ImageCacheServiceProtocol
    ) {
        self.repository = repository
        super.init(imageCache: imageCache)

        setupSearch()
        loadEventTypes()
    }

    private func setupSearch() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterRankings(with: searchText)
            }
    }

    func loadRankings() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let eventType = selectedRankingType == .atp ? atpEventType : wtaEventType
                let loadedRankings = try await repository.getStandings(eventType: eventType)

                self.rankings = loadedRankings.sorted { rank1, rank2 in
                    let rank1Value = rank1.rank ?? Int.max
                    let rank2Value = rank2.rank ?? Int.max
                    return rank1Value < rank2Value
                }

                filterRankings(with: searchText)
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.handleError(error)
            }
        }
    }

    func selectRankingType(_ type: RankingType) {
        selectedRankingType = type
        loadRankings()
    }

    func filterRankings(with searchText: String) {
        guard !searchText.isEmpty else {
            filteredRankings = rankings
            return
        }

        let normalizedSearch = normalizeSearchText(searchText)
        filteredRankings = rankings.filter { ranking in
            let normalizedName = normalizeSearchText(ranking.player.name)
            let normalizedCountry = normalizeSearchText(ranking.player.country ?? "")

            return normalizedName.contains(normalizedSearch) ||
                   normalizedCountry.contains(normalizedSearch)
        }
    }

    private func normalizeSearchText(_ text: String) -> String {
        text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadEventTypes() {
        Task {
            do {
                let events = try await repository.getEvents()
                for event in events {
                    let eventTypeLower = event.type.lowercased()
                    if eventTypeLower.contains("atp") && !eventTypeLower.contains("wta") && !eventTypeLower.contains("doubles") {
                        if atpEventType == nil || atpEventType == "ATP" {
                            atpEventType = "ATP"
                        }
                    } else if eventTypeLower.contains("wta") && !eventTypeLower.contains("doubles") {
                        if wtaEventType == nil || wtaEventType == "WTA" {
                            wtaEventType = "WTA"
                        }
                    }
                }
                loadRankings()
            } catch {
                loadRankings()
            }
        }
    }

    func didSelectPlayer(player: Player) {
        onNavigation?(.showPlayerDetails(player: player))
    }
}
