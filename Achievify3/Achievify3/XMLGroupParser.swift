//
//  XMLGroupParser.swift
//  Achievify3
//
//  Created by Marks on 07/09/2024.
//

import Foundation

class XMLGroupParser: NSObject, XMLParserDelegate {
    var xmlName: String

        init(xmlName: String) {
            self.xmlName = xmlName
        }

        // Parsed variable definitions
        var distance: String?
        var heartRate: String?
        var name: String?
        var pace: String?
        let tags = ["distance", "heartRate", "name", "pace"]

        // Variables for spying
        var elementId = -1
        var passData = false

        var memberData: TaperGroupModel!
        var groupData = [TaperGroupModel]()

        // Parser object
        var parser: XMLParser!

        // MARK: Parsing Methods
        // Did Start Element
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            if elementName == "member" {
                // Reset member data for each new member
                distance = nil
                heartRate = nil
                name = nil
                pace = nil
            }

            if tags.contains(elementName) {
                passData = true
                switch elementName {
                    case "distance" : elementId = 0
                    case "heartRate" : elementId = 1
                    case "name" : elementId = 2
                    case "pace" : elementId = 3
                    default: break
                }
            }
        }

        // Did End Element
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

                if tags.contains(elementName) {
                    passData = false
                    elementId = -1
                }
                if elementName == "member" {
                    memberData = TaperGroupModel(distance: distance, heartRate: heartRate, name: name, pace: pace)
                    groupData.append(memberData)
                }
        }

        // Found Characters
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if passData {
                    switch elementId {
                        case 0: distance = (distance ?? "") + string
                        case 1: heartRate = (heartRate ?? "") + string
                        case 2: name = (name ?? "") + string
                        case 3: pace = (pace ?? "") + string
                        default: break
                    }
                }
        }

        // Begin parsing
        func parsing() {
            let bundle = Bundle.main.bundleURL
               let bundleURL = NSURL(fileURLWithPath: self.xmlName, relativeTo: bundle)
               
               parser = XMLParser(contentsOf: bundleURL as URL)
               parser.delegate = self
               parser.parse()
        }
}

