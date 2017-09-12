//
//  LightboxViewer.swift
//  Bottle Messenger
//
//  Created by Paiste Family on 10/9/17.
//  Copyright © 2017 Bam Bam Labs. All rights reserved.
//

import Foundation
import UIKit
import BFRImageViewer

class LightboxViewer {
    
    private static func rootViewController() -> UIViewController {
        
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    static func showImage(viewController: UIViewController, url: String?, backload: UIImage? = nil) {
        if let getUrl = url {
            print (getUrl)
            if let photoURL = URL(string: getUrl) {
                print ("URL-istamine onnestus")
                var source: [Any] = []
                if let backload = backload {
                    print ("Backload pilt on kaes")
                    source = [BFRBackLoadedImageSource(initialImage: backload, hiResURL: photoURL) as Any]
                }
                if let imageVC = BFRImageViewController(imageSource: [source]) {
                    print ("VC saime tehtud", viewController.nibName as Any)
                    viewController.present(imageVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    static func showGallery(viewController: UIViewController, urlArray: [String]?, backload: [UIImage]? = nil) {
        if let urlArray = urlArray {
            var source: [Any] = []
            var sourceItem: Any = ""
            var imageNumber = 1
            for urlString in urlArray {
                if let photoURL = URL(string: urlString) {
                    sourceItem = photoURL
                    if let backloadArray = backload {
                        let backloadImage = backloadArray[imageNumber]
                        sourceItem = BFRBackLoadedImageSource(initialImage: backloadImage, hiResURL: photoURL) as Any
                    }
                    source.append(sourceItem)
                    imageNumber += 1
                }
            }
            
            if let imageVC = BFRImageViewController(imageSource: [source]) {
                viewController.present(imageVC, animated: true, completion: nil)
            }
        }
    }
}
