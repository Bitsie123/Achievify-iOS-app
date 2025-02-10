//
//  TaperTableViewController.swift
//  Achievify3
//
//  Created by Marks on 07/09/2024.
//

import UIKit
import CoreData

class TaperTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    // Variables for storing Easy plan statistics
    var easyPlanDistance: String?
    var easyPlanPace: String?
    var easyPlanHeartRate: String?
    
    // Variables for storing Tempo plan statistics
    var tempoPlanDistance: String?
    var tempoPlanPace: String?
    var tempoPlanHeartRate: String?
    
    // Variables for storing Interval plan statistics
    var intervalPlanDistance: String?
    var intervalPlanPace: String?
    var intervalPlanHeartRate: String?
    
    // Variables for storing Progression plan statistics
    var progressionPlanDistance: String?
    var progressionPlanPace: String?
    var progressionPlanHeartRate: String?
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsNavButtonItem: UIBarButtonItem!
    
    // Passed selected challenge name and date
    var selectedChallenge: String?
    var competitionDate: String?
    
    // Upload label message
    var uploadMessage: String?
    @IBOutlet weak var uploadLabel: UITextView!
    
    
    // MARK: Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var frc: NSFetchedResultsController<TaperGroup>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Check if competition date is less than 14 days away
        if let competitionDate = competitionDate {
            uploadMessage = checkCompetitionDate(competitionDate: competitionDate)
            uploadLabel.text = uploadMessage
        }
        
        // Hide the back button
        self.navigationItem.hidesBackButton = true
        
        // Set delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register cell identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set up fetch results controller and perform fetch
        frc = NSFetchedResultsController(fetchRequest: makeRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            print("CORE DATA CANNOT FETCH: \(error)")
        }
        
        // Populate Core Data if no records exist
        if frc.sections?.first?.numberOfObjects == 0 {
            xml2CD()
        }
        
        // Create actions for the settings menu
        let firstAction = UIAction(title: "View Badges", image: UIImage(systemName: "star")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
        settingsNavButtonItem.menu = menu
        
        // Update uploadLabel at the end
        if let message = uploadMessage {
            uploadLabel.text = message
        }
    }
    
    // Convert date string to Date object
    func getDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" 
        return dateFormatter.date(from: dateString)
    }
    
    // Calculate days between two dates
    func calculateDaysBetween(now: Date, futureDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: now, to: futureDate)
        return components.day ?? 0
    }
    
    // Check the competition date and return a message
    func checkCompetitionDate(competitionDate: String?) -> String {
        guard let competitionDateString = competitionDate,
              let competitionDate = getDate(from: competitionDateString) else {
            return "No competition date available."
        }
        
        let daysRemaining = calculateDaysBetween(now: Date(), futureDate: competitionDate)
        
        if daysRemaining < 3 && daysRemaining >= 0 {
            return "Upload your last activity. You're almost there."
        } else {
            return "Keep me happy! Add activity to the taper table!"
        }
    }
    
    // Table sorter
    func makeRequest()->NSFetchRequest<TaperGroup>{
        let request: NSFetchRequest<TaperGroup> = TaperGroup.fetchRequest()
        let sorter = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sorter]
        return request
    }
    
    // Delegate method that gets called when the content of the fetched results controller changes
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Fetch and sort members by the number of happy faces
        if let members = frc.fetchedObjects {
            let sortedMembers = members.sorted { (member1, member2) -> Bool in
                let happyFaces1 = countHappyFaces(for: member1)
                let happyFaces2 = countHappyFaces(for: member2)
                return happyFaces1 > happyFaces2
            }
            
            // Update the table view with sorted members
            frc = NSFetchedResultsController(fetchRequest: makeRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            frc.delegate = self
            
            do {
                try frc.performFetch()
                tableView.reloadData()
            } catch {
                print("CORE DATA CANNOT FETCH: \(error)")
            }
        }
    }
    
    // Clear existing data from Core Data
    func clearExistingData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TaperGroup.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to clear existing data: \(error)")
        }
    }
    
    // Load XML data into Core Data
    func xml2CD() {
        // Initialize the XML parser and parse the data
        let parser = XMLGroupParser(xmlName: "group.xml")
        parser.parsing()
        let groupData = parser.groupData

        // Clear existing data to maintain integrity
        clearExistingData()

        // Iterate through the parsed member data
        for member in groupData {
            guard let name = member.name, !name.isEmpty else { continue }

            // Check for existing members to prevent duplicates
            let fetchRequest: NSFetchRequest<TaperGroup> = TaperGroup.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)

            do {
                let existingMembers = try context.fetch(fetchRequest)
                if !existingMembers.isEmpty {
                    continue // Skip if member already exists
                }
            } catch {
                print("Error fetching existing members: \(error)")
            }

            // Create a new TaperGroup entity for each member
            let pEntity = NSEntityDescription.entity(forEntityName: "TaperGroup", in: context)!
            let pManagedObject = TaperGroup(entity: pEntity, insertInto: context)

            // Set the attributes based on the parsed XML data
            pManagedObject.name = member.name
            pManagedObject.distance = member.distance
            pManagedObject.pace = member.pace
            pManagedObject.heartRate = member.heartRate

            // Save the context to persist the new member
            do {
                try context.save()
            } catch {
                print("Error saving member: \(error)")
            }
        }

        // Refresh the table view to display the updated data
        tableView.reloadData()
    }

    
