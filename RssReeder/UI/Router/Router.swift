//
//  Router.swift
//  MoviesDB
//
//  Created by Dmitry Kocherovets on 15.12.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit

fileprivate func createVC<T: UIViewController>(storyboardName: String, type: T.Type) -> T {

    UIStoryboard(name: storyboardName, bundle: nil)
        .instantiateViewController(withIdentifier: String(describing: T.self)) as! T
}

extension UIViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

class Router {

    private static var topmostViewController: UIViewController {
        return UIApplication.shared.windows.first!.topmostViewController!
    }

    private static var navigationController: UINavigationController? {
        return UIApplication.shared.windows.first!.topmostViewController!.navigationController
    }

    static func showNewsItem() {

        ui {
            let vc = createVC(storyboardName: "Main", type: NewsViewVC.self)
            UIViewController.topNavigationController()?.pushViewController(vc, animated: true)
        }
    }
}

extension UIViewController {

    static var topmostViewController: UIViewController? {
        return UIApplication.shared.windows.first?.topmostViewController
    }

    @objc var topmostViewController: UIViewController? {
        return presentedViewController?.topmostViewController ?? self
    }

    static func topNavigationController(vc: UIViewController? = nil) -> UINavigationController? {

        let vc = vc ?? UIApplication.shared.windows.first!.rootViewController
        if let nc = vc as? UINavigationController {
            return nc
        }
        if let tab = vc as? UITabBarController {
            return topNavigationController(vc: tab.selectedViewController)
        }
        if let parent = vc?.children.last {
            return topNavigationController(vc: parent)
        }
        return nil
    }
}

extension UINavigationController {

    @objc override var topmostViewController: UIViewController? {
        return visibleViewController?.topmostViewController
    }
}

extension UITabBarController {

    @objc override var topmostViewController: UIViewController? {
        return selectedViewController?.topmostViewController
    }
}

extension UIWindow {

    var topmostViewController: UIViewController? {
        return rootViewController?.topmostViewController
    }
}

func ui(closure: @escaping () -> ()) {
    let when = DispatchTime.now()
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func delay(_ delay: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
