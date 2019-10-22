//
//  PlacesPhotoManager.swift
//  SalonWalker
//
//  Created by Cooper on 2018/9/4.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation

class PlacesPhotoManager: NSObject {
    
    /// P001 取得相片列表 (場地)
    static func apiGetPlacesPhotoList(page: Int = 1,
                                      pMax: Int = 50,
                                      success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "page":page,
                                            "pMax":pMax]
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.getPlacesPhotoList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P002取得影片列表 (場地)
    static func apiGetPlacesVideoList(page: Int = 1,
                                      pMax: Int = 50,
                                      success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                      failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "page":page,
                                            "pMax":pMax]
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.getPlacesVideoList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P003 取得相簿列表 (場地)
    static func apiGetPlacesAlbumsList(page: Int = 1,
                                       pMax: Int = 50,
                                       success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                       failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "page":page,
                                            "pMax":pMax]
            
            APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.getPlacesAlbumsList, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P004 取得相簿相片列表 (場地)
    static func apiGetPlacesAlbumsPhotoList(ppaId: Int,
                                            page: Int = 1,
                                            pMax: Int = 50,
                                            ouId: Int? = nil,
                                            success: @escaping (_ response: BaseModel<MediaModel>?) -> Void,
                                            failure: @escaping failureClosure) {
        var id = 0
        if let ouId = ouId {
            id = ouId
        } else if let ouId = UserManager.sharedInstance.ouId {
            id = ouId
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
            return
        }
        let parameters: [String:Any] = ["ouId":id,
                                        "ppaId":ppaId,
                                        "page":page,
                                        "pMax":pMax]
        
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.getPlacesAlbumsPhotoList, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<MediaModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// P005 新增相簿 (場地)
    static func apiAddPlacesAlbums(name: String,
                                   albumsDesc: String?,
                                   success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "name":name]
            if let albumsDesc = albumsDesc {
                parameters["albumsDesc"] = albumsDesc
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.addPlacesAlbums, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P006 編輯相簿說明（場地）
    static func apiEditPlacesAlbums(ppaId: Int,
                                    name: String,
                                    albumsDesc: String?,
                                    success: ((_ response: BaseModel<WorksTypeModel>?) -> Void)?,
                                    failure: failureClosure?) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "ppaId":ppaId,
                                            "name":name]
            if let albumsDesc = albumsDesc {
                parameters["albumsDesc"] = albumsDesc
            }
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.editPlacesAlbums, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success?(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P007 刪除相簿 (場地)
    static func apiDelPlacesAlbums(ppaId: [Int],
                                   success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "ppaId":ppaId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.delPlacesAlbums, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P008 設定相簿封面圖片（場地）
    static func apiSetAlbumsCover(ppaId: Int,
                                   ppapId: Int,
                                   success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "ppaId":ppaId,
                                            "ppapId":ppapId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.setAlbumsCover, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P009 上傳相片（場地）
    static func apiUploadPhoto(uploadFile: [UIImage],
                               photoDesc: [String]?,
                               success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                               failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId]
            if let photoDesc = photoDesc {
                parameters["photoDesc"] = photoDesc
            }
            
            APIManager.uploadImageRequestWith(images: uploadFile, parameters: parameters, path: ApiUrl.PlacesPhoto.uploadPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P010 上傳影片（場地）
    static func apiUploadVideo(uploadFile: [AVURLAsset],
                               videoDesc: [String]?,
                               success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId]
            if let videoDesc = videoDesc {
                parameters["videoDesc"] = videoDesc
            }
            APIManager.uploadVideoRequestWith(videos: uploadFile, parameters: parameters, path: ApiUrl.PlacesPhoto.uploadVideo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P011 編輯相片/影片說明（場地）
    static func apiEditPhoto(pppId: Int?,
                             ppvId: Int?,
                             ppDesc: String,
                             success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                             failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "ppDesc":ppDesc]
            if let pppId = pppId {
                parameters["pppId"] = pppId
            }
            if let ppvId = ppvId {
                parameters["ppvId"] = ppvId
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.editPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P012 上傳相簿相片 (場地)
    static func apiUploadAlbumsPhoto(ppaId: Int,
                                     uploadFile: [UIImage],
                                     photoDesc: [String],
                                     success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "ppaId":ppaId,
                                            "photoDesc":photoDesc]
            
            APIManager.uploadImageRequestWith(images: uploadFile, parameters: parameters, path: ApiUrl.PlacesPhoto.uploadAlbumsPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P013 編輯相簿相片說明（場地）
    static func apiEditAlbumsPhoto(ppaId: Int,
                                   albumsPhoto: [[String: Any]],
                                   success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "ppaId":ppaId,
                                            "albumsPhoto":albumsPhoto]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.editAlbumsPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P014 刪除相簿相片 (場地)
    static func apiDelAlbumsPhoto(ppaId: Int,
                                  ppapId: [Int],
                                  success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "ppaId":ppaId,
                                            "ppapId":ppapId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.delAlbumsPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P015 刪除相片（場地）
    static func apiDelPhoto(pppId: [Int],
                            success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                            failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "pppId":pppId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.delPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// P016 刪除影片（場地）
    static func apiDelVideo(ppvId: [Int],
                            success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                            failure: @escaping failureClosure) {
        
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "ppvId":ppvId]
            
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.PlacesPhoto.delVideo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
}
