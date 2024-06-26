//
//  AppCoordinator.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/25.
//

import SwiftUI
import Combine

// MARK: - AppCoordinator
final class AppCoordinator: ObservableObject {

  @Published var path: NavigationPath
  private var cancellables = Set<AnyCancellable>()
  
  init(path: NavigationPath) {
    self.path = path
  }
  
  @ViewBuilder
  func build() -> some View {
    userListView()
  }
  
  private func push<T: Hashable>(_ coordinator: T) {
    path.append(coordinator)
  }
  
  private func userListView() -> some View {
    let userListView = UserListView(viewModel: UserListViewModel(dataProvider: DataProvider()))
    userListView.didClickUser
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] user in
        guard let userName = user.login else { return }
        self?.usersDetailsFlow(userName)
      })
      .store(in: &cancellables)
    return userListView
  }
  
  // MARK: Flow Control Methods
  private func usersDetailsFlow(_ userName: String) {
    let usersFlowCoordinator = UserDetailsCoordinator(userName: userName)
    self.bind(userCoordinator: usersFlowCoordinator)
    self.push(usersFlowCoordinator)
  }
  
  // MARK: Flow Coordinator Bindings
  private func bind(userCoordinator: UserDetailsCoordinator) {
    userCoordinator.pushCoordinator
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] coordinator in
        self?.push(coordinator)
      })
      .store(in: &cancellables)
  }
}
