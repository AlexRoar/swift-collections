//
//  File.swift
//
//
//  Created by  Alex Dremov on 13.11.2021.
//

import Foundation

extension TreeArray: CustomStringConvertible {
  public var description: String {
    var out: String = "["
    for i in 0..<size {
      out += String(describing: self[i])
      if i != size - 1 {
        out += ", "
      }
    }
    out += "]"
    return out
  }
}
