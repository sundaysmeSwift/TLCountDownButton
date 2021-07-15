//
//  ViewController.swift
//  TLCountDownButton
//
//  Created by Biggerlens on 2021/7/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        TLCountDownButton.shared.play(withNumber: 5, endTitle: "1232")
        
        var imageNames: [AnyHashable] = []
        var i = 10
        while i > 0 {
            imageNames.append(String(format: "number%zd", i))
            i -= 1
        }
        
        TLCountDownButton.shared.isScaleNtoIdenty = true
        TLCountDownButton.shared.play(withImages: imageNames, begin: { button in
            print("倒计时开始")
        }, success: { button in
            print("倒计时结束")
        })
    }


}

