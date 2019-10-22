//
//  FixPriceViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

let kReFlashServicePriceVC = "ReFlashServicePriceVC"

class FixPriceViewController: BaseViewController {

    @IBOutlet weak var naviTitleLabel: UILabel!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var tableView: UITableView!

    private var svcItemsInfoModel: SvcItemsInfoModel?
    private var svcCategory: SvcCategoryModel?
    private var editIndex: Int?
    private var editProductIndex: Int?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerHeaderView()
        setupUI()
    }
    
    // MARK: EventHandler
    @IBAction func saveButtonClick(_ sender: UIButton) {
        apiSetSvcItems()
    }
    
    // MARK: Method
    func setupVCWith(svcItemsInfoModel: SvcItemsInfoModel?, editIndex: Int) {
        self.svcItemsInfoModel = svcItemsInfoModel
        self.svcCategory = svcItemsInfoModel?.svcCategory?[editIndex]
        self.editIndex = editIndex
    }
    
    private func setupUI() {
        if let model = svcCategory {
            self.naviTitleLabel.text = model.name + LocalizedString("Lang_AC_046")
            self.serviceNameLabel.text = model.name
            if let iconUrl = model.iconUrl {
                self.serviceImageView.setImage(with: iconUrl)
            }
            if model.svcClass == nil {
                self.lineView.isHidden = true
            }
        }
    }
    
    private func registerHeaderView() {
        tableView.register(UINib(nibName: "EditServicePriceHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "EditServicePriceHeaderView")
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReFlashServicePriceVC), object: nil)
    }
    
    private func gotoEditPhotoVC(product: [SvcProductModel], index: Int) {
        let serviceName = (self.svcCategory?.name ?? "") + " " + (self.svcCategory?.svcClass?[index].name ?? "")
        let vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceProductPhotoViewController.self)) as! ServiceProductPhotoViewController
        vc.setupVCWith(product: product, serviceName: serviceName, delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API
    private func apiSetSvcItems() {
        if SystemManager.isNetworkReachable() {
            if let svcCategory = svcCategory, let index = editIndex {
                self.showLoading()
                self.svcItemsInfoModel?.svcCategory?[index] = svcCategory
                guard let model = self.svcItemsInfoModel else { return }
                DesignerServiceManager.apiSetSvcItems(model: model, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                        self.hideLoading()
                        self.postNotification()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
}

extension FixPriceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return svcCategory?.svcClass?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return svcCategory?.svcClass?[section].svcItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = svcCategory else { return UITableViewCell() }
        if svcCategory?.svcClass == nil { // 大
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditServicePriceCell_Big", for: indexPath) as! EditServicePriceCell
            cell.setupCellWith(price: model.price, delegate: self, indexPath: indexPath)
            return cell
        } else {
            if svcCategory?.svcClass?[indexPath.section].svcItems == nil { // 中
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditServicePriceCell_Middle", for: indexPath) as! EditServicePriceCell
                let svcClass = model.svcClass?[indexPath.section]
                cell.setupCellWith(price: (svcClass?.price), delegate: self, indexPath: indexPath)
                return cell
            } else { // 小
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditServicePriceCell_Small", for: indexPath) as! EditServicePriceCell
                let svcItem = model.svcClass?[indexPath.section].svcItems?[indexPath.row]
                cell.setupCellWith(title: svcItem?.name, price: svcItem?.price, delegate: self, indexPath: indexPath)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if svcCategory?.svcClass == nil { // 大
            return 35
        } else {
            if svcCategory?.svcClass?[indexPath.section].svcItems == nil { // 中
                return 45
            } else { // 小
                return 35
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if svcCategory?.svcClass != nil {
            return 45
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if svcCategory?.svcClass != nil {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EditServicePriceHeaderView") as! EditServicePriceHeaderView
            if let model = svcCategory?.svcClass?[section] {
                headerView.setupHeaderWith(model: model, section: section, delegate: self)
            }
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if svcCategory?.svcClass != nil {
            return 15
        }
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if svcCategory?.svcClass != nil {
            let baseView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 15))
            let underLine = UIView(frame: CGRect(x: 65, y: 14, width: screenWidth - 65, height: 1))
            underLine.backgroundColor = color_C6C6C6
            underLine.layer.opacity = 0.4
            underLine.alpha = 0.4
            baseView.addSubview(underLine)
            return baseView
        }
        return nil
    }
}

extension FixPriceViewController: EditServicePriceHeaderViewDelegate {
    func didTapTickButtonAt(_ section: Int) {
        if let open = self.svcCategory?.svcClass?[section].open {
            self.svcCategory?.svcClass?[section].open = !open
        }
    }
    
    func didTapPhotoButtonAt(_ section: Int) {
        editProductIndex = section
        
        let product = self.svcCategory?.svcClass?[section].svcProduct ?? []
        if product.count == 0 {
            PresentationTool.showImagePickerWith(selectAssets: nil, target: self)
        } else {
            self.gotoEditPhotoVC(product: product, index: section)
        }
    }
}

extension FixPriceViewController: EditServicePriceCellDelegate {
    func didChangePrice(_ price: Int?, at indexPath: IndexPath) {
        if svcCategory?.svcClass == nil { // 大
            self.svcCategory?.price = price
        } else {
            if svcCategory?.svcClass?[indexPath.section].svcItems == nil { // 中
                self.svcCategory?.svcClass?[indexPath.section].price = price
            } else { // 小
                self.svcCategory?.svcClass?[indexPath.section].svcItems?[indexPath.row].price = price
            }
        }
    }
}

extension FixPriceViewController: ServiceProductPhotoViewControllerDelegate {
    func didFinfishEditProductPhoto(product: [SvcProductModel]) {
        if let index = editProductIndex {
            self.svcCategory?.svcClass?[index].svcProduct = product
            self.tableView.reloadData()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension FixPriceViewController: MultipleSelectImageViewControllerDelegate {
    func didSelectAssets(_ assets: [MultipleAsset]) {
        var product = [SvcProductModel]()
        assets.forEach {
            product.append(SvcProductModel(dsciId: nil, brand: nil, product: nil, imgUrl: nil, imageLocalIdentifier: $0.localIdentifier))
        }
        if let index = editProductIndex {
            self.gotoEditPhotoVC(product: product, index: index)
        }
    }
    
    func didCancel() {}
}
