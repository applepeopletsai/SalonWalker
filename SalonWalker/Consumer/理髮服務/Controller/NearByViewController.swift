//
//  NearByViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import FlexiblePageControl

enum DesignerListMode {
    case DesignerListModeTable, DesignerListModeCollection
}

enum MapViewMode: Int {
    case MapViewModeWalk = 0, MapViewModeBus, MapViewModeCar
}

private struct PolyLineModel: Codable {
    
    struct Routes: Codable {
        struct Legs: Codable {
            struct Duration: Codable {
                var text: String
                var value: Int
            }
            var duration: Duration
        }
        struct OverviewPolyline: Codable {
            var points: String
        }
        var legs: [Legs]
        var overview_polyline: OverviewPolyline
    }
    var routes: [Routes]
    var status: String
}

private class CustomMarker: GMSMarker {
    var model: DesignerListModel?
    var ouId: Int = -1
    var originFrame = CGRect(x: 0, y: 0, width: 10, height: 17)
    var selectedFrame = CGRect(x: 0, y: 0, width: 38, height: 54)
    var photoOriginFrame = CGRect(x: 1, y: 1, width: 7.5, height: 7.5)
    var photoSelectedFrame = CGRect(x: 5, y: 5, width: 28, height: 28)
    var photoOriginCornerRadius: CGFloat = 3.75
    var photoSelectedCornerRadius: CGFloat = 14
}

class NearByViewController: BaseViewController {
    
    // MARK: Property
    @IBOutlet private weak var nonDataView: UIView!
    @IBOutlet private weak var containerBaseView: UIView!
    @IBOutlet private weak var tableContainerView: UIView!
    @IBOutlet private weak var collectionContainerView: UIView!
    @IBOutlet private weak var modeButton: UIButton!
    @IBOutlet private weak var containerBaseViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var walkTimeLabel: UILabel!
    @IBOutlet private weak var busTimeLabel: UILabel!
    @IBOutlet private weak var carTimeLabel: UILabel!
    @IBOutlet private weak var mapBaseView: UIView!
    @IBOutlet private weak var filterView: FilterView?
    @IBOutlet private weak var pageControl: FlexiblePageControl!
    @IBOutlet private var mapModeView: [IBInspectableView]!
    
    private var nearbyCollectionVC: NearByCollectionViewController?
    private var nearbyTableVC: NearByTableViewController?
    
    private var mapView: GMSMapView?
    private var markerArray = [CustomMarker]()
    private var selectedMarker: CustomMarker?
    private var listMode: DesignerListMode = .DesignerListModeCollection
    private var mapMode: MapViewMode = .MapViewModeWalk
    private var walkPolyLine: GMSPolyline?
    private var busPolyLine: GMSPolyline?
    private var carPolyLine: GMSPolyline?
    private var selectDesignerCoordinate: CLLocationCoordinate2D?
    private var shouldUpdateUserLocation = true
    
