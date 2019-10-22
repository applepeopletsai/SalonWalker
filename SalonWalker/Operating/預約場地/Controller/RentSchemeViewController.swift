//
//  RentSchemeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol RentSchemeViewControllerDelegate: class {
    func confirmButtonPressWith(selectModel: Codable, purchase: Bool)
}

class RentSchemeViewController: BaseViewController {
 
    @IBOutlet private weak var confirmButton: IBInspectableButton!
    @IBOutlet private weak var topMenuVIew: TopMenuView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var model: SvcPricesModel.LongLease?
    private var selectModel: LongLeasePricesModel?
    private var purchase: Bool?
    private var showSchemeType: ShowPaySchemeType = .check
    private var chooseSchemeType: PaySchemeType = .hour
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let purchaseVC = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchaseViewController.self)) as! PurchaseViewController
    private let notPurchaseVC = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: NotPurchaseViewController.self)) as! NotPurchaseViewController
    private weak var delegate: RentSchemeViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: Method
    func setupVCWith(model: SvcPricesModel.LongLease, showSchemeType: ShowPaySchemeType , chooseSchemeType: PaySchemeType, delegate: RentSchemeViewControllerDelegate) {
        self.model = model
        self.showSchemeType = showSchemeType
        self.chooseSchemeType = chooseSchemeType
        self.delegate = delegate
    }
    
    private func initialize() {
        let purchaseArray = model?.purchasedItems ?? []
        purchaseVC.setupVCWith(dataArray: purchaseArray, showSchemeType: showSchemeType, chooseSchemeType: chooseSchemeType, delegate: self)
        let notPurchaseArray = model?.notPurchased ?? []
        notPurchaseVC.setupVCWith(dataArray: notPurchaseArray, showSchemeType: showSchemeType, chooseSchemeType: chooseSchemeType, delegate: self)
        
        pageMenuControl.setupPageViewWith(topView: topMenuVIew, scrollView: scrollView, titles: [LocalizedString("Lang_PS_007"),LocalizedString("Lang_PS_008")], childVCs: [purchaseVC,notPurchaseVC], baseVC: self, delegate: self, showBorder: true)
        
        self.confirmButton.isHidden = (showSchemeType == .check)
    }
    
    // MARK: Event Handler
    @IBAction func dismissButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonClick(_ sender: UIButton) {
        if let model = selectModel, let purchase = purchase {
            self.delegate?.confirmButtonPressWith(selectModel: model, purchase: purchase)
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension RentSchemeViewController: PurchaseViewControllerDelegate, NotPurchaseViewControllerDelegate {
    func didSelectPaymentTypeWith(model: LongLeasePricesModel, purchase: Bool) {
        self.selectModel = model
        if purchase {
            notPurchaseVC.resetSelectStatus()
        } else {
            purchaseVC.resetSelectStatus()
        }
        self.purchase = purchase
        self.confirmButton.isEnabled = true
    }
}

extension RentSchemeViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
    }
}
