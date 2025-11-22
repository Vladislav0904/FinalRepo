import Foundation
import CoreData

@objc(FavoriteMatch)
public class FavoriteMatch: NSManagedObject {
}

extension FavoriteMatch {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMatch> {
        NSFetchRequest<FavoriteMatch>(entityName: "FavoriteMatch")
    }

    @NSManaged public var matchKey: String
    @NSManaged public var createdAt: Date
}
