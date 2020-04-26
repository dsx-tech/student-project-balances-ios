//
//  RoundedVIews.swift
//  wagon
//
//  Created by Danila Ferents on 16/04/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation
import UIKit

//Classes of a round objects
class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10  //Make corners angled
    }
}

class RoundedShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5  //Make corners angled
        layer.shadowColor = AppColors.Blue.cgColor  //Color for corners
        layer.shadowOpacity = 0.4 //Make View transparent
        layer.shadowOffset = CGSize.zero //shadow bias
        layer.shadowRadius = 3 //make  shadow bigger
    }
}

class RoundedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10  
    }
}

class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}
