//
//  MainTabBarController.swift
//  Library
//
//  Created by Ever Uribe on 8/9/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

///The parent controller in this application. 
class MainTabBarController: CircularTBC {
    
    //Array defining view controllers set in the tab bar controller.
    lazy var tabVCArray: [UIViewController] = {
        let searchVC: SearchVC = SearchVC()
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search"), tag: 0)
        searchVC.tabBarItem.selectedImage = UIImage(named: "search_selected")
        
        let wishlistVC: WishlistVC = WishlistVC()
        wishlistVC.tabBarItem = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), tag: 1)
        wishlistVC.tabBarItem.selectedImage = UIImage(named: "wishlist_selected")
        
        return [searchVC, wishlistVC]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers(tabVCArray, animated: true)
    }
}
