//
//  RobotViewController.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/12.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit




class RobotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Filter"
       
    }

    @IBAction func robotButtonDidPRess(_ sender: Any) {
        let vc = FilterViewController()
        navigationController?.pushViewController(vc, animated: true)
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
