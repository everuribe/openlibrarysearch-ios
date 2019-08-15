//
//  MainSearchBar.swift
//  CornerBlocRefactor
//
//  Created by Ever Uribe on 5/24/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//
import UIKit

class SearchBar: UITextField {
    
    var searchTextColor: UIColor = UIColor.white
    
    override func draw(_ rect: CGRect) {
        textColor = searchTextColor
        backgroundColor = UIColor.clear// UIColor.red //UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        leftViewMode = UITextField.ViewMode.always
        
        let padding = 8
        
        ///Size of the search icon image
        let size = 15
        
        //Create an outer view with padding and then add the left view image for the search bar
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        iconView.image = UIImage(named: "search")
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
    
    init(frame: CGRect, customTextColor: UIColor, customPlaceholder: NSAttributedString) {
        super.init(frame: frame)
        
        attributedPlaceholder = customPlaceholder
        searchTextColor = customTextColor
        textColor = searchTextColor
        font = UIFont.systemFont(ofSize: 16.0)
        
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


