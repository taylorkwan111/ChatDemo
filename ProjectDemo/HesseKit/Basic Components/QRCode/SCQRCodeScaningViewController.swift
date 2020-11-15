//
//  SCQRCodeScaningViewController.swift
//  SACO
//
//  Created by Hesse Huang on 2017/4/1.
//  Copyright © 2017年 Hesse. All rights reserved.
//

import UIKit
import AVFoundation

/// 扫二维码的界面
/// 弹出此界面只需简单地使用:
/// let qrcodeVC = SCQRCodeScaningVC()
/// navigationController?.pushViewController(qrcodeVC, animated: true)
/// 获取扫描结果需要传入 outputObjectsDelegate 对象

class SCQRCodeScaningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let device = AVCaptureDevice.default(for: .video)
    
    private(set) var input: AVCaptureDeviceInput?
    
    let output = AVCaptureMetadataOutput()
    
    let session = AVCaptureSession()
    
    private var scaningView: SCQRCodeScaningView?
    
    private var scanCompletion: ((SCQRCodeScaningViewController, String?) -> Void)?
    
    var localzedScanningDescription: String = "Please put the QR code inside."
    var localzedScanFromAlbumButtonTitle: String = "Scan from Album" {
        didSet {
            scanFromAlbumButton.setTitle(localzedScanFromAlbumButtonTitle, for: .normal)
        }
    }
    var localizedNoQRCodeReadFromAlbumMessage: String = "No QR code found! Please try again."
    
    let scanFromAlbumButton = UIButton(type: .system)
    
    var noPermissionAlertPresentationDuringSetup: ((SCQRCodeScaningViewController) -> Void)?
    
    convenience init(scanCompletion: @escaping (SCQRCodeScaningViewController, String?) -> Void) {
        self.init()
        self.scanCompletion = scanCompletion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
       
        scanFromAlbumButton.setTitle(localzedScanFromAlbumButtonTitle, for: .normal)
        scanFromAlbumButton.addTarget(self, action: #selector(presentAlbumViewController), for: .touchUpInside)
        scanFromAlbumButton.translatesAutoresizingMaskIntoConstraints = false
        scanFromAlbumButton.sizeToFit()
        view.addSubview(scanFromAlbumButton)
        if #available(iOS 11.0, *) {
            scanFromAlbumButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            scanFromAlbumButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        } else {
            scanFromAlbumButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            scanFromAlbumButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
    
    private func setup() {
        
        if let device = self.device, let input = try? AVCaptureDeviceInput(device: device) {
            output.setMetadataObjectsDelegate(self, queue: .main)
            session.sessionPreset = .high
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            output.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
            
            let scaningView = SCQRCodeScaningView(session: session)
            scaningView.descriptionLabel.text = localzedScanningDescription
            scaningView.updateDescriptionLabelPosition()
            view.addSubview(scaningView)
            
            output.rectOfInterest = scaningView.rectOfInterest
            self.scaningView = scaningView

        } else {
            noPermissionAlertPresentationDuringSetup?(self)
            dprint("Error: Can't setup SCQRCodeScanningViewController \(self)")
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            session.stopRunning()
            scanCompletion?(self, object.stringValue)
        }
    }
    

    private func readQRCodeValue(from image: UIImage) {
        if let ciImage = CIImage(image: image),
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: CIContext(options: nil),
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
            if let feature = detector.features(in: ciImage).first as? CIQRCodeFeature, let message = feature.messageString {
                session.stopRunning()
                scanCompletion?(self, message)
            } else {
                scaningView?.descriptionLabel.text = localizedNoQRCodeReadFromAlbumMessage
                scaningView?.descriptionLabel.textColor = .red
                scaningView?.updateDescriptionLabelPosition()
                if #available(iOS 10.0, *) {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                    self.scaningView?.descriptionLabel.text = self.localzedScanningDescription
                    self.scaningView?.descriptionLabel.textColor = .white
                    self.scaningView?.updateDescriptionLabelPosition()
                }
            }
            scaningView?.resetAnimiation()
        }
    }

}

extension SCQRCodeScaningViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func presentAlbumViewController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true) {
            self.readQRCodeValue(from: image)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
