//
//  ServiceItemsTableView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol ServiceItemsTableViewDelegate: class {
    func didUpdateSvcItem(model: OrderSvcItemsModel)
    func didUpdateSvcCategory(array: [SvcCategoryModel])
}

class ServiceItemsTableView: UITableView {
    
    private var svcItemArray = [SvcCategoryModel]()
    private var orderSvcItemsModel: OrderSvcItemsModel?
    private var designerDetailModel: DesignerDetailModel?
    private var designerSvcItemModel: DesignerSvcItemsModel?
    private var mId: Int?
    private var dId: Int?
    private var moId: Int?
    private weak var targetVC: BaseViewController?
    private weak var serviceItemsTableViewDelegate: ServiceItemsTableViewDelegate?
    
    private let dispatchGroup = DispatchGroup()
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        register()
    }
    
    // MARK: Method
    /// 設計師：確認項目頁面
    func setupTableViewWith(mId: Int, dId: Int, moId: Int, targetViewController: BaseViewController?, delegate: ServiceItemsTableViewDelegate?) {
        self.mId = mId
        self.dId = dId
        self.moId = moId
        self.targetVC = targetViewController
        self.serviceItemsTableViewDelegate = delegate
    }
    
    /// 消費者：從設計師列表或設計師詳細頁點擊預約
    func setupTableViewWith(model: DesignerDetailModel, targetViewController: BaseViewController?) {
        self.designerDetailModel = model
        self.targetVC = targetViewController
    }
    
    func callAPI() {
        if UserManager.sharedInstance.userIdentity == .consumer {
            if designerSvcItemModel == nil {
                guard let mId = UserManager.sharedInstance.mId, let dId = designerDetailModel?.dId else {
                    SystemManager.showErrorAlert()
                    return
                }
                if SystemManager.isNetworkReachable() {
                    targetVC?.showLoading()
                    dispatchGroup.enter()
                    apiGetSvcItems(mId: mId, dId: dId)
                    
                    dispatchGroup.notify(queue: .main, execute: { [unowned self] in
                        self.resetSvcItemArray()
                        self.reloadData()
                        self.targetVC?.hideLoading()
                        self.targetVC?.removeMaskView()
                    })
                }
            }
        } else {
            if designerSvcItemModel == nil || orderSvcItemsModel == nil {
                guard let mId = mId, let dId = dId, let moId = moId else {
                    SystemManager.showErrorAlert(backToLoginVC: true)
                    return
                }
                if SystemManager.isNetworkReachable() {
                    targetVC?.showLoading()
                    dispatchGroup.enter()
                    apiGetSvcItems(mId: mId, dId: dId)
                    dispatchGroup.enter()
                    apiGetMemberOrderSvcItems(moId: moId)
                    
                    dispatchGroup.notify(queue: .main, execute: { [unowned self] in
                        self.resetSvcItemArray()
                        self.reloadData()
                        self.targetVC?.hideLoading()
                        self.targetVC?.removeMaskView()
                        
                        self.orderSvcItemsModel?.service.svcCategory = self.svcItemArray
                        if let svcItem = self.orderSvcItemsModel {
                            self.serviceItemsTableViewDelegate?.didUpdateSvcItem(model: svcItem)
                        }
                    })
                }
            }
        }
    }
    
    private func register() {
        self.register(UINib(nibName: String(describing: ServiceItemsTitleHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: ServiceItemsTitleHeaderView.self))
        self.register(UINib(nibName: String(describing: ServiceItemsContentHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: ServiceItemsContentHeaderView.self))
        self.register(UINib(nibName: String(describing: ServiceItemsSingleSelectionCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ServiceItemsSingleSelectionCell.self))
        self.register(UINib(nibName: String(describing: ServiceItemsMultipleSelectionCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ServiceItemsMultipleSelectionCell.self))
    }
    
    private func resetSvcItemArray() {
        for i in 0..<svcItemArray.count {
            if let index = orderSvcItemsModel?.service.svcCategory.index(of: svcItemArray[i]) {
                svcItemArray[i].selectSvcClass = orderSvcItemsModel?.service.svcCategory[index].svcClass
            } else {
                svcItemArray[i].selectSvcClass = [SvcClassModel(open: nil, name: "", price: nil, hours: nil, svcItems: nil, svcProduct: nil, dsciId: nil)]
            }
            svcItemArray[i].select = orderSvcItemsModel?.service.svcCategory.contains(svcItemArray[i]) ?? false
            svcItemArray[i].serviceItemArray = []
            
            let svcCategory = svcItemArray[i]
            if let svcClass = svcCategory.svcClass {
                for svcClass in svcClass {
                    if let svcItems = svcClass.svcItems {
                        for svcItem in svcItems {
                            let model = SvcClassModel(open: svcClass.open, name: svcClass.name, price: svcClass.price, hours: svcClass.hours, svcItems: [svcItem], svcProduct: svcClass.svcProduct, dsciId: svcClass.dsciId)
                            svcItemArray[i].serviceItemArray?.append(model)
                        }
                    } else {
                        svcItemArray[i].serviceItemArray?.append(svcClass)
                    }
                }
                
                if let type = svcCategory.type, type == "most" {
                    svcItemArray[i].selectionType = .MultipleSelection
                } else {
                    svcItemArray[i].selectionType = .SingleSelection
                }
            } else {
                svcItemArray[i].selectionType = .OnlySelect
            }
        }
    }
    
    private func checkSelectStatus() -> Bool {
        for model in svcItemArray {
            if model.select ?? false, model.selectionType != .OnlySelect {
                if let selectSvcClass = model.selectSvcClass, (selectSvcClass.filter{ $0.name.count == 0 }.count) > 0 {
                    SystemManager.showWarningBanner(title: "\(LocalizedString("Lang_RV_016"))「\(model.name)」\(LocalizedString("Lang_DD_007"))", body: LocalizedString("Lang_RV_017"))
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: API
    private func apiGetSvcItems(mId: Int, dId: Int) {
        ReservationManager.apiGetSvcItems(mId: mId, dId: dId, success: { [unowned self] (model) in
            if model?.syscode == 200 {
                self.designerSvcItemModel = model?.data
                if let svcItems = model?.data?.svcCategory {
                    self.svcItemArray = svcItems
                }
                self.dispatchGroup.leave()
            } else {
                self.targetVC?.endLoadingWith(model: model)
            }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
        })
    }
    
    private func apiGetMemberOrderSvcItems(moId: Int) {
        ReservationManager.apiGetMembersOrderSvcItems(moId: moId, success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                self.orderSvcItemsModel = model?.data
                self.dispatchGroup.leave()
            } else {
                self.targetVC?.endLoadingWith(model: model)
            }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
        })
    }
}

extension ServiceItemsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if svcItemArray.count > 0 {
            var count = svcItemArray.count + 1
            if (svcItemArray.filter{ $0.select == true }.count > 0) {
                count += 2
            }
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section > svcItemArray.count {
            return 0
        } else {
            switch svcItemArray[section - 1].selectionType! {
            case .OnlySelect: return 0
            case .SingleSelection: return 1
            case .MultipleSelection: return (svcItemArray[section - 1].selectSvcClass!.count == 0) ? 1 : svcItemArray[section - 1].selectSvcClass!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = svcItemArray[indexPath.section - 1]
        if model.selectionType! == .MultipleSelection {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceItemsMultipleSelectionCell.self), for: indexPath) as! ServiceItemsMultipleSelectionCell
            cell.setupCellWith(serviceItemArray: model.serviceItemArray!, selectSvcClass: model.selectSvcClass?[indexPath.row], indexPath: indexPath, delegate: self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ServiceItemsSingleSelectionCell.self), for: indexPath) as! ServiceItemsSingleSelectionCell
            cell.setupCellWith(serviceItemArray: model.serviceItemArray!, selectSvcClass: model.selectSvcClass?.first, indexPath: indexPath, delegate: self)
            return cell
        }
    }
}

extension ServiceItemsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (svcItemArray[indexPath.section - 1].selectionType! == .MultipleSelection) ? 50 : 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section <= svcItemArray.count {
            if section == 0 {
                #if SALONWALKER
                return titleHeaderView()
                #else
                return nil
                #endif
            } else {
                let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ServiceItemsTitleHeaderView.self)) as! ServiceItemsTitleHeaderView
                view.setupHeaderViewWith(model: svcItemArray[section - 1], section: section - 1, delegate: self)
                return view
            }
        } else {
            if section == svcItemArray.count + 1 {
                let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ServiceItemsContentHeaderView.self)) as! ServiceItemsContentHeaderView
                view.setupHeaderViewWith(model: svcItemArray)
                return view
            } else {
                #if SALONWALKER
                return nextStepHeaderView()
                #else
                return nil
                #endif
            }
        }
    }
    
    private func titleHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 130))
        
        let imageView = UIImageView(frame: CGRect(x: (screenWidth - 80) / 2, y: 15, width: 80, height: 80))
        imageView.image = UIImage(named: "logo__store")
        imageView.contentMode = .scaleAspectFill
        
        let label = UILabel(frame: CGRect(x: (screenWidth - 100) / 2, y: imageView.frame.maxY + 3, width: 100, height: 21))
        label.text = LocalizedString("Lang_DD_007")
        label.textColor = color_1A1C69
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        
        headerView.addSubview(imageView)
        headerView.addSubview(label)
        return headerView
    }
    
    #if SALONWALKER
    private func nextStepHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 130))
        
        let button = UIButton(frame: CGRect(x: screenWidth - 50 - 15, y: 50, width: 50, height: 50))
        button.setImage(UIImage(named: "ic_arrow_r_12x19"), for: .normal)
        button.backgroundColor = color_1A1C69
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 5
        button.layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 1
        button.addTarget(self, action: #selector(gotoReserveDate), for: .touchUpInside)
        
        let label = UILabel(frame: CGRect(x: button.frame.minX - 15 - 50, y: button.frame.midY - 10, width: 50, height: 20))
        label.text = LocalizedString("Lang_RD_032")
        label.textColor = .black
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        
        headerView.addSubview(button)
        headerView.addSubview(label)
        return headerView
    }
    
    @objc private func gotoReserveDate() {
        if checkSelectStatus() {
            let totalPrice = ReservationManager.calculateServiceTotalValue(selectCategory: svcItemArray, type: .Price)
            // 訂金計算方式：總金額大於300，訂金固定300；總價小於等於300，訂金收總金額的一半
            let deposit = (totalPrice > 300) ? 300 : totalPrice / 2
            let finalPayment = totalPrice - deposit
            designerSvcItemModel?.svcCategory = svcItemArray.filter{ $0.select ?? false }
            
            let model = ReservationManager.shared.reservationDetailModel
            ReservationManager.shared.reservationDetailModel = ReservationDetailModel(itemId: designerSvcItemModel?.itemId ,dId: designerDetailModel?.dId ,pId: nil, placeName: nil, nickName: designerDetailModel?.nickName, isTop: designerDetailModel?.isTop, headerImgUrl: designerDetailModel?.headerImgUrl, cityName: designerDetailModel?.cityName, langName: designerDetailModel?.langName, orderDate: model?.orderDate, orderTime: nil, week: model?.week, deposit: deposit, finalPayment: finalPayment, payType: LocalizedString("Lang_RV_015"), svcContent: designerSvcItemModel, hairStyle: model?.hairStyle, oepId: nil, photoImgUrl: nil, coverArray: model?.coverArray, refPhotoArray: model?.refPhotoArray)
            
            let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: ReserveDesignerDateViewController.self)) as! ReserveDesignerDateViewController
            self.targetVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    #endif
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section > svcItemArray.count {
            return nil
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            view.backgroundColor = color_EEEEEE
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            #if SALONWALKER
            return 130
            #else
            return CGFloat.leastNormalMagnitude
            #endif
        } else {
            if section <= svcItemArray.count {
                return 70
            } else if section == svcItemArray.count + 1 {
                return 180
            } else {
                #if SALONWALKER
                return 130
                #else
                return CGFloat.leastNormalMagnitude
                #endif
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section > svcItemArray.count {
            return CGFloat.leastNormalMagnitude
        } else {
            return 1
        }
    }
}

