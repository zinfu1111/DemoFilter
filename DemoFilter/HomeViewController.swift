//
//  HomeViewController.swift
//  HomeViewController
//
//  Created by 連振甫 on 2021/8/4.
//

import UIKit
import Photos

class HomeViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var selectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goTakePhoto", sender: nil)
    }
    
    @IBAction func showPhotoDesk(_ sender: UIButton) {
        openLibrary()
    }
    //打開圖庫
    func openLibrary() {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedImage = info[.originalImage] as? UIImage
            //回到之前的頁面
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "goEditPhoto", sender: nil)
        })
        

    }
    
    @IBSegueAction func goEditPhoto(_ coder: NSCoder) -> EditImageViewController? {
        
        return EditImageViewController(coder: coder, image: selectedImage!)
    }
    
    
    @IBSegueAction func goTakePhoto(_ coder: NSCoder) -> CameraViewController? {
        return CameraViewController(coder: coder)
    }
}
