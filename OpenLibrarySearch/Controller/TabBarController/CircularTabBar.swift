//
//  CircleTabBar.swift
//  Library
//
//  Created by Ever Uribe on 8/9/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

class CircularTabBar: UITabBar {
    var tabWidth: CGFloat = 85
    private var spaceBetweenTabs: CGFloat!
    
    var index: CGFloat = 0 {
        willSet{
            self.previousIndex = index
        }
    }
    private var animated = false
    private var selectedImage: UIImage?
    private var previousIndex: CGFloat = 0
    ///This is used to prevent redrawing the selected tab's bezier path
    private var isSelectedTabDrawn: Bool = false
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let tabCount: CGFloat = CGFloat(self.items?.count ?? 2)
        spaceBetweenTabs = (frame.width - (tabWidth)*tabCount)/(tabCount + 1)
        customInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    //Moves the TabBar recession curve that the circular view sits on
    override func draw(_ rect: CGRect) {
        if isSelectedTabDrawn == false {
            let fillColor: UIColor = .white
            let bezPath = drawPath(for: index)
            bezPath.close()
            fillColor.setFill()
            bezPath.fill()
            let mask = CAShapeLayer()
            mask.fillRule = .evenOdd
            mask.fillColor = UIColor.white.cgColor
            mask.path = bezPath.cgPath
            
            //Performs animation of TabBar recession curve movement
            if (self.animated) {
                let bezAnimation = CABasicAnimation(keyPath: "path")
                let bezPathFrom = drawPath(for: previousIndex)
                bezAnimation.toValue = bezPath.cgPath
                bezAnimation.fromValue = bezPathFrom.cgPath
                bezAnimation.duration = 0.3
                bezAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                mask.add(bezAnimation, forKey: nil)
            }
            self.layer.mask = mask
            
            isSelectedTabDrawn = true
        }
    }
    
    func select(itemAt: Int, animated: Bool) {
        self.index = CGFloat(itemAt)
        self.animated = animated
        self.selectedImage = self.selectedItem?.selectedImage
        isSelectedTabDrawn = false
        self.setNeedsDisplay() //This invalidates visible display and redraws
    }
    
    func customInit(){
        self.tintColor = .white //Change this to make the selected label visible
        self.barTintColor = .white
        self.backgroundColor = .white
    }
    
    //Defines curve of the button recession
    func drawPath(for index: CGFloat) -> UIBezierPath {
        let bezPath = UIBezierPath()
        
        let gapSpace: CGFloat = spaceBetweenTabs * (index + 1)
        
        let firstPoint = CGPoint(x: gapSpace + (index * tabWidth) - 25, y: 0)
        let firstPointFirstCurve = CGPoint(x: (gapSpace + (tabWidth * index) + tabWidth / 4), y: 0)
        let firstPointSecondCurve = CGPoint(x: (gapSpace + (index * tabWidth) - 25) + tabWidth / 8, y: 52)
        
        let middlePoint = CGPoint(x: gapSpace + (tabWidth * index) + tabWidth / 2, y: 55)
        let middlePointFirstCurve = CGPoint(x: gapSpace + (((tabWidth * index) + tabWidth) - tabWidth / 8) + 25, y: 52)
        let middlePointSecondCurve = CGPoint(x: gapSpace + (((tabWidth * index) + tabWidth) - tabWidth / 4), y: 0)
        
        let lastPoint = CGPoint(x: gapSpace + (tabWidth * index) + tabWidth + 25, y: 0)
        bezPath.move(to: firstPoint)
        bezPath.addCurve(to: middlePoint, controlPoint1: firstPointFirstCurve, controlPoint2: firstPointSecondCurve)
        bezPath.addCurve(to: lastPoint, controlPoint1: middlePointFirstCurve, controlPoint2: middlePointSecondCurve)
        bezPath.append(UIBezierPath(rect: self.bounds))
        return bezPath
    }
}
