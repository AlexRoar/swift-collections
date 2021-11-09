//
//  File.swift
//
//
//  Created by  Alex Dremov on 13.11.2021.
//

import Foundation

extension TreeArray: Collection {
  @inlinable
  public subscript(_ x: Int) -> Element {
    get {
      if let val = head?.get(x: x)?.key {
        return val
      }
      fatalError("Index \(x)/ out of range in structure of size \(size)")
    }
    mutating set(value) {
      _ensureUnique()
      if head == nil && x == 0 {
        head = TreeNode(key: value)
        size = 1
        return
      }
      if head == nil || x >= size {
        fatalError("Index \(x)/ out of range in structure of size \(size)")
      }
      head!.get(x: x)!.key = value
    }
  }

  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    if size == 0 {
      return nil
    }
    return remove(at: 0)
  }

  @inlinable
  @inline(__always)
  public mutating func removeFirst() -> Element? {
    return popFirst()
  }

  @inlinable
  @inline(__always)
  public var startIndex: Int {
    0
  }

  @inlinable
  @inline(__always)
  public var endIndex: Int {
    size
  }

  @inlinable
  @inline(__always)
  @_effects(readnone)
  public func index(after i: Int) -> Int {
    i + 1
  }

  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    size == 0
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    size
  }
}
