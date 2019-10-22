//
//  FilterView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/6/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol FilterViewDelegate: class {
    func didPressFinishButton(_ model: CityCodeModel.CityModel?)
    func didPressSearchButton(_ model: CityCodeModel.CityModel?)
    func didSelectRecentSearch(_ model: CityCodeModel.CityModel?)
}

class FilterView: UIView {
    
    @IBOutlet private weak var searchTextField: IBInspectableTextField!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var filterImageView: UIImageView!
    @IBOutlet private weak var filterLabel: IBInspectableLabel!

    private var targetVC: UIViewController?
    private weak var delegate: FilterViewDelegate?
    
    private var locationFilterView: LocationFilterView?
    private var selectCity: [Int] = []
    private var selectDistrict: [Int] = []
    private var filterModel: CityCodeModel.CityModel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            self.loadViewFromNib()
            self.setupLocationFilterView()
            self.setupTextField()
        }
    }
    
    // MARK: Method
    func setupFilterViewWith(targetVC: UIViewController, delegate: FilterViewDelegate) {
        self.targetVC = targetVC
        self.delegate = delegate
    }
    
    func checkRecentSearchData() {
        self.locationFilterView?.checkRecentSearchData()
    }
    
    private func loadViewFromNib() {
        guard let view = Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        addSubview(view)
        view.frame = bounds
        view.backgroundColor = self.backgroundColor
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setupLocationFilterView() {
        if SystemManager.getCityCodeModel() != nil {
            let y = (self.superview == self.targetVC?.view) ? frame.maxY : self.superview!.frame.maxY
            self.locationFilterView = LocationFilterView.initWith(frame: CGRect(x: 0, y: y, width: screenWidth, height: screenHeight), delegate: self)
        } else {
            self.apiGetCityCode { [unowned self] in
                self.setupLocationFilterView()
            }
        }
    }
    
    private func setupTextField() {
        searchTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(textFieldDoneButtonPress))
        searchTextField.placeHolderLocolizedKey = (UserManager.sharedInstance.userIdentity == .designer) ? "Lang_HM_028" : "Lang_HM_027"
    }
    
    @objc func textFieldDoneButtonPress() {
        
    }
    
    private func resetFilterUIColor() {
        self.filterLabel.textColor = (self.selectCity.count != 0) ? color_2F10A0 : .black
        self.filterImageView.image = (self.selectCity.count != 0) ? UIImage(named: "icon_landmark_selected") : UIImage(named: "icon_landmark_b")
    }
    
    private func showOrHideFilterView(_ byPressButton: Bool = false) {
        if self.locationFilterView == nil { return }
        
        if self.filterButton.isSelected {
            self.targetVC?.view.addSubview(locationFilterView!)
        } else {
            if byPressButton {
                self.locationFilterView?.resetSelectStatus()
            } else {
                self.locationFilterView?.removeFromSuperview()
            }
        }
    }
    
    private func resetFilterModel() {
        let keywordEmpty = (searchTextField.text?.count == 0)
        if let first = self.selectCity.first {
            let city = SystemManager.getCityCodeModel()!.city[first]
            var areaArray:[CityCodeModel.AreaModel] = []
            
            if let areas = city.area {
                for index in self.selectDistrict {
                    areaArray.append(areas[index])
                }
            }
            
            self.filterModel = CityCodeModel.CityModel(areaRangCode: city.areaRangCode, cityName: city.cityName, area: areaArray, keyword: keywordEmpty ? nil : searchTextField.text)
        } else if !keywordEmpty {
            self.filterModel = CityCodeModel.CityModel(areaRangCode: nil, cityName: nil, area: nil, keyword: searchTextField.text)
        } else {
            self.filterModel = nil
        }
    }
    
    private func saveFilterModel() {
        self.resetFilterModel()
        if let filerModel = self.filterModel {
            if UserManager.getBrowsingRecord() {
                UserManager.saveRecentSearch(filerModel)
            }
        }
    }
    
    // MARK: Event Handler
    @IBAction private func filterButtonPress(_ sender: UIButton) {
        self.searchTextField.resignFirstResponder()
        
        if SystemManager.getCityCodeModel() == nil {
            self.apiGetCityCode { [unowned self] in
                self.filterButton.isSelected = true
                self.showOrHideFilterView()
            }
        } else {
            sender.isSelected = !sender.isSelected
            self.showOrHideFilterView(true)
        }
    }
    
    // MARK: API
    private func apiGetCityCode(_ success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            SystemManager.showLoading()
            SystemManager.apiGetCityCode(success: { (model) in
                if model?.syscode == 200 {
                    if let cityCodeModel = model?.data {
                        SystemManager.saveCityCodeModel(cityCodeModel)
                        success?()
                    }
                    SystemManager.hideLoading()
                } else {
                    if model?.syscode == 501 { // 501代表已有相同帳號在其他地方登入
                        SystemManager.showAlertWith(alertTitle: model?.sysmsg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            SystemManager.backToLoginVC()
                        })
                    } else {
                        let alert = (model == nil) ? LocalizedString("Lang_GE_014") : model?.sysmsg
                        SystemManager.showAlertWith(alertTitle: alert, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
                    }
                    SystemManager.hideLoading()
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension FilterView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.locationFilterView?.resetSelectStatus()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.saveFilterModel()
        textField.resignFirstResponder()
        self.delegate?.didPressSearchButton(filterModel)
        return true
    }
}

extension FilterView: LocationFilterViewDelegate {
    
    func finishButtonPressWith(selectCity: [Int], selectDistrict: [Int]) {
        self.filterButton.isSelected = false
        self.selectCity = selectCity
        self.selectDistrict = selectDistrict
        self.resetFilterUIColor()
        self.showOrHideFilterView()
        self.saveFilterModel()
        self.delegate?.didPressFinishButton(filterModel)
    }
    
    func didSelectItemWith(currentSelectCity: [Int], currentSelectDistrict: [Int]) {
        self.selectCity = currentSelectCity
        self.selectDistrict = currentSelectDistrict
        self.resetFilterUIColor()
    }
    
    func didSelectRecentSearch(_ model: CityCodeModel.CityModel) {
        self.filterButton.isSelected = false
        self.showOrHideFilterView()
        self.filterModel = model
        self.delegate?.didSelectRecentSearch(filterModel)
    }
    
    func didTapBlackAreaWith(selectCity: [Int], selectDistrict: [Int]) {
        self.filterButton.isSelected = false
        self.selectCity = selectCity
        self.selectDistrict = selectDistrict
        self.resetFilterUIColor()
        self.showOrHideFilterView()
    }
}
