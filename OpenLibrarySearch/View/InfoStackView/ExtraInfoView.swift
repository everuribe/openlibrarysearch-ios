//
//  DetailedInfoView.swift
//  Library
//
//  Created by Ever Uribe on 8/10/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

class ExtraInfoView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.rgb(63, green: 63, blue: 63)
        return label
    }()
    
    let infoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let leftBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let rightBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let borderWidth: CGFloat = 0.5
    
    init(frame: CGRect, titleString: String) {
        super.init(frame: frame)
        titleLabel.text = titleString
        
        addSubview(titleLabel)
        addSubview(leftBorder)
        addSubview(rightBorder)
        addSubview(infoContainerView)
        
        titleLabel.sizeToFit()
        
        leftBorder.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        leftBorder.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        leftBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        leftBorder.widthAnchor.constraint(equalToConstant: borderWidth).isActive = true
        
        rightBorder.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        rightBorder.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        rightBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        rightBorder.widthAnchor.constraint(equalToConstant: borderWidth).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: self.leftBorder.rightAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightBorder.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        infoContainerView.leftAnchor.constraint(equalTo: self.leftBorder.rightAnchor).isActive = true
        infoContainerView.rightAnchor.constraint(equalTo: self.rightBorder.leftAnchor).isActive = true
        infoContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        infoContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
