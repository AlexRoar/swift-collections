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
public struct TreeArrayContinous<T>: Collection, Sequence,
  RangeReplaceableCollection, MutableCollection,
  ExpressibleByArrayLiteral
{
  public typealias Element = T

  @usableFromInline
  internal typealias NodeIndex = Int

  @usableFromInline
  internal typealias Storage = UnsafeMutablePointer<TreeNode>

  @usableFromInline
  internal var storage: Storage

  @usableFromInline
  internal var storageHeader = Header()

  @inlinable
  @inline(__always)
  internal var increaseFactor: Double { 2 }

  @inlinable
  @inline(__always)
  internal var initialSize: Int { 128 }

  @usableFromInline
  internal var head: NodeIndex = 0

  @usableFromInline
  internal var size: Int = 0

  @usableFromInline
  internal struct Header {
    @usableFromInline
    internal var capacity: Int = 0
    @usableFromInline
    internal var freeSize: Int = 0
    @usableFromInline
    internal var freePointer: NodeIndex = 0

    @usableFromInline
    internal init() {}
  }

  @usableFromInline
  internal struct TreeNode {
    @usableFromInline
    internal var key: Element?

    @usableFromInline
    internal var priority: Int = Int.random(in: Int.min...Int.max)

    @usableFromInline
    internal var depth: Int = 1

    @usableFromInline
    internal var left: NodeIndex = 0

    @usableFromInline
    internal var right: NodeIndex = 0

    @usableFromInline
    internal var next: NodeIndex = 0

    @inlinable
    @inline(__always)
    internal init(key: T?, left: Int = 0, right: Int = 0) {
      self.key = key
      self.left = left
      self.right = right
    }

    @inlinable
    @inline(__always)
    internal init() {
    }

    @inlinable
    @inline(__always)
    internal func leftDepth(storage: Storage) -> Int {
      left == 0 ? 0 : storage[left].depth
    }

    @inlinable
    @inline(__always)
    internal func rightDepth(storage: Storage) -> Int {
      left == 0 ? 0 : storage[left].depth
    }

    @inlinable
    @inline(__always)
    static var general: TreeNode {
      TreeNode()
    }
  }

  @inlinable
  internal mutating func requireAvailable(elements: Int) {
    let requireSize = size + storageHeader.freeSize + elements + 1
    if requireSize < storageHeader.capacity { return }

    let newCapacity = Int(Double(requireSize) * increaseFactor)
    let newStorage = Storage.allocate(capacity: newCapacity)
    newStorage.moveInitialize(from: storage, count: storageHeader.capacity)
    storage.deallocate()
    storage = newStorage
    storageHeader.capacity = newCapacity
  }

  @inlinable
  internal mutating func allocateNode() -> NodeIndex {
    if storageHeader.freePointer == 0 {
      requireAvailable(elements: 1)
      size += 1
      storage[size] = TreeNode()
      return size
    }
    let newNodeValue = storageHeader.freePointer
    storageHeader.freeSize -= 1
    storageHeader.freePointer = storage[storageHeader.freePointer].next
    storage[newNodeValue].depth = 1
    storage[newNodeValue].left = 0
    storage[newNodeValue].right = 0
    assert(newNodeValue > 0, "Zero node is reserved")
    return newNodeValue
  }

  @inlinable
  internal mutating func deleteNode(at pos: Int) {
    storageHeader.freeSize += 1
    size -= 1
    if storageHeader.freePointer == 0 {
      storageHeader.freePointer = pos
      return
    }
    storage[pos].key = nil
    storage[pos].next = storageHeader.freePointer
    storageHeader.freePointer = pos
  }

  @inlinable
  @inline(__always)
  internal mutating func updateDepth(node: NodeIndex) {
    if node == 0 { return }
    let depth =
      (storage[storage[node].left].depth) + (storage[storage[node].right].depth) + 1
    storage[node].depth = depth
  }

  @inlinable
  internal mutating func merge(left: NodeIndex = 0, right: NodeIndex = 0) -> NodeIndex {
    if left == 0 {
      return right
    }

    if right == 0 {
      return left
    }

    if storage[left].priority > storage[right].priority {
      storage[left].right = merge(left: storage[left].right, right: right)
      updateDepth(node: left)
      return left
    } else {
      storage[right].left = merge(left: left, right: storage[right].left)
      updateDepth(node: right)
      return right
    }

  }

  @inlinable
  internal mutating func split(node: NodeIndex, no: Int) -> (left: NodeIndex, right: NodeIndex) {
    if node == 0 {
      return (0, 0)
    }
    let curKey = storage[node].leftDepth(storage: storage)
    var ret: (left: NodeIndex, right: NodeIndex) = (0, 0)

    if curKey < no {
      if storage[node].right == 0 {
        (storage[node].right, ret.right) = (0, 0)
      } else {
        (storage[node].right, ret.right) =
          split(node: storage[node].right, no: no - curKey - 1)
      }
      ret.left = node
    } else {
      if storage[node].left == 0 {
        (ret.left, storage[node].left) = (0, 0)
      } else {
        (ret.left, storage[node].left) =
          split(node: storage[node].left, no: no)
      }
      ret.right = node
    }

    updateDepth(node: ret.left)
    updateDepth(node: ret.right)

    return ret
  }

  @inlinable
  @inline(__always)
  internal func getIndexOf(node: NodeIndex, x: Int) -> NodeIndex {
    if node == 0 {
      return 0
    }
    let curKey = storage[node].leftDepth(storage: storage)
    if curKey < x {
      return getIndexOf(node: storage[node].right, x: x - curKey - 1)
    } else if curKey > x {
      return getIndexOf(node: storage[node].left, x: x)
    }
    return node
  }

  @inlinable
  @inline(__always)
  internal mutating func setAtIndex(node: NodeIndex, x: Int, value: Element) {
    let node = getIndexOf(node: node, x: x)
    if node == 0 {
      fatalError("\(x) not in array")
    }
    storage[node].key = value
  }

  @usableFromInline
  internal mutating func _insertNoChecks(_ newElement: Element, at i: Int) {
    let newNodeInd = allocateNode()
    storage[newNodeInd].key = newElement
    if head == 0 {
      head = newNodeInd
      return
    }

    let splitted = split(node: head, no: i)
    head = merge(left: merge(left: splitted.left, right: newNodeInd), right: splitted.right)
  }

  @inlinable
  mutating public func removeSubrange(_ bounds: Range<Int>) {
    if bounds.isEmpty {
      return
    }
    for i in bounds.reversed() {
      remove(at: i)
    }
  }

  @discardableResult
  public mutating func remove(at i: Int) -> T {
    let splitRes = split(node: head, no: i)

    if splitRes.right == 0 {
      fatalError("\(i) not in array")
    }

    let splittedSecond = split(node: splitRes.right, no: 1)
    let value = storage[splittedSecond.left].key!
    head = merge(left: splitRes.left, right: splittedSecond.right)
    deleteNode(at: splittedSecond.left)
    return value
  }

  @inlinable
  @inline(__always)
  mutating public func insert(_ newElement: Element, at i: Int) {
    _insertNoChecks(newElement, at: i)
  }

  @inlinable
  mutating public func insert<S>(contentsOf newElements: S, at i: Int)
  where S: Collection, T == S.Element {
    if newElements.isEmpty {
      return
    }
    var pos = i
    for elem in newElements {
      _insertNoChecks(elem, at: pos)
      pos += 1
    }
  }

  @inlinable
  @inline(__always)
  mutating public func append(_ value: Element) {
    _insertNoChecks(value, at: size)
  }

  @inlinable
  @inline(__always)
  mutating public func appendFront(_ value: Element) {
    _insertNoChecks(value, at: 0)
  }

  @inlinable
  @inline(__always)
  public var getSize: Int {
    size
  }

  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    size == 0
  }

  @inlinable
  @inline(__always)
  public func index(after i: Int) -> Int {
    i + 1
  }

  @inlinable
  @inline(__always)
  public var startIndex: Int {
    0
  }

  @inlinable
  @inline(__always)
  public var endIndex: Int {
    Int(size)
  }

  public subscript(_ x: Int) -> T {
    get {
      let node = getIndexOf(node: head, x: x)
      if node != 0 {
        return storage[node].key!
      }
      fatalError("Index \(x) out of range in structure of size \(size)")
    }
    mutating set(value) {
      if head == 0 && x == 0 {
        insert(value, at: 0)
        return
      }
      if head == 0 || x >= size {
        fatalError("Index \(x) out of range in structure of size \(size)")
      }
      setAtIndex(node: head, x: x, value: value)
    }
  }

  @inlinable
  @inline(__always)
  public init() {
    var implicitNode = TreeNode()
    implicitNode.depth = 0
    storage = Storage.allocate(capacity: 128)
    storageHeader.capacity = 128
    storage[0] = implicitNode
  }

  @inlinable
  @inline(__always)
  public init(_ content: [Element]) {
    self.init()
    requireAvailable(elements: content.capacity)
    for i in content {
      append(i)
    }
  }

  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init()
    requireAvailable(elements: elements.capacity)
    for i in elements {
      append(i)
    }
  }

  @inlinable
  @inline(__always)
  public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
    self.init()
    for i in elements {
      append(i)
    }
  }

  @inlinable
  @inline(__always)
  var array: [Element] {
    var result = [Element]()
    result.reserveCapacity(Int(size))
    for i in self {
      result.append(i)
    }
    return result
  }
}
