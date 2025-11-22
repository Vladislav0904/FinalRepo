import Foundation
import CoreData

@objc(FavoritePlayer)
public class FavoritePlayer: NSManagedObject {
}

extension FavoritePlayer {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePlayer> {
        NSFetchRequest<FavoritePlayer>(entityName: "FavoritePlayer")
    }

    @NSManaged public var playerKey: String
    @NSManaged public var createdAt: Date
}
