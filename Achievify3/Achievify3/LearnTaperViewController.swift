//
//  LearnTaperViewController.swift
//  Achievify3
//
//  Created by Marks on 16/09/2024.
//

import UIKit

class LearnTaperViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var settingsNavButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the back button
        self.navigationItem.hidesBackButton = true
        
        // Create actions for the settings menu
        let firstAction = UIAction(title: "View Badges", image: UIImage(systemName: "star")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Get BadgesViewController
            if let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController {
                self.present(badgesVC, animated: true, completion: nil)
            } else {
                print("BadgesViewController could not be instantiated.")
            }
        }
        
        // Other actions
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
    
    // MARK: Buttons
    // Maximise Performance button
    @IBAction func btnMaximisePerformance(_ sender: Any) {
        showPerformanceAlert()
    }
    
    // Alert controller
    private func showPerformanceAlert() {
        let alert = UIAlertController(title: "Unlock Required",
                                      message: "You need to have 3 taper badges in order to unlock this.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Tapering vs Recovery
    @IBAction func btnDifference(_ sender: Any) {
        showDifferenceAlert()
    }
    
    private func showDifferenceAlert() {
        let alert = UIAlertController(title: "Unlock Required",
                                      message: "You need to have 5 taper badges in order to unlock this.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Reducing Fatigue
    @IBAction func btnFatigue(_ sender: Any) {
        showFatigueAlert()
    }
    
    private func showFatigueAlert() {
        let alert = UIAlertController(title: "Unlock Required",
                                      message: "You need to have 7 taper badges in order to unlock this.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
