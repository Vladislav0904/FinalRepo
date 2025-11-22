import Foundation
import CoreData

final class CoreDataFavoritesService: FavoritesServiceProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func addFavoriteMatch(_ matchKey: String) {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoriteMatch> = FavoriteMatch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "matchKey == %@", matchKey)

        if let existing = try? context.fetch(fetchRequest), !existing.isEmpty {
            return // Already exists
        }

        let favorite = FavoriteMatch(context: context)
        favorite.matchKey = matchKey
        favorite.createdAt = Date()

        coreDataStack.saveContext()
    }

    func removeFavoriteMatch(_ matchKey: String) {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoriteMatch> = FavoriteMatch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "matchKey == %@", matchKey)

        if let favorites = try? context.fetch(fetchRequest) {
            favorites.forEach { context.delete($0) }
            coreDataStack.saveContext()
        }
    }

    func isFavoriteMatch(_ matchKey: String) -> Bool {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoriteMatch> = FavoriteMatch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "matchKey == %@", matchKey)
        fetchRequest.fetchLimit = 1

        return (try? context.count(for: fetchRequest)) ?? 0 > 0
    }

    func getFavoriteMatches() -> [String] {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoriteMatch> = FavoriteMatch.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        guard let favorites = try? context.fetch(fetchRequest) else {
            return []
        }

        return favorites.compactMap { $0.matchKey }
    }

    func addFavoritePlayer(_ playerKey: String) {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoritePlayer> = FavoritePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerKey == %@", playerKey)

        if let existing = try? context.fetch(fetchRequest), !existing.isEmpty {
            return // Already exists
        }

        let favorite = FavoritePlayer(context: context)
        favorite.playerKey = playerKey
        favorite.createdAt = Date()

        coreDataStack.saveContext()
    }

    func removeFavoritePlayer(_ playerKey: String) {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoritePlayer> = FavoritePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerKey == %@", playerKey)

        if let favorites = try? context.fetch(fetchRequest) {
            favorites.forEach { context.delete($0) }
            coreDataStack.saveContext()
        }
    }

    func isFavoritePlayer(_ playerKey: String) -> Bool {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoritePlayer> = FavoritePlayer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playerKey == %@", playerKey)
        fetchRequest.fetchLimit = 1

        return (try? context.count(for: fetchRequest)) ?? 0 > 0
    }

    func getFavoritePlayers() -> [String] {
        let context = coreDataStack.viewContext

        let fetchRequest: NSFetchRequest<FavoritePlayer> = FavoritePlayer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        guard let favorites = try? context.fetch(fetchRequest) else {
            return []
        }

        return favorites.compactMap { $0.playerKey }
    }
}
