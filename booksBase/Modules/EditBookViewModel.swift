//
//  EditBookViewModel.swift
//  booksBase
//
//  Created by Максим Бахарев on 17.02.2025.
//

import SwiftUI
import SwiftData

@MainActor
final class EditBookViewModel: ObservableObject {
    private let dataService: DataServiceProtocol
    var book: Book
    
    init(dataService: DataServiceProtocol, book: Book) {
        self.dataService = dataService
        self.book = book
    }
    
    func saveChanges() async throws {
        try await dataService.updateBook(book)
    }
}
