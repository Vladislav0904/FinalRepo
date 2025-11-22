import Foundation

final class DependencyContainer {
    static func configure() {
        let container = Container.current

        let networkService = NetworkService(apiKey: APIConstants.apiKey)
        container.register { () -> NetworkServiceProtocol in
            networkService
        }

        let tennisAPIService = TennisAPIService()
        container.register { () -> TennisAPIServiceProtocol in
            tennisAPIService
        }

        container.register { () -> TennisRepositoryProtocol in
            TennisRepository(apiService: tennisAPIService)
        }

        let storageService = UserDefaultsStorageService()
        container.register { () -> StorageServiceProtocol in
            storageService
        }

        let coreDataStack = CoreDataStack()
        container.register { () -> CoreDataStack in
            coreDataStack
        }

        let favoritesService = CoreDataFavoritesService(coreDataStack: coreDataStack)
        container.register { () -> FavoritesServiceProtocol in
            favoritesService
        }

        let imageCacheService = ImageCacheService()
        container.register { () -> ImageCacheServiceProtocol in
            imageCacheService
        }
    }
}
