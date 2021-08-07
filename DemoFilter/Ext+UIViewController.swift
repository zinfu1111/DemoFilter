//
//  Ext+UIViewController.swift
//  Ext+UIViewController
//
//  Created by 連振甫 on 2021/8/5.
//

import UIKit
import AVFoundation
import System
import AudioToolbox.AudioServices

// 'Peek' feedback (weak boom)
let peekSound = SystemSoundID(1519)

// 'Pop' feedback (strong boom)
let popSound = SystemSoundID(1520)

// 'Cancelled' feedback (three sequential weak booms)
let cancelledSound = SystemSoundID(1521)

// 'Try Again' feedback (week boom then strong boom)
let tryAgainSound = SystemSoundID(1102)

// 'Failed' feedback (three sequential strong booms)
let failedSound = SystemSoundID(1107)

extension UIDevice {
    
    static func pop(){
        AudioServicesPlaySystemSound(popSound)
    }
    
    static func peek() {
        AudioServicesPlaySystemSound(peekSound)
    }
    
    static func cancelled() {
        AudioServicesPlaySystemSound(cancelledSound)
    }
    
    static func failed() {
        AudioServicesPlaySystemSound(failedSound)
    }
}

extension UIViewController {
    
    func showAlert(title:String?, msg:String?, checkHandler:((UIAlertAction) -> Void)? = nil,cancleHandler:((UIAlertAction) -> Void)? = nil) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            let checkAction = UIAlertAction(title: "確認", style: .default, handler: checkHandler)
            
            let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: cancleHandler)
            alert.addAction(checkAction)
            alert.addAction(cancleAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
}
