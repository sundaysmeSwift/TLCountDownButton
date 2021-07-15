//
//  extension+window.swift
//  TLCountDownButton
//
//  Created by Biggerlens on 2021/7/15.
//

import UIKit

extension UIApplication {
    
    var currentWindow: UIWindow? {
        let windows = UIApplication.shared.windows
        for window in (windows as NSArray).reverseObjectEnumerator() {
            guard let window = window as? UIWindow else {
                continue
            }
            if window.windowLevel == .normal && window.bounds.equalTo(UIScreen.main.bounds) {
                return window
            }
        }
        return UIApplication.shared.keyWindow
    }
}


extension UIViewController {
    // MARK: - 找到当前显示的viewcontroller
    class func current(base: UIViewController? = UIApplication.shared.currentWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return current(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return current(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return current(base: presented)
        }
        if let split = base as? UISplitViewController{
            return current(base: split.presentingViewController)
        }
        return base
    }
    

}

