//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by 連振甫 on 2021/8/5.
//

import UIKit
import Photos

class CameraViewController: UIViewController {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBackgroudView: UIView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet var controlButtons: [UIButton]!
    
    let cameraController = CameraController()
    var photo:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }

                try? self.cameraController.displayPreview(on: self.cameraView)
                
                self.controlView(isHidden: false)
            }
        }
        
        
        configureCameraController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCaptureView()
    }
    
}

extension CameraViewController {
    
    func setupCaptureView(){
        self.captureView.layer.cornerRadius = self.captureView.frame.height * 0.5
    }
    
    func controlView(isHidden: Bool) {
        DispatchQueue.main.async {
            self.controlButtons.forEach({$0.isHidden = isHidden})
            self.captureView.isHidden = isHidden
            self.imageBackgroudView.isHidden = !isHidden
        }
    }
    
}

extension CameraViewController {
    
    @IBAction func captureAction(_ sender: Any) {
        cameraController.captureImage(completion: {[weak self] image,error in
            
            guard let self = self else { return }
           
            UIDevice.pop()
            self.controlView(isHidden: true)
            self.photo = image
            self.imageView.image = self.photo
            self.controlView(isHidden: true)
            
            self.showAlert(title: "要編輯照片嗎？", msg: "選擇確認可編輯照片。", checkHandler: { [weak self] _ in

                guard let self = self else { return }
                DispatchQueue.main.async {
                    
                    self.controlView(isHidden: false)
                    self.performSegue(withIdentifier: "goEditPhoto", sender: nil)

                }

            }, cancleHandler: {[weak self] _ in

                DispatchQueue.main.async {
                    guard let self = self,let image = self.photo else {
                        self?.controlView(isHidden: false)
                        return
                        
                    }
                    //取消直接存照片
                    try? PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }
                    self.controlView(isHidden: false)
                }
            })
            
        })
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            sender.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        }

        else {
            cameraController.flashMode = .on
            sender.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        }
        
        UIDevice.peek()
    }
    
    @IBAction func cancleAction(_ sender: UIButton){
        UIDevice.cancelled()
        dismiss(animated: true)
    }
    
    @IBAction func switchCamerasAction(_ sender: UIButton){
        
        do {
            try cameraController.switchCameras()
        }

        catch {
            print(error)
        }

        UIDevice.peek()
    }
    
    @IBSegueAction func goEditorPhoto(_ coder: NSCoder) -> EditImageViewController? {
        return EditImageViewController(coder: coder, image: self.photo!)
    }
}
