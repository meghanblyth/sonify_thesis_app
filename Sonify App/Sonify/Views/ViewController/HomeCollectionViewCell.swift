//
//  HomeCollectionViewCell.swift
//  Sonify
//
//  Created by Meghan Blyth on 13/07/2021.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var mainTitleView: UILabel!
    
    func setup(with home: Home){
        mainImageView.image = home.image
        mainTitleView.text = home.title
    }
}
