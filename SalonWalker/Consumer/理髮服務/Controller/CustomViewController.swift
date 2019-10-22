//
//  CustomViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class CustomViewController: BaseViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var filterAgainView: UIView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var designerListView: UIView!
    @IBOutlet private weak var tableView: DesignerInfoTableView!
    @IBOutlet private weak var cityLabel: IBInspectableLabel!
    @IBOutlet private weak var areaLabel: IBInspectableLabel!
    @IBOutlet private weak var maleButton: IBInspectableButton!
    @IBOutlet private weak var femaleButton: IBInspectableButton!
    @IBOutlet private weak var sexRegardlessButton: IBInspectableButton!
    @IBOutlet private weak var starSlider: RangeSlider!
    @IBOutlet private weak var starLabel: IBInspectableLabel!
    @IBOutlet private weak var yearSlider: RangeSlider!
    @IBOutlet private weak var yearLabel: IBInspectableLabel!
    @IBOutlet private weak var haveButton: IBInspectableButton!
    @IBOutlet private weak var nonButton: IBInspectableButton!
    @IBOutlet private weak var licenseRegardlessButton: IBInspectableButton!
    @IBOutlet private weak var designerListFilterAgainViewHeight: NSLayoutConstraint!
    
    private var selectCity: CityCodeModel.CityModel?
    private var selectArea: CityCodeModel.AreaModel?
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    private var designerListArray: [DesignerListModel] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupButton()
        self.tableView.setupTableViewWith(targetViewController: self, tableViewType: .Custom, delegate: self)
    }
    
    // MARK: Method
    private func setupViews() {
        self.filterView.isHidden = false
        self.filterAgainView.isHidden = true
        self.designerListView.isHidden = true
    }
    
    private func setupButton() {
        sexRegardlessButton.isSelected = true
        sexRegardlessButton.backgroundColor = color_1A1C69
        licenseRegardlessButton.isSelected = true
        licenseRegardlessButton.backgroundColor = color_1A1C69
    }
    
    private func showCityPickerView() {
        var selectIndex = 0
        if let index = SystemManager.getSelectCityIndex(city: selectCity) {
            selectIndex = index
        }
        PresentationTool.showPickerWith(itemArray: SystemManager.getCityNameArray(), selectedIndex: selectIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            if SystemManager.getSelectCityIndex(city: self.selectCity) != index {
                self.cityLabel.text = item
                self.cityLabel.textColor = .black
                self.areaLabel.text = LocalizedString("Lang_HM_022")
                self.areaLabel.textColor = color_C7C7CD
                self.selectCity = SystemManager.getCityCodeModel()?.city[index]
                self.selectArea = nil
            }
        })
    }
    
    // MARK: Event Handler
    @IBAction private func cityButtonPress() {
        if SystemManager.getCityCodeModel() != nil {
            self.showCityPickerView()
        } else {
            self.apiGetCityCode { [unowned self] in
                self.showCityPickerView()
            }
        }
    }
    
    @IBAction private func areaButtonPress() {
        if selectCity == nil {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_HM_026"), body: "")
            return
        }
        var selectIndex = 0
        if let index = SystemManager.getSelectAreaIndex(city: selectCity, area: selectArea) {
            selectIndex = index
        }
        PresentationTool.showPickerWith(itemArray: SystemManager.getAreaNameArray(city: selectCity!), selectedIndex: selectIndex, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            self.areaLabel.text = item
            self.areaLabel.textColor = .black
            self.selectArea = self.selectCity?.area?[index]
        })
    }
    
    @IBAction private func genderButtonPress(_ sender: IBInspectableButton) {
        maleButton.isSelected = false
        femaleButton.isSelected = false
        sexRegardlessButton.isSelected = false
        maleButton.backgroundColor = color_EEE9FE
        femaleButton.backgroundColor = color_EEE9FE
        sexRegardlessButton.backgroundColor = color_EEE9FE
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = (sender.isSelected) ? color_1A1C69 : color_EEE9FE
    }
    
    @IBAction private func rangeSliderValueChange(_ sender: RangeSlider) {
        let lowerString = String(Int(round(sender.lowerValue)))
        var upperString = String(Int(round(sender.upperValue)))
        switch sender.tag {
        case 0:
            self.starLabel.text = "\(lowerString)-\(upperString)\(LocalizedString("Lang_HM_035"))"
            break
        case 1:
            if Int(round(sender.upperValue)) == 25 {
                upperString += "+"
            }
            self.yearLabel.text = "\(lowerString)-\(upperString)\(LocalizedString("Lang_RT_015"))"
            break
        default:
            break
        }
    }
    
    @IBAction private func licenseButtonPress(_ sender: IBInspectableButton) {
        haveButton.isSelected = false
        nonButton.isSelected = false
        licenseRegardlessButton.isSelected = false
        haveButton.backgroundColor = color_EEE9FE
        nonButton.backgroundColor = color_EEE9FE
        licenseRegardlessButton.backgroundColor = color_EEE9FE
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = (sender.isSelected) ? color_1A1C69 : color_EEE9FE
    }
    
    @IBAction private func filterButtonPress(_ sender: IBInspectableButton) {
        let userLocation = LocationManager.userLastLocation().coordinate
        var sex: String?
        if maleButton.isSelected {
            sex = "m"
        } else if femaleButton.isSelected {
            sex = "f"
        }
        var license: String?
        if haveButton.isSelected {
            license = "t"
        } else if nonButton.isSelected {
            license = "f"
        }
        
        let model = CustomSearchDesignerModel(selectCity: selectCity, selectArea: selectArea, lat: userLocation.latitude, lng: userLocation.longitude, sex: sex, evaluationAvgStart: Int(round(starSlider.lowerValue)), evaluationAvgEnd: Int(round(starSlider.upperValue)), experienceStart: Int(round(yearSlider.lowerValue)), experienceEnd: Int(round(yearSlider.upperValue)), license: license)
        self.tableView.getSpDesignerWith(model: model)
    }
    
    @IBAction private func filerAgainButtonPress(_ sender: IBInspectableButton) {
        self.designerListView.isHidden = true
        self.filterAgainView.isHidden = true
        self.filterView.isHidden = false
    }
    
    // MARK: API
    private func apiGetCityCode(_ success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiGetCityCode(success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let cityCodeModel = model?.data {
                        SystemManager.saveCityCodeModel(cityCodeModel)
                        success?()
                    }
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

extension CustomViewController: DesignerInfoTableViewDelegate {
    
    func didUpdateDesignerList(designerListCount: Int) {
        if designerListCount == 0 {
            self.designerListView.isHidden = true
            self.filterAgainView.isHidden = false
        } else {
            self.designerListView.isHidden = false
            self.filterAgainView.isHidden = true
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == tableView {
            let height: CGFloat = (velocity.y > 0) ? 0 : 50.0
            UIView.animate(withDuration: 0.3) {
                self.designerListFilterAgainViewHeight.constant = height
                self.view.layoutIfNeeded()
            }
        }
    }
}
