//
//  DetailedBookView.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit
import RealmSwift

/**
 Launcher object that handles opening/closing a DetailedBookView.
 - bookTableView: Defines the associated table view.
 - searchVC: Defines whether the associated tableview is the wishlist or search list. Provides reference to SearchVC to reinstantiate values as necessary.
 */
class DetailedBookViewPresenter: NSObject {
    // MARK: VIEWMODEL
    private var viewModel: DetailedBookViewModel!
    
    // MARK: VIEWS
    ///Reference to the table view in which the launcher lives.
    private let bookTableView: UITableView
    
    ///Reference to searchVC to reinstantiate values to prevent failure from edge case where user adds, deletes, and re-adds book on searchVC. Also used to check if the book was presented from wishlist.
    private let searchVC: SearchVC?

    ///Black background that fades in to hide views behind the opened DetailedBookView.
    private var blackBackgroundView: UIView!
    
    ///The Detailed Book View of any book that is selected in the table view where this launcher lives.
    private var openedDetailedBookView: DetailedBookView!
    
    ///Reference to book image view in tableview for transition animation purposes.
    private var selectedImageView: UIImageView!
    
    ///Reference to book image shadow in tableview for transition animation purposes.
    private var selectedImageShadow: RoundShadowView!
    
    // MARK: VIEW PROPERTIES
    ///Initial frame of book view in the tableview superposed onto keyWindow.
    private var viewStartingFrame: CGRect!
    
    //Must deactivate these constraints for openedDetailedBookView when scaling back down.
    private var bookViewRightAnchor: NSLayoutConstraint!
    private var bookViewBottomAnchor: NSLayoutConstraint!
    private var bookViewTopAnchor: NSLayoutConstraint!
    private var bookViewLeftAnchor: NSLayoutConstraint!
    
    
    // MARK: INIT
    init(bookTableView: UITableView, searchVC: SearchVC?) {
        self.bookTableView = bookTableView
        self.searchVC = searchVC
    }
    
    // MARK: USER INPUT ACTIONS
    ///Main launcher action. Creates a DetailedBookView and animates onto screen.
    func openDetailedViewFor(selectedBook: BookObject, selectedImageView: UIImageView, selectedImageShadow: RoundShadowView, selectedBookIndex: IndexPath) {
        if let keyWindow = UIApplication.shared.keyWindow {
            
            viewModel = DetailedBookViewModel(book: selectedBook, bookCover: selectedImageView.image, searchVC: self.searchVC, bookTableView: self.bookTableView, indexInTable: selectedBookIndex)
            
            //Calculate & save starting frame. Create DetailedBookView.
            if let startingFrame = selectedImageView.superview?.convert(selectedImageView.frame, to: nil) {
                viewStartingFrame = startingFrame
                openedDetailedBookView = DetailedBookView(frame: viewStartingFrame, initialCornerRadius: selectedImageView.layer.cornerRadius, presenterReference: self, detailedBookViewModel: viewModel)
                openedDetailedBookView.layer.cornerRadius = selectedImageView.layer.cornerRadius
                openedDetailedBookView.clipsToBounds = true
            } else {return}
            
            //Save all references.
            self.selectedImageView = selectedImageView
            self.selectedImageShadow = selectedImageShadow
            
            //Hide views in table view for smoother animation.
            self.selectedImageView.isHidden = true
            self.selectedImageShadow.isHidden = true
            
            //Create black background.
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeDetailedView)))
            keyWindow.addSubview(blackBackgroundView!)
            
            //Add DetailedBookView
            keyWindow.addSubview(openedDetailedBookView)
            
            //Determine left/right margin of DetailedBookView for when fully expanded.
            let xMargin: CGFloat = keyWindow.frame.width*0.05
            
            //Perform animations necessary for subviews within DetailedBookView
            openedDetailedBookView.expandView()
            
            //Update/animate DetailedBookView by setting constraints and performing layout.
            openedDetailedBookView.translatesAutoresizingMaskIntoConstraints = false
            bookViewLeftAnchor = openedDetailedBookView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: xMargin)
            bookViewTopAnchor = openedDetailedBookView.topAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.topAnchor, constant: 40)
            bookViewRightAnchor = openedDetailedBookView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: -xMargin)
            bookViewBottomAnchor = openedDetailedBookView.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            
            bookViewLeftAnchor.isActive = true
            bookViewTopAnchor.isActive = true
            bookViewRightAnchor.isActive = true
            bookViewBottomAnchor.isActive = true
            
            //Animation with corresponding properties.
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                keyWindow.layoutIfNeeded()
            })
            
            //Perform additional simple animations.
            UIView.animate(withDuration: 0.25, animations: {
                self.blackBackgroundView?.alpha = 0.5
                self.openedDetailedBookView.layer.cornerRadius = xMargin
            })
        }
    }
    
    ///Action to be performed when the DetailedBookView is closed. This includes animations, removeFromSuperview, and property reset actions.
    @objc func closeDetailedView() {
        if let keyWindow = UIApplication.shared.keyWindow {
            //Disabler user interaction to prevent weird UI bugs
            self.openedDetailedBookView.isUserInteractionEnabled = false
            
            //Must deactivate these anchors when scaling back down.
            bookViewLeftAnchor.isActive = false
            bookViewTopAnchor.isActive = false
            bookViewBottomAnchor.isActive = false
            bookViewRightAnchor.isActive = false
            
            self.openedDetailedBookView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: self.viewStartingFrame.origin.x).isActive = true
            self.openedDetailedBookView.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: self.viewStartingFrame.origin.y).isActive = true
            self.openedDetailedBookView.heightAnchor.constraint(equalToConstant: self.viewStartingFrame.height).isActive = true
            self.openedDetailedBookView.widthAnchor.constraint(equalToConstant: self.viewStartingFrame.width).isActive = true
            
            //Perform necessary animations within subviews of DetailedBookView.
            self.openedDetailedBookView.shrinkView()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.blackBackgroundView?.alpha = 0.0
                self.openedDetailedBookView.layer.cornerRadius = self.selectedImageView.layer.cornerRadius
                keyWindow.layoutIfNeeded()
            }, completion: { complete in
                self.viewModel.updateWishlist()
                
                //Necessary for smooth animation.
                self.selectedImageView.isHidden = false
                self.selectedImageShadow.isHidden = false
                
                //Remove main views from superview before reset.
                self.openedDetailedBookView.removeFromSuperview()
                self.blackBackgroundView?.removeFromSuperview()
                
                //Property reset.
                self.openedDetailedBookView = nil
                self.blackBackgroundView = nil
                self.selectedImageView = nil
                self.selectedImageShadow = nil
                self.bookViewBottomAnchor = nil
                self.bookViewRightAnchor = nil
                self.viewStartingFrame = nil
                self.viewModel = nil
            })
        }
    }
}
