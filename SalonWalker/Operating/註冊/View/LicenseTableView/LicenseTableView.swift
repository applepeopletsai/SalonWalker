//
//  LicenseTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let licenseCellHeight: CGFloat = 35.0

protocol LicenseTableViewDelegate: class {
    func updateLicenseData(with licenseArray: [LicenseImg])
    func deleteLicense(at index: Int)
}

class LicenseTableView: UITableView {

    private var licenseArray = [LicenseImg]()
    private weak var targetVC: BaseViewController?
    private weak var licenseTableViewDelegate: LicenseTableViewDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        registerCell()
    }
    
    // MARK: Method
    func setupTableViewWith(licenseArray: [LicenseImg], targetViewController: BaseViewController, delegate: LicenseTableViewDelegate) {
        self.licenseArray = licenseArray
        self.targetVC = targetViewController
        self.licenseTableViewDelegate = delegate
        self.reloadData()
    }
    
    func reloadDataWithLicenseArray(_ licenseArray: [LicenseImg]) {
        self.licenseArray = licenseArray
        self.reloadData()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: "LicenseCell", bundle: nil), forCellReuseIdentifier: String(describing: LicenseCell.self))
    }
    
    // MARK: API
    private func apiTempImage(imageString: String?, row: Int = 0) {
        targetVC?.showLoading()
        
        SystemManager.apiTempImage(imageType: "jpeg", image: imageString, fbImgUrl: nil, googleImgUrl: nil, tempImgId: nil, mId: nil, ouId: nil, licenseImgId: nil, coverImgId: nil, act: "new", success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                if let url = model?.data?.imgUrl, let id = model?.data?.tempImgId {
                    self.licenseArray[row].imgUrl = url
                    self.licenseArray[row].tempImgId = id
                    self.reloadData()
                }
                self.licenseTableViewDelegate?.updateLicenseData(with: self.licenseArray)
                self.targetVC?.hideLoading()
            } else {
                self.targetVC?.endLoadingWith(model: model)
            }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
        })
    }
}


extension LicenseTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LicenseCell.self), for: indexPath) as! LicenseCell
        cell.setupCellWith(model: licenseArray[indexPath.row], row: indexPath.row, target: self)
        return cell
    }
}

extension LicenseTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return licenseCellHeight
    }
}

extension LicenseTableView: LicenseCellDelegate {
    func choosePhotoWith(row: Int, image: UIImage, localIdentifier: String) {
        if SystemManager.isNetworkReachable() {
            licenseArray[row].imageLocalIdentifier = localIdentifier
            licenseArray[row].act = (licenseArray[row].act == "add") ? "add" : "edit"
            apiTempImage(imageString: image.transformToBase64String(format: .jpeg(0.5)), row: row)
        }
    }
    
    func didEnterLicenseNameWith(row: Int, name: String) {
        licenseArray[row].name = name
        licenseArray[row].act = (licenseArray[row].act == "add") ? "add" : "edit"
        licenseTableViewDelegate?.updateLicenseData(with: licenseArray)
    }
    
    func decreaseLicenseWithRow(_ row: Int) {
        licenseTableViewDelegate?.deleteLicense(at: row)
        licenseArray.remove(at: row)
        reloadData()
    }
    
}
