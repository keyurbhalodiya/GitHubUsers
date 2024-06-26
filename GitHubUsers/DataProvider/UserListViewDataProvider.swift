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
    static let perPageLimit = 30
  }
  
  private var cancellables: Set<AnyCancellable> = Set()
  
  @Published private var users: [User] = []
  
  var usersPublisher: AnyPublisher<[User], Never> {
    $users.eraseToAnyPublisher()
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
}
