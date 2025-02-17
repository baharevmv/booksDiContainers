//
//  BookListVIewModel.swift
//  booksBase
//
//  Created by Максим Бахарев on 14.02.2025.
//

import Foundation
import SwiftData

@MainActor
final class BookListViewModel: ObservableObject {
    // Входные данные
    @Published var searchText = ""
    @Published var isAddingBook = false
    @Published var newBookTitle = ""
    @Published var newBookAuthor = ""
    @Published var newBookDescription = ""
    
    @Published var isLoading = false  // Индикатор загрузки
    @Published var errorMessage: String?  // Сообщение об ошибке
    @Published var books: [Book] = []
    
    // Зависимости
    private let dataService: DataServiceProtocol
    private let coordinator: Coordinator
    
    init(
        dataService: DataServiceProtocol,
        coordinator: Coordinator
    ) {
        self.dataService = dataService
        self.coordinator = coordinator
        Task {
            await fetchBooks()
        }
    }
    
    func makeEditBookViewModel(for book: Book) -> EditBookViewModel {
        EditBookViewModel(dataService: dataService, book: book)
    }
    
    // Навигация
    func navigateToEditBook(_ book: Book) {
        coordinator.navigate(to: .editBook(book))
    }
    
    func fetchBooks() async {
        books = await dataService.fetchBooks(searchText: searchText)
    }
    
    // Добавление книги
    func addBook() async {
        isLoading = true  // Показываем индикатор загрузки
        defer { isLoading = false }  // Скрываем индикатор после завершения
        
        let title = newBookTitle.trimmed()
        let author = newBookAuthor.trimmed()
        let description = newBookDescription.trimmed()
        
        guard title.count >= 3, author.count >= 3 else {
            errorMessage = "Название и автор должны содержать не менее 3 символов."
            return
        }
        
        let newBook = Book(title: title, author: author, aboutDescription: description)
        await dataService.addBook(newBook)
        await fetchBooks()
        
        // Сброс полей
        newBookTitle = ""
        newBookAuthor = ""
        newBookDescription = ""
    }
    
    // Удаление книги
    func deleteBook(at offsets: IndexSet) async {
        guard let index = offsets.first else { return }
        let book = books[index]
        // Асинхронная операция удаления
        await dataService.deleteBook(book)
        books.remove(at: index)
    }
}

// MARK: - Расширение для обрезки пробелов
extension String {
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
