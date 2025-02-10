//
//  CircularCheckbox.swift
//  Achievify3
//
//  Created by Marks on 08/09/2024.
//

/* REFERENCE
    iOS Academy (2020) Create Custom Checkbox in Swift 5 (Xcode 12, iOS 2020) - Swift,
    YouTube.
    Available at: https://www.youtube.com/watch?v=R8SGEQXxhWw
 */
import UIKit

final class CircularCheckbox: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set the checkbox to be circular
        layer.cornerRadius = frame.size.width / 2.0
        
        // Add a border to the checkbox with a slight thickness
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.secondaryLabel.cgColor
        
        // Set the background color to match the system's default background colour
        backgroundColor = .systemBackground
    }
    
    // Initialiser
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // Change the checkbox's appearance when checked or unchecked
    func setChecked(_ isChecked: Bool) {
        if isChecked {
            backgroundColor = .systemBlue
        } 
        else {
            backgroundColor = .systemBackground
        }
    }

}
