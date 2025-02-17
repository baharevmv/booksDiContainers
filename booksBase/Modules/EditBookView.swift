//
//  EditBookView.swift
//  booksBase
//
//  Created by Максим Бахарев on 17.02.2025.
//

import Foundation
import SwiftUI
import SwiftData

/// Экран редактирвания книги
struct EditBookView: View {
    @ObservedObject private var viewModel: EditBookViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    
    private let minLength = 3
    
    init(viewModel: EditBookViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Название", text: $viewModel.book.title)
                TextField("Автор", text: $viewModel.book.author)
                TextField("Описание", text: $viewModel.book.aboutDescription)
            }
        }
        .navigationTitle("Редактировать книгу")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    guard validateInput() else {
                        showAlert = true
                        return
                    }
                    
                    Task {
                        do {
                            try await viewModel.saveChanges()
                            dismiss()
                        } catch {
                            print("Ошибка сохранения: \(error)")
                        }
                    }
                }
            }
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Название и автор должны содержать минимум 3 символа")
        }
    }
    
    private func validateInput() -> Bool {
        let title = viewModel.book.title.trimmed()
        let author = viewModel.book.author.trimmed()
        return title.count >= minLength && author.count >= minLength
    }
}

#Preview {
    // Временный контейнер для превью
    let tempContainer: ModelContainer = {
        let schema = Schema([Book.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Не удалось создать временный контейнер: \(error)")
        }
    }()

    // Создаем ModelContext и DataService
    let modelContext = ModelContext(tempContainer)
    let dataService = DataService(modelContext: modelContext)

    // Создаем тестовую книгу
    let book = Book(title: "Тест", author: "Автор", aboutDescription: "Описание")

    // Создаем ViewModel для превью
    let viewModel = EditBookViewModel(dataService: dataService, book: book)

    // Возвращаем EditBookView с ViewModel
    EditBookView(viewModel: viewModel)
}
