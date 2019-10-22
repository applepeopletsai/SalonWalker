//
//  WorksManager.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation

struct AlbumPhotoModel: Codable {
    var dwapId: Int?
    var ppapId: Int?
    var photoDesc: String?
    var photoUrl: String
    var isCover: Bool
    var selected: Bool? = false
}

struct AlbumPhotoListModel: Codable {
    var ouId: Int?
    var meta: MetaModel?
    var msg: String?
    var name: String?
    var albumsDesc: String?
    var createDate: String?
    var albumsPhoto: [AlbumPhotoModel]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if var albumsPhoto = try container.decodeIfPresent([AlbumPhotoModel].self, forKey: .albumsPhoto) {
            for index in 0..<albumsPhoto.count {
                albumsPhoto[index].selected = false
            }
            self.albumsPhoto = albumsPhoto
        }
        if let ouId = try container.decodeIfPresent(Int.self, forKey: .ouId) {
            self.ouId = ouId
        }
        if let meta = try container.decodeIfPresent(MetaModel.self, forKey: .meta) {
            self.meta = meta
        }
        if let msg = try container.decodeIfPresent(String.self, forKey: .msg) {
            self.msg = msg
        }
        if let name = try container.decodeIfPresent(String.self, forKey: .name) {
            self.name = name
        }
        if let albumsDesc = try container.decodeIfPresent(String.self, forKey: .albumsDesc) {
            self.albumsDesc = albumsDesc
        }
        if let createDate = try container.decodeIfPresent(String.self, forKey: .createDate) {
            self.createDate = createDate
        }
    }
}

struct MediaModel: Codable, Equatable {
    var meta: MetaModel?
    
    var dwpId: Int?
    var pppId: Int?
    var photoUrl: String?
    var photoDesc: String?
    
    var dwvId: Int?
    var ppvId: Int?
    var videoImage: Data?
    var videoUrl: String?
    var videoDesc: String?
    
    var dwaId: Int?
    var ppaId: Int?
    var dwapId: Int?
    var ppapId: Int?
    var name: String?
    var coverUrl: String?
    var albumsDesc: String?
    var createDate: String?
    var isCover: Bool?
    var albumsPhoto: [AlbumPhotoModel]?
    
    var selected: Bool?
    var imgUrl: String?
    var tempImgId: Int?
    var tempComment: String?
    var imageLocalIdentifier: String?
    
    /*enum CodingKeys: String, CodingKey {
        //將要api 送下來的欄位做更名的動作時可依此，而沒被更名的欄位全都要case 進來喔
        case dwpId = "pppId"
        case photoUrl
        case photoDesc
        case dwvId = "ppvId"
        case videoUrl
        case videoDesc
        case dwaId = "ppaId"
        case dwapId = "ppapId"
        case name
        case coverUrl
        case albumsDesc
    }*/
    
    static func == (lhs: MediaModel, rhs: MediaModel) -> Bool {
        if let dwpId_l = lhs.dwpId, let dwpId_r = rhs.dwpId {
            return dwpId_l == dwpId_r
        }
        if let dwaId_l = lhs.dwaId, let dwaId_r = rhs.dwaId {
            return dwaId_l == dwaId_r
        }
        if let dwvId_l = lhs.dwvId, let dwvId_r = rhs.dwvId {
            return dwvId_l == dwvId_r
        }
        if let pppId_l = lhs.pppId, let pppId_r = rhs.pppId {
            return pppId_l == pppId_r
        }
        if let ppaId_l = lhs.ppaId, let ppaId_r = rhs.ppaId {
            return ppaId_l == ppaId_r
        }
        if let ppvId_l = lhs.ppvId, let ppvId_r = rhs.ppvId {
            return ppvId_l == ppvId_r
        }
        return false
    }
}

struct WorksTypeModel: Codable {
    var ouId: Int?
    var meta: MetaModel?
    var msg: String?
    var dwaId: Int?
    var ppaId: Int?
    var photoList: [MediaModel]?
    var videoList: [MediaModel]?
    var albumsList: [MediaModel]?
    
    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if var photoList = try container.decodeIfPresent([MediaModel].self, forKey: .photoList) {
            for index in 0..<photoList.count {
                photoList[index].selected = false
            }
            self.photoList = photoList
        }
        if var videoList = try container.decodeIfPresent([MediaModel].self, forKey: .videoList) {
            for index in 0..<videoList.count {
                videoList[index].selected = false
            }
            self.videoList = videoList
        }
        if var albumsList = try container.decodeIfPresent([MediaModel].self, forKey: .albumsList) {
            for index in 0..<albumsList.count {
                albumsList[index].selected = false
            }
            self.albumsList = albumsList
        }
        if let meta = try container.decodeIfPresent(MetaModel.self, forKey: .meta) {
            self.meta = meta
        }
        if let ouId = try container.decodeIfPresent(Int.self, forKey: .ouId) {
            self.ouId = ouId
        }
        if let msg = try container.decodeIfPresent(String.self, forKey: .msg) {
            self.msg = msg
        }
        if let dwaId = try container.decodeIfPresent(Int.self, forKey: .dwaId) {
            self.dwaId = dwaId
        }
        if let ppaId = try container.decodeIfPresent(Int.self, forKey: .ppaId) {
            self.ppaId = ppaId
        }
    }
}

class WorksManager: NSObject {
    
