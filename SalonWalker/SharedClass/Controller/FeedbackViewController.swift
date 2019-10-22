//
//  FeedbackViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/12/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class FeedbackViewController: BaseViewController {

    @IBOutlet private weak var tagView: DynamicLabelView!
    @IBOutlet private weak var tagViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    
    @IBOutlet private weak var uploadPhotoCollectionView: UploadPhotoCollectionView!
    @IBOutlet private weak var uploadPhotoViewHeight: NSLayoutConstraint!
    
    private var feedbackLabelArray = [FeedbackModel.Label]()
    private var selectFlId: Int?
    private var coverArray = [CoverImg]()
    private var itemWidth: CGFloat {
        let collectionViewMargin: CGFloat = 20.0
        let width = (screenWidth - collectionViewMargin * 2) / 2
        return width
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        setupUploadPhotoCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func networkDidRecover() {
        callAPI()
    }
    
    // MARK: Method
    private func setupTagView() {
        self.tagView.setupWith(labelTextArray: self.feedbackLabelArray.map{ $0.content }, target: self, arrangementType: .left, labelSpace: 6, unSelectBgColor: color_F1F1F1, borderWidth: 0, layerCornerRadius: 5)
        self.tagViewHeight.constant = 15 + 20 + self.tagView.frame.size.height
    }
    
    private func callAPI() {
        if feedbackLabelArray.count == 0 {
            apiGetFeedbackLabel()
        }
    }
    
    private func setupUploadPhotoCollectionView() {
         uploadPhotoCollectionView.setupCollectionViewWith(coverArray: coverArray, itemWidth: itemWidth, targetViewController: self, delegate: self, type: .Feedback)
        resetUploadPhotoViewHeight()
    }
    
    private func resetUploadPhotoViewHeight() {
        let line = Int(ceil(CGFloat(coverArray.count + 1) / 2))
        uploadPhotoViewHeight.constant = 20 + 15 + (itemWidth * CGFloat(line) + 5 * 2)
    }
    
    private func checkSaveButtonEnable() {
        let enable = (selectFlId != nil && emailTextField.text?.count ?? 0 > 0 && contentTextView.text.count > 0)
        saveButton.isEnabled = enable
        saveButton.alpha = (enable) ? 1 : 0.5
    }
    
    // MARK: Event Handler
    @IBAction private func editingChanged(_ sender: UITextField) {
        checkSaveButtonEnable()
    }
    
    @IBAction private func saveButtonPress(_ sender: UIButton) {
        if !emailTextField.text!.validateEmail() {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_LI_027"), alertMessage: LocalizedString("Lang_LI_028"), buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            return
        }
        apiGiveFeedback()
    }
    
    // MARK: API
    private func apiGetFeedbackLabel() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            SystemManager.apiGetFeedbackLabel(success: { [weak self] (model) in
                
                if model?.syscode == 200 {
                    if let labels = model?.data?.feedbackLabel {
                        self?.feedbackLabelArray = labels
                        self?.setupTagView()
                        self?.hideLoading()
                        self?.removeMaskView()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGiveFeedback() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiGiveFeedback(flId: selectFlId!, email: emailTextField.text!, content: contentTextView.text, fiId: coverArray.compactMap{ $0.tempImgId }, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    PresentationTool.showNoButtonAlertWith(image: UIImage(named: "img_send_out"), message: LocalizedString("Lang_AC_076"), autoDismiss: false, completion: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                } else {
                    self?.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkSaveButtonEnable()
    }
}

extension FeedbackViewController: DynamicLabelViewDelegate {
    func didSelectItemsIndex(_ itemsIndex: [Int]) {
        if let selectIndex = itemsIndex.first {
            selectFlId = feedbackLabelArray[selectIndex].flId
        } else {
            selectFlId = nil
        }
        checkSaveButtonEnable()
    }
}

extension FeedbackViewController: UploadPhotoCollectionViewDelegate {
    func updatePhotoData(with coverArray: [CoverImg]) {
        self.coverArray = coverArray
        self.resetUploadPhotoViewHeight()
    }
    
    func deletePhoto(at index: Int) {
        self.coverArray.remove(at: index)
        self.resetUploadPhotoViewHeight()
    }
}
