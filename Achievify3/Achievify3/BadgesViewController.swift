//
//  BadgesViewController.swift
//  Achievify3
//
//  Created by Marks on 19/09/2024.
//

import UIKit

class BadgesViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var badgeMessageLabel: UITextView!
    @IBOutlet weak var challengeTitleLabel: UILabel!
    @IBOutlet weak var medalImageView: UIImageView!
    
    // Variables to hold badge data
    var badgeMessage: String?
    var challengeTitle: String?
    var medalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* REFERENCE
         Save Label Text and Button States
         Apple Developer Forums. (n.d.).
         Available at: https://forums.developer.apple.com/forums/thread/91782
         */
        // Load saved values from UserDefaults
        if let savedBadgeMessage = UserDefaults.standard.string(forKey: "badgeMessage"),
           let savedChallengeTitle = UserDefaults.standard.string(forKey: "challengeTitle"),
           let savedMedalImageData = UserDefaults.standard.data(forKey: "medalImage") {
            
            badgeMessageLabel.text = savedBadgeMessage
            challengeTitleLabel.text = savedChallengeTitle
            medalImageView.image = UIImage(data: savedMedalImageData)
        } else {
            // Set the passed data to the UI components if no saved data exists
            badgeMessageLabel.text = badgeMessage
            challengeTitleLabel.text = challengeTitle
            medalImageView.image = medalImage
        }
    }
    
    // MARK: Save Earned Badge
    // Save badge data in UserDefaults when the badge is earned
    func saveBadgeData() {
        UserDefaults.standard.set(badgeMessageLabel.text, forKey: "badgeMessage")
        UserDefaults.standard.set(challengeTitleLabel.text, forKey: "challengeTitle")
        if let image = medalImageView.image, let imageData = image.pngData() {
            UserDefaults.standard.set(imageData, forKey: "medalImage")
        }
    }
    
    /* REFERENCE
     swift present controller with a back button to get back to last screen. (April 2, 2018).
     Stack Overflow.
     Available at: https://stackoverflow.com/questions/49610138/swift-present-controller-with-a-back-button-to-get-back-to-last-screen
     */
    @IBAction func backButtonPressed(_ sender: Any) {
        saveBadgeData()
        // Check if the current medal image matches the second medal image ("badge")
        if let currentMedalImage = medalImageView.image,
           let secondMedalImage = UIImage(named: "badge"),
           currentMedalImage.pngData() == secondMedalImage.pngData() {
            
            // If the second medal is displayed, navigate to the OpeningViewController
            let homeVC = storyboard?.instantiateViewController(withIdentifier: "OpeningViewController") as! OpeningViewController
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
            
        } else {
            // If not the second medal, just dismiss to go back to the previous screen
            self.dismiss(animated: true, completion: nil)
        }
    }
}
