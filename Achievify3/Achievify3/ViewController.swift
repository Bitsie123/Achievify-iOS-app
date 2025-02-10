//
//  ViewController.swift
//  Achievify3
//
//  Created by Claire Marks on 27/08/2024.
//

import UIKit
import CoreData

/* REFERENCE
 https://www.youtube.com/watch?v=D3DCPaEE4hQ
*/
class CellClass: UITableViewCell {
    
}

class ViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var btnSelectType: UIButton!
    
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var paceTextField: UITextField!
    @IBOutlet weak var heartRateTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var settingsNavButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var messageLabel: UITextView!
    
    var competitionDate: String?
    var selectedChallenge: String?
    
    let transparentView = UIView()
    let tableView = UITableView()
    
    var selectedButton = UIButton()
    
    var dataSource = [String]()
    
    /* REFRENCE */
    // Define maximum character limits
    let maxDistanceCharacters = 10
    let maxPaceCharacters = 10
    let maxHeartRateCharacters = 3
    let maxDurationCharacters = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        // Set keyboard type to numberPad for numeric input
        distanceTextField.keyboardType = .numberPad
        paceTextField.keyboardType = .numberPad
        heartRateTextField.keyboardType = .numberPad
        durationTextField.keyboardType = .numberPad
        
        // Set the text field delegates
        distanceTextField.delegate = self
        paceTextField.delegate = self
        heartRateTextField.delegate = self
        durationTextField.delegate = self
        
        checkCompetitionDate() // Call this to update messageLabel
        
        // Create actions for the menu
        let firstAction = UIAction(title: "View Badges", image: UIImage(systemName: "star")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Try to instantiate the BadgesViewController
            if let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController {
                // Push the BadgesViewController if a navigation controller exists
                self.present(badgesVC, animated: true, completion: nil)
            } else {
                // Debugging print if the view controller fails to load
                print("BadgesViewController could not be instantiated.")
            }
        }
        
        let secondAction = UIAction(title: "Notifications", image: UIImage(systemName: "bell")) { action in
            print("Notifications...")
        }
        
        let thirdAction = UIAction(title: "Account", image: UIImage(systemName: "person")) { action in
            print("Account...")
        }
        
        // Create the menu with the actions
        let menu = UIMenu(title: "Options", children: [firstAction, secondAction, thirdAction])
        
        // Attach the menu to the UIBarButtonItem
        settingsNavButtonItem.menu = menu
        
    /* REFERENCE
     Spacecash21. (2020, November 19). Close iOS Keyboard by touching anywhere using Swift. 
     Stack Overflow.
     Avaliable at: https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
    */
        // Close keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // Method to close the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /* REFRENCE
     Frankie. (2016, October 24). Restrict the characters that can be entered in a uitextfield in Swift.
     Stack Overflow.
     Avaliable at: https://stackoverflow.com/questions/40228837/restrict-the-characters-that-can-be-entered-in-a-uitextfield-in-swift
     
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Define allowed characters within textFields
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        
        // Get the current text and the new text length
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        
        switch textField {
        case distanceTextField:
            return allowedCharacters.isSuperset(of: characterSet) && newLength <= maxDistanceCharacters
            
        case paceTextField:
            // Allow numbers and a single '.'
            let allowedPaceCharacters = CharacterSet(charactersIn: "0123456789.")
            if !allowedPaceCharacters.isSuperset(of: characterSet) {
                return false
            }
            // Prevent more than one '.'
            if currentText.contains(".") && string == "." {
                return false
            }
            return newLength <= maxPaceCharacters
            
        case heartRateTextField:
            return allowedCharacters.isSuperset(of: characterSet) && newLength <= maxHeartRateCharacters
            
        case durationTextField:
            return allowedCharacters.isSuperset(of: characterSet) && newLength <= maxDurationCharacters
            
        default:
            return true
        }
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
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
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut,
                       animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @IBAction func onClickSelect(_ sender: Any) {
        dataSource = ["Run", "Walk"]
        selectedButton = btnSelectType
        addTransparentView(frames: btnSelectType.frame)
    }
    
    // Uploading activity
    @IBAction func submitData(_ sender: Any) {
        // Validate text fields
        // Validate text fields
        if !validateTextFields() {
            let alert = UIAlertController(title: "Input Error", message: "Please fill in all fields before submitting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let distance = distanceTextField.text ?? ""
        let pace = paceTextField.text ?? ""
        let heartRate = heartRateTextField.text ?? ""
        
        // Save the user's stats with the name "You"
        let fetchRequest: NSFetchRequest<TaperGroup> = TaperGroup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "You")
        
        do {
            let results = try context.fetch(fetchRequest)
            let userEntry: TaperGroup
            
            if results.isEmpty {
                let entity = NSEntityDescription.entity(forEntityName: "TaperGroup", in: context)!
                userEntry = TaperGroup(entity: entity, insertInto: context)
                userEntry.name = "You"
            } else {
                userEntry = results.first!
            }
            
            // Update the user's data
            userEntry.distance = distance
            userEntry.pace = pace
            userEntry.heartRate = heartRate
            
            // Save changes to Core Data
            try context.save()
            
            // Check if competition is less than 4 days away
            guard let competitionDateString = competitionDate else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let competitionDate = dateFormatter.date(from: competitionDateString) {
                let currentDate = Date()
                let calendar = Calendar.current
                let daysUntilCompetition = calendar.dateComponents([.day], from: currentDate, to: competitionDate).day ?? 0
                
                if daysUntilCompetition < 4 && daysUntilCompetition >= 0 {
                    // Navigate to BadgesViewController
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController {
                        badgesVC.badgeMessage = "Congratulations on finishing your taper!\nYou've earned a badge!"
                        badgesVC.challengeTitle = selectedChallenge // Pass the selected challenge
                        badgesVC.medalImage = UIImage(named: "badge") // Ensure "badge" exists in your assets
                        self.present(badgesVC, animated: true, completion: nil)
                    }
                } else {
                    // Navigate back or update the table view, as needed
                    navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Error fetching or saving user data: \(error)")
        }
    }
    
    
    // MARK: Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var pEntity : NSEntityDescription!
    var pManagedObject : TaperGroup!
    
    // Add new Player
    func insertMember(){
        // make a new pManagedObject - need entity first and then managed object
        pEntity = NSEntityDescription.entity(forEntityName: "TaperGroup", in: context)
        
        pManagedObject = TaperGroup(entity: pEntity, insertInto: context)
        
        // collect the fields from the outlets
        pManagedObject.distance = distanceTextField.text
        pManagedObject.pace = paceTextField.text
        pManagedObject.heartRate = heartRateTextField.text
        
        //save it (context is to save)
        do {
            try context.save()
        } catch {
            print ("CORE DATA CANNOT SAVE")
        }
    }
    
    
    func validateTextFields() -> Bool {
        return !distanceTextField.text!.isEmpty && !paceTextField.text!.isEmpty && !heartRateTextField.text!.isEmpty
    }
    
    func checkCompetitionDate() {
        guard let competitionDateString = competitionDate else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Convert competitionDate string to Date
        if let competitionDate = dateFormatter.date(from: competitionDateString) {
            let currentDate = Date()
            
            // Calculate the difference in days
            let calendar = Calendar.current
            let daysUntilCompetition = calendar.dateComponents([.day], from: currentDate, to: competitionDate).day ?? 0
            
            // Update messageLabel based on the days until the competition
            if daysUntilCompetition < 3 && daysUntilCompetition >= 0 {
                messageLabel.text = "You're almost there!\nUpload your last activity!"
            } else {
                messageLabel.text = "" // You can set a default message or keep it empty
            }
        } else {
            print("Invalid competition date format")
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
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
    }
}
