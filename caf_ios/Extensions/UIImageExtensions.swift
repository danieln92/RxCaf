//
//  UIImageExtensions.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation
import Toucan

public extension UIImage {
    public func toJPEG(_ compressionQuality: CGFloat) -> Data? {
        return UIImageJPEGRepresentation(self, compressionQuality)
    }
    
    public func toPNG(_ compressionQuality: CGFloat) -> Data? {
        return UIImagePNGRepresentation(self)
    }
    
    public func resizeToJPEG(maxWidth: Int, compressQuality : CGFloat) -> Data {
        let resizedImage = Toucan(image: self).resize(CGSize(width: maxWidth, height: 0), fitMode: .clip).image
        return  UIImageJPEGRepresentation(resizedImage, compressQuality)!
    }
    
    public func resizeToJPEG(maxHeight: Int, compressQuality : CGFloat) -> Data {
        let resizedImage = Toucan(image: self).resize(CGSize(width: 0, height: maxHeight), fitMode: .clip).image
        return  UIImageJPEGRepresentation(resizedImage, compressQuality)!
    }
    
    public func resizeToJPEG(width: Int, height: Int, compressQuality : CGFloat) -> Data {
        let resizedImage = Toucan(image: self).resize(CGSize(width: width, height: height), fitMode: .clip).image
        return  UIImageJPEGRepresentation(resizedImage, compressQuality)!
    }
}
