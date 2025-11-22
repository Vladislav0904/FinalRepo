import Foundation
import Combine

@MainActor
final class PlayerDetailsViewModel: BaseViewModel {
    @Published var player: Player
    @Published var recentMatches: [Match] = []

    private let repository: TennisRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol

    init(
        repository: TennisRepositoryProtocol,
        favoritesService: FavoritesServiceProtocol,
        player: Player,
        imageCache: ImageCacheServiceProtocol
    ) {
        self.repository = repository
        self.favoritesService = favoritesService
        self.player = player
        super.init(imageCache: imageCache)
    }

    func loadPlayerDetails() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let players = try await repository.getPlayers(playerKey: player.key)
                if let fullPlayer = players.first {
                    self.player = fullPlayer
                }

                let today = Date()
                let calendar = Calendar.current
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
                let thirtyDaysAhead = calendar.date(byAdding: .day, value: 30, to: today) ?? today

                async let fixtures = repository.getFixtures(
                    dateStart: thirtyDaysAgo.toString(),
                    dateStop: thirtyDaysAhead.toString(),
                    eventTypeKey: nil,
                    tournamentKey: nil,
                    tournamentSeason: nil,
                    matchKey: nil,
                    playerKey: player.key,
                    timezone: nil
                )

                async let livescore = repository.getLivescore(
                    eventTypeKey: nil,
                    tournamentKey: nil,
                    matchKey: nil,
                    playerKey: player.key,
                    timezone: nil
                )

                let fixturesData = try await fixtures
                let livescoreData = try await livescore

                let allMatches = fixturesData + livescoreData
                var seenKeys = Set<String>()
                var uniqueMatches: [Match] = []
                for match in allMatches where !seenKeys.contains(match.key) {
                    seenKeys.insert(match.key)
                    uniqueMatches.append(match)
                }
                uniqueMatches.sort { $0.date > $1.date }

                self.recentMatches = Array(uniqueMatches.prefix(20))

                self.isLoading = false
            } catch {
                self.isLoading = false
                self.handleError(error)
            }
        }
    }

    func isFavorite() -> Bool {
        favoritesService.isFavoritePlayer(player.key)
    }

    func toggleFavorite() {
        if isFavorite() {
            favoritesService.removeFavoritePlayer(player.key)
        } else {
            favoritesService.addFavoritePlayer(player.key)
        }
    }

    func didSelectPlayer(player: Player) {
        onNavigation?(.showPlayerDetails(player: player))
    }

    func didSelectMatch(matchKey: String) {
        onNavigation?(.showMatchDetails(matchKey: matchKey))
    }
}
