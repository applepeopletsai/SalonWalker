//
//  LocationFilterView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/29.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol LocationFilterViewDelegate: class {
    func finishButtonPressWith(selectCity: [Int], selectDistrict: [Int])
    func didSelectItemWith(currentSelectCity: [Int], currentSelectDistrict: [Int])
    func didTapBlackAreaWith(selectCity: [Int], selectDistrict: [Int])
    func didSelectRecentSearch(_ model: CityCodeModel.CityModel)
}

class LocationFilterView: UIView {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var segment: UISegmentedControl!
    @IBOutlet private weak var segmentTopConstraint: NSLayoutConstraint!
    
    private weak var delegate: LocationFilterViewDelegate?
    
    private var cityLabelView: DynamicLabelView = DynamicLabelView()
    private var districtLabelView: DynamicLabelView = DynamicLabelView()
    private var recentSearchesTableView: UITableView?
    
    private var selectCity: [Int] = []
    private var selectDistrict: [Int] = []
    private var currentSelectCity: [Int] = []
    private var currentSelectDistrict: [Int] = []
    private var recentSearchArray: [CityCodeModel.CityModel] = []
    
    private var currentSelectSegmentIndex = 0
    private var cellHeihgt: CGFloat = 35
    
    static func initWith(frame: CGRect, delegate: LocationFilterViewDelegate?) -> LocationFilterView? {
        guard let view = Bundle.main.loadNibNamed("LocationFilterView", owner: nil, options: nil)?.first as? LocationFilterView else {
            return nil
        }
        view.frame = frame
        view.alpha = 0
        view.delegate = delegate
        view.setupLabelView()
        view.setupTableView()
        view.setupScrollView()
        view.setupSegment()
        view.layoutIfNeeded()
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil { // Did Add Self To Superview
            self.segmentTopConstraint.constant = 0
            UIView.animate(withDuration: 0.15, animations: { [weak self] in
                self?.alpha = 1
                self?.layoutIfNeeded()
            }, completion: { [weak self] (finish) in
                if finish {
                    self?.checkRecentSearchData()
                }
            })
        }
    }
    
