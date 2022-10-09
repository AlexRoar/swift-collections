//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension PersistentSet {
  /// Returns a Boolean value that indicates whether the set has no members in
  /// common with the given set.
  ///
  ///     let a: PersistentSet = [1, 2, 3, 4]
  ///     let b: PersistentSet = [5, 6]
  ///     a.isDisjoint(with: b) // true
  ///
  /// - Parameter other: Another set.
  ///
  /// - Returns: `true` if `self` has no elements in common with `other`;
  ///   otherwise, `false`.
  ///
  /// - Complexity: Expected to be O(min(`self.count`, `other.count`)) on
  ///    average, if `Element` implements high-quality hashing.
  @inlinable
  public func isDisjoint(with other: Self) -> Bool {
    self._root.isDisjoint(.top, with: other._root)
  }

  /// Returns a Boolean value that indicates whether the set has no members in
  /// common with the given set.
  ///
  ///     let a: PersistentSet = [1, 2, 3, 4]
  ///     let b: PersistentSet = [5, 6]
  ///     a.isDisjoint(with: b) // true
  ///
  /// - Parameter other: The keys view of a persistent dictionary.
  ///
  /// - Returns: `true` if `self` has no elements in common with `other`;
  ///   otherwise, `false`.
  ///
  /// - Complexity: Expected to be O(min(`self.count`, `other.count`)) on
  ///    average, if `Element` implements high-quality hashing.
 @inlinable
  public func isDisjoint<Value>(
    with other: PersistentDictionary<Element, Value>.Keys
  ) -> Bool {
    self._root.isDisjoint(.top, with: other._base._root)
  }

  /// Returns a Boolean value that indicates whether the set has no members in
  /// common with the given set.
  ///
  ///     let a: PersistentSet = [1, 2, 3, 4]
  ///     let b: PersistentSet = [5, 6]
  ///     a.isDisjoint(with: b) // true
  ///
  /// - Parameter other: A sequence of elements, some of whose elements may
  ///    appear more than once.
  ///
  /// - Returns: `true` if `self` has no elements in common with `other`;
  ///   otherwise, `false`.
  ///
  /// - Complexity: In the worst case, this makes O(*n*) calls to
  ///    `self.contains`, where *n* is the length of the sequence.
  @inlinable
  public func isDisjoint<S: Sequence>(with other: S) -> Bool
  where S.Element == Element
  {
    if S.self == Self.self {
      return isDisjoint(with: other as! Self)
    }
    return other.allSatisfy { !self.contains($0) }
  }
}
