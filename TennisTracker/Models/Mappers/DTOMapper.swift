import Foundation

enum DTOMapper {
    static func map(_ dto: EventTypeDTO) -> EventType {
        EventType(
            key: dto.eventTypeKey,
            type: dto.eventTypeType
        )
    }

    static func map(_ dto: FixtureDTO) -> Match {
        let scores = dto.scores?.compactMap { map($0) } ?? []
        let sets = mapPointByPointToSets(dto.pointByPoint, scores: scores)

        return Match(
            key: dto.eventKey,
            date: dto.eventDate,
            time: dto.eventTime,
            firstPlayer: PlayerInfo(
                key: dto.firstPlayerKey,
                name: dto.eventFirstPlayer,
                logoURL: dto.eventFirstPlayerLogo
            ),
            secondPlayer: PlayerInfo(
                key: dto.secondPlayerKey,
                name: dto.eventSecondPlayer,
                logoURL: dto.eventSecondPlayerLogo
            ),
            finalResult: dto.eventFinalResult,
            gameResult: dto.eventGameResult,
            serve: dto.eventServe,
            winner: dto.eventWinner,
            status: dto.eventStatus,
            eventType: dto.eventTypeType,
            tournament: TournamentInfo(
                key: dto.tournamentKey,
                name: dto.tournamentName
            ),
            round: dto.tournamentRound,
            season: dto.tournamentSeason,
            isLive: dto.eventLive == "1" || !dto.eventLive.isEmpty,
            isQualification: (dto.eventQualification?.lowercased() ?? "false") == "true",
            scores: scores,
            sets: sets
        )
    }

    static func map(_ dto: LiveMatchDTO) -> Match {
        let scores = dto.scores?.compactMap { map($0) } ?? []
        let sets = mapPointByPointToSets(dto.pointByPoint, scores: scores)

        return Match(
            key: dto.eventKey,
            date: dto.eventDate,
            time: dto.eventTime,
            firstPlayer: PlayerInfo(
                key: dto.firstPlayerKey,
                name: dto.eventFirstPlayer ?? "",
                logoURL: dto.eventFirstPlayerLogo
            ),
            secondPlayer: PlayerInfo(
                key: dto.secondPlayerKey,
                name: dto.eventSecondPlayer ?? "",
                logoURL: dto.eventSecondPlayerLogo
            ),
            finalResult: nil,
            gameResult: dto.eventGameResult,
            serve: dto.eventServe,
            winner: dto.eventWinner,
            status: dto.eventStatus,
            eventType: dto.eventTypeType,
            tournament: TournamentInfo(
                key: dto.tournamentKey,
                name: dto.tournamentName
            ),
            round: dto.tournamentRound,
            season: dto.tournamentSeason,
            isLive: true,
            isQualification: (dto.eventQualification?.lowercased() ?? "false") == "true",
            scores: scores,
            sets: sets
        )
    }

    static func map(_ dto: PlayerDTO) -> Player {
        let stats = dto.stats?.map { map($0) }
        return Player(
            key: dto.playerKey,
            name: dto.playerName,
            fullName: dto.playerFullName,
            country: dto.playerCountry,
            countryCode: dto.playerCountryCode,
            birthday: dto.playerBday,
            logoURL: dto.playerLogo,
            stats: stats
        )
    }

    static func map(_ dto: PlayerStatDTO) -> PlayerStat {
        PlayerStat(
            season: dto.season,
            type: dto.type,
            rank: dto.rank,
            titles: dto.titles,
            matchesWon: dto.matchesWon,
            matchesLost: dto.matchesLost,
            hardWon: dto.hardWon,
            hardLost: dto.hardLost,
            clayWon: dto.clayWon,
            clayLost: dto.clayLost,
            grassWon: dto.grassWon,
            grassLost: dto.grassLost
        )
    }

    static func map(_ dto: StandingDTO) -> PlayerRanking? {

        guard let playerKey = dto.playerKey, !playerKey.isEmpty else {
            return nil
        }

        let player = Player(
            key: playerKey,
            name: dto.playerName,
            fullName: nil,
            country: dto.playerCountry,
            countryCode: dto.playerCountryCode,
            birthday: nil,
            logoURL: dto.playerLogo,
            stats: nil
        )

        return PlayerRanking(
            player: player,
            rank: dto.rank.flatMap { Int($0) },
            points: dto.points.flatMap { Int($0) },
            tournamentsPlayed: dto.tournamentPlayed.flatMap { Int($0) }
        )
    }

    static func map(_ dto: ScoreDTO) -> Score? {
        guard let first = dto.scoreFirst,
              let second = dto.scoreSecond,
              let set = dto.scoreSet else {
            return nil
        }
        return Score(
            firstPlayerScore: first,
            secondPlayerScore: second,
            setNumber: set
        )
    }

