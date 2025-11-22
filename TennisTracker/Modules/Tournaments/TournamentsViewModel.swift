import Foundation
import Combine

@MainActor
final class TournamentsViewModel: BaseViewModel {
    @Published var fixtures: [Match] = []
    @Published var selectedDate: Date = Date()

    private let repository: TennisRepositoryProtocol

    init(
        repository: TennisRepositoryProtocol,
        imageCache: ImageCacheServiceProtocol
    ) {
        self.repository = repository
        super.init(imageCache: imageCache)
    }

    func loadFixtures(for date: Date) {
        isLoading = true
        errorMessage = nil

        let dateString = date.toString()

        Task {
            do {
                let fixtures = try await repository.getFixtures(
                    dateStart: dateString,
                    dateStop: dateString,
                    eventTypeKey: nil,
                    tournamentKey: nil,
                    tournamentSeason: nil,
                    matchKey: nil,
                    playerKey: nil,
                    timezone: "Europe/Berlin"
                )
                self.fixtures = fixtures
                self.selectedDate = date
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.handleError(error)
            }
        }
    }

    func didSelectMatch(matchKey: String) {
        onNavigation?(.showMatchDetails(matchKey: matchKey))
    }

    func didSelectPlayer(player: Player) {
        onNavigation?(.showPlayerDetails(player: player))
    }
}
