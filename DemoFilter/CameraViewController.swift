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
    var snowEmitterLayer: CAEmitterLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }

                try? self.cameraController.displayPreview(on: self.cameraView)
                self.showSnowAnimate()
                self.controlView(isHidden: false)
            }
        }
        
        
        configureCameraController()
        
        setupCaptureView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            self.snowEmitterLayer.isHidden = isHidden
            if !isHidden {
                self.imageView.image = nil
            }
        }
    }
    
    
    func showSnowAnimate(){
        //Emitter發射的意思
        let snowEmitterCell = CAEmitterCell()
        snowEmitterCell.contents = UIImage(named: "bokeh")?.cgImage
        
        //設定每秒射幾個雪花
        snowEmitterCell.birthRate = 1
        //每個雪花生存20秒
        snowEmitterCell.lifetime = 20
        //雪花移動的速度
        snowEmitterCell.velocity = 100
        //雪花大小0.2(0.5-0.3)~0.8(0.5+0.3)
        snowEmitterCell.scale = 0.5
        snowEmitterCell.scaleRange = 0.3
        //雪花大小改變的速度。大於0會越來越大，小於0會越來越小。
        snowEmitterCell.scaleSpeed = -0.02
        //垂直落下的速度為30。如果要改往上升速度30須設定-30
        snowEmitterCell.yAcceleration = 30
        //雪花轉速範圍-0.5(0.5-1)~1.5(0.5+1)
        snowEmitterCell.spin = 0.5
        snowEmitterCell.spinRange = 1
        //讓雪花飄下時會左右，不會直直地落下而已
        snowEmitterCell.emissionRange = CGFloat.pi
        
        //讓發射的雪花顯示出來
        snowEmitterLayer = CAEmitterLayer()
        //發射位置
        snowEmitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        snowEmitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        snowEmitterLayer.emitterShape = .line
        //讓雪花的大小產生速度加倍
        snowEmitterLayer.scale = 2
        snowEmitterLayer.birthRate = 2
        //顯示的內容
        snowEmitterLayer.emitterCells = [snowEmitterCell]
        //雪花要在image上才會看得到！
        imageView.layer.addSublayer(snowEmitterLayer)
    }
    
}

extension CameraViewController {
    
    @IBAction func captureAction(_ sender: Any) {
        
        cameraController.captureImage(completion: {[weak self] image,error in
            
            guard let self = self else { return }
           
            UIDevice.pop()
            self.imageView.image = image
            self.imageBackgroudView.isHidden = false
            
            let renderer = UIGraphicsImageRenderer(size: self.imageBackgroudView.bounds.size)
            let makeImage = renderer.image(actions: { (context) in
                self.imageBackgroudView.drawHierarchy(in: self.imageBackgroudView.bounds, afterScreenUpdates: true)
            })
            
            self.imageView.image = makeImage
            self.snowEmitterLayer.isHidden = true
            self.photo = makeImage
            
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
