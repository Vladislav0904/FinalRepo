import Foundation

protocol FavoritesServiceProtocol {
    func addFavoriteMatch(_ matchKey: String)
    func removeFavoriteMatch(_ matchKey: String)
    func isFavoriteMatch(_ matchKey: String) -> Bool
    func getFavoriteMatches() -> [String]

    func addFavoritePlayer(_ playerKey: String)
    func removeFavoritePlayer(_ playerKey: String)
    func isFavoritePlayer(_ playerKey: String) -> Bool
    func getFavoritePlayers() -> [String]
}
