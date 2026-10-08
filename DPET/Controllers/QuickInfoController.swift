//
//  QuickInfoController.swift
//  DPET
//
//  Created by Ryan Madlangbayan on 15/03/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit
import WebKit

class QuickInfoController: UIViewController {

    @IBOutlet weak var brInfoWV: WKWebView!
    var brFileName: String!
    
    init(_brFileName: String) {
        brFileName = _brFileName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Broselow"
        addBackButton()
        loadBrosloeInfo()
    }
    
    func loadBrosloeInfo() {
        let htmFilePath:String = "\(String(format: "Broselow/%@", brFileName))"
        brInfoWV.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: htmFilePath, ofType: "html")!)))
    }

    func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back"), for: .normal)
        backButton.setTitleColor(backButton.tintColor, for: .normal)
        backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @IBAction func backTouch(_ sender: UIButton) {
        //        self.navigationController?.popViewController(animated: true)
        self .dismiss(animated: true, completion: nil)
    }
}
