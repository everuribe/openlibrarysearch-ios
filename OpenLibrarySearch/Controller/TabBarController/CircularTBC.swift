//
//  CircularTBC.swift
//  Library
//
//  Created by Ever Uribe on 8/9/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

class CircularTBC: UITabBarController {
    
    fileprivate var shouldSelectOnTabBar : Bool = true
    private var circularView : UIView!
    private var iconImageView: UIImageView!
    var initalViewControllerIndex: Int = 0
    ///Boolean to ensure the tab image is not reset when the controller view is re-adjusted.
    var isInitialTabSet: Bool = false
    
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    open override var selectedViewController: UIViewController? {
        willSet {
            guard shouldSelectOnTabBar, let newValue = newValue else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? CircularTabBar, let index = viewControllers?.firstIndex(of: newValue) else {return}
            tabBar.select(itemAt: index, animated: true)
        }
    }
    
    open override var selectedIndex: Int {
        willSet {
            guard shouldSelectOnTabBar else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? CircularTabBar else {
                return
            }
            tabBar.select(itemAt: initalViewControllerIndex, animated: true) //Sets initiallySelectedIndex
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set view controllers
        let tabWidth = self.view.bounds.width / CGFloat(self.tabBar.items?.count ?? 2)
        let tabBar = CircularTabBar(frame: CGRect(x: 0, y: self.view.frame.height - barHeight, width: self.view.frame.width, height: barHeight))
        self.setValue(tabBar, forKey: "tabBar")
        self.view.addSubview(tabBar)
        
        tabBar.layer.cornerRadius = self.view.frame.width*0.05 //This is the radius on left and right of tabBar
        tabBar.clipsToBounds = true
        
        //Set the circular view
        self.circularView = UIView(frame: CGRect(x: 0 + tabWidth / 2 - 30, y: self.tabBar.frame.origin.y - 40, width: 60, height: 60))
        circularView.layer.cornerRadius = 30
        circularView.backgroundColor = .white
        circularView.isUserInteractionEnabled = false
        
        self.iconImageView = UIImageView(frame: self.circularView.bounds)
        iconImageView.layer.cornerRadius = 30
        iconImageView.isUserInteractionEnabled = false
        iconImageView.contentMode = .center
        
        circularView.addSubview(iconImageView)
        self.view.addSubview(circularView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedIndex = initalViewControllerIndex //This ensures the tabBar is visible when the app opens
    }
    
    ///The bar height with default of 60 and adds more height if on iOS 11+
    private var _barHeight: CGFloat = 60 //74
    open var barHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return _barHeight + view.safeAreaInsets.bottom
            } else {
                return _barHeight
            }
        }
        set {
            _barHeight = newValue
            updateTabBarFrame() //Update tab bar frame in case _barHeight is set
        }
    }
    
    ///Updates height of tabFrame depending on final view height and adds a blur view of same size as tab bar behind the tab bar.
    func updateTabBarFrame() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = barHeight
        tabFrame.origin.y = self.view.frame.size.height - barHeight
        self.tabBar.frame = tabFrame
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            blurEffectView.frame = tabFrame //CGRect(x: 0, y: 200, width: 200, height: 200) //tabFrame
            blurEffectView.backgroundColor = backgroundGray
            
            if blurEffectView.superview == nil {
                
                blurEffectView.layer.cornerRadius = tabBar.layer.cornerRadius
                blurEffectView.alpha = 0.8
                self.view.insertSubview(blurEffectView, belowSubview: self.tabBar)
            }
            //            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.clipsToBounds = true
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTabBarFrame() //This is after the true barHeight is calculated
        
        initialTabSetting(idx: 0)
        
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        updateTabBarFrame()
    }
    
    ///Sets the initial location of the circular frame and sets the initial view controller. Ensure this is set after tabBar frame is appropriately set.
    func initialTabSetting(idx: Int) {
        if let controller = viewControllers?[idx] {
            shouldSelectOnTabBar = false
            selectedIndex = idx
            let tabWidth: CGFloat = 85
            
            let tabCount: CGFloat = CGFloat(tabBar.items?.count ?? 2)
            let spaceBetweenTabs: CGFloat = (tabBar.frame.width - (tabWidth)*tabCount)/(tabCount + 1)
            let gapSpace: CGFloat = spaceBetweenTabs * (CGFloat(idx) + 1)
            
            //Moves circular to the corresponding selected TabBarItem location
            self.circularView.frame = CGRect(x: gapSpace + (tabWidth * CGFloat(idx) + tabWidth / 2 - 30), y: self.tabBar.frame.origin.y - 11, width: 60, height: 60)
            
            //Fades previous tab icon in the circularView of CircularTabBar. Upon completion, fades in the new tab icon.
            if isInitialTabSet == false {
                self.iconImageView.alpha = 0
                self.iconImageView.image = self.image(with: (self.tabBar.items?[idx].selectedImage)!, scaledTo: CGSize(width: 30, height: 30))
                self.iconImageView.alpha = 1
                isInitialTabSet = true
            }
            
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }
    
    ///Moves the circularView and sets the view controller when UITabBarItem is selected
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item) else { return }
        if  idx != selectedIndex, let controller = viewControllers?[idx] {
            shouldSelectOnTabBar = false
            selectedIndex = idx
            let tabWidth: CGFloat = 85
            
            let tabCount: CGFloat = CGFloat(tabBar.items?.count ?? 2)
            let spaceBetweenTabs: CGFloat = (tabBar.frame.width - (tabWidth)*tabCount)/(tabCount + 1)
            let gapSpace: CGFloat = spaceBetweenTabs * (CGFloat(idx) + 1)
            
            //Moves circular to the corresponding selected TabBarItem location
            UIView.animate(withDuration: 0.3) {
                self.circularView.frame = CGRect(x: gapSpace + (tabWidth * CGFloat(idx) + tabWidth / 2 - 30), y: self.tabBar.frame.origin.y - 11, width: 60, height: 60)
            }
            
            //Fades previous tab icon in the circularView of CircularTabBar. Upon completion, fades in the new tab icon.
            UIView.animate(withDuration: 0.3, animations: {
                self.iconImageView.alpha = 0
            }) { (_) in
                self.iconImageView.image = self.image(with: item.selectedImage!, scaledTo: CGSize(width: 30, height: 30))
                UIView.animate(withDuration: 0.15, animations: {
                    self.iconImageView.alpha = 1
                })
            }
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }
    
    private func image(with image: UIImage?, scaledTo newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, _: false, _: 0.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
