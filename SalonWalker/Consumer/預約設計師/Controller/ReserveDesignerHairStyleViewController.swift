//
//  ReserveDesignerHairStyleViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ReserveDesignerHairStyleViewController: BaseViewController {

    @IBOutlet private weak var naviTitleLabel: UILabel!
    @IBOutlet private weak var svgFemaleView: UIView!
    @IBOutlet private weak var svgMaleView: UIView!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var tipLabel: IBInspectableLabel!
    @IBOutlet private weak var maleLabel: UILabel!
    @IBOutlet private weak var maleLabelXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var femaleLabel: UILabel!
    @IBOutlet private weak var uploadPhotoCollectionView: UploadPhotoCollectionView!
    @IBOutlet private weak var uploadPhotoView: UIView!
    @IBOutlet private weak var uploadPhotoViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var uploadPhotoViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var refPhotoCollectionView: RefPhotoCollectionView!
    @IBOutlet private weak var refPhotoView: UIView!
    @IBOutlet private weak var refPhotoViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var refPhotoViewBottom: NSLayoutConstraint!
    
    @IBOutlet private var hairStyleButtons: [IBInspectableButton]!
    @IBOutlet private var showPhotoTypeButtons: [IBInspectableButton]!
    @IBOutlet private var genderButtons: [IBInspectableButton]!
    
    private var itemWidth: CGFloat {
        let collectionViewMargin: CGFloat = 50.0
        let width = (screenWidth - collectionViewMargin * 2) / 2
        return width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    // MARK: Method
    private func initialize() {
        if ReservationManager.shared.reservationDetailModel?.hairStyle == nil {
            ReservationManager.shared.reservationDetailModel?.hairStyle = HairStyleModel(sex: "", growth: 0, style: 1)
        } else {
            self.configureSVGHairView()
            self.configureHairStyleButtons()
            self.maleLabelXConstraint.constant = (ReservationManager.shared.reservationDetailModel?.hairStyle?.style == 2) ? 10 : 0
            self.slider.value = Float(ReservationManager.shared.reservationDetailModel?.hairStyle?.growth ?? 0) / 100
        }
        let model = ReservationManager.shared.reservationDetailModel
        naviTitleLabel.text = model?.nickName
        
        uploadPhotoCollectionView.setupCollectionViewWith(coverArray: model?.coverArray ?? [], itemWidth: itemWidth, targetViewController: self, delegate: self, type: .ReserveDesigner)
        resetUploadPhotoViewHeight()
        
        refPhotoCollectionView.setupCollectionViewWith(selectRefPhotoArray: model?.refPhotoArray ?? [], itemWidth: itemWidth, targetViewController: self, delegate: self)
        resetRefPhotoViewHeight()
        
        resetSVGLayer()
    }
    
    private func configureSVGHairView() {
        let isFemale = ReservationManager.shared.reservationDetailModel?.hairStyle?.sex == "f"
        self.svgFemaleView.alpha = (isFemale) ? 1.0 : 0.6
        self.svgMaleView.alpha = (!isFemale) ? 1.0 : 0.6
        self.femaleLabel.alpha = (isFemale) ? 1.0 : 0.6
        self.maleLabel.alpha = (!isFemale) ? 1.0 : 0.6
        self.tipLabel.isHidden = true
        self.slider.isEnabled = true
        self.hairStyleButtons.forEach {
            $0.isEnabled = true
            $0.alpha = 1.0
        }
    }
    
    private func configureHairStyleButtons() {
        let model = ReservationManager.shared.reservationDetailModel
        self.hairStyleButtons.forEach{
            $0.isSelected = ($0.tag == model?.hairStyle?.style)
            $0.backgroundColor = ($0.tag == model?.hairStyle?.style) ? color_1A1C69 : color_EEE9FE
        }
    }
    
    private func redrawSVGView() {
        guard let svgFemaleViewSublayers = self.svgFemaleView.layer.sublayers else { return }
        guard let svgMaleViewSublayers = self.svgMaleView.layer.sublayers else { return }
        
        let model = ReservationManager.shared.reservationDetailModel
        let newFemaleLayerArray = SVGLayer.getSVGLayersWith(sideLength: 80.0, sliderPercentage: CGFloat(model?.hairStyle?.growth ?? 0) / 100, hairStyle: HairStyle(rawValue: model?.hairStyle?.style ?? 1)!, gender: .Female, color: (model?.hairStyle?.sex == "f") ? color_2F10A0 : color_C6C6C6)
        for i in 0..<svgFemaleViewSublayers.count {
            let layer = svgFemaleViewSublayers[i]
            self.svgFemaleView.layer.replaceSublayer(layer, with: newFemaleLayerArray[i])
        }
        
        let newMaleLayerArray = SVGLayer.getSVGLayersWith(sideLength: 80.0, sliderPercentage: CGFloat(model?.hairStyle?.growth ?? 0) / 100, hairStyle: HairStyle(rawValue: model?.hairStyle?.style ?? 1)!, gender: .Male, color: (model?.hairStyle?.sex == "m") ? color_2F10A0 : color_C6C6C6)
        for i in 0..<svgMaleViewSublayers.count {
            let layer = svgMaleViewSublayers[i]
            self.svgMaleView.layer.replaceSublayer(layer, with: newMaleLayerArray[i])
        }
    }
    
    private func resetSVGLayer() {
        self.svgFemaleView.removeAllSublayers()
        self.svgMaleView.removeAllSublayers()
        
        let model = ReservationManager.shared.reservationDetailModel
        self.svgFemaleView.addSublayer(layers: SVGLayer.getSVGLayersWith(sideLength: 80, sliderPercentage: CGFloat(model?.hairStyle?.growth ?? 0) / 100, hairStyle: HairStyle(rawValue: model?.hairStyle?.style ?? 1)!, gender: .Female, color: (model?.hairStyle?.sex == "f") ? color_2F10A0 : color_C6C6C6))
        self.svgMaleView.addSublayer(layers: SVGLayer.getSVGLayersWith(sideLength: 80, sliderPercentage: CGFloat(model?.hairStyle?.growth ?? 0) / 100, hairStyle: HairStyle(rawValue: model?.hairStyle?.style ?? 1)!, gender: .Male, color: (model?.hairStyle?.sex == "m") ? color_2F10A0 : color_C6C6C6))
    }
    
    private func resetUploadPhotoViewHeight() {
        let coverArray = ReservationManager.shared.reservationDetailModel?.coverArray ?? []
        let cellCount = (coverArray.count < 4) ? coverArray.count + 1 : coverArray.count
        let line = Int(ceil(CGFloat(cellCount) / 2))
        uploadPhotoViewHeight.constant = itemWidth * CGFloat(line) + 10 * 2
    }
    
    private func resetRefPhotoViewHeight() {
        let line: CGFloat = 2
        let space: CGFloat = 10
        let buttonHeight: CGFloat = 24
        refPhotoViewHeight.constant = itemWidth * line + space * 3 + buttonHeight
    }
    
    private func gotoReservationDetailVC(tempImageModel: [TempImageModel]? = nil) {
        var oepId = [Int]()
        var photoImgUrl = [String]()
        let coverArray = ReservationManager.shared.reservationDetailModel?.coverArray ?? []
        coverArray.forEach{
            if let tempImgId = $0.tempImgId {
                oepId.append(tempImgId)
            }
            if let imgUrl = $0.imgUrl {
                photoImgUrl.append(imgUrl)
            }
        }
        tempImageModel?.forEach{
            oepId.append($0.tempImgId)
            photoImgUrl.append($0.imgUrl)
        }
        ReservationManager.shared.reservationDetailModel?.oepId = oepId
        ReservationManager.shared.reservationDetailModel?.photoImgUrl = photoImgUrl
        
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing: ConsumerReservationDetailViewController.self)) as! ConsumerReservationDetailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Event Handler
    @IBAction private func svgHairViewPress(_ sender: UIButton) {
        // tag0: female, tag1: male
        ReservationManager.shared.reservationDetailModel?.hairStyle?.sex = (sender.tag == 0) ? "f" : "m"
        self.configureSVGHairView()
        self.resetSVGLayer()
    }
    
    @IBAction private func hairStyleButtonPress(_ sender: UIButton) {
        // tag1: 瀏海, tag2: 側分, tag3: 中分, tag4: 鮑伯
        guard let hairStyle = HairStyle(rawValue: sender.tag) else { return }
        
        ReservationManager.shared.reservationDetailModel?.hairStyle?.style = sender.tag
        self.configureHairStyleButtons()
        self.resetSVGLayer()
        
        self.maleLabelXConstraint.constant = (hairStyle == .SideParting) ? 10 : 0
    }
    
    @IBAction private func slierValueChange(_ sender: UISlider) {
        ReservationManager.shared.reservationDetailModel?.hairStyle?.growth = Int(sender.value * 100)
        self.redrawSVGView()
    }
    
    // 上傳範例照片/窩客推薦
    @IBAction private func showPhotoTypeButtonPress(_ sender: IBInspectableButton) {
        showPhotoTypeButtons.forEach{ $0.isSelected = ($0.tag == sender.tag) }
        uploadPhotoView.isHidden = !(sender.tag == 0)
        refPhotoView.isHidden = !(sender.tag == 1)
        uploadPhotoViewBottom.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue((sender.tag == 0) ? 999 : 900))
        refPhotoViewBottom.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue((sender.tag == 1) ? 999 : 900))
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func genderButtonPress(_ sender: IBInspectableButton) {
        genderButtons.forEach{
            $0.backgroundColor = ($0.tag == sender.tag) ? color_1A1C69 : color_EEE9FE
            $0.isSelected = ($0.tag == sender.tag)
        }
        refPhotoCollectionView.changeGender(sex: (sender.tag == 0) ? "f" : "m")
    }
    
    @IBAction private func reservationButtonPress(_ sender: IBInspectableButton) {
        if uploadPhotoCollectionView.isUploading {
            SystemManager.showWarningBanner(title: "", body: LocalizedString("Lang_RV_018"))
            return
        }
        let model = ReservationManager.shared.reservationDetailModel
        if model?.refPhotoArray?.count ?? 0 > 0 {
            self.apiOrderPhotoTempImage(rpId: model!.refPhotoArray!.map{ $0.rpId })
        } else {
            self.gotoReservationDetailVC()
        }
    }
    
    @IBAction private func cancelReservationButtonPress(_ sender: UIButton) {
        guard let naviVCS = self.navigationController?.viewControllers else { return }
        for vc in naviVCS {
            if vc is DesignerDetailViewController {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: API
    private func apiOrderPhotoTempImage(rpId: [Int]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiOrderPhotoTempImage(image: nil, rpId: rpId, oepId: nil, act: "new", success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    self?.gotoReservationDetailVC(tempImageModel: model?.data)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension ReserveDesignerHairStyleViewController: UploadPhotoCollectionViewDelegate {
    
    func updatePhotoData(with coverArray: [CoverImg]) {
        ReservationManager.shared.reservationDetailModel?.coverArray = coverArray
        self.resetUploadPhotoViewHeight()
    }
    
    func deletePhoto(at index: Int) {
        ReservationManager.shared.reservationDetailModel?.coverArray?.remove(at: index)
        self.resetUploadPhotoViewHeight()
    }
}

extension ReserveDesignerHairStyleViewController: RefPhotoCollectionViewDelegate {
    
    func updateSelectRefPhotoArray(_ refPhotoIdArray: [RefPhotoModel.RefPhoto]) {
        ReservationManager.shared.reservationDetailModel?.refPhotoArray = refPhotoIdArray
    }
}
