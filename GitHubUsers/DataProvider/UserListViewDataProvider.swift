//
//  UserListViewDataProvider.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

final class UserListViewDataProvider: UserListViewDataProviding {
  
  private enum Constant {
    static let keySince = "since"
    static let keyPerPageLimit = "per_page"
    static let keySearchQuery = "q"
    static let perPageLimit = 30
    static let perPageLimitForSearch = 100
  }
  
  private var cancellables: Set<AnyCancellable> = Set()
  
  @Published private var users: [User] = []
  @Published private var usersSearch: [User] = []

  var usersPublisher: AnyPublisher<[User], Never> {
    $users.eraseToAnyPublisher()
  }
  
  var usersSearchPublisher: AnyPublisher<[User], Never> {
    $usersSearch.eraseToAnyPublisher()
  }

  var hasLoadedAllUsers: Bool = false

  func loadGitHubUsers(index: Int?) {
    guard !hasLoadedAllUsers else { return }
    var parameters: [String : Any] = [Constant.keyPerPageLimit : Constant.perPageLimit]
    if let index {
      parameters[Constant.keySince] = index
    }
    NetworkService.shared.getData(endpoint: "users", parameters: parameters, type: [User].self)
      .sink { completion in
        switch completion {
        case .failure(let err):
          print("Error is \(err.localizedDescription)")
        case .finished:
          print("Finished successfully")
        }
      } receiveValue: { [weak self] users in
        self?.users = users
        self?.hasLoadedAllUsers = users.count < Constant.perPageLimit
      } .store(in: &cancellables)
  }
  
  func searchUsers(with name: String) {
    var parameters: [String : Any] = [Constant.keyPerPageLimit : Constant.perPageLimitForSearch]
    parameters[Constant.keySearchQuery] = name
    NetworkService.shared.getData(endpoint: "search/users", parameters: parameters, type: UsersSearch.self)
      .sink { completion in
        switch completion {
        case .failure(let err):
          print("Error is \(err.localizedDescription)")
        case .finished:
          print("Finished search successfully")
        }
      } receiveValue: { [weak self] usersSearch in
        self?.usersSearch = usersSearch.users ?? []
      } .store(in: &cancellables)
  }
}
