//
//  BoolDetailView.swift
//  Library
//
//  Created by Ever Uribe on 8/10/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

///Used to display a checkmark or x to represent boolean value.
class BoolDetailView: ExtraInfoView {
    
    ///Image view displaying checkmark or x.
    private let boolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }()
    
    init(frame: CGRect = .zero, titleString: String, showCheck: Bool) {
        super.init(frame: frame, titleString: titleString)
        
        //Determine which image to display. 
        if showCheck {
            boolImageView.image = UIImage(named: "error")
        }
        else {
            boolImageView.image = UIImage(named: "success")
        }
        
        infoContainerView.addSubview(boolImageView)
        
        boolImageView.centerYAnchor.constraint(equalTo: infoContainerView.centerYAnchor).isActive = true
        boolImageView.centerXAnchor.constraint(equalTo: infoContainerView.centerXAnchor).isActive = true
        boolImageView.widthAnchor.constraint(equalTo: infoContainerView.widthAnchor, multiplier: 0.3).isActive = true
        boolImageView.heightAnchor.constraint(equalTo: infoContainerView.widthAnchor, multiplier: 0.3).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
