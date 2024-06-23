//
//  GitUsers.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import SwiftUI

protocol GitUsersViewState: ObservableObject {
  var gitUsers: [User] { get set }
}

struct GitUsers<ViewModel: GitUsersViewState>: View {
  
  @StateObject private var viewModel: ViewModel
  
  public init(viewModel: ViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    NavigationView {
      List(viewModel.gitUsers, id: \.self) { user in
        HStack {
          Text(user.login ?? "")
        }
      }
      .listStyle(.plain)
      .navigationTitle("GitHub Users")
    }
  }
}

// MARK: Preview

#if DEBUG
private final class GitUsersViewModelMock: GitUsersViewState {
  var gitUsers: [User] = [
    User(login: "User 1", id: 1, avatarURL: "https://avatarURL"),
    User(login: "User 2", id: 2, avatarURL: "https://avatarURL")
  ]

}
#Preview {
  GitUsers(viewModel: GitUsersViewModelMock())
}

#endif