    /// W001 取得相片列表（設計師）
    static func apiGetWorksPhotoList(photoType: String,
                                     page: Int = 1,
                                     pMax: Int = 50,
                                     ouId: Int? = nil,
                                     success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
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
                                        "photoType":photoType,
                                        "page":page,
                                        "pMax":pMax]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Works.getWorksPhotoList, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// W002 取得影片列表（設計師）
    static func apiGetWorksVideoList(photoType: String,
                                     page: Int = 1,
                                     pMax: Int = 50,
                                     ouId: Int? = nil,
                                     success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
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
                                        "photoType":photoType,
                                        "page":page,
                                        "pMax":pMax]
        
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Works.getWorksVideoList, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// W003 取得相簿列表（設計師）
    static func apiGetWorksAlbumsList(photoType: String,
                                      page: Int = 1,
                                      pMax: Int = 50,
                                      ouId: Int? = nil,
                                      success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
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
                                        "photoType":photoType,
                                        "page":page,
                                        "pMax":pMax]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Works.getWorksAlbumsList, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// W004 取得相簿相片列表（設計師）
    static func apiGetWorksAlbumsPhotoList(dwaId: Int,
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
                                        "dwaId":dwaId,
                                        "page":page,
                                        "pMax":pMax]
        APIManager.sendGetRequestWith(parameters: parameters, path: ApiUrl.Works.getWorksAlbumsPhotoList, success: { (response) in
            let result = APIManager.decode(response: response, type: BaseModel<MediaModel>.self)
            success(result)
        }, failure: failure)
    }
    
    /// W005 新增相簿（設計師）
    static func apiAddWorksAlbums(photoType: String,
                                  name: String,
                                  albumsDesc: String?,
                                  success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "photoType":photoType,
                                            "name":name]
            if let albumsDesc = albumsDesc {
                parameters["albumsDesc"] = albumsDesc
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.addWorksAlbums, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W006 編輯相簿名稱/說明（設計師）
    static func apiEditWorksAlbums(dwaId: Int,
                                   name: String,
                                   albumsDesc: String?,
                                   success: ((_ response: BaseModel<WorksTypeModel>?) -> Void)?,
                                   failure: failureClosure?) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "dwaId":dwaId,
                                            "name":name]
            if let albumsDesc = albumsDesc {
                parameters["albumsDesc"] = albumsDesc
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.editWorksAlbums, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success?(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W007 刪除相簿（設計師）
    static func apiDelWorksAlbums(dwaId: [Int],
                                  success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwaId":dwaId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.delWorksAlbums, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W008 設定相簿封面圖片（設計師）
    static func apiSetAlbumsCover(dwaId: Int,
                                  dwapId: Int,
                                  success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwaId":dwaId,
                                            "dwapId":dwapId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.setAlbumsCover, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W009 上傳相片 (設計師)
    static func apiUploadPhoto(photoType: String,
                               uploadFile: [UIImage],
                               photoDesc: [String],
                               success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "photoType":photoType,
                                            "photoDesc":photoDesc]
            APIManager.uploadImageRequestWith(images: uploadFile, parameters: parameters, path: ApiUrl.Works.uploadPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
        
    }
    
    /// W010
    static func apiUploadVideo(videoType: String,
                               uploadFile: [AVURLAsset],
                               videoDesc: [String]?,
                               success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                               failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "videoType":videoType]
            if let videoDesc = videoDesc {
                parameters["videoDesc"] = videoDesc
            }
            APIManager.uploadVideoRequestWith(videos: uploadFile, parameters: parameters, path: ApiUrl.Works.uploadVideo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W011 編輯相片/影片說明（設計師）
    static func apiEditPhoto(dwpId: Int?,
                             dwvId: Int?,
                             dpDesc: String,
                             success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                             failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            var parameters: [String:Any] = ["ouId":ouId,
                                            "dpDesc":dpDesc]
            if let dwpId = dwpId {
                parameters["dwpId"] = dwpId
            }
            if let dwvId = dwvId {
                parameters["dwvId"] = dwvId
            }
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.editPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W012 上傳/編輯相簿相片（設計師）
    static func apiUploadAlbumsPhoto(dwaId: Int,
                                     uploadFile: [UIImage],
                                     photoDesc: [String],
                                     success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                     failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwaId":dwaId,
                                            "photoDesc":photoDesc]
            APIManager.uploadImageRequestWith(images: uploadFile, parameters: parameters, path: ApiUrl.Works.uploadAlbumsPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W013 編輯相簿相片說明（設計師）
    static func apiEditAlbumsPhoto(dwaId: Int,
                                   albumsPhoto: [[String: Any]],
                                   success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                   failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwaId":dwaId,
                                            "albumsPhoto":albumsPhoto]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.editAlbumsPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W014 刪除相簿相片 (設計師)
    static func apiDelAlbumsPhoto(dwaId: Int,
                                  dwapId: [Int],
                                  success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                                  failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwaId":dwaId,
                                            "dwapId":dwapId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.delAlbumsPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W015 刪除相片（設計師）
    static func apiDelPhoto(dwpId: [Int],
                            success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                            failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwpId":dwpId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.delPhoto, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
    
    /// W016 刪除影片 (設計師)
    static func apiDelVideo(dwvId: [Int],
                            success: @escaping (_ response: BaseModel<WorksTypeModel>?) -> Void,
                            failure: @escaping failureClosure) {
        if let ouId = UserManager.sharedInstance.ouId {
            let parameters: [String:Any] = ["ouId":ouId,
                                            "dwvId":dwvId]
            APIManager.sendPostRequestWith(parameters: parameters, path: ApiUrl.Works.delVideo, success: { (response) in
                let result = APIManager.decode(response: response, type: BaseModel<WorksTypeModel>.self)
                success(result)
            }, failure: failure)
        } else {
            SystemManager.showErrorAlert(backToLoginVC: true)
        }
    }
}
