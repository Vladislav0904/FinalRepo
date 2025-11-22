import Foundation
import Combine

@MainActor
final class FavouritesViewModel: BaseViewModel {
    @Published var favoriteMatches: [Match] = []
    @Published var favoritePlayers: [Player] = []
    @Published var selectedSegment: FavouritesSegment = .matches

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

    func loadFavorites() {
        switch selectedSegment {
        case .matches:
            loadFavoriteMatches()
        case .players:
            loadFavoritePlayers()
        }
    }

    func loadFavoriteMatches() {
        errorMessage = nil

        Task {
            let favoriteMatchKeys = favoritesService.getFavoriteMatches()

            guard !favoriteMatchKeys.isEmpty else {
                self.favoriteMatches = []
                return
            }

            var loadedMatches: [Match] = []

            for matchKey in favoriteMatchKeys {
                let calendar = Calendar.current
                let today = Date()
                let startDate = calendar.date(byAdding: .month, value: -3, to: today) ?? today
                let endDate = calendar.date(byAdding: .month, value: 3, to: today) ?? today

                let dateStart = startDate.toString()
                let dateStop = endDate.toString()

                do {
                    let fixtures = try await repository.getFixtures(
                        dateStart: dateStart,
                        dateStop: dateStop,
                        eventTypeKey: nil,
                        tournamentKey: nil,
                        tournamentSeason: nil,
                        matchKey: matchKey,
                        playerKey: nil,
                        timezone: nil
                    )

                    if let match = fixtures.first {
                        loadedMatches.append(match)
                        continue
                    }
                } catch {
                    // Continue to try livescore if fixtures fail
                }

                do {
                    let liveMatches = try await repository.getLivescore(
                        eventTypeKey: nil,
                        tournamentKey: nil,
                        matchKey: matchKey,
                        playerKey: nil,
                        timezone: nil
                    )
                    if let match = liveMatches.first {
                        loadedMatches.append(match)
                    }
                } catch {
                    // Skip this match if both requests fail
                }
            }

            loadedMatches.sort { match1, match2 in
                let date1 = "\(match1.date) \(match1.time)"
                let date2 = "\(match2.date) \(match2.time)"
                return date1 > date2
            }

            self.favoriteMatches = loadedMatches
        }
    }

    func loadFavoritePlayers() {
        errorMessage = nil

        Task {
            let favoritePlayerKeys = favoritesService.getFavoritePlayers()

            guard !favoritePlayerKeys.isEmpty else {
                self.favoritePlayers = []
                return
            }

            var loadedPlayers: [Player] = []

            let batchSize = 10
            for iteration in stride(from: 0, to: favoritePlayerKeys.count, by: batchSize) {
                let batch = Array(favoritePlayerKeys[iteration..<min(iteration + batchSize, favoritePlayerKeys.count)])

                for playerKey in batch {
                    do {
                        let players = try await repository.getPlayers(playerKey: playerKey)
                        if let player = players.first {
                            loadedPlayers.append(player)
                        }
                    } catch {
                        // Skip this player if request fails
                    }
                }
            }

            loadedPlayers.sort { $0.name < $1.name }

            self.favoritePlayers = loadedPlayers
        }
    }

    func removeFavoriteMatch(_ matchKey: String) {
        favoritesService.removeFavoriteMatch(matchKey)
        favoriteMatches.removeAll { $0.key == matchKey }
    }

    func removeFavoritePlayer(_ playerKey: String) {
        favoritesService.removeFavoritePlayer(playerKey)
        favoritePlayers.removeAll { $0.key == playerKey }
    }

    func isFavoriteMatch(_ matchKey: String) -> Bool {
        favoritesService.isFavoriteMatch(matchKey)
    }

    func isFavoritePlayer(_ playerKey: String) -> Bool {
        favoritesService.isFavoritePlayer(playerKey)
    }

    func didSelectMatch(matchKey: String) {
        onNavigation?(.showMatchDetails(matchKey: matchKey))
    }

    func didSelectPlayer(player: Player) {
        onNavigation?(.showPlayerDetails(player: player))
    }
}
