//
//  EditImageViewController.swift
//  DemoFilter
//
//  Created by 連振甫 on 2021/8/3.
//

import UIKit
import CoreImage.CIFilterBuiltins


class EditImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let originImage: UIImage
    var filter:CIFilter?
    
    init?(coder: NSCoder,image:UIImage){
        self.originImage = image
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no init")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = originImage
    }
    
}

extension EditImageViewController {
    
    @IBSegueAction func showFilterPicker(_ coder: NSCoder) -> FilterPickerViewController? {
        return FilterPickerViewController(coder: coder, delegate: self)
    }
}

extension EditImageViewController:PhotoManagerDelegate {
    
    func makePhoto(with filterItem: Int) {
        let ciImage = CIImage(image: originImage)
        if let filter = CIFilter(name: PhotoManager.shared.filters[filterItem]) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            self.imageView.image = filter.getOriginFilterImage(by: originImage)
        }
    }
    
    
}
