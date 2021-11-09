//
//  File.swift
//
//
//  Created by  Alex Dremov on 13.11.2021.
//

import Foundation

extension TreeArray {
  @usableFromInline
  internal class TreeNode: CustomStringConvertible {
    @usableFromInline
    internal typealias Children = (left: TreeNode?, right: TreeNode?)

    @usableFromInline
    var key: Element?

    @usableFromInline
    var priority = Int.random(in: Int.min...Int.max)

    @usableFromInline
    var depth: Int = 1

    @usableFromInline
    var children: Children

    @inlinable
    @inline(__always)
    init(key: Element?, left: TreeNode? = nil, right: TreeNode? = nil) {
      self.key = key
      self.children = (left, right)
      update()
    }

    @inlinable
    @inline(__always)
    var leftDepth: Int {
      children.left?.depth ?? 0
    }

    @inlinable
    @inline(__always)
    var rightDepth: Int {
      children.right?.depth ?? 0
    }

    @inlinable
    @inline(__always)
    func update() {
      depth = leftDepth + rightDepth + 1
    }

    @usableFromInline
    func dump(str: inout String, depthPrint: Int = 1) {
      let strValue = "<\(String(describing: key))>\n"

      if children.right != nil {
        children.right!.dump(str: &str, depthPrint: depthPrint + Int(strValue.count))
      }

      str += String(repeating: " ", count: Int(depthPrint - 1)) + "|"
      str += strValue

      if children.left != nil {
        children.left!.dump(str: &str, depthPrint: depthPrint + Int(strValue.count))
      }
    }

    @inlinable
    @inline(__always)
    public var description: String {
      var out: String = ""
      dump(str: &out)
      return out
    }

    @inlinable
    @inline(__always)
    var copy: TreeNode {
      TreeNode(key: key, left: children.left?.copy, right: children.right?.copy)
    }
  }
}
