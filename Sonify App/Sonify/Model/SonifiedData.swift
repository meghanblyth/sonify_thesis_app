//
//  SonifiedData.swift
//  Sonify
//
//  Created by Meghan Blyth on 05/08/2021.
//

import UIKit

/// In future it is better to not store this data in the user defaults since it could be quite large. Maybe use Realm or CoreData instead
struct SonifiedData: Codable {
    let imageData: Data
    let name: String
    
    private var image: UIImage? {
        return UIImage(data: imageData)
    }
}

extension SonifiedData {
    var asHome: Home {
        return Home(title: "", image: image, name: name)
    }
}
