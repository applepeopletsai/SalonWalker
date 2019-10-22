//
//  WriteCommentViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/25.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos

class WriteCommentViewController: BaseViewController {

    @IBOutlet private weak var sendButton: IBInspectableButton!
    @IBOutlet private weak var starView: CosmosView!
    @IBOutlet private weak var textView: IBInspectableTextView!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var dId: Int?
    private var moId: Int?
    private var pId: Int?
    private var doId: Int?
    private let itemWidth: CGFloat = (screenWidth - (5.0 * 2) - (10.0 * 2)) / 3
    private let itemHeight: CGFloat = 25.0
    private var itemArray: [String] {
        if UserManager.sharedInstance.userIdentity == .consumer {
            return [LocalizedString("Lang_CT_006"),LocalizedString("Lang_CT_007"),LocalizedString("Lang_CT_008")]
        } else {
            return [LocalizedString("Lang_CT_003"),LocalizedString("Lang_CT_004"),LocalizedString("Lang_CT_005")]
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
        starView.didTouchCosmos = { [unowned self] (rating) in
            self.sendButton.isEnabled = (rating != 0)
        }
    }
    
    // MARK: Method
    func setupVCWith(dId: Int, moId: Int) {
        self.dId = dId
        self.moId = moId
    }
    
    func setupVCWith(pId: Int, doId: Int) {
        self.pId = pId
        self.doId = doId
    }
    
    private func registerCell() {
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func postNotification() {
        // 填寫評價後，要更新訂單記錄列表
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
    }
    
    // MARK: Event Handler
    @IBAction private func sendButtonClick(_ sender: UIButton) {
        if UserManager.sharedInstance.userIdentity == .consumer {
            apiGiveDesignerEvaluate()
        } else if UserManager.sharedInstance.userIdentity == .designer {
            apiGiveProviderEvaluate()
        }
    }
    
    // MAKR: API
    private func apiGiveDesignerEvaluate() {
        guard let dId = dId, let moId = moId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OrderDataManager.apiGiveDesignerEvaluate(dId: dId, moId: moId, point: Int(starView.rating), comment: textView.text, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_CT_010"), body: "")
                    self.postNotification()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGiveProviderEvaluate() {
        guard let pId = pId, let doId = doId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OrderDataManager.apiGiveProviderEvaluate(pId: pId, doId: doId, point: Int(starView.rating), comment: textView.text, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_CT_010"), body: "")
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

extension WriteCommentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        if let totalString = totalString, totalString.count > 200 {
            return false
        }
        return true
    }
}

extension WriteCommentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let label = IBInspectableLabel(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight))
        label.cornerRadius = itemHeight / 2
        label.borderWidth = 1
        label.borderColor = color_1A1C69
        label.text = itemArray[indexPath.item]
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = color_1A1C69
        label.textAlignment = .center
        label.autoresizingMask = .flexibleWidth
        cell.contentView.addSubview(label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if textView.text.count > 0 {
            if textView.text.count + String("、\(itemArray[indexPath.item])").count <= 200 {
                textView.text.append(String("、\(itemArray[indexPath.item])"))
            }
        } else {
            textView.text = itemArray[indexPath.item]
        }
    }
}