    static func map(_ dto: PointByPointDTO) -> TennisSet? {
        guard let setNumber = dto.setNumber else { return nil }

        var games: [Game] = []

        if let gameNumber = dto.numberGame {
            let gamePoints = dto.points?.map { map($0) } ?? []
            let gameScore = parsePointScore(dto.score)

            let game = Game(
                number: gameNumber,
                firstPlayerPoints: gameScore.first,
                secondPlayerPoints: gameScore.second,
                server: dto.playerServed,
                points: gamePoints,
                isCompleted: dto.serveWinner != nil || dto.serveLost != nil
            )
            games.append(game)
        }

        let firstPlayerGames = 0
        let secondPlayerGames = 0

        return TennisSet(
            number: setNumber,
            firstPlayerGames: firstPlayerGames,
            secondPlayerGames: secondPlayerGames,
            games: games,
            isCompleted: dto.score != nil && !(dto.score?.isEmpty ?? true)
        )
    }

    static func mapPointByPointToSets(_ pointByPoint: [PointByPointDTO]?, scores: [Score]) -> [TennisSet] {
        guard let pointByPoint = pointByPoint, !pointByPoint.isEmpty else {

            return scores.map { score in
                TennisSet(
                    number: score.setNumber,
                    firstPlayerGames: Int(score.firstPlayerScore) ?? 0,
                    secondPlayerGames: Int(score.secondPlayerScore) ?? 0,
                    games: [],
                    isCompleted: true
                )
            }
        }

        var setsDict: [String: [PointByPointDTO]] = [:]
        for pointData in pointByPoint {
            guard let setNumber = pointData.setNumber else { continue }

            if setsDict[setNumber] == nil {
                setsDict[setNumber] = []
            }
            setsDict[setNumber]?.append(pointData)
        }

        var sets: [TennisSet] = []
        for (setNumber, pointByPointArray) in setsDict.sorted(by: { $0.key < $1.key }) {

            let setScore = scores.first(where: { $0.setNumber == setNumber })
            let firstPlayerGames = setScore.flatMap { Int($0.firstPlayerScore) } ?? 0
            let secondPlayerGames = setScore.flatMap { Int($0.secondPlayerScore) } ?? 0

            var gamesDict: [String: [PointByPointDTO]] = [:]
            for pointData in pointByPointArray {
                guard let gameNumber = pointData.numberGame else { continue }

                if gamesDict[gameNumber] == nil {
                    gamesDict[gameNumber] = []
                }
                gamesDict[gameNumber]?.append(pointData)
            }

            var games: [Game] = []
            for (gameNumber, gamePointDataArray) in gamesDict.sorted(by: { Int($0.key) ?? 0 < Int($1.key) ?? 0 }) {

                if let latestPointData = gamePointDataArray.last {
                    let gamePoints = latestPointData.points?.map { map($0) } ?? []
                    let gameScore = parsePointScore(latestPointData.score)

                    let game = Game(
                        number: gameNumber,
                        firstPlayerPoints: gameScore.first,
                        secondPlayerPoints: gameScore.second,
                        server: latestPointData.playerServed,
                        points: gamePoints,
                        isCompleted: latestPointData.serveWinner != nil || latestPointData.serveLost != nil
                    )
                    games.append(game)
                }
            }

            let tennisSet = TennisSet(
                number: setNumber,
                firstPlayerGames: firstPlayerGames,
                secondPlayerGames: secondPlayerGames,
                games: games,
                isCompleted: setScore != nil
            )
            sets.append(tennisSet)
        }

        return sets
    }

    private static func parsePointScore(_ score: String?) -> (first: String, second: String) {
        guard let score = score else { return ("0", "0") }

        let components = score.components(separatedBy: "-")
        guard components.count == 2 else {
            return ("0", "0")
        }
        return (
            components[0].trimmingCharacters(in: .whitespaces),
            components[1].trimmingCharacters(in: .whitespaces)
        )
    }

    private static func parseGameScore(_ score: String?) -> (first: Int, second: Int) {
        guard let score = score else { return (0, 0) }

        let components = score.components(separatedBy: "-")
        guard components.count == 2,
              let first = Int(components[0].trimmingCharacters(in: .whitespaces)),
              let second = Int(components[1].trimmingCharacters(in: .whitespaces)) else {
            return (0, 0)
        }
        return (first, second)
    }

    static func map(_ dto: PointDTO) -> TennisPoint {
        TennisPoint(
            number: dto.numberPoint ?? "",
            score: dto.score ?? "",
            isBreakPoint: dto.breakPoint != nil && dto.breakPoint?.lowercased() != "null",
            isSetPoint: dto.setPoint != nil && dto.setPoint?.lowercased() != "null",
            isMatchPoint: dto.matchPoint != nil && dto.matchPoint?.lowercased() != "null"
        )
    }
}
