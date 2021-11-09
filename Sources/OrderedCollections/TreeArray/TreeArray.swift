//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
import Foundation

@frozen
public struct TreeArray<Element>: RangeReplaceableCollection, MutableCollection, CustomDebugStringConvertible {
  @usableFromInline
  internal var head: TreeNode?

  @usableFromInline
  internal var size: Int = 0

  @inlinable
  @inline(__always)
  public init() {}

  @inlinable
  @inline(__always)
  public init(_ content: [Element]) {
    for i in content {
      append(i)
    }
  }

  var array: [Element] {
    var result = [Element]()
    result.reserveCapacity(size)
    for i in self {
      result.append(i)
    }
    return result
  }

  public var debugDescription: String {
    let mirror = Mirror(reflecting: self)
    var out: String = "\(mirror.subjectType) {\n"
    out += head?.description ?? "<Empty>"
    out += "\n}"
    return out
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUnique() {
    if isKnownUniquelyReferenced(&self.head) { return }
    head = head?.copy
  }

  mutating public func append(_ value: Element) {
    _ensureUnique()
    head = head?.insert(x: size, key: value) ?? TreeNode(key: value)
    size += 1
  }

  mutating public func appendFront(_ value: Element) {
    _ensureUnique()
    head = head?.insert(x: 0, key: value) ?? TreeNode(key: value)
    size += 1
  }

  @inlinable
  @inline(__always)
  mutating public func removeAll(keepingCapacity keepCapacity: Bool) {
    _ensureUnique()
    size = 0
    head = nil
  }

  mutating public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    _ensureUnique()
    for i in (0..<size).reversed() {
      if try shouldBeRemoved(self[i]) {
        remove(at: i)
      }
    }
  }

  @inlinable
  @inline(__always)
  @discardableResult
  mutating public func remove(at index: Int) -> Element {
    if let res = try? head?.remove(x: index) {
      head = res.head
      let elem = (res.removed?.key)!
      res.removed?.key = nil
      size -= 1
      return elem
    }
    fatalError("NO")
  }

  @inlinable
  @inline(__always)
  mutating public func removeFirst() -> Element {
    _ensureUnique()
    return remove(at: 0)
  }

  @inlinable
  @inline(__always)
  mutating public func removeFirst(_ k: Int) {
    _ensureUnique()
    for _ in (0..<k) {
      remove(at: 0)
    }
  }

  @inlinable
  mutating public func insert(_ newElement: Element, at i: Int) {
    _ensureUnique()
    if i > size {
      fatalError("Index \(i) out of range in structure of size \(size)")
    }
    _insertNoCheck(newElement, at: i)
  }

  @inlinable
  @inline(__always)
  mutating internal func _insertNoCheck(_ newElement: Element, at i: Int) {
    head = head?.insert(x: i, key: newElement) ?? TreeNode(key: newElement)
    size += 1
  }

  @inlinable
  mutating public func insert<S>(contentsOf newElements: S, at i: Int)
  where S: Collection, Element == S.Element {
    if newElements.isEmpty {
      return
    }
    _ensureUnique()
    var pos = i
    for elem in newElements {
      _insertNoCheck(elem, at: Int(pos))
      pos += 1
    }
  }

  @inlinable
  @inline(__always)
  public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
    for i in elements {
      append(i)
    }
  }

  @inlinable
  @inline(__always)
  public init(repeating repeatedValue: Element, count: Int) {
    for _ in 0..<count {
      append(repeatedValue)
    }
  }

  mutating public func append<S>(contentsOf newElements: S)
  where S: Sequence, Element == S.Element {
    _ensureUnique()
    for elem in newElements {
      append(elem)
    }
  }

  mutating public func removeSubrange(_ bounds: Range<Int>) {
    if bounds.isEmpty {
      return
    }
    // TODO: two splits
    _ensureUnique()
    for i in bounds.reversed() {
      remove(at: i)
    }
  }
}
