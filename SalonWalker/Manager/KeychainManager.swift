//
//  KeychainManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/18.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class KeychainManager: NSObject {
    
    private static func createQuaryMutableDictionary(identifier: String) -> NSMutableDictionary {
        // 創建一個條件字典
        let keychainQuaryMutableDictionary = NSMutableDictionary.init(capacity: 0)
        // 設置條件存儲的類型
        keychainQuaryMutableDictionary.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        // 設置存儲數據的標記
        keychainQuaryMutableDictionary.setValue(identifier, forKey: kSecAttrService as String)
        keychainQuaryMutableDictionary.setValue(identifier, forKey: kSecAttrAccount as String)
        // 設置數據訪問屬性
        keychainQuaryMutableDictionary.setValue(kSecAttrAccessibleAfterFirstUnlock, forKey: kSecAttrAccessible as String)
        // 返回創建條件字典
        return keychainQuaryMutableDictionary
    }
    
    static func saveData(data:Any ,withIdentifier identifier: String) -> Bool {
        // 獲取存儲數據的條件
        let keyChainSaveMutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 刪除舊的存儲數據
        SecItemDelete(keyChainSaveMutableDictionary)
        // 設置數據
        keyChainSaveMutableDictionary.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: kSecValueData as String)
        // 進行存儲數據
        let saveState = SecItemAdd(keyChainSaveMutableDictionary, nil)
        if saveState == noErr  {
            return true
        }
        return false
    }
    
    static func updateData(data:Any ,withIdentifier identifier: String) -> Bool {
        // 獲取更新的條件
        let keyChainUpdataMutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 創建數據存儲字典
        let updataMutableDictionary = NSMutableDictionary.init(capacity: 0)
        // 設置數據
        updataMutableDictionary.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: kSecValueData as String)
        // 更新數據
        let updataStatus = SecItemUpdate(keyChainUpdataMutableDictionary, updataMutableDictionary)
        if updataStatus == noErr {
            return true
        }
        return false
    }
    
    static func readData(identifier: String) -> Any {
        var idObject:Any?
        // 獲取查詢條件
        let keyChainReadmutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 提供查詢數據的兩個必要參數
        keyChainReadmutableDictionary.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        keyChainReadmutableDictionary.setValue(kSecMatchLimitOne, forKey: kSecMatchLimit as String)
        // 創建獲取數據的引用
        var queryResult: AnyObject?
        // 通過查詢是否存儲在數據
        let readStatus = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(keyChainReadmutableDictionary, UnsafeMutablePointer($0))
        }
        if readStatus == errSecSuccess {
            if let data = queryResult as! NSData? {
                idObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as Any
            }
        }
        return idObject as Any
    }
    
    static func deleteData(identifier: String) -> Bool {
        // 獲取刪除的條件
        let keyChainDeleteMutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 刪除數據
        let status = SecItemDelete(keyChainDeleteMutableDictionary)
        if status == noErr {
            return true
        }
        return false
    }
}

