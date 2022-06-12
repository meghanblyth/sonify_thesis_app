//
//  String+Extension.swift
//  Sonify
//
//  Created by Meghan Blyth on 06/08/2021.
//

import Foundation

extension String {
    var fullPathFromDocuments: URL {
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent(self)
    }
}
