import Foundation
import Combine

@MainActor
final class MatchDetailsViewModel: BaseViewModel {
    @Published var match: Match?

    private let repository: TennisRepositoryProtocol
    private let matchKey: String

    init(
        repository: TennisRepositoryProtocol,
        matchKey: String,
        imageCache: ImageCacheServiceProtocol
    ) {
        self.repository = repository
        self.matchKey = matchKey
        super.init(imageCache: imageCache)
    }

    func loadMatchDetails() {
        isLoading = true
        errorMessage = nil

        Task {
            var matchData: Match?

            do {
                let livescore = try await repository.getLivescore(
                    eventTypeKey: nil,
                    tournamentKey: nil,
                    matchKey: matchKey,
                    playerKey: nil,
                    timezone: nil
                )
                matchData = livescore.first
            } catch {
                // Continue to try fixtures if livescore fails
            }

            if matchData == nil {
                let today = Date()
                let calendar = Calendar.current
                let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: today) ?? today
                let ninetyDaysAhead = calendar.date(byAdding: .day, value: 90, to: today) ?? today

                do {
                    let fixtures = try await repository.getFixtures(
                        dateStart: ninetyDaysAgo.toString(),
                        dateStop: ninetyDaysAhead.toString(),
                        eventTypeKey: nil,
                        tournamentKey: nil,
                        tournamentSeason: nil,
                        matchKey: matchKey,
                        playerKey: nil,
                        timezone: nil
                    )
                    matchData = fixtures.first
                } catch {
                    // Continue to try wider date range if this fails
                }
            }

            if matchData == nil {
                let today = Date()
                let calendar = Calendar.current
                let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) ?? today
                let oneYearAhead = calendar.date(byAdding: .year, value: 1, to: today) ?? today

                do {
                    let fixtures = try await repository.getFixtures(
                        dateStart: oneYearAgo.toString(),
                        dateStop: oneYearAhead.toString(),
                        eventTypeKey: nil,
                        tournamentKey: nil,
                        tournamentSeason: nil,
                        matchKey: matchKey,
                        playerKey: nil,
                        timezone: nil
                    )
                    matchData = fixtures.first
                } catch {
                    // All attempts failed
                }
            }

            guard let match = matchData else {
                self.errorMessage = "Match not found"
                self.isLoading = false
                return
            }

            self.match = match
            self.isLoading = false
        }
    }

    func didSelectPlayer(player: Player) {
        onNavigation?(.showPlayerDetails(player: player))
    }
}
