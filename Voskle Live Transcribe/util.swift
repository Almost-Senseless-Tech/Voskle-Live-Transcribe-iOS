//
//  util.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 25.06.24.
//

import UIKit

/**
 Returns a human-readable name for many common iPhones and iPads.
 
 - returns: A human-readable version of the model identifier if possible, otherwise the machine-readable one.
 */
func deviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    switch identifier {
    // iPhone models
    case "iPhone8,1": return "iPhone 6s"
    case "iPhone8,2": return "iPhone 6s Plus"
    case "iPhone9,1", "iPhone9,3": return "iPhone 7"
    case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
    case "iPhone10,1", "iPhone10,4": return "iPhone 8"
    case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6": return "iPhone X"
    case "iPhone11,2": return "iPhone XS"
    case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
    case "iPhone11,8": return "iPhone XR"
    case "iPhone12,1": return "iPhone 11"
    case "iPhone12,3": return "iPhone 11 Pro"
    case "iPhone12,5": return "iPhone 11 Pro Max"
    case "iPhone12,8": return "iPhone SE (2nd generation)"
    case "iPhone13,1": return "iPhone 12 mini"
    case "iPhone13,2": return "iPhone 12"
    case "iPhone13,3": return "iPhone 12 Pro"
    case "iPhone13,4": return "iPhone 12 Pro Max"
    case "iPhone14,2": return "iPhone 13 Pro"
    case "iPhone14,3": return "iPhone 13 Pro Max"
    case "iPhone14,4": return "iPhone 13 mini"
    case "iPhone14,5": return "iPhone 13"
    case "iPhone14,6": return "iPhone SE (3rd generation)"
    case "iPhone15,2": return "iPhone 14 Pro"
    case "iPhone15,3": return "iPhone 14 Pro Max"
    case "iPhone14,7": return "iPhone 14"
    case "iPhone14,8": return "iPhone 14 Plus"
        
    // iPad models
    case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
    case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
    case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
    case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
    case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
    case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
    case "iPad5,3", "iPad5,4": return "iPad Air 2"
    case "iPad11,3", "iPad11,4": return "iPad Air (3rd generation)"
    case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
    case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"
    case "iPad6,3", "iPad6,4": return "iPad Pro 9.7-inch"
    case "iPad6,7", "iPad6,8": return "iPad Pro 12"
    default: return identifier
    }
}


/**
 Creates an email URL from recipient, subject and body parameters.
 
 `subject` and `body` get URL encoded.

 - parameter to: The recipient of the email.
 - parameter subject: The subject of the email.
 - parameter body: The (plain text) body of the email.
 */
func createEmailURL(to: String, subject: String, body: String) -> URL? {
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = to
    components.queryItems = [
        URLQueryItem(name: "subject", value: subject),
        URLQueryItem(name: "body", value: body)
    ]
    return components.url
}