    override func removeFromSuperview() {
        self.segmentTopConstraint.constant = -(30 + self.scrollViewHeight.constant + 40)
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            self?.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { [weak self] (finish) in
            if finish {
                self?.superRemoveFromSuperview()
            }
        })
    }
    
    private func superRemoveFromSuperview() {
        super.removeFromSuperview()
    }
    
    // MARK: Method
    func checkRecentSearchData() {
        if let array = UserManager.getRecentSearches() {
            self.recentSearchArray = array
        } else {
            self.recentSearchArray = []
        }
        self.recentSearchesTableView?.reloadData()
        if segment.selectedSegmentIndex == 2 {
            self.resetScrollViewHeight(2)
        }
    }
    
    func resetSelectStatus() {
        self.delegate?.didTapBlackAreaWith(selectCity: self.selectCity, selectDistrict: self.selectDistrict)
        self.currentSelectCity = self.selectCity
        self.currentSelectDistrict = self.selectDistrict
        self.reflashDistrictLabelView()
        self.cityLabelView.resetSelectStatus(self.selectCity)
        self.districtLabelView.resetSelectStatus(self.selectDistrict)
        self.resetScrollViewHeight(self.segment.selectedSegmentIndex)
        
        if self.selectCity.count == 0, self.segment.selectedSegmentIndex == 1 {
            self.segment.selectedSegmentIndex = 0
            let width = self.cityLabelView.frame.size.width
            let height = self.cityLabelView.frame.size.height
            self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: width, height: height), animated: false)
            
            self.scrollViewHeight.constant = height
            self.layoutIfNeeded()
        }
    }
    
    private func reflashDistrictLabelView() {
        if let index = self.currentSelectCity.first {
            let city = SystemManager.getCityCodeModel()!.city[index]
            var areaArray: [String] = []
            for model in city.area! {
                areaArray.append(model.areaName!)
            }
            self.districtLabelView.reflashViewWithLabelTextArray(areaArray)
        } else {
            self.districtLabelView.reflashViewWithLabelTextArray([])
        }
    }
    
    private func setupLabelView() {
        let width = self.frame.size.width
        
        var city: [String] = []
        for model in SystemManager.getCityCodeModel()!.city {
            city.append(model.cityName!)
        }
        self.cityLabelView = DynamicLabelView(frame: CGRect(x: 0, y: 0, width: width, height: 50), labelTextArray: city, target: self)
        self.districtLabelView = DynamicLabelView(frame: CGRect(x: width, y: 0, width: width, height: 50), labelTextArray: [],target: self, multipleSelect:true)
        self.scrollView.addSubview(self.cityLabelView)
        self.scrollView.addSubview(self.districtLabelView)
    }
    
    private func setupTableView() {
        let width = self.frame.size.width
        self.recentSearchesTableView = UITableView(frame: CGRect(x: width * 2, y: 0, width: self.bounds.size.width, height: 150))
        self.recentSearchesTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.recentSearchesTableView?.dataSource = self
        self.recentSearchesTableView?.delegate = self
        self.recentSearchesTableView?.separatorStyle = .none
        self.checkRecentSearchData()
        
        self.scrollView.addSubview(self.recentSearchesTableView!)
    }
    
    private func setupScrollView() {
        switch segment.selectedSegmentIndex {
        case 0:
//            self.cityLabelView.resizeFrame(self.scrollView.bounds)
            self.scrollViewHeight.constant = self.cityLabelView.frame.size.height
            break
        case 1:
//            self.districtLabelView.resizeFrame(self.scrollView.bounds)
            self.scrollViewHeight.constant = self.districtLabelView.frame.size.height
            break
        case 2:
//            self.recentSearchesTableView?.frame = CGRect(x: self.scrollView.bounds.size.width * 2, y: 0, width: self.scrollView.bounds.size.width, height: 150)
            self.scrollViewHeight.constant = 150
            break
        default: break
        }
        self.scrollView.contentSize = CGSize(width: self.bounds.size.width * 3, height: self.bounds.size.height)
        self.segmentTopConstraint.constant = -(30 + self.scrollViewHeight.constant + 40)
    }
    
    private func setupSegment() {
        self.segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white]
            , for: .selected)
        self.segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color_1A1C69]
            , for: .normal)
    }
    
    private func resetScrollViewHeight(_ index: Int) {
        switch index {
        case 0:
            self.scrollViewHeight.constant = self.cityLabelView.frame.size.height
            break
        case 1:
            self.scrollViewHeight.constant = self.districtLabelView.frame.size.height
            break
        case 2:
            if self.recentSearchArray.count == 0 {
                self.scrollViewHeight.constant = self.cellHeihgt
            } else {
                self.scrollViewHeight.constant = (self.cellHeihgt * CGFloat(self.recentSearchArray.count) > 150) ? 150 : self.cellHeihgt * CGFloat(self.recentSearchArray.count)
            }
            break
        default: break
        }
    }
    
    private func getRecentSearchText(_ indexPath: IndexPath) -> String {
        var textEmpty: Bool = true
        var text = "" {
            didSet {
                textEmpty = (text.count == 0)
            }
        }
        
        if self.recentSearchArray.count == 0 {
            text = LocalizedString("Lang_HM_025")
        } else {
            let model = self.recentSearchArray[indexPath.row]
            if let cityName = model.cityName {
                text.append("\(cityName)")
            }
            if let areas = model.area {
                for i in 0..<areas.count {
                    if i == 0 {
                        text.append(textEmpty ? "\(areas[i].areaName!)" : "/\(areas[i].areaName!)")
                    } else {
                        text.append(",\(areas[i].areaName!)")
                    }
                }
            }
            if let keyword = model.keyword {
                text.append(textEmpty ? "\(keyword)" : "/\(keyword)")
            }
        }
        return text
    }
    
    // MARK: Event Handler
    @IBAction private func segmentValueChange(_ sender: UISegmentedControl) {
        let width = scrollView.bounds.size.width
        let height = scrollView.bounds.size.height
        
        if sender.selectedSegmentIndex == 1, currentSelectCity.count == 0 {
            sender.selectedSegmentIndex = 0
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_HM_026"), body: "")
        }
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(sender.selectedSegmentIndex) * width, y: 0, width: width, height: height), animated: true)

        self.resetScrollViewHeight(sender.selectedSegmentIndex)
        var contentSzie = self.scrollView.contentSize
        contentSzie.height = self.scrollViewHeight.constant
        self.scrollView.contentSize = contentSzie
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.layoutIfNeeded()
        })
    }
    
    @IBAction private func finishButtonPress(_ sender: UIButton) {
        self.selectCity = self.currentSelectCity
        self.selectDistrict = self.currentSelectDistrict
        self.delegate?.finishButtonPressWith(selectCity: self.selectCity, selectDistrict: self.selectDistrict)
    }
    
    @IBAction private func blackAreaButtonPress(_ sender: UIButton) {
        self.resetSelectStatus()
    }
}

extension LocationFilterView: DynamicLabelViewDelegate {
    
    func didSelectItemsIndex(_ itemsIndex: [Int]) {
        if self.segment.selectedSegmentIndex == 0 {
            self.currentSelectCity = itemsIndex
            self.currentSelectDistrict = []
            self.reflashDistrictLabelView()
        } else if self.segment.selectedSegmentIndex == 1 {
            self.currentSelectDistrict = itemsIndex
        }
        self.delegate?.didSelectItemWith(currentSelectCity: self.currentSelectCity, currentSelectDistrict: self.currentSelectDistrict)
    }
}

extension LocationFilterView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.recentSearchArray.count == 0 {
            return 1
        }
        return self.recentSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.textColor = color_1A1C69
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.text = getRecentSearchText(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeihgt
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.recentSearchArray.count != 0 {
            let model = self.recentSearchArray[indexPath.row]
            self.delegate?.didSelectRecentSearch(model)
            UserManager.saveRecentSearch(model)
        }
    }
}

