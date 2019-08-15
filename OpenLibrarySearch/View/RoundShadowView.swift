//
//  ShadowedView.swift
//  Library
//
//  Created by Ever Uribe on 8/9/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

///View that acts as a basic drop shadow when placed behind another view.
class RoundShadowView: UIView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = bounds.height*0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
