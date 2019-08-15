//
//  BookDocumentDTO.swift
//  Library
//
//  Created by Ever Uribe on 8/13/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation

///Data transfer object model for decoded JSON results.
struct BookDTO: Decodable {
    let title: String?
    let author_name: [String]?
    let publisher: [String]?
    let first_publish_year: Int?
    let cover_i: Int?
    let key: String?
    let id_goodreads: [String]?
    let has_fulltext: Bool?
    let subject: [String]?
    let language: [String]?
    let edition_count: Int?
}