    private var filterModel: CityCodeModel.CityModel?
    private var designerListArray: [DesignerListModel] = []
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        setupFilterView()
        setupMapView()
        setupPageControl()
        changeContainerBaseViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mapView?.frame = self.mapBaseView.bounds
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "NearByCollectionViewControllerSegue" {
            self.nearbyCollectionVC = segue.destination as? NearByCollectionViewController
            self.nearbyCollectionVC?.delegate = self
        } else if segueName == "NearByTableViewControllerSegue" {
            self.nearbyTableVC = segue.destination as? NearByTableViewController
            self.nearbyTableVC?.delegate = self
        }
    }
    
    // MARK: Method
    func callAPI() {
        if designerListArray.count == 0 {
            if shouldUpdateUserLocation {
                if LocationManager.userLastLocation().horizontalAccuracy == 2000 &&
                    LocationManager.userLastLocation().verticalAccuracy == 2000 {
                    LocationManager.getLocationWithTarget(self)
                } else {
                    animateCameraPosition()
                    apiGetNearbyDesignerList()
                }
            } else {
                animateCameraPosition()
                apiGetNearbyDesignerList()
            }
        }
    }
    
    func checkRecentSearchData() {
        self.filterView?.checkRecentSearchData()
    }
    
    private func animateCameraPosition() {
        self.mapView?.animate(toLocation: LocationManager.userLastLocation().coordinate)
        self.shouldUpdateUserLocation = false
    }
    
    private func setupFilterView() {
        self.filterView?.setupFilterViewWith(targetVC: self, delegate: self)
    }
    
    private func setupMapView() {
        self.mapView = GMSMapView(frame: self.mapBaseView.bounds)
        let position = LocationManager.userLastLocation().coordinate
        
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 16)
        self.mapView?.camera = camera
        self.mapView?.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.settings.compassButton = false
        self.mapView?.settings.rotateGestures = false
        self.mapBaseView.insertSubview(self.mapView!, at: 0)
    }
    
    private func setupPageControl() {
        let config = FlexiblePageControl.Config(displayCount: 7, dotSize: 6, dotSpace: 5, smallDotSizeRatio: 0.5, mediumDotSizeRatio: 0.7)
        pageControl.setConfig(config)
        pageControl.pageIndicatorTintColor = color_D8D8D8
        pageControl.currentPageIndicatorTintColor = color_8F92F5
        pageControl.updateViewSize()
    }
    
    private func searchDesigner() {
        self.currentPage = 1
        self.apiGetNearbyDesignerList()
    }
    
    private func checkDataCount() {
        self.nonDataView.isHidden = (self.designerListArray.count == 0) ? false : true
    }
    
    private func changeContainerBaseViewHeight() {
        if SizeTool.isIphone5() {
            self.containerBaseViewHeight.constant = 10
        }
    }
    
    private func changeMapModeViewLayerColor() {
        for view in mapModeView {
            if mapMode.rawValue == view.tag {
                view.layer.borderColor = color_0087FF.cgColor
            } else {
                view.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    private func getPolyLineWithCoordinate(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, index: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            var polylineModeArray = ["walking","transit","driving"]
            let polylineMode = polylineModeArray[index]
            var language = "zh-TW"
            switch LanguageManager.currentLanguage() {
            case "zh":
                language = "zh-TW"
                break
            case "cn":
                language = "zh-CN"
                break
            case "en":
                language = "en"
                break
            default:
                language = "zh-TW"
                break
            }
            
            // origin：起點
            // destination：終點
            // mode：計算路徑的運輸模式(driving(預設)、walking、transit)
            // alternatives：若為true，可指定路線規劃服務會在回應中提供多條替代路線
            // key: API金鑰，與Android共用
            // 參考網址：https://developers.google.com/maps/documentation/directions/intro#TravelModes
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=\(polylineMode)&language=\(language)&alternatives=true&key=AIzaSyDltagciwmG9r1TAF78b5NU8i2UD2zFZO0"
            
            Alamofire.request(url).responseJSON { [unowned self]  (respnose) in
                if let data = respnose.data {
                    do {
                        let polyLineModel = try JSONDecoder().decode(PolyLineModel.self, from: data)
                        // 找出花費時間最少的路線
                        var minimum = Int.max
                        var point = ""
                        var durationText = ""
                        for route in polyLineModel.routes {
                            if let leg = route.legs.first {
                                if leg.duration.value < minimum {
                                    minimum = leg.duration.value
                                    point = route.overview_polyline.points
                                    durationText = leg.duration.text.replacingOccurrences(of: " ", with: "")
                                }
                            }
                        }
                        
                        let path = GMSPath.init(fromEncodedPath: point)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 2
                        polyline.strokeColor = color_0087FF
                        
                        switch index {
                        case 0:
                            self.walkPolyLine = polyline
                            self.walkTimeLabel.text = durationText
                            break
                        case 1:
                            self.busPolyLine = polyline
                            self.busTimeLabel.text = durationText
                            break
                        case 2:
                            self.carPolyLine = polyline
                            self.carTimeLabel.text = durationText
                            break
                        default: break
                        }
                        
                        if index == 2 {
                            self.resetPolyLine()
                            self.changeMapModeViewLayerColor()
                            self.hideLoading()
                        } else {
                            self.getPolyLineWithCoordinate(origin: origin, destination: destination, index: index + 1)
                        }
                    } catch {
                        print("JSONDecoder fail in getPolyLineWithCoordinate : \(error.localizedDescription)")
                        SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: "")
                        self.hideLoading()
                    }
                } else {
                    print("getPolyLineWithCoordinate fail")
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: "")
                    self.hideLoading()
                }
            }
        }
    }
    
    private func cleanPolyLine() {
        self.walkPolyLine?.map = nil
        self.busPolyLine?.map = nil
        self.carPolyLine?.map = nil
    }
    
    private func resetPolyLine() {
        switch self.mapMode {
        case .MapViewModeWalk:
            self.walkPolyLine?.map = self.mapView
            break
        case .MapViewModeBus:
            self.busPolyLine?.map = self.mapView
            break
        case .MapViewModeCar:
            self.carPolyLine?.map = self.mapView
            break
        }
    }
    
    private func addMarker() {
        let index = (markerArray.count == 0) ? 0 : markerArray.count
        
        for i in index..<designerListArray.count {
            let model = designerListArray[i]
            let marker = CustomMarker(position: CLLocationCoordinate2D(latitude: model.lat, longitude: model.lng))
            let iconImageView = UIImageView(frame: marker.originFrame)
            iconImageView.image = UIImage(named: "ic_maplandmark")
            marker.iconView = iconImageView
            marker.ouId = model.ouId
            marker.model = model
            marker.map = mapView
            markerArray.append(marker)
        }
    }
    
    private func resetMarkerArray() {
        _ = self.markerArray.map({ $0.map = nil })
        self.markerArray.removeAll()
        self.selectedMarker = nil
    }
    
    private func resetSelectedMarker(_ marker: CustomMarker) {
        if let selectMarker = self.selectedMarker, selectMarker.ouId != marker.ouId {
            for view in selectMarker.iconView!.subviews {
                view.removeFromSuperview()
            }
            self.selectedMarker?.zIndex = 0
            self.selectedMarker?.iconView?.frame = selectMarker.originFrame
            (self.selectedMarker?.iconView as! UIImageView).image = UIImage(named: "ic_maplandmark")
        }
    }
    
    private func didSelectedMarker(_ marker: CustomMarker) {
        let baseImageView = UIImageView(frame: marker.originFrame)
        baseImageView.image = UIImage(named: "ic_map_designer")
        
        let photoImageView = UIImageView(frame: marker.photoOriginFrame)
        if let headerImgUrl = marker.model?.headerImgUrl, headerImgUrl.count > 0 {
            photoImageView.setImage(with: headerImgUrl)
        } else {
            photoImageView.image = UIImage(named: "img_account_user")
        }
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = marker.photoOriginCornerRadius
        photoImageView.layer.masksToBounds = true
        
        baseImageView.addSubview(photoImageView)
        
        UIView.animate(withDuration: 0.3, animations: {
            marker.iconView?.alpha = 0.6
            marker.iconView?.frame = marker.selectedFrame
        }, completion: { (finish) in
            marker.iconView?.alpha = 1
            baseImageView.frame = marker.selectedFrame
            photoImageView.frame = marker.photoSelectedFrame
            photoImageView.layer.cornerRadius = marker.photoSelectedCornerRadius
            marker.iconView = baseImageView
        })
        
        marker.zIndex = INT_MAX // 顯示層級
        self.selectedMarker = marker
    }
    
    private func indexOfSelectMarker(_ selectMarker: CustomMarker) -> Int {
        for i in 0..<markerArray.count {
            if selectMarker.ouId == markerArray[i].ouId {
                return i
            }
        }
        return 0
    }
    
    private func scrollToIndexPath(_ indexPath: IndexPath) {
        self.nearbyTableVC?.scrollToIndexPath(indexPath)
//        self.nearbyCollectionVC?.scrollToIndexPath(indexPath)
    }
    
    private func getNextPageData(indexPath: IndexPath) {
        if indexPath.row == designerListArray.count - 2 && currentPage < totalPage {
            currentPage += 1
            apiGetNearbyDesignerList(showLoading: false)
        }
    }
    
    // MARK: Event Handler
    @IBAction private func changeModeButtonPress(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        if self.listMode == .DesignerListModeTable {
            self.listMode = .DesignerListModeCollection
        } else {
            self.listMode = .DesignerListModeTable
        }
//        CATransaction.flush()
        UIView.transition(with: self.modeButton, duration: 0.3, options: (self.listMode == .DesignerListModeTable) ? .transitionFlipFromLeft : .transitionFlipFromRight, animations: { [unowned self] in
            let image = (self.listMode == .DesignerListModeTable) ? "btn_mapview" : "btn_listview"
            self.modeButton.setImage(UIImage(named: image), for: .normal)
        }, completion: { (finish) in
            sender.isUserInteractionEnabled = true
        })
        
        UIView.transition(with: self.containerBaseView, duration: 0.3, options: (self.listMode == .DesignerListModeTable) ? .transitionFlipFromLeft : .transitionFlipFromRight, animations: { [unowned self] in
            self.tableContainerView.isHidden = (self.listMode == .DesignerListModeTable) ? false : true
            self.collectionContainerView.isHidden = (self.listMode == .DesignerListModeTable) ? true : false
        }, completion: { (finish) in
            
        })
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.pageControl.alpha = (self.listMode == .DesignerListModeTable) ? 0 : 1
        }
    }
    
    @IBAction private func mapModeButtonPress(_ sender: UIButton) {
        if let mode = MapViewMode(rawValue: sender.tag) {
            self.mapMode = mode
            cleanPolyLine()
            resetPolyLine()
            changeMapModeViewLayerColor()
        }
    }
    
    @IBAction private func openGoogleMapButtonPress(_ sender: UIButton) {
        // saddr：設定路線搜尋的的起點。這可以是「緯度,經度」，或是查詢格式的地址。 如果它是傳回多個結果的查詢字串，則會選擇第一個結果。如果值是空白，則會使用使用者的目前位置。
        // daddr：設定路線搜尋的終點。具有與 saddr 相同的格式與行為。
        // views：開啟/關閉特定檢視。可以設定為：satellite、traffic 或 transit。 可以使用逗點分隔符號來設定多個值。 如果只指定參數而未指定值，則會清除所有檢視。
        // directionsmode：運輸方法。可以設定為：driving、transit、bicycling 或 walking。
        // 參考網址：https://developers.google.com/maps/documentation/ios-sdk/urlscheme?hl=zh-tw
        var directionsMode = ""
        switch self.mapMode {
        case .MapViewModeWalk:
            directionsMode = "walking"
            break
        case .MapViewModeBus:
            directionsMode = "transit"
            break
        case .MapViewModeCar:
            directionsMode = "driving"
            break
        }
        if let coordinate = selectDesignerCoordinate {
            var googleMapURLstring = "?daddr=\(String(describing:coordinate.latitude)),\(String(describing:coordinate.longitude))&zoom=16&views=traffic&directionsmode=\(directionsMode)"
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                googleMapURLstring.insert(contentsOf: "comgooglemaps://", at: googleMapURLstring.startIndex)
            } else {
                googleMapURLstring.insert(contentsOf: "https://maps.google.com/", at: googleMapURLstring.startIndex)
            }
            UIApplication.shared.openURL(URL(string: googleMapURLstring)!)
        }
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
    
    private func apiGetNearbyDesignerList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            
            if showLoading { self.showLoading() }
            
            let areaNameArray = filterModel?.area?.map({ $0.areaName ?? "" })
            let userLocation = LocationManager.userLastLocation().coordinate
            HomeManager.apiGetTopOrNearbyDesignerList(lat: userLocation.latitude, lng: userLocation.longitude, page: self.currentPage, pMax: 30, cityName: self.filterModel?.cityName, areaName: areaNameArray, cons: 1, keyWord: self.filterModel?.keyword, success: { [weak self] (model) in
                guard let strongSelf = self else { return }
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta.totalPage {
                        strongSelf.totalPage = totalPage
                    }
                    
                    if let designerList = model?.data?.designerList {
                        if strongSelf.currentPage == 1 {
                            strongSelf.designerListArray = designerList
                        } else {
                            strongSelf.designerListArray.append(contentsOf: designerList)
                        }
                    } else {
                        strongSelf.designerListArray = []
                    }
                    strongSelf.resetMarkerArray()
                    strongSelf.addMarker()
                    strongSelf.nearbyCollectionVC?.reloadData(strongSelf.designerListArray)
                    strongSelf.nearbyTableVC?.reloadData(strongSelf.designerListArray, defaultSelect: (strongSelf.currentPage == 1))
                    strongSelf.checkDataCount()
                    strongSelf.pageControl.numberOfPages = strongSelf.designerListArray.count
                    strongSelf.pageControl.updateViewSize()
                    strongSelf.hideLoading()
                } else {
                    strongSelf.endLoadingWith(model: model)
                }
                strongSelf.removeMaskView()
                }, failure: { [weak self] (error) in
                    SystemManager.showErrorAlert(error: error)
                    self?.removeMaskView()
            })
        }
    }
}

