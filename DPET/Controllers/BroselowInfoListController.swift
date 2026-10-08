//
//  BroselowInfoListController.swift
//  DPET
//
//  Created by Ryan Madlangbayan on 15/03/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit

class BroselowInfoListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var infoTbl:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Broselow"
        addBackButton()
        
        let nib = UINib.init(nibName: "BroslowInfoCellTableViewCell", bundle: nil)
        infoTbl.register(nib, forCellReuseIdentifier: "infoCellId")
    }

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BrosloeInfo.list.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCellId", for: indexPath) as! BroslowInfoCellTableViewCell
        
        let descVal = BrosloeInfo.list[indexPath.row] 
        cell.desc.text = descVal
        
        if(descVal == "Colors") {
            cell.accessoryType = UITableViewCell.AccessoryType.none
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.desc.textColor = UIColor.lightGray
        }
        
        if(indexPath.row > 5) {
            if(descVal.contains("KG")) {
                cell.desc.text = "\(String(format: "     Zone %@", descVal))"
            } else {
                cell.desc.text = "\(String(format: "     %@", descVal))"
            }
        }
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let descVal = BrosloeInfo.list[indexPath.row]
        var brInfToUse:String = descVal
    
        if(descVal != "Colors") {
            
            if(indexPath.row > 5) {
                brInfToUse = descVal.uppercased()
            }
            
            let qinfVC:QuickInfoController = QuickInfoController(_brFileName: brInfToUse)
            let navCtrl:UINavigationController = UINavigationController(rootViewController: qinfVC)
            navCtrl.modalPresentationStyle = .fullScreen;
            self.navigationController?.present(navCtrl, animated: true, completion: nil)
        }
        
        tableView.reloadData()
    }
    
    func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back"), for: .normal)
        backButton.setTitleColor(backButton.tintColor, for: .normal)
        backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @IBAction func backTouch(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
