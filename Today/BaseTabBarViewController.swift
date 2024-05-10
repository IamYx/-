//
//  BaseTabBarViewController.swift
//  Today
//
//  Created by 姚肖 on 2023/7/20.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
        // Do any additional setup after loading the view.
    }
    
    func loadUI() {
        let musicVc = MainViewController()
        let videoVc = DyPlayerViewController()
        
        let musicNav = UINavigationController(rootViewController: musicVc)
        let videoNav = UINavigationController(rootViewController: videoVc)
        
        musicVc.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        videoVc.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
        
        self.viewControllers = [musicNav, videoNav]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
