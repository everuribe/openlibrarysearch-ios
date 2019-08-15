//
//  UIImageView+downloadImage.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    ///Fetches book cover image.
    func fetchCoverImage(coverID: String?) {
        //Run code asynchronously whule not blocking the UI
        DispatchQueue.global().async {
        
            if let key: String = coverID {
                //Attempt to fetch image from cache
                if let cachedImage: UIImage = imageCache.object(forKey: key as AnyObject) as? UIImage {
                    DispatchQueue.main.async {
                        self.image = cachedImage
                    }
                //Attempt to fetch image from web
                } else {
                    let baseUrlString: String = "https://covers.openlibrary.org/b/id/"
                    let imageUrlString: String = baseUrlString + "\(key)" + "-M.jpg"
                    
                    guard let imageUrl: URL =  URL(string: imageUrlString) else {
                        self.setNoCoverImageAvailable()
                        return
                    }
                    let data: Data? = try? Data(contentsOf: imageUrl)
                    
                    if let data: Data = data {
                        DispatchQueue.main.async {
                            self.image = UIImage(data: data)
                        }
                    }
                    else {
                        self.setNoCoverImageAvailable()
                    }
                }
            } else {
                self.setNoCoverImageAvailable()
            }
        }
    }

    //Sets noCover image. 
    private func setNoCoverImageAvailable() {
        DispatchQueue.main.async {
            self.image = UIImage(named: "noCover")
        }
    }
}
