//
//  IntroductionView.swift
//  SalonWalker
//
//  Created by skywind on 2018/2/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol IntroductionViewDelegate: class {
    func experienceButtonPress()
}

class IntroductionView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private var buttonAction: actionClosure?
    private var viewFrame: CGRect = CGRect.zero
    private var titleString: String = ""
    private var subtitleString: String = ""
    private var image: UIImage?
    private var color: UIColor?
    
    weak var delegate: IntroductionViewDelegate?
    
    class func getGuideView(titleString: String,subtitleString: String, image: UIImage?,type: AppIdentity,index: NSInteger) -> IntroductionView? {
        guard let view = Bundle.main.loadNibNamed("IntroductionView", owner: nil, options: nil)?.first as? IntroductionView else { return nil }
        view.frame = CGRect(x: screenWidth * CGFloat(index), y: 0, width: screenWidth, height: screenHeight)
        view.titleLabel.text = titleString
        view.subtitleLabel.text = subtitleString
        view.imageView.image = image
        view.actionButton.isHidden = true

        if type == .SalonWalker {
            view.backgroundColor = color_E1FFF4
        } else {
            view.backgroundColor = color_7A57FA
        }
        return view
    }
    
    private func setupView() {
        imageView.image = image
        titleLabel.text = titleString
        subtitleLabel.text = subtitleString
        self.backgroundColor = color
    }
    
    @IBAction func actionButtonOnClick(_ sender: Any) {
        delegate?.experienceButtonPress()
    }
}
