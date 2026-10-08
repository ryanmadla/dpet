//
//  Constants.swift
//  DPET
//
//  Created by June Albert Alberto on 08/03/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit

struct Disclaimer {
    static let lastUpdated = 20190307
    static let key = "disclaimer"
}

struct Hint {
    static let BeginText = "Start measurement from top of the head"
    static let EndText = "End measurement at \nfeet/heels"
    static let key = "hint"
    static let isHidden = UserDefaults.standard.bool(forKey: Hint.key)
}

struct Icons {
    static let Add = UIImage(named: "Add")?.withRenderingMode(.alwaysTemplate)
    static let Tick = UIImage(named: "Tick")?.withRenderingMode(.alwaysTemplate)
}

struct NavBar {
    static let barTintColor = UIColor.groupTableViewBackground
    static let tintColor = UIColor.black
    static let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                      NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 16)]
}

struct BrosloeInfo {
    static let list = ["Broselow-Luten Zones", "Initial Ventilator Settings", "No IV Quick Access Meds", "Recommended Concentrations", "Severity Category", "Colors", "3KG", "4KG", "5KG", "Pink", "Red", "Purple", "Yellow", "White", "Blue", "Orange", "Green"]
}
