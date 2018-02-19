//
//  SplashViewController.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadApplicationData()
    }
    
    // MARK: - Layout
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Methods
    func loadApplicationData() {
        activityIndicator.startAnimating()
        CoreDataController.shared.load {
            self.activityIndicator.stopAnimating()
            self.showMainNavigationController()
        }
    }
    
    func showMainNavigationController() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
            let mainNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController")
            window.rootViewController = mainNavigationController
            window.makeKeyAndVisible()
        }
    }
    
}
