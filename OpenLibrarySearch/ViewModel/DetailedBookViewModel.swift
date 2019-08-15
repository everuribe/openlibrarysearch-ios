//
//  DetailedBookViewModel.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

/**
 Handles wishlist local database update and button toggling for DetailedBookView.
 - book: Selected book object. Used to add to wishlist + reference to key and isOnWishlist properties.
 - bookCover: Cover of book. Used to add/remove to cache if wishlisted.
 - searchVC: Defines whether the associated tableview is the wishlist or search list. Provides reference to SearchVC to reinstantiate values as necessary.
 - bookTableView: Defines the associated table view.
 - indexInTable: Selected book object index in bookTableView.
 */
class DetailedBookViewModel {
    let book: BookObject
    let bookCover: UIImage
    
    ///Reference to searchVC to reinstantiate values to prevent failure from edge case where user adds, deletes, and re-adds book on searchVC. Also used to check if the book was presented from wishlist.
    private let searchVC: SearchVC?
    
    ///Reference to the table view in which the launcher lives.
    private let bookTableView: UITableView
    
    ///Reference to book index in tableview/data array in case that user selects to remove from wishlist.
    private var indexInTable: IndexPath!
    
    ///Determines action to take on book wishlist status once view is closed.
    var changedWishlistStatus: Bool = false
    
    init(book: BookObject, bookCover: UIImage?, searchVC: SearchVC?, bookTableView: UITableView, indexInTable: IndexPath) {
        self.book = book
        self.bookCover = bookCover ?? UIImage(named: "noCover")!
        self.searchVC = searchVC
        self.bookTableView = bookTableView
        self.indexInTable = indexInTable
    }
    
    ///Toggles wishlist status and returns whether to set button to save
    func toggleWishlistStatusAndSetButtonSave() -> Bool {
        changedWishlistStatus.toggle()
        if book.isWishlisted {
            return changedWishlistStatus
        } else {
            return !changedWishlistStatus
        }
    }
    
    ///Determines if book should be added/deleted from wishlist
    func updateWishlist() {
        //Delete book from wishlist
        if book.isWishlisted && changedWishlistStatus {
            let realm = try! Realm()

            if let existingObject = realm.object(ofType: BookObject.self, forPrimaryKey: book.key) {
                try! realm.write {
                    realm.delete(existingObject)
                }
            }
            //Reinstantiate bookTableView data to prevent realm crash if the book is re-added to wishlist
            if let searchVC = self.searchVC {
                searchVC.viewModel.reinstantiateBookObjects(searchState: { (searchState) in
                    searchVC.searchState = searchState
                })
            }
            //Perform delete animation in bookTableView of wishlist
            else {
                self.bookTableView.deleteRows(at: [self.indexInTable], with: .top)
            }
        }
        //Add book to wishlist and save image to local cache
        else if !book.isWishlisted && changedWishlistStatus {
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(self.book)
                self.book.isWishlisted = true
            }
            
            if let coverID: String = book.cover_i {
                imageCache.setObject(bookCover, forKey: coverID as AnyObject)
            }
            
            //Reinstantiate bookTableView data to show book is on wishlist
            if let searchVC = self.searchVC {
                searchVC.viewModel.reinstantiateBookObjects(searchState: { (searchState) in
                    searchVC.searchState = searchState
                })
            }
        }
    }
}
