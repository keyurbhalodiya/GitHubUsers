//
//  UserDetailsView.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

protocol UserDetailsViewState: ObservableObject {
  var userInfo: UserInfo? { get }
  var repos: [UserRepositories] { get }
  var lastRepoId: Int? { get }
  var isLoadingRepos: Bool { get }
}

protocol UserDetailsViewListner {
  func loadGitRepos()
}

typealias UserInfoViewModel = UserDetailsViewState & UserDetailsViewListner

struct UserDetailsView<ViewModel: UserInfoViewModel>: View {
  
  @StateObject private var viewModel: ViewModel
  @Environment(\.isLoading) private var isLoading

  let didTapped = PassthroughSubject<String?, Never>()

  public init(viewModel: ViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    headerViewContent
    Divider()
    userConnectionViewContent
    Divider()
    repoListViewContent
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: viewModel.isLoadingRepos) { newValue in
        isLoading.wrappedValue = newValue
    }
    .onAppear {
      viewModel.loadGitRepos()
    }
  }
  
  @ViewBuilder
  var headerViewContent: some View {
    HStack(spacing: 20) {
      WebImage(url: URL(string: viewModel.userInfo?.avatarURL ?? ""))
        .resizable()
        .frame(width: 100, height: 100)
        .clipShape(.circle)
      VStack(alignment: .leading) {
        Text(viewModel.userInfo?.name ?? "NA")
        Spacer()
        Text("@\(viewModel.userInfo?.login ?? "")")
          .foregroundStyle(.blue)
          .onTapGesture {
            didTapped.send(viewModel.userInfo?.htmlURL)
          }
      }
      .frame(height: 50)
      .font(.system(size: 22, weight: .heavy, design: .default))
      Spacer()
    }
    .padding(20)
  }
  
  @ViewBuilder
  var userConnectionViewContent: some View {
    HStack(spacing: 20) {
      VStack(alignment: .center) {
        Text("\(viewModel.userInfo?.followers ?? 0)")
          .font(.system(size: 20, weight: .heavy, design: .default))
        Spacer()
        Text("Followers")
          .foregroundStyle(.gray)
          .font(.system(size: 16, weight: .medium, design: .default))
      }
      Divider()
      VStack(alignment: .center) {
        Text("\(viewModel.userInfo?.following ?? 0)")
          .font(.system(size: 20, weight: .heavy, design: .default))
        Spacer()
        Text("Following")
          .foregroundStyle(.gray)
          .font(.system(size: 16, weight: .medium, design: .default))
      }
      Divider()
      VStack(alignment: .center) {
        Text(viewModel.userInfo?.location ?? "NA")
          .font(.system(size: 20, weight: .heavy, design: .default))
          .lineLimit(2)
        Spacer()
        Text("Location")
          .foregroundStyle(.gray)
          .font(.system(size: 16, weight: .medium, design: .default))
      }
    }
    .frame(height: 40)
    .padding(20)
  }
  
  @ViewBuilder
  var repoListViewContent: some View {
    List(viewModel.repos, id: \.self) { repo in
      VStack(alignment: .leading, spacing: 5) {
        HStack {
          Text(repo.name ?? "")
            .font(.system(size: 20, weight: .medium, design: .default))
          Spacer()
          Text("⭐ \(repo.starCount ?? 0)")
            .font(.system(size: 20, weight: .medium, design: .default))
        }
        HStack {
          Text("Language :")
          Text(repo.language ?? "")
        }
        
        Text(repo.description ?? "")
          .font(.system(size: 16, weight: .regular, design: .default))
          .foregroundStyle(.gray)
      }
      .contentShape(Rectangle())
      .onAppear {
        guard repo.id == viewModel.lastRepoId else { return }
        viewModel.loadGitRepos()
      }
      .onTapGesture {
        didTapped.send(repo.htmlURL)
      }
    }
    .listStyle(.plain)
  }
}

// MARK: Preview

#if DEBUG
private final class UserDetailsViewModelMock: UserInfoViewModel {
  var isLoadingRepos: Bool = true
  var lastRepoId: Int?
  var userInfo: UserInfo? = UserInfo(login: "keyur", id: 1, htmlURL: nil, name: "Keyur Bhalodiya", avatarURL: "https://avatars.githubusercontent.com/u/1?v=4", location: "India", followers: 123, following: 456)
  var repos: [UserRepositories] = [UserRepositories(id: 1, name: "chronic", htmlURL: "https://github.com/mojombo/30daysoflaptops.github.io", description: "Chronic is a pure Ruby natural language date parser.", language: "Swift", starCount: 36)]
  
  func loadGitRepos() { }
}

#Preview {
  NavigationStack {
    UserDetailsView(viewModel: UserDetailsViewModelMock())
  }
}

#endif
