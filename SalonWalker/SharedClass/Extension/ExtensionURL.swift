//
//  ExtensionURL.swift
//  SalonWalker
//
//  Created by Cooper on 2018/9/19.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

extension URL {
    
    /** return Byte, if return -1 means error occured */
    func getFileSize() -> Double {
        do {
            let resourceValues = try self.resourceValues(forKeys: [URLResourceKey.fileSizeKey])
            let fileSize = resourceValues.fileSize!
            print("File size = " + ByteCountFormatter().string(fromByteCount: Int64(fileSize)))
            return Double(fileSize) / 1000.0 / 1000.0
        } catch {
            print(error)
            return -1
        }
    }

}
