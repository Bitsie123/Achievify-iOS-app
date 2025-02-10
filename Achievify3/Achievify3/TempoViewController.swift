//
//  TempoViewController.swift
//  Achievify3
//
//  Created by Marks on 09/09/2024.
//

import UIKit

// Custom UITableViewCell class
class cellclassTempo: UITableViewCell {}

class TempoViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var btnRange: UIButton!
    @IBOutlet weak var btnDistance: UIButton!
    @IBOutlet weak var variationButton: UIButton!
    
    // Data source for Tempo distance options
    var secondDataSource = ["2-4km (1.2-2.5 miles)", "4-6km (2.5-3.7 miles)", "6-8km (3.7-5 miles)", "8-10km (5-6.2 miles)", "10-12km (6.2-7.5 miles)"]
    
    // Text Fields
    @IBOutlet weak var durationTextField: UITextField!
    
    // Level Label
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var distanceLevelLabel: UILabel!
    
    // Passed selected challenge name and date
    var selectedChallenge: String?
    var competitionDate: String?
    
    // Transparent view components for dropdown box
    let transparentView = UIView()
    let tableView = UITableView()
    
    var selectedButton = UIButton()
    
    // Data source for Tempo pace ranges
    var dataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate and data source for the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellclassTempo.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: Transparent View
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.5
            
            // Set the height based on the selected button's data source
            let dataSourceToUse = (self.selectedButton == self.btnRange) ? self.dataSource : self.secondDataSource
            self.tableView.frame.size.height = CGFloat(dataSourceToUse.count * 50)
            self.tableView.frame.origin = CGPoint(x: frames.origin.x, y: frames.origin.y + frames.height + 5)
        }
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0
            self.tableView.frame.size.height = 0
        } completion: { _ in
            self.transparentView.removeFromSuperview()
            self.tableView.removeFromSuperview()
        }
    }
    
    
    // MARK: Dropdown boxes
    // Pace dropdown box
    @IBAction func onClickSelect(_ sender: Any) {
        dataSource = ["6:30-7:00 min/km", "5:30-6:00 min/km", "6:00-6:30 min/km", "5:00-5:30 min/km", "4:30-5:00 min/km"]
        selectedButton = btnRange
        addTransparentView(frames: btnRange.frame)
    }
    
    // Distance dropdown box
    @IBAction func onClickSelectDistance(_ sender: Any) {
        dataSource = secondDataSource // Assign the second data source
        selectedButton = btnDistance
        addTransparentView(frames: btnDistance.frame)
    }
    
    // Saving selections and navigating to the TaperTableViewController
    @IBAction func onSave(_ sender: Any) {
        if validateTextFields() {
            // Get TaperTableViewController
            let taperVC = storyboard?.instantiateViewController(withIdentifier: "TaperTableViewController") as! TaperTableViewController
            
            taperVC.competitionDate = competitionDate // Pass the competition date
            taperVC.tempoPlanHeartRate = "143-162 bpm" // Pass average Heart Rate value
            taperVC.tempoPlanPace = btnRange.title(for: .normal) // Pass the selected range
            taperVC.tempoPlanDistance = btnDistance.title(for: .normal) // Pass the selected distance
            taperVC.selectedChallenge = selectedChallenge // Pass the selected challenge
            
            // Navigate to TaperTableViewController
            navigationController?.pushViewController(taperVC, animated: true)
        } else {
            showAlert()
        }
    }
    
    // Validation before continuing
    func validateTextFields() -> Bool {
        if durationTextField.text?.isEmpty == true {
            return false
        }
        return true
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Missing Information", message: "You must fill in all text fields before saving.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Opional Variations alert controller
    @IBAction func onVariationTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Optional Variations", message: "Add Strides: 4 x 20-second strides at the end.\n\nBreaks: 2-minute easy jog between tempo intervals.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UITableView Delegate and DataSource
extension TempoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Set the cell text based on the selected button
        if selectedButton == btnRange {
            cell.textLabel?.text = dataSource[indexPath.row]
        } else {
            cell.textLabel?.text = secondDataSource[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the button title based on the selected row
        if selectedButton == btnRange {
            selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
            
            // Update the level label based on the selected pace range
            switch indexPath.row {
            case 0:
                levelLabel.text = "Beginner Level"
            case 1:
                levelLabel.text = "Universal Level"
            case 2:
                levelLabel.text = "Intermediate Level"
            case 3:
                levelLabel.text = "Advanced Level"
            case 4:
                levelLabel.text = "Elite Level"
            default:
                levelLabel.text = "Universal Level"
            }
        } else {
            selectedButton.setTitle(secondDataSource[indexPath.row], for: .normal)
            
            // Update the distance level label based on the selected distance range
            switch indexPath.row {
            case 0:
                distanceLevelLabel.text = "Beginner Level"
            case 1:
                distanceLevelLabel.text = "Universal Level"
            case 2:
                distanceLevelLabel.text = "Intermediate Level"
            case 3:
                distanceLevelLabel.text = "Advanced Level"
            case 4:
                distanceLevelLabel.text = "Elite Level"
            default:
                distanceLevelLabel.text = "Universal Level"
            }
        }
        
        removeTransparentView()
    }
}
