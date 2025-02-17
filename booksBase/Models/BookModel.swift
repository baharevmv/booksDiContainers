//
//  BookModel.swift
//  booksBase
//
//  Created by Maksim Bakharev on 12.02.2025.
//

import SwiftData
import SwiftUI

@Model
final class Book: Hashable {
    var title: String
    var author: String
    var aboutDescription: String

    init(title: String, author: String, aboutDescription: String) {
        self.title = title
        self.author = author
        self.aboutDescription = aboutDescription
    }
    
    // Реализация Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }

    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }
}
