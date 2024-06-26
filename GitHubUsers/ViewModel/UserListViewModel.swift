//
//  UserListViewModel.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

protocol UserListViewDataProviding {
  var usersPublisher: AnyPublisher<[User], Never> { get }
  func loadGitHubUsers(index: Int?)
  var hasLoadedAllUsers: Bool { get }
}

final class UserListViewModel: UsersListViewModel {
  
  // MARK: Dependencies
  private let dataProvider: UserListViewDataProviding
  
  private var cancellables = Set<AnyCancellable>()
  @Published var isLoading: Bool = false
  @Published var users: [User] = []

  var lastUserId: Int? {
    guard !users.isEmpty else { return nil }
    return users.last?.id
  }
  
  init(dataProvider: UserListViewDataProviding) {
    self.dataProvider = dataProvider
    subscribeForGitHubUsers()
    loadGitHubUsers()
  }
  
  private func subscribeForGitHubUsers() {
    dataProvider.usersPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] users in
        guard let self else { return }
        self.users.append(contentsOf: users)
        self.isLoading = false
      }
      .store(in: &cancellables)
  }
  
  func loadGitHubUsers() {
    guard !isLoading, !dataProvider.hasLoadedAllUsers else { return }
    self.isLoading = true
    self.dataProvider.loadGitHubUsers(index: lastUserId)
  }
}

