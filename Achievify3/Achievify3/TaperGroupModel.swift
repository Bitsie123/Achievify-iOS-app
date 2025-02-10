//
//  TaperGroupModel.swift
//  Achievify3
//
//  Created by Marks on 07/09/2024.
//

import Foundation

class TaperGroupModel {
    var distance: String?
    var heartRate: String?
    var name: String?
    var pace: String?
    
    init(distance: String?, heartRate: String?, name: String?, pace: String?) {
        self.distance = distance
        self.heartRate = heartRate
        self.name = name
        self.pace = pace
    }
}
