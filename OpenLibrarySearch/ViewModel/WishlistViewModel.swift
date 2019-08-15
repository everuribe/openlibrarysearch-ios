//
//  WishlistViewModel.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

/// Handles wishlist view functions. References Realm-persisted local database. 
class WishlistViewModel {
    var books: Results<BookObject>
    
    init() {
        let realm = try! Realm()
        self.books = realm.objects(BookObject.self)
    }
    
    ///Checks if savedBooks is empty and outputs corresponding background image.
    func setBackgroundImage() -> UIImage? {
        if books.isEmpty {
            return UIImage(named: "emptyWishlist")
        } else {return nil}
    }
    
    ///Deletes book at given index.
    func deleteBookAt(index: Int) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self.books[index])
        }
    }
}