extension NearByViewController: FilterViewDelegate {
    func didPressFinishButton(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchDesigner()
    }
    
    func didPressSearchButton(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchDesigner()
    }
    
    func didSelectRecentSearch(_ model: CityCodeModel.CityModel?) {
        self.filterModel = model
        self.searchDesigner()
    }
}

extension NearByViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let selectMarker = self.selectedMarker, selectMarker.ouId == (marker as! CustomMarker).ouId {
            return true
        }
        
        self.scrollToIndexPath(IndexPath(row: indexOfSelectMarker((marker as! CustomMarker)), section: 0))
        return true
    }
}

extension NearByViewController: NearByCollectionViewControllerDelegate {
    
    func collectionViewDidScroll(_ collectionView: UICollectionView) {
        pageControl.setProgress(contentOffsetX: collectionView.contentOffset.x, pageWidth: collectionView.bounds.width)
    }
    
    func collectionViewWillDispalyCellAt(_ indexPath: IndexPath) {
        getNextPageData(indexPath: indexPath)
    }
    
    func changeFavStatusAt(_ indexPath: IndexPath) {
        self.designerListArray[indexPath.row].isFav = !self.designerListArray[indexPath.row].isFav
    }
}

extension NearByViewController: NearByTableViewControllerDelegate {
    
    func didSelectDesigner(at indexPath: IndexPath, coordinate: CLLocationCoordinate2D) {
        self.resetSelectedMarker(self.markerArray[indexPath.row])
        self.didSelectedMarker(self.markerArray[indexPath.row])
//        self.nearbyCollectionVC?.scrollToIndexPath(indexPath)
        
        mapMode = .MapViewModeWalk
        selectDesignerCoordinate = coordinate
        cleanPolyLine()
        getPolyLineWithCoordinate(origin: LocationManager.userLastLocation().coordinate, destination: coordinate, index: 0)
    }
    
    func tableViewWillDisplayCellAt(_ indexPath: IndexPath) {
        getNextPageData(indexPath: indexPath)
    }
}

extension NearByViewController: LocationManagerDelegate {
    
    func locationDidUpdateWithCoordinate(lat: Double, lng: Double) {
        animateCameraPosition()
        apiGetNearbyDesignerList()
    }
    
    func didCancelAllowGPS() {
        animateCameraPosition()
        apiGetNearbyDesignerList()
    }
}

