import Foundation
import Combine

@MainActor
final class LiveMatchesViewModel: BaseViewModel {
    @Published var matches: [Match] = []
    @Published var filteredMatches: [Match] = []

    private let repository: TennisRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol

    init(
        repository: TennisRepositoryProtocol,
        favoritesService: FavoritesServiceProtocol,
        imageCache: ImageCacheServiceProtocol
    ) {
        self.repository = repository
        self.favoritesService = favoritesService
        super.init(imageCache: imageCache)
    }

    func loadLiveMatches() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let liveMatches = try await repository.getLivescore(
                    eventTypeKey: nil,
                    tournamentKey: nil,
                    matchKey: nil,
                    playerKey: nil,
                    timezone: nil
                )
                self.matches = liveMatches
                self.filteredMatches = liveMatches
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.handleError(error)
            }
        }
    }

    func isFavorite(matchKey: String) -> Bool {
        favoritesService.isFavoriteMatch(matchKey)
    }

    func toggleFavorite(matchKey: String) {
        if isFavorite(matchKey: matchKey) {
            favoritesService.removeFavoriteMatch(matchKey)
        } else {
            favoritesService.addFavoriteMatch(matchKey)
        }
    }

    func filterMatches(by eventType: String?) {
        if let eventType = eventType {
            filteredMatches = matches.filter { $0.eventType == eventType }
        } else {
            filteredMatches = matches
        }
    }

    func didSelectMatch(matchKey: String) {
        onNavigation?(.showMatchDetails(matchKey: matchKey))
    }

    func didSelectPlayer(player: Player) {
        onNavigation?(.showPlayerDetails(player: player))
    }
}
