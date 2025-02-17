//
//  booksBaseApp.swift
//  booksBase
//
//  Created by Maksim Bakharev on 12.02.2025.
//

import SwiftUI
import SwiftData

@main
struct BookBaseApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var coordinator = AppCoordinator()
    @State private var diContainer: DIContainer?

    var body: some Scene {
        WindowGroup {
            Group {
                if let diContainer = diContainer {
                    BookListView(
                        modelContext: diContainer.modelContext,
                        coordinator: coordinator
                    )
                    .environmentObject(coordinator)
                } else {
                    ProgressView()
                        .onAppear { setupDIContainer() }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background { saveData() }
        }
    }

    @MainActor
    private func setupDIContainer() {
        let modelContext = ModelContext(sharedModelContainer) // Теперь sharedModelContainer видна
        diContainer = DIContainer(modelContext: modelContext, coordinator: coordinator)
    }

    private func saveData() {
        let context = ModelContext(sharedModelContainer)
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }
}

var sharedModelContainer: ModelContainer = {
    let schema = Schema([Book.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}()
