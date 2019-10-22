//
//  QRcodeScannerView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRcodeScannerViewDelegate: class {
    func catpureQRCode(string: String)
}

class QRcodeScannerView: UIView {

    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    weak var delegate: QRcodeScannerViewDelegate?
    
    // MARK: Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeQRcodeScanner()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeQRcodeScanner()
    }
    
    override func layoutSubviews() {
        videoPreviewLayer?.frame = self.layer.bounds
    }
    
    // MARK: Method
    func reStartScanner() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    private func initializeQRcodeScanner() {
        // 取得AVCaptureDevice類別的實體來初始化一個device物件，並提供video作為媒體型態參數
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            debugPrint("=== AVCaptureDevice 初始化失敗")
            return
        }
        
        do {
            // 使用AVCaptureDevice物件取得AVCaptureDeviceInput類別的實體
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // 在captureSession 設定輸入裝置
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                debugPrint("=== captureSession 設定輸入裝置失敗")
                return
            }
            
            // 初始化AVCaptureMetadataOutput物件
            let output = AVCaptureMetadataOutput()
            
            // 在captureSession 設定擷取Session的輸出裝置
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
                
                // 設定代理並使用預設的調度佇列來執行回呼(call back)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                
                // 初始化影像預覽層，並將其加為目前視圖層的子層
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                if let videoPreviewLayer = videoPreviewLayer {
                    self.layer.addSublayer(videoPreviewLayer)
                }
                
                // 開始影像擷取
                if !captureSession.isRunning {
                    captureSession.startRunning()
                }
            } else {
                debugPrint("=== captureSession 設定擷取Session的輸出裝置失敗")
                return
            }
            
        } catch {
            debugPrint("=== AVCaptureDeviceInput 初始化失敗")
            return
        }
    }
}

extension QRcodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 { return }
        
        // 取得資料物件(metadata)
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        
        // 檢查物件資料是否為QRcode
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let data = metadataObj.stringValue {
                if captureSession.isRunning {
                    captureSession.stopRunning()
                }
                
                self.delegate?.catpureQRCode(string: data)
            }
        }
    }
}

