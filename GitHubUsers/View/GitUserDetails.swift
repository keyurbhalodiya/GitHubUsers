//
//  GitUserDetails.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct GitUserDetails: View {
  @State var userInfo: UserInfo
  @State var repos: [UserRepositories]
  
  var body: some View {
    HStack(spacing: 20) {
      WebImage(url: URL(string: userInfo.avatarURL ?? ""))
        .resizable()
        .frame(width: 100, height: 100)
        .clipShape(.circle)
      VStack(alignment: .leading) {
        Text(userInfo.name ?? "NA")
        Spacer()
        Text("@\(userInfo.login ?? "")")
          .foregroundStyle(.link)
      }
      .frame(height: 50)
      .font(.system(size: 22, weight: .heavy, design: .default))
      Spacer()
    }
    .padding(20)
    
    HStack(spacing: 20) {
      VStack(alignment: .center) {
        Text("\(userInfo.followers ?? 0)")
          .font(.system(size: 22, weight: .heavy, design: .default))
        Spacer()
        Text("Followers")
          .foregroundStyle(.gray)
          .font(.system(size: 18, weight: .medium, design: .default))
      }
      Divider()
      VStack(alignment: .center) {
        Text("\(userInfo.following ?? 0)")
          .font(.system(size: 22, weight: .heavy, design: .default))
        Spacer()
        Text("Following")
          .foregroundStyle(.gray)
          .font(.system(size: 18, weight: .medium, design: .default))
      }
      Divider()
      VStack(alignment: .center) {
        Text(userInfo.location ?? "NA")
          .font(.system(size: 22, weight: .heavy, design: .default))
        Spacer()
        Text("Location")
          .foregroundStyle(.gray)
          .font(.system(size: 18, weight: .medium, design: .default))
      }
    }
    .frame(height: 50)
    
    List(repos, id: \.self) { repo in
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
    }
    .listStyle(.plain)
  }
}

#Preview {
  GitUserDetails(userInfo: UserInfo(login: "keyur", id: 1, htmlURL: nil, name: "Keyur Bhalodiya", avatarURL: "https://avatars.githubusercontent.com/u/1?v=4", location: "India", followers: 123, following: 456),
                 repos: [UserRepositories(id: 1, name: "chronic", htmlURL: "https://github.com/mojombo/30daysoflaptops.github.io", description: "Chronic is a pure Ruby natural language date parser.", language: "Swift", starCount: 36)])
}
