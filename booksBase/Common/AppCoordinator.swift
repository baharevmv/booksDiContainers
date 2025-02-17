//
//  AppCoordinator.swift
//  booksBase
//
//  Created by Максим Бахарев on 17.02.2025.
//

import Foundation
import SwiftUI

protocol Coordinator {
    func navigate(to route: AppRoute)
}

final class AppCoordinator: Coordinator, ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
}

enum AppRoute: Hashable {
    case editBook(Book)
}
