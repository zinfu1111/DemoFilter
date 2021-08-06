//
//  PhotoManager.swift
//  PhotoManager
//
//  Created by 連振甫 on 2021/8/6.
//

import UIKit
import Foundation
import CoreImage.CIFilterBuiltins


protocol PhotoManagerDelegate {
    func makePhoto(with filterItem:Int)
}

class PhotoManager {
    
    
    let titleData:[String] = ["原圖","懷舊","黑白","色調","歲月","褪色","沖印","單色","加亮","假色","印刷","底片"]
    let filters = ["", "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CIPhotoEffectFade", "CIPhotoEffectProcess", "CIPhotoEffectMono", "CIPhotoEffectChrome", "CIFalseColor", "CIColorPosterize", "CIColorInvert"]
    var sampleImageData = [UIImage]()
    
    private let sampleImageId = "Image"
    static let shared = PhotoManager()
    
    init() {
        sampleImageData.append(UIImage(named: sampleImageId)!)
        filters.forEach({ key in
            let ciImage = CIImage(image: UIImage(named: sampleImageId)!)
            if let filter = CIFilter(name: key) {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if let image = filter.image {
                    sampleImageData.append(image)
                }
            }
        })
    }
}
