//
//  DataService.swift
//  booksBase
//
//  Created by Максим Бахарев on 14.02.2025.
//

import SwiftData
import SwiftUI

protocol DataServiceProtocol {
    func addBook(_ book: Book) async
    func deleteBook(_ book: Book) async
    func fetchBooks(searchText: String) async -> [Book]
    func updateBook(_ book: Book) async throws
}

struct DataService: DataServiceProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addBook(_ book: Book) async {
        modelContext.insert(book)
        try? modelContext.save()
    }
    
    func deleteBook(_ book: Book) async {
        modelContext.delete(book)
        try? modelContext.save()
    }
    
    func fetchBooks(searchText: String) async -> [Book] {
        await MainActor.run {  // Переключаемся в главный поток
            let descriptor = FetchDescriptor<Book>(
                predicate: #Predicate { book in
                    searchText.isEmpty ||  // Если поиск пустой, возвращаем все книги
                    book.title.localizedStandardContains(searchText) ||  // Поиск по названию
                    book.author.localizedStandardContains(searchText)  // Поиск по автору
                }
//                sortBy: [SortDescriptor(\Book.title)]  // Сортировка по названию
            )
            
            do {
                return try modelContext.fetch(descriptor)  // Получаем книги
            } catch {
                print("Ошибка при получении книг: \(error)")
                return []
            }
        }
    }
    
    func updateBook(_ book: Book) async throws {
        try await MainActor.run {
            try modelContext.save()
        }
    }
}
