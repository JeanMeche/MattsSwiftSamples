//
//  CameraRoll.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 01/09/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CameraRollViewController:DetailViewController {
    
    @IBOutlet weak var collectionView:UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var selectedCell:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = PHFetchOptions()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
//        moments.enumerateObjects({ (object:AnyObject, count:Int, stop) in
//            
//            guard let moment = object as? PHAssetCollection else {
//                return
//            }
//            self.moments.append(moment.localizedTitle)
//            let assetsInMoment = PHAsset.fetchAssets(in: moment, options: nil)
//            let section = count
//            assetsInMoment.enumerateObjects({ (object:AnyObject, count:Int, stop) in
//                if let asset = object as? PHAsset {
//                    let imageSize = CGSize(width: 60, height: 60)
//                    let options = PHImageRequestOptions()
//                    options.deliveryMode = .fastFormat
//                    options.isSynchronous = true
//                    self.imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { image, info in
//                        print(info, "\n\n\n")
//                        self.data[section].append(image!)
//                        self.collectionView.reloadData()
//                    })
//                }
//            })
//        })
        view.backgroundColor = .red
    }

    override func viewDidLayoutSubviews() {
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CameraRollDetailViewController {
            let indexPath = collectionView!.indexPath(for: sender as! UICollectionViewCell)!
            destination.asset = fetchResult.object(at: indexPath.item)
            destination.assetCollection = assetCollection
        }
    }
}


extension CameraRollViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.size.width/4-1
        return CGSize(width:side,height:side)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as? CameraRollCell else {
            return UICollectionViewCell()
        }
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
                cell.imageView.image = image
            })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"CameraRollHeader", for:indexPath) as! CollectionHeaderView
            header.backgroundColor = .lightGray
            return header
        }
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell = indexPath
        
        performSegue(withIdentifier: "detail", sender: collectionView.cellForItem(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedCell = nil
    }
}

extension CameraRollViewController:UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop || operation == .push {
            return PopInAndOutAnimator(operation: operation)
        }
        return nil
    }
}

extension CameraRollViewController:CollectionPushAndPoppable {
    internal var theCollectionView: UICollectionView? {
        return collectionView
    }

    internal var sourceCell: UICollectionViewCell? {
        return self.collectionView.cellForItem(at: selectedCell!)
    }
}

class CameraRollCell:UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}

class CollectionHeaderView:UICollectionReusableView {
    @IBOutlet weak var label:UILabel!
}

protocol CollectionPushAndPoppable {
    var sourceCell: UICollectionViewCell? { get }
    var theCollectionView: UICollectionView? { get }
    var view: UIView! { get }
}

class PopInAndOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration:TimeInterval = 0.5
    let operationType:UINavigationControllerOperation
    
    init(operation:UINavigationControllerOperation) {
        operationType = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if operationType == .push {
            performPushTransition(transitionContext)
        } else if operationType == .pop {
            performPopTransition(transitionContext)
        }
    }
    
    func performPushTransition(_ transitionContext:UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
             else {
                // Something really bad happend and it is not possible to perform the transition
                print("ERROR: Transition impossible to perform since either the destination view or the conteiner view are missing!")
                return
        }
        
        let container = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? CollectionPushAndPoppable,
            let fromView = fromViewController.theCollectionView,
            let currentCell = fromViewController.sourceCell else {
                // There are not enough info to perform the animation but it is still possible
                // to perform the transition presenting the destination view
                container.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        // Add to container the destination view
        container.addSubview(toView)
        
        // Prepare the screenshot of the destination view for animation
        let screenshotToView =  UIImageView(image: toView.screenshot)
        // set the frame of the screenshot equals to the cell's one
        screenshotToView.frame = currentCell.frame
        // Now I get the coordinates of screenshotToView inside the container
        let containerCoord = fromView.convert(screenshotToView.frame.origin, to: container)
        // set a new origin for the screenshotToView to overlap it to the cell
        screenshotToView.frame.origin = containerCoord
        
        // Prepare the screenshot of the source view for animation
        let screenshotFromView = UIImageView(image: currentCell.screenshot)
        screenshotFromView.frame = screenshotToView.frame
        
        // Add screenshots to transition container to set-up the animation
        container.addSubview(screenshotToView)
        container.addSubview(screenshotFromView)
        
        // Set views initial states
        toView.isHidden = true
        screenshotToView.isHidden = true
        
        // Delay to guarantee smooth effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            screenshotToView.isHidden = false
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            screenshotFromView.alpha = 0.0
            screenshotToView.frame = UIScreen.main.bounds
            screenshotToView.frame.origin = CGPoint(x: 0.0, y: 0.0)
            screenshotFromView.frame = screenshotToView.frame
            
        }, completion: { _ in
            
            screenshotToView.removeFromSuperview()
            screenshotFromView.removeFromSuperview()
            toView.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func performPopTransition(_ transitionContext:UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
             else {
                // Something really bad happend and it is not possible to perform the transition
                print("ERROR: Transition impossible to perform since either the destination view or the conteiner view are missing!")
                return
        }
        
        let container = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? CollectionPushAndPoppable,
            let toCollectionView = toViewController.theCollectionView,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromViewController.view,
            let currentCell = toViewController.sourceCell else {
                // There are not enough info to perform the animation but it is still possible
                // to perform the transition presenting the destination view
                container.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        // Add destination view to the container view
        container.addSubview(toView)
        
        // Prepare the screenshot of the source view for animation
        let screenshotFromView = UIImageView(image: fromView.screenshot)
        screenshotFromView.frame = fromView.frame
        
        // Prepare the screenshot of the destination view for animation
        let screenshotToView = UIImageView(image: currentCell.screenshot)
        screenshotToView.frame = screenshotFromView.frame
        
        // Add screenshots to transition container to set-up the animation
        container.addSubview(screenshotToView)
        container.insertSubview(screenshotFromView, belowSubview: screenshotToView)
        
        // Set views initial states
        screenshotToView.alpha = 0.0
        fromView.isHidden = true
        currentCell.isHidden = true
        
        let containerCoord = toCollectionView.convert(currentCell.frame.origin, to: container)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            screenshotToView.alpha = 1.0
            screenshotFromView.frame = currentCell.frame
            screenshotFromView.frame.origin = containerCoord
            screenshotToView.frame = screenshotFromView.frame
            
        }) { _ in
            
            currentCell.isHidden = false
            screenshotFromView.removeFromSuperview()
            screenshotToView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
