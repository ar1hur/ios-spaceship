//
//  PhysicsCategories.swift
//  game1
//
//  Created by Arthur on 31.08.18.
//  Copyright © 2018 AZ. All rights reserved.
//

import Foundation

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let rocketCategory: UInt32 = 0x1             // 01
    static let asteroidCategory: UInt32 = 0x1 << 1      // 10
    static let bottomCategory: UInt32 = 0x1 << 2
}
