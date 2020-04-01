//
//  GraphTabVC.swift
//  graphs
//
//  Created by Danila Ferents on 26.11.2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit

class GraphTabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

		let pieChartVC = PieChartVC()
		pieChartVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "pie"), selectedImage: UIImage(named: "pieopen"))

//		let areaChartVC = AreaChartVC()
//		areaChartVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "spline"), selectedImage: UIImage(named: "splineopen"))
//		let tabBarList = [pieChartVC, areaChartVC]
//		viewControllers = tabBarList
    }
}
