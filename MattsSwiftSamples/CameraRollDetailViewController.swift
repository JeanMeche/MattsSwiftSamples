//
//  CameraRollDetailViewController.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 02/09/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit
import Photos

class CameraRollDetailViewController:UIViewController {

    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var tapGestureRecognizer:UITapGestureRecognizer!
    
    var asset: PHAsset!
    var assetCollection: PHAssetCollection!
    var presenting:Bool = false {
        willSet {
            if newValue {
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                imageView.backgroundColor = .black
                scrollView.backgroundColor = .black
                view.backgroundColor = .black
            } else {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                imageView.backgroundColor = .red
                scrollView.backgroundColor = .white
                view.backgroundColor = .white

                // setZoomScale works only when viewForZooming(in:) returns the view
                // there doing it before changing the value of presenting
                scrollView.setZoomScale(1.0, animated: true)
            }
            print(view.frame, scrollView.frame)
        }
        didSet {
            print(edgesForExtendedLayout)
        }
    }
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }
    
    override func viewDidLoad() {
        print("-- ", edgesForExtendedLayout)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0

        presenting = false
        edgesForExtendedLayout = []
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in

            // If successful, show the image view and display the image.
            guard let image = image else { return }
            
            // Now that we have the image, show it.
            self.imageView.isHidden = false
            self.imageView.image = image
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.hidesBarsOnTap = false
    }
    
    @IBAction func didTap(sender:AnyObject) {
        presenting = !presenting
    }    
}


extension CameraRollDetailViewController:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return presenting ? imageView : nil
    }
}
