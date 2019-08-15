//
//  EmphasizeDetailView.swift
//  Library
//
//  Created by Ever Uribe on 8/10/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

class EmphasizedTextDetailView: DetailedInfoView {
    
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        return textView
    }()
    
    init(frame: CGRect, titleString: String, infoText: String) {
        super.init(frame: frame, titleString: titleString)
        
        infoTextView.text = infoText
        addSubview(infoTextView)
        
        infoTextView.leftAnchor.constraint(equalTo: self.leftBorder.rightAnchor).isActive = true
        infoTextView.rightAnchor.constraint(equalTo: self.rightBorder.leftAnchor).isActive = true
        infoTextView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2).isActive = true
        infoTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
