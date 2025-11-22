import CoreData
import Foundation

final class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let model = createManagedObjectModel()

        let container = NSPersistentContainer(name: "TennisTracker", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let favoriteMatchEntity = NSEntityDescription()
        favoriteMatchEntity.name = "FavoriteMatch"
        favoriteMatchEntity.managedObjectClassName = NSStringFromClass(FavoriteMatch.self)

        let matchKeyAttribute = NSAttributeDescription()
        matchKeyAttribute.name = "matchKey"
        matchKeyAttribute.attributeType = .stringAttributeType
        matchKeyAttribute.isOptional = false

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        favoriteMatchEntity.properties = [matchKeyAttribute, createdAtAttribute]

        let favoritePlayerEntity = NSEntityDescription()
        favoritePlayerEntity.name = "FavoritePlayer"
        favoritePlayerEntity.managedObjectClassName = NSStringFromClass(FavoritePlayer.self)

        let playerKeyAttribute = NSAttributeDescription()
        playerKeyAttribute.name = "playerKey"
        playerKeyAttribute.attributeType = .stringAttributeType
        playerKeyAttribute.isOptional = false

        let playerCreatedAtAttribute = NSAttributeDescription()
        playerCreatedAtAttribute.name = "createdAt"
        playerCreatedAtAttribute.attributeType = .dateAttributeType
        playerCreatedAtAttribute.isOptional = false

        favoritePlayerEntity.properties = [playerKeyAttribute, playerCreatedAtAttribute]

        model.entities = [favoriteMatchEntity, favoritePlayerEntity]
        return model
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                assertionFailure("Unresolved Core Data error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await persistentContainer.performBackgroundTask { context in
            try block(context)
        }
    }
}