/* REFERENCE
    Noonan, R. (2019) Swift Programming - Count Elements in Strings, Arrays, and Dictionaries,
    YouTube.
    Available at: https://www.youtube.com/watch?v=dt0PpMdGSxc
 */
    // Count happy faces for a given member
    func countHappyFaces(for member: TaperGroup) -> Int {
        // Initial happy faces count
        var happyFacesCount = 0
        
        
    /* REFERENCE
        Qasem, M., Saini, N.S. and fzh (2019) Converting string to int with swift,
        Stack Overflow.
        Available at: https://stackoverflow.com/questions/24115141/converting-string-to-int-with-swift
    */
        // Get member stats and convert to Integer
        let memberDistance = Int(member.distance ?? "0") ?? 0
        let memberPace = Int(member.pace ?? "0") ?? 0
        let memberHeartRate = Int(member.heartRate ?? "0") ?? 0

        // Convert taper plan stats to Integer
        let easyDistance = Int(easyPlanDistance ?? "0") ?? 0
        let easyPace = Int(easyPlanPace ?? "0") ?? 0
        let easyHeartRate = Int(easyPlanHeartRate ?? "0") ?? 0
        let tempoDistance = Int(tempoPlanDistance ?? "0") ?? 0
        let tempoPace = Int(tempoPlanPace ?? "0") ?? 0
        let tempoHeartRate = Int(tempoPlanHeartRate ?? "0") ?? 0
        let intervalDistance = Int(intervalPlanDistance ?? "0") ?? 0
        let intervalPace = Int(intervalPlanPace ?? "0") ?? 0
        let intervalHeartRate = Int(intervalPlanHeartRate ?? "0") ?? 0
        let progressionDistance = Int(progressionPlanDistance ?? "0") ?? 0
        let progressionPace = Int(progressionPlanPace ?? "0") ?? 0
        let progressionHeartRate = Int(progressionPlanHeartRate ?? "0") ?? 0
        
        // Check for happy faces based on distance
        if memberDistance >= 3 && memberDistance <= 5 {
            // Add happy face
            happyFacesCount += 1
        } else if memberDistance < 3 {
            happyFacesCount -= 1
        }
        
        // Check for happy faces based on pace
        if memberPace >= 4 && memberPace <= 6 {
            happyFacesCount += 1
        } else if memberPace < 4 {
            happyFacesCount -= 1
        }
        
        // Check for happy faces based on heart rate
        if memberHeartRate >= 120 && memberHeartRate <= 150 {
            happyFacesCount += 1
        } else if memberHeartRate < 120 {
            happyFacesCount -= 1
        }
        
        // Return total happy faces count
        return happyFacesCount
    }
    
    
    // MARK: - Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }
    
    let currentUserName = UserDefaults.standard.string(forKey: "currentUserName") ?? ""
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Clear previous images and text
        cell.contentView.subviews.forEach { subview in
            if subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        let pManagedObject = frc.object(at: indexPath)
        
    /* REEFREMCE
        Core Data Predicate - Table View Display Format
        Apple Developer Forums, (2015, December).
        Available at: https://forums.developer.apple.com/forums/thread/28155
    */
        // Add member name label
        let nameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 20))
        // Check if this is the current user (replace 'You' with the key name from Core Data)
        if pManagedObject.name == "You" {
            nameLabel.text = "You"
            
            // Label attributes
            nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
            nameLabel.textColor = UIColor.blue
        } else {
            nameLabel.text = pManagedObject.name
            nameLabel.font = UIFont.systemFont(ofSize: 16)
            nameLabel.textColor = UIColor.black
        }
        cell.contentView.addSubview(nameLabel)
        
        // Compare and add other stat images (distance, pace, heart rate)
        let memberDistance = Int(pManagedObject.distance ?? "0") ?? 0
        let memberPace = Int(pManagedObject.pace ?? "0") ?? 0
        let memberHeartRate = Int(pManagedObject.heartRate ?? "0") ?? 0
        
        // Convert taper plan stats to Int
        let easyDistance = Int(easyPlanDistance ?? "0") ?? 0
        let easyPace = Int(easyPlanPace ?? "0") ?? 0
        let easyHeartRate = Int(easyPlanHeartRate ?? "0") ?? 0
        let tempoDistance = Int(tempoPlanDistance ?? "0") ?? 0
        let tempoPace = Int(tempoPlanPace ?? "0") ?? 0
        let tempoHeartRate = Int(tempoPlanHeartRate ?? "0") ?? 0
        let intervalDistance = Int(intervalPlanDistance ?? "0") ?? 0
        let intervalPace = Int(intervalPlanPace ?? "0") ?? 0
        let intervalHeartRate = Int(intervalPlanHeartRate ?? "0") ?? 0
        let progressionDistance = Int(progressionPlanDistance ?? "0") ?? 0
        let progressionPace = Int(progressionPlanPace ?? "0") ?? 0
        let progressionHeartRate = Int(progressionPlanHeartRate ?? "0") ?? 0
            
    /* REFERENCE
        Miller, J. and Tekbiyik, O. (2019) How add size and position to ImageView in UITableView cell?,
        Stack Overflow.
        Available at: https://stackoverflow.com/questions/54670429/how-add-size-and-position-to-imageview-in-uitableview-cell
    */
        // Configure and add expression image view for stats
        let distanceImageView = UIImageView(frame: CGRect(x: 100, y: -4, width: 60, height: 50))
        configureImageView(distanceImageView, memberStat: Int16(memberDistance), easyStat: easyDistance)
        cell.contentView.addSubview(distanceImageView)
        
        let paceImageView = UIImageView(frame: CGRect(x: 195, y: -4, width: 60, height: 50))
        configureImageView(paceImageView, memberStat: Int16(memberPace), easyStat: easyPace)
        cell.contentView.addSubview(paceImageView)
        
        let heartRateImageView = UIImageView(frame: CGRect(x: 290, y: -4, width: 60, height: 50))
        configureImageView(heartRateImageView, memberStat: Int16(memberHeartRate), easyStat: easyHeartRate)
        cell.contentView.addSubview(heartRateImageView)
        
        return cell
    }
    
    /* REFRENCE
        dabdoue and Fox, T. (2019) Display image from parse in swift,
        Stack Overflow.
        Available at: https://stackoverflow.com/questions/55670721/display-image-from-parse-in-swift
    */
    func configureImageView(_ imageView: UIImageView, memberStat: Int16, easyStat: Int) {
        // Easy Stats
        if memberStat == easyStat {
            imageView.image = UIImage(named: "happyExpression") // Display happy face if stats are equal
        } else if memberStat > easyStat {
            imageView.image = UIImage(named: "angryExpression") // Display angry face if member's stat is higher
        } else {
            imageView.image = UIImage(named: "neutralExpression") // Display neutral face
        }
        
        // Tempo stats
        
    }
    
    
    // MARK: Uploaded Activity
    // Uploaded activity data
    func didEnterData(distance: String, pace: String, heartRate: String) {
        let fetchRequest: NSFetchRequest<TaperGroup> = TaperGroup.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "You")
        
        do {
            let existingMembers = try context.fetch(fetchRequest)
            
            if let existingMember = existingMembers.first {
                // Update existing "You" member
                existingMember.distance = distance
                existingMember.pace = pace
                existingMember.heartRate = heartRate
            } else {
                // Create new "You" member
                let newMember = TaperGroup(context: context)
                newMember.name = "You"
                newMember.distance = distance
                newMember.pace = pace
                newMember.heartRate = heartRate
            }
            
            // Save the context after updating or creating a member
            try context.save()
            
            // Refresh the table view to reflect the updated stats
            tableView.reloadData()
            
        } catch {
            print("Error fetching or saving data: \(error)")
        }
    }
    
    
    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeSegue" {
            // Prepare for homeSegue (OpeningViewController)
            let destination = segue.destination as! OpeningViewController
        } else if segue.identifier == "activitySegue" {
            // Prepare for activitySegue (ViewController)
            let destination = segue.destination as! ViewController
            destination.competitionDate = competitionDate // Transfer competitionDate here
            destination.selectedChallenge = selectedChallenge // Transfer selectedChallenge here
        }
    }
    
    // Go back to selected taper plan
    @IBAction func taperPlan(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

