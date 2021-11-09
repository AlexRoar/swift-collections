//
//  File.swift
//
//
//  Created by  Alex Dremov on 13.11.2021.
//

import Foundation

extension TreeArray.TreeNode {
  @usableFromInline
  internal typealias TreeNode = TreeArray.TreeNode

  @inlinable
  static func merge(left: TreeNode?, right: TreeNode?) -> TreeNode? {
    guard let leftUnwrapped = left else {
      return right
    }

    guard let rightUnwrapped = right else {
      return left
    }

    if leftUnwrapped.priority > rightUnwrapped.priority {
      leftUnwrapped.children.right = merge(left: leftUnwrapped.children.right, right: rightUnwrapped)
      leftUnwrapped.update()
      return left
    } else {
      rightUnwrapped.children.left = merge(left: leftUnwrapped, right: rightUnwrapped.children.left)
      rightUnwrapped.update()
      return right
    }
  }

  @inlinable
  func split(no: Int) -> Children {
    let curKey = leftDepth

    var ret: Children = (self, self)
    defer {
      ret.left?.update()
      ret.right?.update()
    }

    if curKey < no {
      (children.right, ret.right) = children.right?.split(no: no - curKey - 1) ?? (nil, nil)
    } else {
      (ret.left, children.left) = children.left?.split(no: no) ?? (nil, nil)
    }

    return ret
  }

}
