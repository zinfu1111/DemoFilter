//
//  EditImageViewController.swift
//  DemoFilter
//
//  Created by 連振甫 on 2021/8/3.
//

import UIKit
import CoreImage.CIFilterBuiltins
import Photos


class EditImageViewController: UIViewController {

    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var resultImage: UIImage?
    
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupImageView()
    }
    
    func setupImageView() {
        let scale = imageBackgroundView.frame.height/UIScreen.main.bounds.height
        let newWidth = imageBackgroundView.frame.width * scale
        
        imageView.frame.size = CGSize(width: newWidth, height: imageBackgroundView.frame.height)
        imageView.center = CGPoint(x: imageBackgroundView.center.x, y: 0)
        
        imageView.frame.origin.y = 0
        
    }
    
}

extension EditImageViewController {
    
    @IBAction func showColorView(_ sender: UIButton) {
        
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        let renderer = UIGraphicsImageRenderer(size: imageBackgroundView.bounds.size)
        let image = renderer.image(actions: { (context) in
            imageBackgroundView.drawHierarchy(in: imageBackgroundView.bounds, afterScreenUpdates: true)
        })
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBSegueAction func showFilterPicker(_ coder: NSCoder) -> FilterPickerViewController? {
        return FilterPickerViewController(coder: coder, delegate: self)
    }
}

extension EditImageViewController:PhotoManagerDelegate {
    
    
    func makePhoto(with filterItem: Int) {
        if PhotoManager.shared.filters[filterItem].isEmpty {
            self.resultImage = originImage
            self.imageView.image = originImage
            return
        }
        let ciImage = CIImage(image: originImage)
        if let filter = CIFilter(name: PhotoManager.shared.filters[filterItem]) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            self.imageView.image = filter.getOriginFilterImage(by: originImage)
            self.resultImage = filter.getOriginFilterImage(by: originImage)
        }
    }
    
    
}

extension EditImageViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        imageBackgroundView.backgroundColor = viewController.selectedColor
    }
}
