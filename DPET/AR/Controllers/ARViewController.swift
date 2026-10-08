//
//  ARViewController.swift
//  DPET
//
//  Reference: https://github.com/TBXark/Ruler
//  Created by June Albert Alberto on 13/05/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Photos
import AudioToolbox
import VideoToolbox

class ARViewController: UIViewController {
    // @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var measurementLbl: UILabel!
    @IBOutlet weak var measurementBg: UIView!
    @IBOutlet weak var resultBtn: UIButton!
    @IBOutlet weak var tipsView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var zoneDetail: UILabel!

    enum MeasurementMode {
        case length
        case area
        func toAttrStr() -> NSAttributedString {
            let str = self == .area ? "Area measurement" : "Length measurement"
            return NSAttributedString(string: str, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 4),
                                                                NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    struct Texts {
        struct Button {
            static let start = "START"
            static let end = "END"
        }
        struct Tips {
            static let start = "Aim reticle to the top of the patient's head and tap on Start."
            static let end = "Aim reticle to the patient's toes or heels and tap on End."
        }
    }
    
    struct Colors {
        struct Button {
            static let start = UIColor(red: 0.47, green: 0.83, blue: 0.33, alpha: 1)
            static let end = UIColor(red: 0.98, green: 0.37, blue: 0.38, alpha: 1)
        }
    }

    struct Image {
        struct Info {
            static let normal = #imageLiteral(resourceName: "Info")
        }
        struct Place {
            static let area =  #imageLiteral(resourceName: "place_area")
            static let length = #imageLiteral(resourceName: "place_length")
            static let done = #imageLiteral(resourceName: "place_done")
        }
        struct Close {
            static let delete = #imageLiteral(resourceName: "Refresh")
            static let cancel = #imageLiteral(resourceName: "Refresh")
        }
        struct Indicator {
            static let enable = #imageLiteral(resourceName: "crosshair_green")
            static let disable = #imageLiteral(resourceName: "crosshair_red")
        }
        struct Result {
            static let copy = #imageLiteral(resourceName: "place_done")
        }
    }
    
    struct Sound {
        static var soundID: SystemSoundID = 0
        static func install() {
            guard let path = Bundle.main.path(forResource: "SetPoint", ofType: "wav") else { return  }
            let url = URL(fileURLWithPath: path)
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        }
        static func play() {
            guard soundID != 0 else { return }
            AudioServicesPlaySystemSound(soundID)
        }
        static func dispose() {
            guard soundID != 0 else { return }
            AudioServicesDisposeSystemSoundID(soundID)
        }
        
    }
    
    private let sceneView: ARSCNView = ARSCNView(frame: UIScreen.main.bounds)
    private let indicator = UIImageView()
    
    private let resultLabelBg = UIView()
    private let resultLabel = UILabel().then({
        $0.textAlignment = .center
        $0.textColor = UIColor.white
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.heavy)
    })
    
    
    private var line: LineNode?
    private var lineSet: LineSetNode?
    
    
    private var lines: [LineNode] = []
    private var lineSets: [LineSetNode] = []
    private var planes = [ARPlaneAnchor: Plane]()
    private var focusSquare: FocusSquare?
    
    private var mode = MeasurementMode.length
    private var measureUnit = MeasurementUnit.Unit.inch
    
    private var finishButtonState = false
    private var lastState: ARCamera.TrackingState = .notAvailable {
        didSet {
            switch lastState {
            case .notAvailable:
                guard PopupAlert.isVisible else { return }
                PopupAlert.show(title: "Sensor failed to initialize due to hardware restrictions.")
                // print("AR not available")
            case .limited(let reason):
                switch reason {
                case .initializing:
                    PopupAlert.show(title: nil,
                                    message: "Sensors need calibration. Please point camera to an open space and move the phone around",
                                    inSource: self,
                                    autoDismissDuration: nil)
                    // print("AR is initializing")
                case .insufficientFeatures:
                    PopupAlert.show(title: nil,
                                    message: "The feature point is not sufficient, please sway the equipment to obtain more feature points",
                                    inSource: self,
                                    autoDismissDuration: 5)
                    // print("AR is initializing")
                case .excessiveMotion:
                    PopupAlert.show(title: nil,
                                    message: "Device moves too fast",
                                    inSource: self,
                                    autoDismissDuration: 5)
                    // print("Device moves too fast")
                case .relocalizing:
                    PopupAlert.show(title: nil,
                                    message: "Please shake the device to get more feature points",
                                    inSource: self,
                                    autoDismissDuration: 5)
                    // print("Please wait")
                }
            case .normal:
                PopupAlert.dismiss()
                // print("Dismiss message")
            }
        }
    }

