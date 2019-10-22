//
//  ExtensionUIImage.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/1.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ImageFormat {
    case png, jpeg(CGFloat)
}

extension UIImage {
    func reduceImageWithPercent(_ percent: CGFloat) -> UIImage {
        guard let imageData = self.jpegData(compressionQuality: percent), let newImage = UIImage(data: imageData) else { return UIImage() }
        return newImage
    }
    
    func scaleImageWithNewSize(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage ?? UIImage()
    }
    
    func resize(_ size: CGSize, completion: @escaping (UIImage?) -> Void) {
        
        var newImage: UIImage?
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = size.width
        let targetHeight = size.height
        
        var scaleFactor: CGFloat = 0.0
        var scaleWidth: CGFloat = targetWidth
        var scaleHeight: CGFloat = targetHeight
        var thumbnailPoint = CGPoint.zero
        
        if imageSize != size {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            scaleWidth = width * scaleFactor
            scaleHeight = height * scaleFactor
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaleHeight) * 0.5
            } else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetWidth - scaleWidth) * 0.5
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            UIGraphicsBeginImageContext(size)
            let thumbnailRect = CGRect(origin: thumbnailPoint, size: CGSize(width: scaleWidth, height: scaleHeight))
            self.draw(in: thumbnailRect)
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            if newImage == nil {
                debugPrint("Scale image fail...")
            }
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                completion(newImage)
            }
        }
    }
    
    func compressForSize(_ size: CGSize) -> UIImage {
        var newImage: UIImage?
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = size.width
        let targetHeight = size.height

        var scaleFactor: CGFloat = 0.0
        var scaleWidth: CGFloat = targetWidth
        var scaleHeight: CGFloat = targetHeight
        var thumbnailPoint = CGPoint.zero

        if imageSize != size {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            scaleWidth = width * scaleFactor
            scaleHeight = height * scaleFactor
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaleHeight) * 0.5
            } else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetWidth - scaleWidth) * 0.5
            }
        }

        UIGraphicsBeginImageContext(size)
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: CGSize(width: scaleWidth, height: scaleHeight))
        self.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        if newImage == nil {
            debugPrint("Scale image fail...")
        }
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    func compressForWidth(_ width: CGFloat) -> UIImage {
        var newImage: UIImage?
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = width
        let targetHeight = height / (width / targetWidth)
        let size = CGSize(width: targetWidth, height: targetHeight)

        var scaleFactor: CGFloat = 0.0
        var scaleWidth: CGFloat = targetWidth
        var scaleHeight: CGFloat = targetHeight
        var thumbnailPoint = CGPoint.zero

        if imageSize != size {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            scaleWidth = width * scaleFactor
            scaleHeight = height * scaleFactor
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaleHeight) * 0.5
            } else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetWidth - scaleWidth) * 0.5
            }
        }

        UIGraphicsBeginImageContext(size)
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: CGSize(width: scaleWidth, height: scaleHeight))
        self.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        if newImage == nil {
            debugPrint("Scale image fail...")
        }
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    func imageSize() -> UInt {
        let cgImageBytesPerRow = cgImage?.bytesPerRow ?? 0
        let cgImageHeight = cgImage?.height ?? 0
        let size: UInt = UInt(cgImageHeight * cgImageBytesPerRow)
        debugPrint("size:\(size)")
        let kbSize: UInt = size / 1024
        return kbSize
    }
    
    func transformToBase64String(format: ImageFormat) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = self.pngData()
        case .jpeg(let compression): imageData = self.jpegData(compressionQuality: compression)
        }
        return imageData?.base64EncodedString()
    }
}
