//
//  DetailedBookView.swift
//  Library
//
//  Created by Ever Uribe on 8/10/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

class DetailedBookView: UIView {
    // MARK: VIEWMODEL
    var viewModel: DetailedBookViewModel
    
    // MARK: DETAILEDBOOKVIEW PRESENTER
    ///Reference to presenter to handle close actions.
    private let presenterReference: DetailedBookViewPresenter
    
    // MARK: VIEWS
    ///Used to display book cover.
    private let imageView: UIImageView = UIImageView()
    
    ///Shadow for imageView.
    private let imageShadow: RoundShadowView = RoundShadowView()
    
    ///Stack view used to present additional details of book using ExtraInfoView.
    private var infoStackView: UIStackView!
    
    ///Array of views to be displayed in infoStackView.
    private var additionalDetailViews: [ExtraInfoView] = [ExtraInfoView]()
    
    ///Button used to close DetailedBookView and perform any actions necessary.
    private let closeButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    ///Label of book title.
    private let titleLabel: UITextView = {
        let label = UITextView()
        label.text = "Loading Book Title..."
        label.isScrollEnabled = false
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    ///Label of author.
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Author Name..."
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    ///Label with edition/published year info.
    private let additionalInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Additional Info..."
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    ///Button to save/remove book from wishlist.
    private let wishlistButton: UIButton = {
        let button: UIButton = UIButton()
        button.addTarget(self, action: #selector(handleWishlistAction), for: .touchUpInside)
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.layer.borderWidth = 1.5
        return button
    }()
    
    ///View containing all book info below cover image.
    private let infoContainerView: UIView = UIView()
    
    // MARK: VIEW PROPERTIES
    ///Scale of width/height for book image.
    private let imageFormFactor: CGFloat = 0.725
    
    ///Left/right margin of subviews.
    private let xMargin: CGFloat = 15
    
    ///Height of closeButton.
    private let buttonHeight: CGFloat = 50
    
    ///Corner radius used for animation of book view.
    private let initialCornerRadius: CGFloat
    
    //Must deactivate these anchors when scaling back down.
    private var imageHeightConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!
    private var imageTopConstraint: NSLayoutConstraint!
    private var imageCenterXConstraint: NSLayoutConstraint!
    
    // MARK: INIT
    init(frame: CGRect, initialCornerRadius: CGFloat, presenterReference: DetailedBookViewPresenter, detailedBookViewModel: DetailedBookViewModel) {
        self.viewModel = detailedBookViewModel
        self.initialCornerRadius = initialCornerRadius
        self.presenterReference = presenterReference
        
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setViewData()
        setupViews()
    }
    
    // MARK: VIEW SETUP
    ///Uses book data to population views.
    private func setViewData(){
        imageView.image = viewModel.bookCover
        titleLabel.text = viewModel.book.title
        authorLabel.text = viewModel.book.authorLabelText
        additionalInfoLabel.text = viewModel.book.additionalInfoText
        additionalDetailViews = viewModel.book.generateInfoStackViews()
        toggleButton(setToSave: !viewModel.book.isWishlisted)
    }
    
    ///Sets up the view and its subviews.
    private func setupViews() {
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageShadow.frame = imageView.frame
        imageShadow.alpha = 0
        
        infoContainerView.clipsToBounds = true
        infoContainerView.alpha = 0

        wishlistButton.layer.cornerRadius = buttonHeight*0.2
        
        addSubview(scrollView)
        addSubview(closeButton)
        scrollView.addSubview(infoContainerView)
        scrollView.addSubview(imageView)
        
        scrollView.insertSubview(imageShadow, belowSubview: imageView)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        wishlistButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: xMargin).isActive = true
        closeButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: xMargin).isActive = true
        closeButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.025).isActive = true
        closeButton.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.025).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        infoContainerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
        infoContainerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        infoContainerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        titleLabel.sizeToFit()
        authorLabel.sizeToFit()
        additionalInfoLabel.sizeToFit()
        
        infoContainerView.addSubview(titleLabel)
        infoContainerView.addSubview(authorLabel)
        infoContainerView.addSubview(additionalInfoLabel)
        infoContainerView.addSubview(wishlistButton)
        
        titleLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor, constant: xMargin).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: infoContainerView.rightAnchor, constant: -xMargin).isActive = true
        
        authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        authorLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        authorLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
        
        additionalInfoLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8).isActive = true
        additionalInfoLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        additionalInfoLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
        
        wishlistButton.topAnchor.constraint(equalTo: additionalInfoLabel.bottomAnchor, constant: 20).isActive = true
        wishlistButton.widthAnchor.constraint(equalTo: infoContainerView.widthAnchor, multiplier: 0.7).isActive = true
        wishlistButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        wishlistButton.centerXAnchor.constraint(equalTo: infoContainerView.centerXAnchor).isActive = true
        
        setupInfoStackView()
        
        infoContainerView.bottomAnchor.constraint(equalTo: self.infoStackView.bottomAnchor, constant: 20).isActive = true
    }
    
    ///Sets up infoStackView.
    private func setupInfoStackView() {
        for (index, view) in additionalDetailViews.enumerated() {
            if index != 0 {
                view.leftBorder.isHidden = false
            }
        }
        
        infoStackView = UIStackView(arrangedSubviews: additionalDetailViews)
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .horizontal
        infoStackView.distribution = .fillEqually
        infoStackView.alignment = .fill
        
        infoContainerView.addSubview(infoStackView)
        
        infoStackView.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor, constant: xMargin).isActive = true
        infoStackView.rightAnchor.constraint(equalTo: infoContainerView.rightAnchor, constant: -xMargin).isActive = true
        infoStackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        infoStackView.topAnchor.constraint(equalTo: wishlistButton.bottomAnchor, constant: 20).isActive = true
    }
    
    // MARK: VIEW ANIMATIONS
    ///Handles expansion of views when DetailedBookView is first opened.
    func expandView(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.5)
        imageWidthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageFormFactor)
        imageTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30)
        imageCenterXConstraint = imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        
        imageHeightConstraint.isActive = true
        imageWidthConstraint.isActive = true
        imageTopConstraint.isActive = true
        imageCenterXConstraint.isActive = true
        
        imageShadow.translatesAutoresizingMaskIntoConstraints = false
        imageShadow.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        imageShadow.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
        imageShadow.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        imageShadow.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.imageView.layer.cornerRadius = self.imageView.frame.height*0.2
            self.infoContainerView.alpha = 1
        }, completion: { complete in
            self.scrollView.contentSize.height = self.infoContainerView.frame.origin.y + self.infoContainerView.frame.height
            self.imageShadow.alpha = 1
            self.closeButton.isHidden = false
        })
    }
    
    ///Handles shrinking of views when DetailedBookView is closed.
    func shrinkView(){
        imageHeightConstraint.isActive = false
        imageWidthConstraint.isActive = false
        imageTopConstraint.isActive = false
        imageCenterXConstraint.isActive = false
        
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        self.scrollView.isScrollEnabled = false //disabled to prevent weird UI bugs in case user interaction is enabled
        self.infoContainerView.alpha = 0
        self.closeButton.isHidden = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.imageView.layer.cornerRadius = self.initialCornerRadius
        })
    }
    
    // MARK: USER INPUT ACTIONS
    @objc private func handleClose() {
        presenterReference.closeDetailedView()
    }
    
    @objc private func handleWishlistAction(){
        toggleButton(setToSave: viewModel.toggleWishlistStatusAndSetButtonSave())
    }
    
    ///Updates button to correspond with adding/removing from wishlist
    private func toggleButton(setToSave: Bool){
        if setToSave {
            wishlistButton.setTitle("Add to Wishlist", for: .normal)
            wishlistButton.layer.borderColor = UIColor.rgb(74, green: 144, blue: 226).cgColor
            wishlistButton.setTitleColor(.rgb(74, green: 144, blue: 226), for: .normal)
        } else {
            wishlistButton.setTitle("Remove from Wishlist", for: .normal)
            wishlistButton.layer.borderColor = UIColor.rgb(218, green: 19, blue: 19).cgColor
            wishlistButton.setTitleColor(.rgb(218, green: 19, blue: 19), for: .normal)
        }
    }
    
    // MARK: MISC
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
