//
//  DIContainer.swift
//  booksBase
//
//  Created by Максим Бахарев on 17.02.2025.
//

import Foundation
import SwiftData

// MARK: - DI Container
struct DIContainer {
    let modelContext: ModelContext
    let dataService: DataServiceProtocol
    let coordinator: AppCoordinator // Используем переданный координатор
    
    init(modelContext: ModelContext, coordinator: AppCoordinator) {
        self.modelContext = modelContext
        self.dataService = DataService(modelContext: modelContext)
        self.coordinator = coordinator
    }
    
    @MainActor func makeBookListViewModel() -> BookListViewModel {
        BookListViewModel(
            dataService: dataService,
            coordinator: coordinator
        )
    }
}
