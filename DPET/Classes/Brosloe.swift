//
//  Brosloe.swift
//  DPET
//
//  Created by Ryan Madlangbayan on 03/03/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit

class Brosloe: NSObject {
    
    
    static func getZoneForMeasurement(measIn:Float) -> Int {
        if(measIn > 18.50 && measIn < 20.50) {
            return 3
        } else if(measIn > 20.50 && measIn < 21.75) {
            return 4
        } else if(measIn > 21.75 && measIn < 23.25) {
            return 5
        } else if(measIn > 23.25 && measIn < 24.75) {
            return 6
        } else if(measIn > 24.75 && measIn < 26.25) {
            return 7
        } else if(measIn > 26.25 && measIn < 27.75) {
            return 8
        } else if(measIn > 27.75 && measIn < 29.25) {
            return 9
        } else if(measIn > 29.25 && measIn < 31.25) {
            return 10
        } else if(measIn > 31.25 && measIn < 33.00) {
            return 11
        } else if(measIn > 33.00 && measIn < 34.50) {
            return 12
        } else if(measIn > 34.50 && measIn < 36.00) {
            return 13
        } else if(measIn > 36.00 && measIn < 37.75) {
            return 14
        } else if(measIn > 37.75 && measIn < 39.00) {
            return 15
        } else if(measIn > 39.00 && measIn < 40.25) {
            return 16
        } else if(measIn > 40.25 && measIn < 41.50) {
            return 17
        } else if(measIn > 41.50 && measIn < 42.75) {
            return 18
        } else if(measIn > 42.75 && measIn < 44.00) {
            return 19
        } else if(measIn > 44.00 && measIn < 45.25) {
            return 20
        } else if(measIn > 45.25 && measIn < 47.75) {
            return 22
        } else if(measIn > 47.75 && measIn < 49.00) {
            return 24
        } else if(measIn > 49.00 && measIn < 51.25) {
            return 26
        } else if(measIn > 51.25 && measIn < 51.50) {
            return 28
        } else if(measIn > 51.50 && measIn < 52.75) {
            return 30
        } else if(measIn > 52.75 && measIn < 54.00) {
            return 32
        } else if(measIn > 54.00 && measIn < 55.25) {
            return 34
        } else if(measIn > 55.25 && measIn < 56.50) {
            return 36
        }
        
        return 0
    }
    
    static func getColorForMeasurement(measIn:Float) -> UIColor {
        if(measIn > 18.25 && measIn < 23.25) {
            return UIColor.lightGray
        } else if(measIn > 23.25 && measIn < 26.25) {
            return hexStringToUIColor(hex: "#FFC0CB") //Pink
        } else if(measIn > 26.25 && measIn < 29.25) {
            return UIColor.red
        } else if(measIn > 29.25 && measIn < 33.0) {
            return hexStringToUIColor(hex: "#EE82EE") //Violet
        } else if(measIn > 33.00 && measIn < 37.75) {
            return UIColor.yellow
        } else if(measIn > 37.75 && measIn < 42.75) {
            return UIColor.white
        } else if(measIn > 42.75 && measIn < 47.75) {
            return UIColor.blue
        } else if(measIn > 47.75 && measIn < 51.50) {
            return UIColor.orange
        } else if(measIn > 51.50 && measIn < 56.50) {
            return UIColor.green
        }
        return UIColor.black
    }
    
    static func getTextColorForMeasurement(measIn:Float) -> UIColor {
        if(measIn > 18.25 && measIn < 23.25) {
            return UIColor.black // UIColor.lightGray
        } else if(measIn > 23.25 && measIn < 26.25) {
            return UIColor.black // hexStringToUIColor(hex: "#FFC0CB") //Pink
        } else if(measIn > 26.25 && measIn < 29.25) {
            return UIColor.white // return UIColor.red
        } else if(measIn > 29.25 && measIn < 33.0) {
            // return hexStringToUIColor(hex: "#EE82EE") //Violet
            return UIColor.white
        } else if(measIn > 33.00 && measIn < 37.75) {
            return UIColor.black // UIColor.yellow
        } else if(measIn > 37.75 && measIn < 42.75) {
            return UIColor.black // return UIColor.white
        } else if(measIn > 42.75 && measIn < 47.75) {
            return UIColor.white// return UIColor.blue
        } else if(measIn > 47.75 && measIn < 51.50) {
            return UIColor.white // return UIColor.orange
        } else if(measIn > 51.50 && measIn < 56.50) {
            return UIColor.black // return UIColor.green
        }
        return UIColor.white
    }
    
    static func getStringForMeasurement(measIn:Float) -> String {
        if(measIn > 18.25 && measIn < 23.25) {
            return "gray"
        } else if(measIn > 23.25 && measIn < 26.25) {
            return "pink"
        } else if(measIn > 26.25 && measIn < 29.25) {
            return "red"
        } else if(measIn > 29.25 && measIn < 33.0) {
            return "purple"
        } else if(measIn > 33.00 && measIn < 37.75) {
            return "yellow"
        } else if(measIn > 37.75 && measIn < 42.75) {
            return "white"
        } else if(measIn > 42.75 && measIn < 47.75) {
            return "blue"
        } else if(measIn > 47.75 && measIn < 51.50) {
            return "orange"
        } else if(measIn > 51.50 && measIn < 56.50) {
            return "green"
        }
        return ""
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
