//
//  TaperPlanViewController.swift
//  Achievify3
//
//  Created by Marks on 30/08/2024.
//

import UIKit

class TaperPlanViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var deadlineLabel: UILabel!
    
    @IBOutlet weak var settingsNavButtonItem: UIBarButtonItem!
    
    // Transferred selected competition date and challenge
    var competitionDate: String?
    var selectedChallenge: String?
    
    
  /* REFERENCE
     iOS Academy (2020) Create Custom Checkbox in Swift 5 (Xcode 12, iOS 2020) - Swift,
     YouTube.
     Available at: https://www.youtube.com/watch?v=R8SGEQXxhWw
  */
    // MARK: Checkboxes
    // Checkboxes
    let checkbox1 = CircularCheckbox(frame: CGRect(x:45, y:360, width: 40, height: 40))
    let checkbox2 = CircularCheckbox(frame: CGRect(x:45, y:435, width: 40, height: 40))
    let checkbox3 = CircularCheckbox(frame: CGRect(x:45, y:508, width: 40, height: 40))
    let checkbox4 = CircularCheckbox(frame: CGRect(x:45, y:590, width: 40, height: 40))
    
    var checkboxes: [CircularCheckbox] = []
    var selectedCheckbox: CircularCheckbox?
    
    // Dictionary to store competition dates
    let competitionDates: [String: String] = [
        "Cork 10k": "2024-09-28", // competition passed
        "Cork Half (21k)": "2024-10-05", // within 4 days
        "Cork Full (42k)": "2024-10-30",
        "Very Pink Run (5k)": "2024-10-25",
        "Very Pink Run (10k)": "2024-10-31",
        "Charleville International Half (21k)": "2024-10-04",
        "Glengariff 5 Mile Run": "2024-10-22",
        "Run in the Dark (5k)": "2024-11-10",
        "Run in the Dark (10k)": "2024-11-10",
        "The Great Railway Run (25k)": "2024-12-01"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    /* REFERENCE
        Swift - How to hide back button in navigation item? (n.d.).
        Stack Overflow.
        Available at: https://stackoverflow.com/questions/27373812/swift-how-to-hide-back-button-in-navigation-item
     */
        // Hide back navigation button
        self.navigationItem.hidesBackButton = true
        
        // Create actions for the settings menu
        let firstAction = UIAction(title: "View Badges", image: UIImage(systemName: "star")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Connect to BadgesViewController
            if let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController {
                self.present(badgesVC, animated: true, completion: nil)
            } else {
                // Debugging print if the view controller fails to load
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
        
        // Set challenge and deadline labels
        if let challenge = selectedChallenge {
            challengeLabel.text = challenge
            deadlineLabel.text = updateDeadlineLabel(for: challenge)
        }
        
        // Add checkboxes to view and add tap gesture
        checkboxes = [checkbox1, checkbox2, checkbox3, checkbox4]
        for checkbox in checkboxes {
            view.addSubview(checkbox)
            checkbox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox(_:))))
        }
    }
    
    // Function to update deadline label
    func updateDeadlineLabel(for challenge: String) -> String {
        guard let competitionDateString = competitionDates[challenge],
              let competitionDate = getDate(from: competitionDateString) else {
            return "Unknown deadline"
        }
        
        let daysRemaining = calculateDaysBetween(now: Date(), futureDate: competitionDate)
        
        if daysRemaining >= 0 {
            return "\(daysRemaining) days until the competition"
        } else {
            return "Competition has passed"
        }
    }
    
    // Helper function to convert date string to Date
    func getDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
    
    // Helper function to calculate the days between two dates
    func calculateDaysBetween(now: Date, futureDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: now, to: futureDate)
        return components.day ?? 0
    }
    
    // Checkbox selection
    @objc func didTapCheckbox(_ sender: UITapGestureRecognizer) {
        guard let tappedCheckbox = sender.view as? CircularCheckbox else { return }
        
        for checkbox in checkboxes {
            checkbox.setChecked(false)
        }
        
        tappedCheckbox.setChecked(true)
        selectedCheckbox = tappedCheckbox
    }
    
    
    /* REFERENCE
     Apple (no date) UIAlertController,
     Apple Developer Documentation.
     Available at: https://developer.apple.com/documentation/uikit/uialertcontroller
     */
    // MARK: Alert Controllers
    // Displaying Easy Plan info
    @IBAction func easyInfo(_ sender: Any) {
        let alertController = UIAlertController(title: "Easy Plan Info", message: "An easy run is a short to moderate-length run done at the runner's natural pace.\n\nWhile individual easy runs are not intended to be difficult, they should be done frequently, and in the aggregate, they promote significant improvements in aerobic capacity, endurance, and running economy.\n\nThese will make up the majority of your tapering distance.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Displaying Tempo Plan info
    @IBAction func tempoInfo(_ sender: Any) {
        let alertController = UIAlertController(title: "Tempo Plan Info", message: "A tempo run is a sustained effort at lactate threshold intensity, which is the quickest pace that highly fit runners can maintain for an hour and the fastest pace that less fit runners can keep for 20 minutes.\n\nTempo or threshold runs are designed to increase the speed you can maintain for an extended length of time as well as the duration of that relatively fast pace.\n\nThese runs should comprise warm-up miles, increased effort in the middle, and cool-down miles at the finish.\n\nThese runs can be as short as three miles.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Displaying Interval Plan info
    @IBAction func intervalInfo(_ sender: Any) {
        let alertController = UIAlertController(title: "Interval Plan Info", message: "Interval training consists of repeated brief bursts of fast running followed by gradual jogging or standing recoveries.\n\nThis style allows a runner to fit more fast running into a single workout than he or she could with a single extended fast effort till fatigue.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Displaying Progression Plan info
    @IBAction func progressionInfo(_ sender: Any) {
        let alertController = UIAlertController(title: "Progression Plan Info", message: "A progression run starts at a runner's natural speed and ends with a faster portion, increasing the pace incrementally throughout the run.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    /* REFERENCE
     Programming Guru (2021) SWITCH STATEMENT IN SWIFT IOS XCODE | SWIFT SWITCH STATEMENT | SWIFT TUTORIAL FOR BEGINNERS,
     YouTube.
     Available at: https://www.youtube.com/watch?v=_KDZP5kpnTg
     */
    // MARK: Checkbox Selection
    // Action for continuing to the next view controller based on the selected checkbox
    @IBAction func continueButton(_ sender: Any) {
        guard let selectedCheckbox = selectedCheckbox else {
            return
        }
        
        let viewControllerIdentifier: String
        
        switch selectedCheckbox {
        case checkbox1:
            viewControllerIdentifier = "EasyPlanViewController"
        case checkbox2:
            viewControllerIdentifier = "TempoViewController"
        case checkbox3:
            viewControllerIdentifier = "IntervalViewController"
        case checkbox4:
            viewControllerIdentifier = "ProgressionViewController"
        default:
            return
        }
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: viewControllerIdentifier) {
            // Pass the competition date and name to selected taper plan
            if let easyPlanVC = viewController as? EasyPlanViewController {
                easyPlanVC.competitionDate = competitionDate
                easyPlanVC.selectedChallenge = selectedChallenge
            }
            
            if let tempoPlanVC = viewController as? TempoViewController {
                tempoPlanVC.competitionDate = competitionDate
                tempoPlanVC.selectedChallenge = selectedChallenge
            }
            
            if let intervalPlanVC = viewController as? IntervalViewController {
                intervalPlanVC.competitionDate = competitionDate
                intervalPlanVC.selectedChallenge = selectedChallenge
            }
            
            if let progressionPlanVC = viewController as? ProgressionViewController {
                progressionPlanVC.competitionDate = competitionDate
                progressionPlanVC.selectedChallenge = selectedChallenge
            }
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
