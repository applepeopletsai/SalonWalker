//
//  ExtensionUIImageView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

let imageCache = NSCache<NSString,AnyObject>()

private struct AssociatedKeys {
    static var url = "url"
}

extension UIImageView {
    
    private var url: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.url) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.url, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private weak var queue: OperationQueue? {
        let q = OperationQueue()
        q.qualityOfService = .default
        q.maxConcurrentOperationCount = 1
        return q
    }
    
    func cancelOperation() {
        self.queue?.cancelAllOperations()
        self.kf.cancelDownloadTask()
    }
    
    func setImage(with urlString: String, autoSetImage: Bool = true, completion: ((_ image: UIImage?, _ url: String) -> Void)? = nil) {
        if let url = URL(string: urlString) {
            self.url = urlString
            self.image = nil
            self.kf.indicatorType = .activity
            self.kf.indicator?.startAnimatingView()
            self.queue?.addOperation {
                let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage
                if cachedImage != nil {
                    print("has cachedImage")
                    OperationQueue.main.addOperation { [weak self] in
                        if self?.url != url.absoluteString { return }
                        self?.kf.indicator?.stopAnimatingView()
                        if autoSetImage {
                            self?.image = cachedImage
                        }
                        completion?(cachedImage,urlString)
                    }
                } else {
                    print("has no cachedImage")
                    let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                    KingfisherManager.shared.retrieveImage(with: resource, options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { [weak self] (image, error, type, url) in
                        if image != nil {
                            imageCache.setObject(image!, forKey: urlString as NSString)
                        }
                        OperationQueue.main.addOperation { [weak self] in
                            if self?.url != url?.absoluteString { return }
                            self?.kf.indicator?.stopAnimatingView()
                            if autoSetImage {
                                self?.image = image
                            }
                            completion?(image,url?.absoluteString ?? "")
                        }
                    }
                }
            }
        } else {
            self.image = nil
        }
    }
    
    func getVideoImage(with urlString: String, completion: ((_ image: UIImage?, _ time: String?, _ url: String) -> Void)? = nil) {
        if let url = URL(string: urlString) {
            self.url = urlString
            self.image = nil
            self.kf.indicatorType = .activity
            self.kf.indicator?.startAnimatingView()

            self.queue?.addOperation {
                let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage
                let time = imageCache.object(forKey: urlString + "/time" as NSString) as? String
                if cachedImage != nil, time != nil {
                    OperationQueue.main.addOperation { [weak self] in
                        if self?.url != url.absoluteString { return }
                        self?.kf.indicator?.stopAnimatingView()
                        completion?(cachedImage,time,urlString)
                    }
                } else {
                    let asset = AVURLAsset(url: url)
                    let second:Int = Int(CMTimeGetSeconds(asset.duration))
                    let time = "\(self.getTwoDigits(second / 60)):\(self.getTwoDigits(second % 60))"
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    do {
                        let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                        let img = UIImage(cgImage: thumbnailImage)
                        imageCache.setObject(img, forKey: urlString as NSString)
                        imageCache.setObject(time as NSString, forKey: urlString + "/time" as NSString)
                        OperationQueue.main.addOperation { [weak self] in
                            if self?.url != url.absoluteString { return }
                            self?.kf.indicator?.stopAnimatingView()
                            completion?(img,time,urlString)
                        }
                    } catch let error {
                        OperationQueue.main.addOperation { [weak self] in
                            self?.kf.indicator?.stopAnimatingView()
                            self?.image = nil
                        }
                        print("=== getVideoImage error: \(error)")
                    }
                }
            }
        } else {
            self.image = nil
        }
    }
    
    private func getTwoDigits(_ input: Int) -> String {
        return (input < 10) ? "0\(input)" : "\(input)"
    }
}
