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

import CollectionsTestSupport
@_spi(Testing) @testable import SortedCollections

final class SortedDictionaryTests: CollectionTestCase {
  func test_keysAndValues() {
    withEvery("count", in: [0, 1, 2, 4, 8, 16, 32, 64, 128, 1024, 4096]) { count in
      let kvs = (0..<count).map { (key: $0, value: $0) }
      let sortedDictionary = SortedDictionary<Int, Int>(keysWithValues: kvs)
      expectEqual(sortedDictionary.count, count)
    }
  }
  
  func test_orderedInsertion() {
    withEvery("count", in: [0, 1, 2, 3, 4, 8, 16, 64]) { count in
      var sortedDictionary: SortedDictionary<Int, Int> = [:]
      
      for i in 0..<count {
        sortedDictionary[i] = i * 2
      }
      
      expectEqual(sortedDictionary.count, count)
      expectEqual(sortedDictionary.underestimatedCount, count)
      expectEqual(sortedDictionary.isEmpty, count == 0)
      
      for i in 0..<count {
        expectEqual(sortedDictionary[i], i * 2)
      }
    }
  }
  
  func test_reversedInsertion() {
    withEvery("count", in: [0, 1, 2, 3, 4, 8, 16, 64]) { count in
      var sortedDictionary: SortedDictionary<Int, Int> = [:]
      
      for i in (0..<count).reversed() {
        sortedDictionary[i] = i * 2
      }
      
      expectEqual(sortedDictionary.count, count)
      expectEqual(sortedDictionary.underestimatedCount, count)
      expectEqual(sortedDictionary.isEmpty, count == 0)
      
      for i in 0..<count {
        expectEqual(sortedDictionary[i], i * 2)
      }
    }
  }
  
  func test_arbitraryInsertion() {
    withEvery("count", in: [0, 1, 2, 3, 4, 8, 16, 64]) { count in
      for i in 0...count {
        let kvs = (0..<count).map { (key: $0 * 2 + 1, value: $0) }
        var sortedDictionary = SortedDictionary<Int, Int>(keysWithValues: kvs)
        sortedDictionary[i * 2] = -i
        
        var comparison = Array(kvs)
        comparison.insert((key: i * 2, value: -i), at: i)
        
        expectEqualElements(comparison, sortedDictionary)
      }
    }
  }
  
  func test_updateValue() {
    withEvery("count", in: [1, 2, 4, 8, 16, 32, 64, 512]) { count in
      var sortedDictionary: SortedDictionary<Int, Int> = [:]
      
      for i in 0..<count {
        sortedDictionary[i] = i
        sortedDictionary[i] = -sortedDictionary[i]!
      }
      
      for i in 0..<count {
        expectEqual(sortedDictionary[i], -i)
      }
    }
  }
  
  func test_modifySubscriptRemoval() {
    func modify(_ value: inout Int?, setTo newValue: Int?) {
      value = newValue
    }
    
    withEvery("count", in: [1, 2, 4, 8, 16, 32, 64, 512]) { count in
      let kvs = (0..<count).map { (key: $0, value: -$0) }
      
      withEvery("key", in: 0..<count) { key in
        var d = SortedDictionary<Int, Int>(keysWithValues: kvs)
        
        withEvery("isShared", in: [false, true]) { isShared in
          withHiddenCopies(if: isShared, of: &d) { d in
            modify(&d[key], setTo: nil)
            var comparisonKeys = Array(0..<count)
            comparisonKeys.remove(at: key)
          
            expectEqual(d.count, count - 1)
            expectEqualElements(d.map { $0.key }, comparisonKeys)
          }
        }
      }
    }
  }
  
  func test_modifySubscriptInsertUpdate() {
    func modify(_ value: inout Int?, setTo newValue: Int?) {
      value = newValue
    }

    withEvery("count", in: [1, 2, 4, 8, 16, 32, 64, 512]) { count in
      withEvery("isShared", in: [false, true]) { isShared in
        var d: SortedDictionary<Int, Int> = [:]

        withHiddenCopies(if: isShared, of: &d) { d in
          for i in 0..<count {
            modify(&d[i], setTo: i)
            modify(&d[i], setTo: -i)
          }

          for i in 0..<count {
            expectEqual(d[i], -i)
          }
        }
      }
    }
  }
}
