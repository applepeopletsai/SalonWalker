//
//  ServiceProductPhotoViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ServiceProductPhotoViewControllerDelegate: class {
    func didFinfishEditProductPhoto(product: [SvcProductModel])
}

class ServiceProductPhotoViewController: BaseViewController {

    @IBOutlet private var naviTitleLabel: UILabel!
    @IBOutlet private var tableView: ServiceProductPhotoTableView!
    
    private var productArray = [SvcProductModel]()
    private var serviceName: String?
    private weak var delegate: ServiceProductPhotoViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    // MARK: Method
    func setupVCWith(product: [SvcProductModel], serviceName: String, delegate: ServiceProductPhotoViewControllerDelegate?) {
        self.productArray = product
        self.serviceName = serviceName
        self.delegate = delegate
    }
    
    private func initialize() {
        naviTitleLabel.text = serviceName
        tableView.setupTableViewWith(photoArray: productArray, targetViewController: self, delegate: self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    }
    
    // MARK: Event Handler
    @IBAction private func finishButtonPress() {
        tableView.finishEditPhoto()
    }
}

extension ServiceProductPhotoViewController: ServiceProductPhotoTableViewDelegate {
    
    func didSelectPhotoWith(productArray: [SvcProductModel]) {
        self.delegate?.didFinfishEditProductPhoto(product: productArray)
    }
}

