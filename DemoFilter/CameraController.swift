//
//  CameraController.swift
//  CameraController
//
//  Created by 連振甫 on 2021/8/5.
//

import UIKit
import AVFoundation

class CameraController: NSObject {

    //建立 Capture Session
    var captureSession: AVCaptureSession?

    //設定 Capture Devices
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?

    //設定 Device Inputs
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?

    //設定 Photo Outputs
    var photoOutput: AVCapturePhotoOutput?

    //顯示預覽畫面
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //開關閃光燈/切換相機功能
    var flashMode = AVCaptureDevice.FlashMode.off
    
    //實作 Image Captures
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
}

extension CameraController {

    
    /// 相片擷取
    /// - Parameter completionHandler: 設定完成後執行 completionHandler
    func prepare(completionHandler: @escaping (Error?) -> Void) {

        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }

        func configureCaptureDevices() throws {
            //1 使用AVCaptureDeviceDiscoverySession找出裝置上所有可用的內置相機 (.builtInDualCamera)。
            // 需要修改為（.builtInWideAngleCamera）
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = session.devices.compactMap { $0 }

            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }

            //2
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }

                if camera.position == .back {
                    self.rearCamera = camera

                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }

        func configureDeviceInputs() throws {

            //1
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

            //2
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }

                self.currentCameraPosition = .rear
            }

            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)

                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }

                self.currentCameraPosition = .front
            }

            else { throw CameraControllerError.noCamerasAvailable }

        }

        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)

            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }

            captureSession.startRunning()
        }

        DispatchQueue(label: "prepare").async {
                do {
                    createCaptureSession()
                    try configureCaptureDevices()
                    try configureDeviceInputs()
                    try configurePhotoOutput()
                }

                catch {
                    DispatchQueue.main.async {
                        completionHandler(error)
                    }

                    return
                }

                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
    }
    
    
    /// 顯示預覽畫面
    /// - Parameter view: 在哪個view
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }


    /// 切換前後盡頭
    func switchCameras() throws {
        //5
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }

        //6
        captureSession.beginConfiguration()

        func switchToFrontCamera() throws {
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                    let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
                
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        func switchToRearCamera() throws {
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                    let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
                
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }

        //7
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()

        case .rear:
            try switchToFrontCamera()
        }

        //8
        captureSession.commitConfiguration()
    }
    
    
    /// 實作 Image Capture
    /// - Parameter completion: 回傳圖片
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode

        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
        else if let imageData = photo.fileDataRepresentation(){
               let image = UIImage(data: imageData)
               self.photoCaptureCompletionBlock?(image, nil)
           }else {
               self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
           }
   }
}

extension CameraController {
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }

    public enum CameraPosition {
        case front
        case rear
    }
}
