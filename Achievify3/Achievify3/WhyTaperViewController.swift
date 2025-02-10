//
//  WhyTaperViewController.swift
//  Achievify3
//
//  Created by Marks on 16/09/2024.
//

import UIKit
import WebKit

class WhyTaperViewController: UIViewController {
    
    // Outleys
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var settingsNavButtonItem: UIBarButtonItem!
    
    
    var webURL : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safely unwrap the webURL
        if let webURLString = webURL, let urlWeb = URL(string: webURLString) {
            let webURLRequest = URLRequest(url: urlWeb)
            webView.load(webURLRequest)
        } else {
            // Handle the case where webURL is nil or invalid
            let defaultURL = URL(string: "https://www.asics.com/gb/en-gb/running-advice/why-tapering-is-important-before-race-day/")!
            let defaultURLRequest = URLRequest(url: defaultURL)
            webView.load(defaultURLRequest)
        }
        
        // Create actions for the settings menu
        let firstAction = UIAction(title: "View Badges", image: UIImage(systemName: "star")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Get the BadgesViewController
            if let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController {
                self.present(badgesVC, animated: true, completion: nil)
            } else {
                print("BadgesViewController could not be instantiated.")
            }
        }
        
        // Other Actions
        let secondAction = UIAction(title: "Notifications", image: UIImage(systemName: "bell")) { action in
            print("Notifications...")
        }
        
        let thirdAction = UIAction(title: "Account", image: UIImage(systemName: "person")) { action in
            print("Account...")
        }
        
        // Create the menu with the actions with Options title
        let menu = UIMenu(title: "Options", children: [firstAction, secondAction, thirdAction])
        
        // Attach the menu to the UIBarButtonItem
        settingsNavButtonItem.menu = menu
    }
}
