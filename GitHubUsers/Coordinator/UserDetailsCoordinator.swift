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
  
  private var cancellables = Set<AnyCancellable>()
  let pushCoordinator = PassthroughSubject<UserDetailsCoordinator, Never>()
  
  init(userName: String) {
    id = UUID()
    self.userName = userName
  }
  
  func build() -> some View {
    let userDetailsView = UserDetailsView(viewModel: UserDetailsViewModel(loginUsername: userName, dataProvider: UserDetailsViewDataProvider()))
    userDetailsView.didTapped
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { url in
        guard let url, let repoUrl = URL(string: url) else { return }
        UIApplication.shared.open(repoUrl)
      })
      .store(in: &cancellables)
    return userDetailsView
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: UserDetailsCoordinator, rhs: UserDetailsCoordinator) -> Bool {
    return lhs.id == rhs.id
  }
}


