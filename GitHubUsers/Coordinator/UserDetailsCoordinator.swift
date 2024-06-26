//
//  UserDetailsCoordinator.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import SwiftUI
import Combine

// MARK: - UserDetailsCoordinator
final class UserDetailsCoordinator: Hashable {
  
  private var userName: String
  private var id: UUID
  let pushCoordinator = PassthroughSubject<UserDetailsCoordinator, Never>()
  
  init(userName: String) {
    id = UUID()
    self.userName = userName
  }
  
  @ViewBuilder
  func build() -> some View {
    UserDetailsView(viewModel: UserDetailsViewModel(loginUsername: userName, dataProvider: UserDetailsViewDataProvider()))
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: UserDetailsCoordinator, rhs: UserDetailsCoordinator) -> Bool {
    return lhs.id == rhs.id
  }
}


