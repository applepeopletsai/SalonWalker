//
//  HairTypeViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit


protocol PersonalHairDataViewControllerDelegate: class {
    func changeCustomerData(model: CustomerDataModel, dataChanged: Bool)
}

class PersonalHairDataViewController: BaseViewController {

    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private var buttons: [UIButton]!
    
    private weak var delegate: PersonalHairDataViewControllerDelegate?
    
    private var mId: Int?
    private var model: CustomerDataModel?
    private var selectHairType_original: Int?
    private var scalp_original: Int?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Method
    func setupVCWith(mId: Int?, delegate: PersonalHairDataViewControllerDelegate) {
        self.mId = mId
        self.delegate = delegate
    }
    
    func callAPI() {
        if model == nil {
            apiGetCustomerData()
        }
    }
    
    private func setupUI() {
        if let model = model {
            buttons.forEach { (button) in
                button.isSelected = (model.hairType == button.tag)
            }
            slider.value = Float(model.scalp)
            
            selectHairType_original = model.hairType
            scalp_original = model.scalp
        }
    }
    
    private func changeCustomerData() {
        if let model = model {
            let changedData = selectHairType_original != model.hairType || scalp_original != model.scalp
            delegate?.changeCustomerData(model: model, dataChanged: changedData)
        }
    }
    
    // MARK: Event Handler
    @IBAction private func buttonPress(_ sender: UIButton) {
        buttons.forEach { (button) in
            button.isSelected = (button.tag == sender.tag)
        }
        model?.hairType = sender.tag
        changeCustomerData()
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        model?.scalp = Int(sender.value)
        changeCustomerData()
    }

    // MARK: API
    private func apiGetCustomerData() {
        guard let mId = mId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            CustomerManager.apiGetCustomerData(mId: mId, success: { (model) in
                if model?.syscode == 200 {
                    self.model = model?.data
                    self.setupUI()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}
