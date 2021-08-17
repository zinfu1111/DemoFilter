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
    @IBOutlet weak var imageScaleConstraint: NSLayoutConstraint!
    var resultImage: UIImage?
    var originSize = CGSize()
    let originImage: UIImage
    var filter:CIFilter?
    var mirrorCount = 1
    var degree = CGFloat.pi / 180
    var roateCount = 0
    
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
        setupImageView()
        
    }
    
    func setupImageView() {
        //計算原圖尺寸比例
        let scale = imageView.frame.height/originImage.size.height
        let newWidth = originImage.size.width * scale
        let newScale = newWidth/imageView.frame.height
        
        originSize.height = imageView.frame.height
        originSize.width = newWidth
        
        //將新的比例設定到imageScaleConstraint
        imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: newScale)
        imageView.image = originImage
    }
    
    func scalePhoto(id:Int) {
        let width = originImage.size.width / 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: width))
        let x = -(originImage.size.width - width) / 2
        let y = -(originImage.size.height - width) / 2
        let image = renderer.image { (context) in
            originImage.draw(at: CGPoint(x: x, y: y))
         }
        imageView.image = image
        
    }
    
}

extension EditImageViewController {
    
    //MARK: 旋轉
    @IBAction func roateAction(_ sender: UIButton) {
        
        roateCount += 1
        imageView.transform = CGAffineTransform(rotationAngle: degree * 90 * CGFloat(-(roateCount + 4 ) % 4))

    }
    
    //MARK: 鏡像
    @IBAction func mirrorAction(_ sender: Any) {
        mirrorCount *= -1
        imageBackgroundView.transform = CGAffineTransform(scaleX: CGFloat(mirrorCount), y: 1 )
    }
    
    //MARK: 調整比例
    @IBAction func changeScale(_ sender: UIButton) {
        
        let originScale = originSize.width/originSize.height
        
        switch sender.tag {
        case 0:
            //原圖
            imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: originScale)
        case 1:
            //正方形
            imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: 1)
        case 2:
            //16：9
            imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: originScale * 16/9)
        case 3:
            //10：8
            imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: originScale * 10/8)
        case 4:
            //7：5
            imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: originScale * 7/5)
        case 5:
            //4:3
            imageScaleConstraint = imageScaleConstraint.setMultiplier(multiplier: originScale * 4/3)
        default:
            break
        }
    }
    
    //MARK: 設定背景色
    @IBAction func showColorView(_ sender: UIButton) {
        
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: 分享圖片
    @IBAction func savePhoto(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: imageBackgroundView.bounds.size)
        let image = renderer.image(actions: { (context) in
            imageBackgroundView.drawHierarchy(in: imageBackgroundView.bounds, afterScreenUpdates: true)
        })
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.completionWithItemsHandler =
        {[weak self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            guard let self = self,completed else { return  }
            self.dismiss(animated: true, completion: nil)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: 關閉編輯
    @IBAction func closeEdit(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //MARK: 顯示濾鏡項目
    @IBSegueAction func showFilterPicker(_ coder: NSCoder) -> FilterPickerViewController? {
        return FilterPickerViewController(coder: coder, delegate: self)
    }
}

extension EditImageViewController:PhotoManagerDelegate {
    
    //MARK: 加入濾鏡效果
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
