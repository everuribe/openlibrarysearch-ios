//
//  EmphasizeDetailView.swift
//  Library
//
//  Created by Ever Uribe on 8/10/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

///Displays large text value (ie to represent language)
class EmphasizedDetailView: ExtraInfoView {
    
    ///Label displaying large text.
    let infoLabel: UILabel = {
        let textView = UILabel()
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        return textView
    }()
    
    init(frame: CGRect = .zero, titleString: String, infoText: String) {
        super.init(frame: frame, titleString: titleString)
        
        infoLabel.text = infoText
        infoContainerView.addSubview(infoLabel)
        
        infoLabel.leftAnchor.constraint(equalTo: infoContainerView.leftAnchor).isActive = true
        infoLabel.rightAnchor.constraint(equalTo: infoContainerView.rightAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
