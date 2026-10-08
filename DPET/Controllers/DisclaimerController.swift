//
//  DisclaimerController.swift
//  DPET
//
//  Created by June Albert Alberto on 06/03/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit

class DisclaimerController: UIViewController {

    @IBOutlet weak var disclaimerSV: UIScrollView!
    @IBOutlet weak var disclaimerTV: UITextView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        checkExpiration()
    }
    
    
    func checkExpiration() {

        let userDefaults = UserDefaults.standard
        
        let expDt = userDefaults.string(forKey: "exp")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        
        if(expDt == nil) {
            let dateNow = formatter.string(from: Date())
            userDefaults.set(dateNow, forKey: "exp")
            userDefaults.synchronize()
        } else {
            let dateExp = formatter.date(from: expDt ?? "10-Sep-2019")
//            let dateExp = formatter.date(from: "10-Sep-2019")
            
//            NSLog("\(dateExp)")
            
            let calendar = NSCalendar.current
            
            let stDt = calendar.startOfDay(for: dateExp ?? Date())
            let enDt = calendar.startOfDay(for: Date())            
            let components = calendar.dateComponents([.day], from: stDt, to: enDt)
  
            let noOfDays: Int? = components.day
            
            
            if(noOfDays! >= 15 || noOfDays! < 0)
            {
                for view in self.view.subviews {
                    if(view.tag == 99) {
                        view.isHidden = false
                    } else {
                        view.isHidden = true
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Important! Hide Navbar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        let contentSize = disclaimerTV.frame.size
        var btnFrame = continueBtn.frame
        
        btnFrame.origin.y = contentSize.height + 10.0
        
        titleLbl.textColor = UIColor(red: 0.28, green: 0.32, blue: 0.37, alpha: 1)
        disclaimerTV.textColor = UIColor.darkGray

        continueBtn.backgroundColor = UIColor(red: 0.28, green: 0.32, blue: 0.37, alpha: 1)
        continueBtn.layer.masksToBounds = true
        continueBtn.layer.cornerRadius = 5.0
        
//        disclaimerSV.contentSize = CGSize(width: 0, height: contentSize.height + btnFrame.size.height + 10.0)
//        continueBtn.frame = btnFrame
    }
    
    @IBAction func onAccept(_ sender: UIButton) {
        let navigationController = UINavigationController(rootViewController: ARViewController())
        navigationController.modalPresentationStyle = .fullScreen;
        navigationController.isNavigationBarHidden = true
        
        // Remember the last accepted Disclaimer
        UserDefaults.standard.set(Disclaimer.lastUpdated, forKey: Disclaimer.key)
        self.present(navigationController, animated: false, completion: nil)
    }
}
