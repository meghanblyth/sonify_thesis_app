//
//  Home.swift
//  Sonify
//
//  Created by Meghan Blyth on 14/07/2021.
//

import UIKit

struct Home {
    let title: String
    var image: UIImage?
    let name: String
}

extension Home {
    var asSonifiedData: SonifiedData {
        return SonifiedData(imageData: image?.jpegData(compressionQuality: 0.7) ?? Data(),
                            name: name)
    }
}
