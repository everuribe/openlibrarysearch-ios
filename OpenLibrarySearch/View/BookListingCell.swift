//  Library
//
//  Created by Ever Uribe on 8/13/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit
import RealmSwift

class BookListingCell: UITableViewCell {
    // MARK: VIEWMODEL
    var book: BookObject! {
        didSet {
            setViewData()
        }
    }

    // MARK: VIEWS
    ///Contains all textual info views of the cell.
    private let infoContainerView: UIView = UIView()
    
    private  let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Book Title..."
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()
    
    private  let authorLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Author Name..."
        label.font = .systemFont(ofSize: 14)
        return label
        }()
    
    private  let additionalInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Additional Info..."
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        return imageView
    }()
    
    let wishlistedIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "wishlist_selected")
        imageView.isHidden = true
        return imageView
    }()
    
    let imageShadow: RoundShadowView = RoundShadowView()
    
    // MARK: VIEW PROPERTIES
    private let imageHeight: CGFloat = 88
    private let imageWidth: CGFloat = 63.8
    private let customBorderHeight: CGFloat = 0.5
    
    // MARK: INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = backgroundGray

        setupViews()
    }
    
    // VIEW SETUP
    ///Uses book data to population views.
    private func setViewData(){
        titleLabel.text = book.title
        authorLabel.text = book.authorLabelText
        additionalInfoLabel.text = book.additionalInfoText
        wishlistedIcon.isHidden = !book.isWishlisted
        coverImageView.fetchCoverImage(coverID: book.cover_i)
    }
    
    private func setupViews() {
        let xMargin: CGFloat = self.frame.width*0.05
        
        //add custom border since super.layoutSubviews() is not called and prefer customized border
        let customBorder: UIView = UIView(frame: .zero)
        customBorder.backgroundColor = .rgb(216, green: 216, blue: 216)
        
        //add views
        self.addSubview(imageShadow)
        self.addSubview(coverImageView)
        self.addSubview(customBorder)
        self.addSubview(infoContainerView)
        self.addSubview(wishlistedIcon)
        infoContainerView.addSubview(titleLabel)
        infoContainerView.addSubview(authorLabel)
        infoContainerView.addSubview(additionalInfoLabel)
        
        //turn on autolayout
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        imageShadow.translatesAutoresizingMaskIntoConstraints = false
        customBorder.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        wishlistedIcon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //x,y,w,h
        coverImageView.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: (xMargin + imageWidth/2)).isActive = true
        coverImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        coverImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        coverImageView.layer.cornerRadius = imageHeight*0.05
        
        imageShadow.leftAnchor.constraint(equalTo: self.coverImageView.leftAnchor).isActive = true
        imageShadow.rightAnchor.constraint(equalTo: self.coverImageView.rightAnchor).isActive = true
        imageShadow.topAnchor.constraint(equalTo: self.coverImageView.topAnchor).isActive = true
        imageShadow.bottomAnchor.constraint(equalTo: self.coverImageView.bottomAnchor).isActive = true
        
        titleLabel.sizeToFit()
        authorLabel.sizeToFit()
        additionalInfoLabel.sizeToFit()
        
        titleLabel.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: infoContainerView.widthAnchor).isActive = true
        
        authorLabel.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor).isActive = true
        authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        authorLabel.widthAnchor.constraint(equalTo: infoContainerView.widthAnchor).isActive = true
        
        additionalInfoLabel.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor).isActive = true
        additionalInfoLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5).isActive = true
        additionalInfoLabel.widthAnchor.constraint(equalTo: infoContainerView.widthAnchor).isActive = true
        
        infoContainerView.sizeToFit()
        
        infoContainerView.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: xMargin).isActive = true
        infoContainerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -xMargin*2).isActive = true
        infoContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        infoContainerView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, constant: authorLabel.frame.height + additionalInfoLabel.frame.height + 10).isActive = true
        
        wishlistedIcon.leftAnchor.constraint(equalTo: infoContainerView.rightAnchor, constant: xMargin/2).isActive = true
        wishlistedIcon.widthAnchor.constraint(equalToConstant: xMargin).isActive = true
        wishlistedIcon.heightAnchor.constraint(equalToConstant: xMargin).isActive = true
        wishlistedIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: xMargin).isActive = true
        
        customBorder.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor).isActive = true
        customBorder.rightAnchor.constraint(equalTo: infoContainerView.rightAnchor).isActive = true
        customBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        customBorder.heightAnchor.constraint(equalToConstant: customBorderHeight).isActive = true
    }
    
    // MARK: MISC
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
