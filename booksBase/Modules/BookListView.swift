//
//  ContentView.swift
//  booksBase
//
//  Created by Maksim Bakharev on 12.02.2025.
//

import SwiftUI
import SwiftData

struct BookListView: View {
    @StateObject private var viewModel: BookListViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showAlert = false
    
    private let minLength = 3
    
    init(
        modelContext: ModelContext,
         coordinator: AppCoordinator
    ) {
        let diContainer = DIContainer(
            modelContext: modelContext,
            coordinator: coordinator
        )
        _viewModel = StateObject(wrappedValue: diContainer.makeBookListViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 0) {
                // Кнопка для показа/скрытия блока добавления
                HStack {
                    // Индикатор загрузки
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    TextField("Поиск", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .onChange(of: viewModel.searchText) {
                            Task {
                                await viewModel.fetchBooks()  // Загружаем книги при изменении поиска
                            }
                        }
                    
                    Text(String(localized: "add_book_title"))
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.isAddingBook.toggle()
                        }
                    }) {
                        Image(systemName: viewModel.isAddingBook ? "minus.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(viewModel.isAddingBook ? 180 : 0))
                            .padding(.trailing)
                            .padding(.bottom, 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Блок добавления книги
                if viewModel.isAddingBook {
                    addBookForm
                }
                
                // Список книг
                bookList
            }
            .navigationTitle(String(localized: "book_list_title"))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(String(localized: "error_title")),
                    message: Text(String(localized: "error_message")),
                    dismissButton: .default(Text(String(localized: "OK")))
                )
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .editBook(let book):
                    EditBookView(
                        viewModel: viewModel.makeEditBookViewModel(for: book)
                    )
                }
            }
        }
    }
    
    // MARK: - Компоненты
    private var addBookForm: some View {
        VStack(spacing: 12) {
            // Поля ввода
            VStack(spacing: 8) {
                TextField(String(localized: "book_title_placeholder"), text: $viewModel.newBookTitle)
                    .textFieldStyle(.roundedBorder)
                TextField(String(localized: "book_author_placeholder"), text: $viewModel.newBookAuthor)
                    .textFieldStyle(.roundedBorder)
                TextField(String(localized: "book_description_placeholder"), text: $viewModel.newBookDescription)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            // Кнопка добавления книги
            Button {
                Task {
                    await viewModel.addBook()
                }
            } label: {
                if viewModel.isLoading {  // Если идет загрузка, показываем индикатор
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {  // Иначе показываем текст кнопки
                    Text(String(localized: "add_book_button"))
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(viewModel.isLoading)  // Отключаем кнопку во время загрузки
            
            // Сообщение об ошибке
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .transition(.opacity.combined(with: .scale))
    }
    
    private var bookList: some View {
        List {
            ForEach(viewModel.books) { book in
                Button {
                    viewModel.navigateToEditBook(book) // Навигация через координатор
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title).font(.title3)
                        Text(book.author).font(.headline).foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .onDelete { indexSet in
                Task {
                    await viewModel.deleteBook(at: indexSet)
                }
            }
            .listRowSeparator(.visible)
        }
        .listStyle(.plain)
    }
}



#Preview {
    // Создаем координатор для превью
    let coordinator = AppCoordinator()
    
    // Создаем временный ModelContainer в памяти
    let tempContainer: ModelContainer = {
        let schema = Schema([Book.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()
    
    // Создаем ModelContext из временного контейнера
    let modelContext = ModelContext(tempContainer)
    
    return BookListView(
        modelContext: modelContext,
        coordinator: coordinator
    )
    .modelContainer(tempContainer) // Привязываем контейнер к превью
    .environmentObject(coordinator) // Добавляем координатор в окружение
}
