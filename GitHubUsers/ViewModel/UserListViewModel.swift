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
  var usersSearchPublisher: AnyPublisher<[User], Never> { get }
  var hasLoadedAllUsers: Bool { get }
  func loadGitHubUsers(index: Int?)
  func searchUsers(with name: String)
}

final class UserListViewModel: UsersListViewModel {
  
  // MARK: Dependencies
  private let dataProvider: UserListViewDataProviding
  
  private var cancellables = Set<AnyCancellable>()
  private let searchTextPublisher = PassthroughSubject<String, Never>()
  private var usersCache: [User] = []
  private var isSearching: Bool = false
  
  // MARK: UserListViewState
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
        self.usersCache = self.users
        self.isLoading = false
      }
      .store(in: &cancellables)
    
    dataProvider.usersSearchPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] users in
        guard let self else { return }
        self.users.append(contentsOf: users)
        self.isLoading = false
      }
      .store(in: &cancellables)
    
    searchTextPublisher
      .debounce(for: .milliseconds(700), scheduler: DispatchQueue.main)
      .removeDuplicates()
      .sink(receiveValue: { [weak self] searchText in
        guard let self, !isLoading, !searchText.isEmpty else { return }
        self.isLoading = true
        self.users.removeAll()
        self.dataProvider.searchUsers(with: searchText)
      })
      .store(in: &cancellables)
  }
  
  private func cancelSearch() {
    self.users = self.usersCache
    isSearching = false
    searchTextPublisher.send("")
  }
}

// MARK: UserListViewListner
extension UserListViewModel {
  
  func loadGitHubUsers() {
    guard !isLoading, !dataProvider.hasLoadedAllUsers, !isSearching else { return }
    self.isLoading = true
    self.dataProvider.loadGitHubUsers(index: lastUserId)
  }
  
  func searchUsers(with name: String) {
    guard name.count != 0 else {
      cancelSearch()
      return
    }
    isSearching = true
    searchTextPublisher.send(name)
  }
  
  func dismissSearchUsers() {
    cancelSearch()
  }
}
