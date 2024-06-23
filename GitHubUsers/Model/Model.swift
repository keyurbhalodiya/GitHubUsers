//
//  Model.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation

// MARK: - User
struct User: Codable, Hashable {
  let login: String?
  let id: Int?
  let avatarURL: String?
}

