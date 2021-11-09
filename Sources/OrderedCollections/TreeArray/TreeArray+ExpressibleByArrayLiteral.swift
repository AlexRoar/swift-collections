//
//  File.swift
//
//
//  Created by  Alex Dremov on 13.11.2021.
//

import Foundation

extension TreeArray: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = Element

  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    // TODO: O(n) solution exists
    for i in elements {
      append(i)
    }
  }

}
