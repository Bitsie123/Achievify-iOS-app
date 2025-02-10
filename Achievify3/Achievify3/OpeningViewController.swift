//
//  OpeningViewController.swift
//  Achievify3
//
//  Created by Marks on 30/08/2024.
//

import UIKit

// Custom UITableViewCell class for challenge selection dropdown
class cellClass: UITableViewCell {}

class OpeningViewController: UIViewController {

    // Outlets
    @IBOutlet weak var btnSelectChallenge: UIButton!
    @IBOutlet weak var settingsNavButtonItem: UIBarButtonItem!
    @IBOutlet weak var daysAwayLabel: UILabel!
    
    // Transparent view components for dropdown box
    let transparentView = UIView()
    let tableView = UITableView()
    
    var selectedButton = UIButton()
    
    // Data source for challenges dropdown
    var dataSource = [String]()
    
    // Dictionary to store competition names and dates
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
        
        // Set delegate and data source for the TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass.self, forCellReuseIdentifier: "Cell")
        
        // Hide the back button
        self.navigationItem.hidesBackButton = true
        
        // Initially hide the days away label
        daysAwayLabel.isHidden = true
        
    /* REFERENCE
        Apple Developer (no date) UIAction,
        Apple Developer Documentation.
        Available at: https://developer.apple.com/documentation/uikit/uiaction?changes=_5
    */
        // Create actions for the settings menu
        let firstAction = UIAction(title: "View Badges", image: UIImage(systemName: "star")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Connect to BadgesViewController
            if let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController {
                self.present(badgesVC, animated: true, completion: nil)
            } else {
                print("BadgesViewController is not available")
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
        
        // Attach the menu to the settings UIBarButtonItem
        settingsNavButtonItem.menu = menu
    }
    
    
/* REFERENCE
    Agarwal, S. (2019) Swift 4.2: How to Create DropDown list dynamically (Xcode 10.1),
    YouTube.
    Available at: https://www.youtube.com/watch?v=D3DCPaEE4hQ
*/
    // MARK: Transparent View
    // Adds a transparent view and a tableView for selecting challenges
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        // Position tableView under the button
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        // Tap gesture
        let tapgesture = UITapGestureRecognizer(target: self, action:
                                                    #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut,
                       animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    
    // Removes the transparent view and collapses the tableView
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut,
                       animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    // tableView triggered when selecting a challenge
    @IBAction func onClickSelect(_ sender: Any) {
        dataSource = ["Cork 10k", "Cork Half (21k)", "Cork Full (42k)", "Very Pink Run (5k)",
                      "Very Pink Run (10k)", "Charleville International Half (21k)", "Glengariff 5 Mile Run",
                      "Run in the Dark (5k)", "Run in the Dark (10k)", "The Great Railway Run (25k)"
        ]
        selectedButton = btnSelectChallenge
        addTransparentView(frames: btnSelectChallenge.frame)
    }
    

/* REFERENCE
    iOS Minds (2021) Swift: Navigating to the next screen and data passing using Navigation Controller in XCode12,
    YouTube.
    Available at: https://www.youtube.com/watch?v=X7FanhKuBJw
*/
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taperPlanSegue" {
            if let navigationController = segue.destination as? UINavigationController,
               let destinationVC = navigationController.viewControllers.first as? TaperPlanViewController {
                let selectedChallenge = btnSelectChallenge.title(for: .normal)
                destinationVC.selectedChallenge = selectedChallenge
                
                // Pass competition date as a string
                if let competitionDateString = competitionDates[selectedChallenge ?? ""] {
                    destinationVC.competitionDate = competitionDateString
                }
            }
        }
    }
    
    @IBAction func onContinue(_ sender: Any) {
        if let selectedChallenge = btnSelectChallenge.title(for: .normal), !selectedChallenge.isEmpty {
            // Retrieve the competition date string from the dictionary
            if let competitionDateString = competitionDates[selectedChallenge],
               let competitionDate = getDate(from: competitionDateString) {
                let daysRemaining = calculateDaysBetween(now: Date(), futureDate: competitionDate)
                
                // Only proceed if daysRemaining is a valid number
                if daysRemaining >= 0 {
                    if daysRemaining < 1 {
                        // Show alert if it's too late to start a taper plan
                        let alert = UIAlertController(title: "Too Late", message: "Unfortunately, it's too late to start a taper plan.\n\nRest up and good luck in your competition!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    } else {
                        // More than 14 days remaining, allow segue to TaperPlanViewController
                        performSegue(withIdentifier: "taperPlanSegue", sender: self)
                    }
                } else {
                    // Show an alert if the competition has already passed
                    let alert = UIAlertController(title: "Error", message: "This competition has already passed.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
        } else {
            // Show an alert if no challenge is selected
            let alert = UIAlertController(title: "Error", message: "You must select a challenge before proceeding.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
/* REFERENCE
    Hudson, P. (2022) How to convert dates and Times to a string using DateFormatter, 
    Hacking with Swift.
    Available at: https://www.hackingwithswift.com/example-code/system/how-to-convert-dates-and-times-to-a-string-using-dateformatter
*/
    // Convert date string to Date
    func getDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
        
/* REFERENCE
    Wongpatcharapakorn, S. (2020) Getting the number of days between two dates in swift, 
    Sarunw.
    Available at: https://sarunw.com/posts/getting-number-of-days-between-two-dates/
 */
    // Calculate days between two dates
    func calculateDaysBetween(now: Date, futureDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: now, to: futureDate)
        return components.day ?? 0
    }
    
    // Days away label
    func updateDaysAwayLabel(for competition: String) {
        guard let competitionDateString = competitionDates[competition],
              let competitionDate = getDate(from: competitionDateString) else {
            daysAwayLabel.isHidden = true
            return
        }
        
        let daysRemaining = calculateDaysBetween(now: Date(), futureDate: competitionDate)
        
        if daysRemaining >= 0 {
            daysAwayLabel.text = "\(daysRemaining) days away"
            daysAwayLabel.isHidden = false
        } else {
            daysAwayLabel.text = "Competition has passed"
            daysAwayLabel.isHidden = false
        }
    }
}

// MARK: - UITableView Delegate and DataSource
extension OpeningViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // Configure each cell with the challenge name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
        
        // Update days away label when a competition is selected
        let selectedCompetition = dataSource[indexPath.row]
        updateDaysAwayLabel(for: selectedCompetition)
    }
}




