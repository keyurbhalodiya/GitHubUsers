//
//  Extension.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import SwiftUI

public extension View {
  func hudOverlay(_ isShowing: Bool) -> some View {
    modifier(
      LoadingIndicatorModifier(isShowing: isShowing)
    )
  }
}
