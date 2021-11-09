//
//  File.swift
//
//
//  Created by  Alex Dremov on 13.11.2021.
//

import Foundation

extension TreeArray.TreeNode {
  @inlinable
  func insert(x: Int, key: Element) -> TreeNode? {
    let splitted = split(no: x)

    let m = TreeNode(key: key)
    return TreeNode.merge(
      left: TreeNode.merge(
        left: splitted.0,
        right: m),
      right: splitted.1)
  }

  @inlinable
  func remove(x: Int) throws -> (head: TreeNode?, removed: TreeNode?) {
    let splitRes = split(no: x)

    if splitRes.1 == nil {
      fatalError("\(x) not in array")
    }

    let splittedSecond = splitRes.1!.split(no: 1)
    return (TreeNode.merge(left: splitRes.0, right: splittedSecond.1), splittedSecond.0)
  }

  @inline(__always)
  @usableFromInline
  internal func get(x: Int) -> TreeNode? {
    let curKey = leftDepth
    if curKey < x {
      return children.right?.get(x: x - curKey - 1)
    } else if curKey > x {
      return children.left?.get(x: x)
    }
    return self
  }

  @inline(__always)
  @usableFromInline
  internal func set(x: Int, value: Element) throws {
    let node = get(x: x)
    if node == nil {
      fatalError("\(x) not in array")
    }
    node!.key = value
  }

}
