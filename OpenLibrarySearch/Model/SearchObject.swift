//
//  SearchObject.swift
//  Library
//
//  Created by Ever Uribe on 8/13/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation

struct SearchObject: Decodable {
    let start: Int?
    let num_found: Int?
    let docs: [BookDTO]
}
