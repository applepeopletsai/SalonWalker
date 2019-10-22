//
//  ServiceProductPhotoTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/12.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

protocol ServiceProductPhotoTableViewDelegate: class {
    func didSelectPhotoWith(productArray: [SvcProductModel])
}

class ServiceProductPhotoTableView: UITableView {

    private var productArray = [SvcProductModel]()
    private var uploadFailIndexArray = [Int]()
    private weak var targetVC: BaseViewController?
    private weak var serviceProductPhotoTableViewDelegate: ServiceProductPhotoTableViewDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        self.registerCell()
    }
    
    func setupTableViewWith(photoArray: [SvcProductModel], targetViewController: BaseViewController, delegate: ServiceProductPhotoTableViewDelegate?) {
        self.productArray = photoArray
        self.targetVC = targetViewController
        self.serviceProductPhotoTableViewDelegate = delegate
    }
    
    func finishEditPhoto() {
        if checkProductField() {
            let newProductArray = productArray.filter{ $0.dsciId == nil }
            if newProductArray.count > 0 {
                
                if SystemManager.isNetworkReachable() {
                    uploadFailIndexArray.removeAll()
                    
                    var imageStringArray = [String?]()
                    
                    newProductArray.forEach {
                        let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [$0.imageLocalIdentifier ?? ""], options: nil)
                        
                        if let phAsset = phAssets.firstObject {
                            let asset = MultipleAsset(originalAsset: phAsset)
                            asset.fetchOriginalImage(completeBlock: { [unowned self] (image, info) in
                                imageStringArray.append(image?.transformToBase64String(format: .jpeg(1.0)))
                                
                                if imageStringArray.count == newProductArray.count {
                                    self.apiAddProductTempImage(imageStringArray: imageStringArray, index: 0)
                                }
                            })
                        }
                    }
                }
            } else {
                self.serviceProductPhotoTableViewDelegate?.didSelectPhotoWith(productArray: productArray)
            }
        }
    }
    
    private func registerCell() {
        self.register(UINib(nibName: String(describing: ServiceProductPhotoCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ServiceProductPhotoCell.self))
        self.register(UINib(nibName: String(describing: ServiceProductAddPhotoCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ServiceProductAddPhotoCell.self))
    }

    private func checkProductField() -> Bool {
        for product in productArray {
            if (product.brand?.count ?? 0) == 0 || (product.product?.count ?? 0) == 0 {
                SystemManager.showWarningBanner(title: LocalizedString("Lang_AC_055"), body: "")
                return false
            }
        }
        return true
    }
    
    private func shouldRecallAPI(imageStringArray: [String?], index: Int) {
        if index < imageStringArray.count - 1 {
            self.apiAddProductTempImage(imageStringArray: imageStringArray, index: index + 1)
        } else {
            // 將上傳失敗的照片刪除
            if self.uploadFailIndexArray.count != 0 {
                self.productArray = self.productArray.enumerated().filter{ !self.uploadFailIndexArray.contains($0.offset) }.map{ $0.element }
                self.reloadData()
                SystemManager.showWarningBanner(title: LocalizedString("Lang_GE_028"), body: LocalizedString("Lang_RT_026"))
            }
            self.serviceProductPhotoTableViewDelegate?.didSelectPhotoWith(productArray: productArray)
        }
    }
    
    // MARK: API
    private func apiAddProductTempImage(imageStringArray: [String?], index: Int) {
        self.targetVC?.showLoading()
        
        let editIndex = productArray.count - imageStringArray.count + index
        SystemManager.apiProductTempImage(image: imageStringArray[index], dscild: nil, brand: productArray[editIndex].brand, product: productArray[editIndex].product, act: "new", success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                if let url = model?.data?.imgUrl, let dsciId = model?.data?.dsciId {
                    self.productArray[editIndex].imgUrl = url
                    self.productArray[editIndex].dsciId = dsciId
                } else {
                    self.uploadFailIndexArray.append(editIndex)
                }
            } else if model?.syscode == 501 {
                self.targetVC?.endLoadingWith(model: model)
                return
            } else {
                self.uploadFailIndexArray.append(editIndex)
            }
            
            self.shouldRecallAPI(imageStringArray: imageStringArray, index: index)
            
        }, failure: { (error) in
            SystemManager.showErrorAlert(error: error)
        })
    }
    
}

extension ServiceProductPhotoTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceProductAddPhotoCell.self), for: indexPath) as! ServiceProductAddPhotoCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceProductPhotoCell.self), for: indexPath) as! ServiceProductPhotoCell
            cell.setupCellWith(model: productArray[indexPath.row - 1], indexPath: indexPath, delegate: self)
            return cell
        }
    }
}

extension ServiceProductPhotoTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 70
        } else {
            return screenWidth + 25 * 2 + 10 * 2 + 5 * 2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 點擊新增更多
            var selectAssets = [MultipleAsset]()
            productArray.filter{ $0.imageLocalIdentifier != nil }.forEach {
                let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [$0.imageLocalIdentifier ?? ""], options: nil)
                if let phAsset = phAssets.firstObject {
                    let asset = MultipleAsset(originalAsset: phAsset)
                    selectAssets.append(asset)
                }
            }
            PresentationTool.showImagePickerWith(selectAssets: selectAssets, showVideo: false, target: self)
        }
    }
}

extension ServiceProductPhotoTableView: ServiceProductPhotoCellDelegate {
    func didUpdateData(productBrand: String?, productName: String?, indexPath: IndexPath) {
        productArray[indexPath.row - 1].brand = productBrand
        productArray[indexPath.row - 1].product = productName
    }
    
    func deleteButtonPressAtIndexPath(_ indexPath: IndexPath) {
        productArray.remove(at: indexPath.row - 1)
        reloadData()
    }
}

extension ServiceProductPhotoTableView: MultipleSelectImageViewControllerDelegate {
    
    func didSelectAssets(_ assets: [MultipleAsset]) {
        productArray = productArray.filter{ $0.dsciId != nil || $0.imageLocalIdentifier != nil }
        
        var array = [SvcProductModel]()
        assets.forEach { (asset) in
            let sameImage = productArray.contains { (model) -> Bool in
                return asset.localIdentifier == (model.imageLocalIdentifier ?? "")
            }
            if !sameImage {
                array.append(SvcProductModel(dsciId: nil, brand: nil, product: nil, imgUrl: nil, imageLocalIdentifier: asset.localIdentifier))
            }
        }
        productArray.append(contentsOf: array)
        self.reloadData()
    }
    
    func didCancel() {}
}

