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

protocol LightboxViewerDelegate {

}

class LightboxViewer: UIViewController {
    
    var delegate: LightboxViewerDelegate?
    
    private static func rootViewController() -> UIViewController {
        
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
 func showImage(viewController: UIViewController, url: String?, backload: UIImage? = nil) {
        if let getUrl = url {
            if let photoURL = URL(string: getUrl) {
                if let backload = backload {
                    var source = [BFRBackLoadedImageSource(initialImage: backload, hiResURL: photoURL) as Any]
                } else {
                    var source = [photoURL]
                }
                if let imageVC = BFRImageViewController(imageSource: [photoURL]) {
                    viewController.present(imageVC, animated: true, completion: nil)
                }
            }
        }
    }
    
 func showGallery(viewController: UIViewController, urlArray: [String]?, backload: [UIImage]? = nil) {
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
                imageVC.present(imageVC, animated: true, completion: nil)
            }
        }
    }
}
