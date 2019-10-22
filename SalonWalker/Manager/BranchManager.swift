//
//  BranchManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/25.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Branch

// ios11.2，安裝app後點擊連結無法打開app(會下載app)
// 參考連結：https://blog.branch.io/notice-inconsistent-universal-link-behavior-on-ios-11-2/

class BranchManager: NSObject {
    
    // dId為設計師id,pId是場地id
    // seArticlesId,maArticleId為經精選文章的id
    static func createDeepLinkUrl(dId: Int? = nil,
                                  pId: Int? = nil,
                                  seArticlesId: Int? = nil,
                                  maArticleId: Int? = nil,
                                  title: String? = nil,
                                  contentDescription: String? = nil,
                                  imageUrl: String? = nil,
                                  success: @escaping ((_ url: String) -> Void),
                                  failure: @escaping failureClosure) {
        SystemManager.showLoading()
        
        // 參考：https://docs.branch.io/pages/apps/ios/
        
        let obj = BranchUniversalObject(canonicalIdentifier: (SystemManager.getAppIdentity() == .SalonWalker) ? "SalonWalker" : "SalonMaker")
        obj.title = title
        obj.contentDescription = contentDescription
        obj.imageUrl = imageUrl
//        obj.publiclyIndex = true
//        obj.locallyIndex = true
        
        let dataDic = NSMutableDictionary()
        if let dId = dId {
            dataDic["dId"] = dId
        }
        if let pId = pId {
            dataDic["pId"] = pId
        }
        if let seArticlesId = seArticlesId {
            dataDic["seArticlesId"] = seArticlesId
        }
        if let maArticleId = maArticleId {
            dataDic["maArticleId"] = maArticleId
        }
        
        if dataDic.count == 0 { return }
        obj.contentMetadata.customMetadata = dataDic
        
        var downloadUrl_ios = "itms-services://?action=download-manifest&url=https://wing-tst.skywind.com.tw/download_ios/SalonWalker/"
        var downloadUrl_android = "https://wing-tst.skywind.com.tw/download_ios/SalonWalker/"
        
        #if SALONMAKER
        
        // SalonMaker
        #if DEV
        downloadUrl_ios += "SalonMaker_DEV.plist"
        downloadUrl_android += "SalonWalker_designer_debug_v1.0.0_20190116.apk"
        #elseif UAT
        downloadUrl_ios += "SalonMaker_UAT.plist"
        downloadUrl_android += "SalonWalker_designer_debug_v1.0.0_20190116.apk"
        #else
        downloadUrl_ios = "https://itunes.apple.com/app/id1450476108"
        downloadUrl_android += "SalonWalker_designer_debug_v1.0.0_20190116.apk"
        #endif
        
        #else
        
        // SalonWalker
        #if DEV
        downloadUrl_ios += "SalonWalker_DEV.plist"
        downloadUrl_android += "SalonWalker_user_debug_v1.0.0_20190118.apk"
        #elseif UAT
        downloadUrl_ios += "SalonWalker_UAT.plist"
        downloadUrl_android += "SalonWalker_user_debug_v1.0.0_20190118.apk"
        #else
        downloadUrl_ios = "https://itunes.apple.com/app/id1450474788"
        downloadUrl_android += "SalonWalker_designer_debug_v1.0.0_20190116.apk"
        #endif
        
        #endif
        
        let lp = BranchLinkProperties()
        lp.addControlParam("random", withValue: UUID.init().uuidString)
        lp.addControlParam("$desktop_url", withValue: "https://www.facebook.com/salonwalker/")
        lp.addControlParam("$ios_url", withValue: downloadUrl_ios)
        lp.addControlParam("$ipad_url", withValue: downloadUrl_ios)
        lp.addControlParam("$android_url", withValue: downloadUrl_android)
        
        obj.getShortUrl(with: lp, andCallback: { (url, error) in
            SystemManager.hideLoading()
            
            if error != nil {
                failure(error)
            } else {
                if let url = url {
                    success(url)
                } else {
                    failure(error)
                }
            }
        })
    }
}


