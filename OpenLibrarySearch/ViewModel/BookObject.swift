//
//  New Book.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

/**
 View model used to store book info locally and provide view data.
 - bookDTO: Data transfer object of decoded JSON results.
 */
class BookObject: Object, Decodable {
    @objc dynamic var key: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var authorLabelText: String = ""
    @objc dynamic var additionalInfoText: String = ""
    @objc dynamic var language: String = ""
    @objc dynamic var cover_i: String? = nil
    @objc dynamic var publisher: String? = nil
    @objc dynamic var isWishlisted: Bool = false
    @objc dynamic var has_fulltext: Bool = false
    @objc dynamic var goodreadsAvailable: Bool = false
    let subject = List<String>()
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    convenience init(bookDTO: BookDTO) {
        self.init()
        
        self.key = bookDTO.key! //Per OpenLibrary API key is always available
        self.title = bookDTO.title ?? "Unknown title"
        
        // MARK: authorLabelText init
        var authorLabelText: String = "By "
        
        let bookAuthors: [String] = bookDTO.author_name ?? ["Unknown author"]
        
        for (index, author) in bookAuthors.enumerated() {
            if index == 0 {
                authorLabelText = authorLabelText + author
            }
            else if index == (bookAuthors.count - 1) {
                authorLabelText = authorLabelText + " and " + author
            }
            else {
                authorLabelText = authorLabelText + ", " + author
            }
        }
        self.authorLabelText = authorLabelText
        
        // MARK: additionalInfoText init
        var additionalInfoText: String = ""
        
        let editionCount: Int = bookDTO.edition_count ?? 1
        
        if editionCount != 1 {
            additionalInfoText = "\(editionCount)" + " editions"
        } else {
            additionalInfoText = "1 edition"
        }
        
        if let year: Int = bookDTO.first_publish_year {
            additionalInfoText = additionalInfoText + " - first published " + "\(year)"
        }
        
        self.additionalInfoText = additionalInfoText
        
        // MARK: cover_i init
        if let cover_i: Int = bookDTO.cover_i {
            self.cover_i = "\(cover_i)"
        }

        // MARK: has_fulltext init
        self.has_fulltext = bookDTO.has_fulltext ?? false
        
        // MARK: isWishlisted init
        let realm = try! Realm()
        if realm.object(ofType: BookObject.self, forPrimaryKey: bookDTO.key!) != nil {
            self.isWishlisted = true
        }
        
        // MARK: language init
        if let languages = bookDTO.language {
            if !languages.isEmpty {
                if languages.contains("eng") { //API entries are in lowercase
                    self.language = "ENG"
                } else {
                    self.language = languages.first!.uppercased()
                }
            } else {self.language = "ENG"} //Assume english per OpenLibrary API
        }
        
        // MARK: publisher init
        if let validPublisher = bookDTO.publisher {
            if !validPublisher.isEmpty {
                self.publisher = validPublisher.first
            }
        }
        
        // MARK: goodreadsAvailable init
        if let validGoodreads = bookDTO.id_goodreads {
            if !validGoodreads.isEmpty {
                self.goodreadsAvailable = true
            }
        }
        
        // MARK: subjects init
        if let validSubjects = bookDTO.subject {
            self.subject.append(objectsIn: validSubjects)
        }
    }
    
    ///Generates views used to display additional details in DetailedBookView.
    func generateInfoStackViews() -> [ExtraInfoView] {
        var views: [ExtraInfoView] = []
        
        if let validPublisher = publisher {
            let publisherView: SimpleDetailView = SimpleDetailView(titleString: "PUBLISHER", infoText: validPublisher)
            views.append(publisherView)
        }
        
        let languageView: EmphasizedDetailView = EmphasizedDetailView(titleString: "LANGUAGE", infoText: language)
        views.append(languageView)
        
        //Add full text availability indicator
        let fullTextInfoView: BoolDetailView = BoolDetailView(titleString: "FULL TEXT", showCheck: has_fulltext)
        views.append(fullTextInfoView)
        
        //Add goodreads availability indicator
        let goodreadsInfoView: BoolDetailView = BoolDetailView(titleString: "GOODREADS", showCheck: goodreadsAvailable)
        views.append(goodreadsInfoView)
        
        return views
    }
}