extension ServiceItemsTableView: ServiceItemsTitleHeaderViewDelegate {
    
    func didTapAt(_ section: Int) {
        
    }
    
    func didSelectAt(_ section: Int) {
        self.svcItemArray[section].select = !self.svcItemArray[section].select!
        self.reloadData()
        self.serviceItemsTableViewDelegate?.didUpdateSvcCategory(array: self.svcItemArray)
    }
}

extension ServiceItemsTableView: ServiceItemsSingleSelectionCellDelegate {
    
    func singleSelectItem(model: SvcClassModel, indexPath: IndexPath) {
        self.svcItemArray[indexPath.section - 1].selectSvcClass = [model]
        self.reloadData()
        self.serviceItemsTableViewDelegate?.didUpdateSvcCategory(array: self.svcItemArray)
    }
}

extension ServiceItemsTableView: ServiceItemsMultipleSelectionCellDelegate {
    
    func multipleSelectItem(model: SvcClassModel, indexPath: IndexPath) {
        self.svcItemArray[indexPath.section - 1].selectSvcClass?[indexPath.row] = model
        self.reloadData()
        self.serviceItemsTableViewDelegate?.didUpdateSvcCategory(array: self.svcItemArray)
    }
    
    func didPressAddButtonAt(_ indexPath: IndexPath) {
        self.svcItemArray[indexPath.section - 1].selectSvcClass?.append(SvcClassModel(open: nil, name: "", price: nil, hours: nil, svcItems: nil, svcProduct: nil, dsciId: nil))
        self.reloadData()
        self.serviceItemsTableViewDelegate?.didUpdateSvcCategory(array: self.svcItemArray)
    }
    
    func didPressDeleteButtonAt(_ indexPath: IndexPath) {
        self.svcItemArray[indexPath.section - 1].selectSvcClass?.remove(at: indexPath.row)
        self.reloadData()
        self.serviceItemsTableViewDelegate?.didUpdateSvcCategory(array: self.svcItemArray)
    }
}