    private var measureValue: MeasurementUnit? {
        didSet {
            if let m = measureValue {
                // resultLabel.text = nil
                // resultLabel.attributedText = m.attributeString(type: measureUnit)
                measurementBg.isHidden = false
                measurementLbl.text = nil
                resultLbl.attributedText = m.attributeString(type: measureUnit)
                measurementLbl.attributedText = m.attributeString(type: measureUnit)
            } else {
                // resultLabel.attributedText = mode.toAttrStr()
                
                measurementBg.isHidden = true
                resultLbl.attributedText = mode.toAttrStr()
                measurementLbl.attributedText = mode.toAttrStr()
            }
        }
    }
    
    private let finishButton = UIButton.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 60)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        setupFocusSquare()
        Sound.install()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartSceneView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func layoutViewController() {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let width = screenSize.width//view.bounds.width
        let height = view.bounds.height - bottomView.bounds.height // Deduct bottomView height
        
        view.backgroundColor = UIColor.black
        
        tipsView.backgroundColor = UIColor(red: 0, green: 0.65, blue: 1, alpha: 0.5)
        
        // Actions
        cancelButton.addTarget(self, action: #selector(ARViewController.deleteAction(_:)), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(ARViewController.finishAreaAction(_:)), for: .touchUpInside)
        placeButton.addTarget(self, action: #selector(ARViewController.placeAction(_:)), for: .touchUpInside)
        
        infoButton.addTarget(self, action: #selector(ARViewController.infoTouch(_:)), for: .touchUpInside)
        resultBtn.addTarget(self, action: #selector(ARViewController.showResult(_:)), for: .touchUpInside)
        
        placeButton.backgroundColor = Colors.Button.start
        
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        cancelButton.backgroundColor = UIColor(red: 0.92, green: 0.98, blue: 0.37, alpha: 1)
        cancelButton.layer.cornerRadius = 25.0
        cancelButton.layer.masksToBounds = true
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.3
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        infoButton.backgroundColor = UIColor(red: 0, green: 0.65, blue: 1, alpha: 1)
        infoButton.imageView?.contentMode = .scaleAspectFit
        infoButton.layer.cornerRadius = 25.0
        infoButton.layer.masksToBounds = true
    
        resultView.isHidden = true

       
        
        do {
            
            
            
            
            view.insertSubview(sceneView, belowSubview: bottomView)
            sceneView.frame = CGRect(x: 0, y: 0, width: width, height: height) // view.bounds
            sceneView.delegate = self
            view.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        }
        do {
            // Result Happen Here
            resultLabelBg.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            resultLabelBg.layer.cornerRadius = 20
            resultLabelBg.clipsToBounds = true
            resultLabelBg.isHidden = true
//         let copy = UIButton(size: CGSize(width: 30, height: 30), image: Image.Result.copy)
//         copy.addTarget(self, action: #selector(ARViewController.copyAction(_:)), for: .touchUpInside)

            let tap = UITapGestureRecognizer(target: self, action: #selector(ARViewController.changeMeasureUnitAction(_:)))
            resultLabel.addGestureRecognizer(tap)
            resultLabel.isUserInteractionEnabled = true

            resultLabelBg.frame = CGRect(x: 30, y: 30, width: width - 60, height: 60)
//             copy.frame = CGRect(x: resultLabelBg.frame.maxX - 10 - 30,
//                                y: resultLabelBg.frame.minY + (resultLabelBg.frame.height - 30)/2,
//                                width: 30, height: 30)
            resultLabel.frame = resultLabelBg.frame.insetBy(dx: 10, dy: 0)
            resultLabel.attributedText = mode.toAttrStr()
            resultLabel.isHidden = true
            measurementBg.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            measurementBg.isHidden = true;
            measurementBg.layer.cornerRadius = 20
            measurementBg.clipsToBounds = true

//            view.addSubview(resultLabelBg)
//            view.addSubview(resultLabel)
//            view.addSubview(copy)
        }
        
//        let myView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        myView.backgroundColor = UIColor.green
//        self.view.addSubview(myView)
//        view.insertSubview(myView, at: 0);
        
        do {
            indicator.image = Image.Indicator.disable
            view.addSubview(indicator)
            indicator.frame = CGRect(x: (width - 60)/2, y: (height - 60)/2, width: 60, height: 60)
        }
        do {
            bottomView.addSubview(finishButton)
            
            placeButton.setTitle(Texts.Button.start, for: .normal)
            placeButton.backgroundColor = Colors.Button.start
            tipsLabel.text = Texts.Tips.start
            
            finishButton.center = placeButton.center
            finishButton.isHidden = true
        }
    }
    
    private func configureObserver() {
        func cleanLine() {
            line?.removeFromParent()
            line = nil
            for node in lines {
                node.removeFromParent()
            }
            
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { _ in
            cleanLine()
        }
    }
    
    deinit {
        Sound.dispose()
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Target Action
@objc private extension ARViewController {
    func placeAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (value) in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseIn], animations: {
                sender.transform = CGAffineTransform.identity
            }) { (value) in
            }
        }

        // Skip drawing another line
        if lines.count > 0 { return }

        Sound.play()
        
        cancelButton.isEnabled = true
        cancelButton.alpha = 1.0
        infoButton.isEnabled = false
        infoButton.alpha = 0.3
        resultView.isHidden = false
        
        // switch mode {
        // case .length:
        if let l = line {
            placeButton.setTitle(Texts.Button.start, for: .normal)
            placeButton.backgroundColor = Colors.Button.start
            placeButton.isEnabled = false
            tipsLabel.text = Texts.Tips.start
            resultView.isHidden = false
            
            placeButton.isHidden = true

            lines.append(l)
            line = nil
            
        
            if (measuringZone() < 3) {
                // resultBtn.setTitle("OUT OF RANGE!", for: .normal)
                // resultBtn.backgroundColor = bottomView.backgroundColor
                // resultBtn.setTitleColor(UIColor.red, for: .normal)
                resultView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                resultLbl.textColor = UIColor.red
                resultLbl.text = "OUT OF RANGE!"
            } else {
                let measVal = measurementLbl.text ?? "0"
                let inches:String = measVal.replacingOccurrences(of: "in", with: "")
                
                resultView.backgroundColor = measuringColor().withAlphaComponent(0.8)
                resultLbl.textColor = UIColor.darkGray
                resultLbl.text = "\(inches) Inches"
                
                // resultBtn.backgroundColor = measuringColor()
                // resultBtn.setTitle("Check Result", for: .normal)
                // resultBtn.setTitleColor(UIColor.darkGray, for: .normal)
            }
            
//            measuringZone() < 3) {
//                startBtn.isHidden = true
//                measurementLbl.text = "Measurement is OUT OF RANGE: \(String(format: "%.2f in", meas))"
//                measurementLbl.textColor = UIColor.red
//            } else {
//                startBtn.isHidden = false
//                measurementLbl.text = "Measurement: \(String(format: "%.2f in", meas))"
//                measurementLbl.textColor = UIColor.darkGray
//            }

        } else  {
            placeButton.setTitle(Texts.Button.end, for: .normal)
            placeButton.backgroundColor = Colors.Button.end
            tipsLabel.text = Texts.Tips.end

            resultLabelBg.isHidden = false
            measurementBg.isHidden = false
            measurementBg.isHidden = false
            
            let startPos = sceneView.worldPositionFromScreenPosition(indicator.center, objectPos: nil)
            if let p = startPos.position {
                line = LineNode(startPos: p, sceneV: sceneView)
            }
        }
        // }
    }
    
    func infoTouch(_ sender: UIButton) {
        let qinfVC:BroselowInfoListController = BroselowInfoListController()
        let navCtrl:UINavigationController = UINavigationController(rootViewController: qinfVC)
        navCtrl.modalPresentationStyle = .fullScreen;
        self.navigationController?.present(navCtrl, animated: true, completion: nil)
    }
    
    func showResult(_ sender: UIButton) {
        if (measuringZone() < 3 || measuringZone() > 36) {
            return;
        }
        
        let strCol = measuringStringColor()
        let zone = measuringZone()
        
        let btVC:BrosloeTapeViewController = BrosloeTapeViewController(_stringColor: strCol, _zone: zone)
        let navCtrl:UINavigationController = UINavigationController(rootViewController: btVC)
        
        self.navigationController?.present(navCtrl, animated: true, completion: nil)
        
        deleteAction(cancelButton)
    }

    func restartAction(_ sender: UIButton) {
        placeButton.setTitle(Texts.Button.start, for: .normal)
        placeButton.isEnabled = true
        tipsLabel.text = Texts.Tips.start
        resultLabelBg.isHidden = true
        measurementBg.isHidden = true;
        
        line?.removeFromParent()
        line = nil
        for node in lines {
            node.removeFromParent()
        }
        
        lineSet?.removeFromParent()
        lineSet = nil
        for node in lineSets {
            node.removeFromParent()
        }
        restartSceneView()
        measureValue = nil
    }
    
    func deleteAction(_ sender: UIButton) {
        placeButton.setTitle(Texts.Button.start, for: .normal)
        placeButton.isEnabled = true
        placeButton.isHidden = false
        tipsLabel.text = Texts.Tips.start
        resultLabelBg.isHidden = true
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.3
        infoButton.isEnabled = true
        infoButton.alpha = 1.0
        // resultBtn.isHidden = true
        resultView.isHidden = true
        
        
        switch mode {
        case .length:
            if line != nil {
                line?.removeFromParent()
                line = nil
            } else if let lineLast = lines.popLast() {
                lineLast.removeFromParent()
            } else {
                lineSets.popLast()?.removeFromParent()
            }
        case .area:
            if let ls = lineSet {
                if !ls.removeLine() {
                    lineSet = nil
                }
            } else if let lineSetLast = lineSets.popLast() {
                lineSetLast.removeFromParent()
            } else {
                lines.popLast()?.removeFromParent()
            }
        }
        
        measureValue = nil
    }
    
    func copyAction(_ sender: UIButton) {
    }

    func finishAreaAction(_ sender: UIButton) {
        guard mode == .area,
            let line = lineSet,
            line.lines.count >= 2 else {
                lineSet = nil
                return
        }
        lineSets.append(line)
        lineSet = nil
        changeFinishState(state: false)
    }

    func changeFinishState(state: Bool) {
        guard finishButtonState != state else { return }
        finishButtonState = state

        var center = placeButton.center
        if state {
            center.y -= 100
        }
        UIView.animate(withDuration: 0.3) {
            self.finishButton.center = center
        }
    }

    func changeMeasureUnitAction(_ sender: UITapGestureRecognizer) {
        measureUnit = measureUnit.next()
    }
}


// MARK: - UI
fileprivate extension ARViewController {
    func restartSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        measureUnit = MeasurementUnit.Unit.inch // ApplicationSetting.Status.defaultUnit
//        resultLabel.attributedText = mode.toAttrStr()
        measurementLbl.attributedText = mode.toAttrStr()
        updateFocusSquare()
    }
    
    func updateLine() -> Void {
        let startPos = sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
        if let p = startPos.position {
            let camera = self.sceneView.session.currentFrame?.camera
            let cameraPos = SCNVector3.positionFromTransform(camera!.transform)
            if cameraPos.distanceFromPos(pos: p) < 0.05 {
                if line == nil {
                    placeButton.isEnabled = false
                    indicator.image = Image.Indicator.disable
                }
                return;
            }
            placeButton.isEnabled = true
            indicator.image = Image.Indicator.enable
            switch mode {
            case .length:
                guard let currentLine = line else {
                    // cancelButton.normalImage = Image.Close.delete
                    return
                }
                let length = currentLine.updatePosition(pos: p, camera: self.sceneView.session.currentFrame?.camera, unit: measureUnit, color: measuringColor())
                measureValue =  MeasurementUnit(meterUnitValue: length, isArea: false)
             
                 if (measuringZone() < 3) {
                    resultView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    zoneDetail.textColor = UIColor.red
                    zoneDetail.text = "OUT OF RANGE!"
                 } else {
                    resultView.backgroundColor = measuringColor().withAlphaComponent(0.5)
                    zoneDetail.textColor = UIColor.white
                    
                    var valRes:String = "\(String(format: "%d KG Zone", measuringZone()))"
                    
                    if(measuringStringColor() != "gray") {
                        let strinCol:String = measuringStringColor()
                        valRes = "\(String(format: "%@ Zone", strinCol.uppercased()))"
                    }
                    
                    zoneDetail.text = valRes
                }
                // cancelButton.normalImage = Image.Close.cancel
            case .area:
                guard let set = lineSet else {
                    changeFinishState(state: false)
                    // cancelButton.normalImage = Image.Close.delete
                    return
                }
                let area = set.updatePosition(pos: p, camera: self.sceneView.session.currentFrame?.camera, unit: measureUnit, color: UIColor.white)
                measureValue =  MeasurementUnit(meterUnitValue: area, isArea: true)
                changeFinishState(state: set.lines.count >= 2)
                // cancelButton.normalImage = Image.Close.cancel
            }
        }
    }
    
    func distanceInInches() -> Float {
        let measVal = measurementLbl.text ?? "0"
        let measWithoutUnit:String = measVal.replacingOccurrences(of: "in", with: "")
        
        // NSLog("\(String(format: "distance val  %ld", Float(measWithoutUnit) ?? 0.0))")
        return Float(measWithoutUnit) ?? 0.0
    }
    
    func measuringColor() -> UIColor {
        return Brosloe.getColorForMeasurement(measIn: distanceInInches())
    }
    
    func measuringTextColor() -> UIColor {
        return Brosloe.getTextColorForMeasurement(measIn: distanceInInches())
    }
    
    func measuringStringColor() -> String {
//        NSLog("\(String(format: "distance val  %ld", distance))")
//        NSLog("\(String(format: "distance in inches %ld", distanceInInches()))")
        return Brosloe.getStringForMeasurement(measIn: distanceInInches())
    }
    
    func measuringZone() -> Int {
        return Brosloe.getZoneForMeasurement(measIn: distanceInInches())
    }
}

// MARK： - AR
// MARK: - Plane
fileprivate extension ARViewController {
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        let plane = Plane(anchor, false)
        planes[anchor] = plane
        node.addChildNode(plane)
        indicator.image = Image.Indicator.enable
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
}

// MARK: - FocusSquare
fileprivate extension ARViewController {
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
    }
    
    func updateFocusSquare() {
        // if ApplicationSetting.Status.displayFocus {
            focusSquare?.unhide()
        // } else {
        //    focusSquare?.hide()
        // }
        let (worldPos, planeAnchor, _) = sceneView.worldPositionFromScreenPosition(sceneView.bounds.mid, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
        }
    }
}


// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            PopupAlert.show(title: (error as NSError).localizedDescription)
            // print("Error found \((error as NSError).localizedDescription)")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
            self.updateLine()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.removePlane(anchor: planeAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        let state = camera.trackingState
        DispatchQueue.main.async {
            self.lastState = state
        }
    }
}
