//
//  QRcodeScannerViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ScanType {
    case SignIn, SignOut
}

protocol QRcodeScannerViewControllerDelegate: class {
    func didCatpureQRCode(string: String)
}

class QRcodeScannerViewController: BaseViewController {

    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var scanView: QRcodeScannerView!
    @IBOutlet private weak var tutorScanButton: IBInspectableButton!
    @IBOutlet private weak var tutorScanButtonWidth: NSLayoutConstraint!

    private var scanType: ScanType = .SignIn
    private weak var delegate: QRcodeScannerViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: Method
    func setupVCWith(type: ScanType, delegate: QRcodeScannerViewControllerDelegate?) {
        self.scanType = type
        self.delegate = delegate
    }
    
    func reStartScanner() {
        scanView.reStartScanner()
    }
    
    private func initialize() {
        naviTitleLabel.text = (scanType == .SignIn) ? LocalizedString("Lang_SD_005") : LocalizedString("Lang_SD_006")
        scanView.delegate = self
        
        if let tutor: String = tutorScanButton.titleLabel?.text {
            let frame = tutorScanButton.frame
            tutorScanButtonWidth.constant = tutor.width(withConstrainedHeight: frame.size.height, font: (tutorScanButton.titleLabel?.font)!) + 40
        }
    }
    
    @objc private func dismissTutor() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Event Handler
    @IBAction private func scanTutorButtonPress(_ sender: UIButton) {
        let vc = UIViewController()
        vc.view.frame = UIApplication.shared.keyWindow?.frame ?? CGRect.zero
        let imageView = UIImageView(frame: vc.view.frame)
        imageView.image = UIImage(named: "G_3.0-001_1_place_qrcode")
        imageView.contentMode = .scaleAspectFill
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismissTutor))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        vc.view.addSubview(imageView)
        self.present(vc, animated: true, completion: nil)
    }
}

extension QRcodeScannerViewController: QRcodeScannerViewDelegate {
    
    func catpureQRCode(string: String) {
        print("=== catpureQRCode: \(string)")
        self.delegate?.didCatpureQRCode(string: string)
    }
}


