//
//  AddressDBManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/5/2.
//  Copyright © 2018年 skywind. All rights reserved.
//

import Foundation
import SQLite

struct AddressModel {
    var ID: String
    var city: String
    var area: String
}

class AddressDBManager {
    
    static let sharedInstance = AddressDBManager()
    private var db: Connection!
    
    init() {
        guard let path = Bundle.main.path(forResource: "Address", ofType: "db") else {
            print("Can't find resource of AddressDB")
            return
        }
        do {
            db = try Connection(path, readonly: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func selectDBForCity() -> Array<String> {
        let table = Table("zip_code")
        let CITY = Expression<String>("zc_city")
        return try! AddressDBManager.sharedInstance.db.prepare(table.select(distinct: CITY)).map { return $0[CITY] }
    }
    
    static func selectDBForArea(withCity city: String) -> Array<String> {
        let table = Table("zip_code")
        let CITY = Expression<String>("zc_city")
        let AREA = Expression<String>("zc_country")
        return try! AddressDBManager.sharedInstance.db.prepare(table.select(distinct: AREA).filter(CITY == city)).map { return $0[AREA] }
    }
    
    static func selectDBForId(withCity city: String, area: String) -> Array<String> {
        let table = Table("zip_code")
        let CITY = Expression<String>("zc_city")
        let AREA = Expression<String>("zc_country")
        let ID = Expression<Int>("zc_id")
        return try! AddressDBManager.sharedInstance.db.prepare(table.filter(CITY == city && AREA == area)).map { return "\($0[ID])" }
    }
    
    static func selectDB(withID id: String) -> AddressModel? {
        let table = Table("zip_code")
        let CITY = Expression<String>("zc_city")
        let AREA = Expression<String>("zc_country")
        let ID = Expression<Int>("zc_id")
        let addresses = try! AddressDBManager.sharedInstance.db.prepare(table.filter(ID == Int(id) ?? 0))
        let addressModels = addresses.map { return AddressModel(ID: "\($0[ID])", city: $0[CITY], area: $0[AREA]) }
        return addressModels.first
    }
    
    static func getZipCodeWith(city: String, area: String) -> Int {
        let table = Table("zip_code")
        let CITY = Expression<String>("zc_city")
        let AREA = Expression<String>("zc_country")
        let ID = Expression<Int>("zc_id")
        
        if let zipCodeString = try! AddressDBManager.sharedInstance.db.prepare(table.filter(CITY == city && AREA == area)).map({ return "\($0[ID])" }).first {
            return Int(zipCodeString) ?? -1
        }
        
        return -1
    }
}
