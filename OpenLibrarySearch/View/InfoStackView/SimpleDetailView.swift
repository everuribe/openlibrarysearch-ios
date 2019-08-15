//
//  SimpleDetailView.swift
//  Library
//
//  Created by Ever Uribe on 8/10/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

///Displays simple text value as additional info.
class SimpleDetailView: ExtraInfoView {
    
    let infoLabel: UILabel = {
        let textView = UILabel()
        textView.font = UIFont.systemFont(ofSize: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.numberOfLines = 0
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
