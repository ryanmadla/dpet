//
//  BrosloeTapeViewController.swift
//  DPET
//
//  Created by Ryan Madlangbayan on 03/03/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit
import WebKit

class BrosloeTapeViewController: UIViewController, WKUIDelegate {
    
    
    @IBOutlet weak var zoneLbl: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var stringColor: String!
    var zone: Int!
    
    init(_stringColor: String, _zone: Int) {
        stringColor = _stringColor
        zone = _zone        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        addBackButton()
        self.title = "\(String(format: "Broselow Tape %d KG", zone))"
        loadInformationZone()
    }
    
    func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back"), for: .normal) 
        backButton.setTitleColor(backButton.tintColor, for: .normal)
        backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func loadInformationZone() {
        var brosloePath:String = "\(String(format: "Broselow/%@", stringColor.uppercased()))"
        
        if(stringColor == "gray") {
            brosloePath = "\(String(format: "Broselow/%dKG", zone))"
        }

        NSLog(brosloePath)
        webView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: brosloePath, ofType: "html")!)))
    }
    
    @IBAction func backTouch(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
        self .dismiss(animated: true, completion: nil)
    }
}
