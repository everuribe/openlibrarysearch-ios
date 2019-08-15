//
//  SearchBar.swift
//  Library
//
//  Created by Ever Uribe on 8/9/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//
import UIKit

/**
 Defines the custom search bar used in this application. Due to limitations of UISearchBar, this is subclassed from UITextField and layered with the required functionality.
- frame: A CGRect value with default of .zero. Leave this empty if using autoconstraints.
- textColor: UIColor used for user's input text.
- placeholderText: A NSAttributedString used as the placeholder text for the search bar.
*/
class SearchBar: UITextField {
    
    ///Defines the cornerRadius of the searchBar.
    let radius: CGFloat
    
    // MARK: VIEW SETUP
    init(frame: CGRect = .zero, textColor: UIColor = .black, placeholderText: NSAttributedString, height: CGFloat) {
        radius = height/2
        super.init(frame: frame)
        
        self.attributedPlaceholder = placeholderText
        
        setupViews()
    }
    
    ///Sets up the view and its subviews.
    private func setupViews() {
        self.font = UIFont.systemFont(ofSize: 18.0)
        self.textColor = textColor
        self.frame = frame
        self.backgroundColor = .rgb(225, green: 225, blue: 225)
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        leftViewMode = UITextField.ViewMode.always
        
        let padding: CGFloat = 8
        
        ///Size of the search icon image
        let size: CGFloat = 15
        
        //Create an outer view with padding and then add the left view image for the search bar
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: radius+size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: radius, y: 0, width: size, height: size))
        iconView.image = UIImage(named: "search")!.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .gray
        outerView.addSubview(iconView)
        leftView = outerView
        
        super.draw(rect)
    }
    
    func setLeftPaddingPoints(_ amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    // MARK: VIEW ANIMATION
    ///Function that animates search bar subviews when search is toggled.
    func toggleSearch(didBeganEditing: Bool) {
        if didBeganEditing {
            UIView.animate(withDuration: 0.25, animations: {
                self.leftView?.subviews[0].frame = CGRect(x: self.radius - 5, y: -2.5, width: 20, height: 20)
            })
        }
        else {
            if self.text == "" {
                UIView.animate(withDuration: 0.25, animations: {
                    self.leftView?.subviews[0].frame = CGRect(x: self.radius, y: 0, width: 15, height: 15)
                })
            }
        }
    }
    
    // MARK: MISC
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


