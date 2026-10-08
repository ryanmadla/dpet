//
//  SceneController.swift
//  DPET
//
//  Created by Ryan Madlangbayan on 26/02/2019.
//  Copyright © 2019 Ryan Madlangbayan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
//import PusherSwift

class SceneController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var measurementLbl: UILabel!
    @IBOutlet weak var trackingLbl: UILabel!
    @IBOutlet weak var measurementView: UIView!
    
    
    @IBOutlet weak var hintText: UITextView!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var resultBtn: UIButton!
    @IBOutlet weak var cursorBtn: UIButton!
    
    @IBOutlet weak var infoBtn: UIButton!


    var doneMeasuring: Bool!
    var box: Box!
    var startPosition: SCNVector3!
    var distance: Float!
    var trackingState: ARCamera.TrackingState!
    
    enum Mode {
        case waitingForMeasuring
        case measuring
    }
    
    var mode: Mode = .waitingForMeasuring {
        didSet {
            switch mode {
            case .waitingForMeasuring:
                statusView.backgroundColor = UIColor.red
            case .measuring:
                box.update(minExtents: SCNVector3Zero, maxExtents: SCNVector3Zero)
                
                
                box.isHidden = false
                startPosition = nil
                distance = 0.0
                statusView.backgroundColor = UIColor.green
            }
        }
    }
    
    func updateDetails() {
        if(mode == .waitingForMeasuring) {
            return;
        }
        let meas = (distance! * 100.0) * 0.393700787
//        measurementLbl.text = "Measurement: \(String(format: "%.2f in", meas))"
//
//        startBtn.isHidden = (measuringZone() < 3)
        
        if(measuringZone() < 3) {
            startBtn.isHidden = true
            measurementLbl.text = "Measurement is OUT OF RANGE: \(String(format: "%.2f in", meas))"
            measurementLbl.textColor = UIColor.red
        } else {
            startBtn.isHidden = false
            measurementLbl.text = "Measurement: \(String(format: "%.2f in", meas))"
            measurementLbl.textColor = UIColor.darkGray
        }

    }
    
    func distanceInInches() -> Float {
        return (distance! * 100.0) * 0.393700787
    }
    
    func measuringColor() -> UIColor {
        return Brosloe.getColorForMeasurement(measIn: distanceInInches())
    }
    
    func measuringTextColor() -> UIColor {
        return Brosloe.getTextColorForMeasurement(measIn: distanceInInches())
    }
    
    func measuringStringColor() -> String {
        NSLog("\(String(format: "distance val  %ld", distance))")
        NSLog("\(String(format: "distance in inches %ld", distanceInInches()))")
        return Brosloe.getStringForMeasurement(measIn: distanceInInches())
    }
    
    func measuringZone() -> Int {
        return Brosloe.getZoneForMeasurement(measIn: distanceInInches())
    }
    
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "TRACKING UNAVAILABLE"
            case .normal:
                description = "TRACKING NORMAL"
            case .limited(let reason):
                if reason == .excessiveMotion {
                    description = "TRACKING LIMITED - Too much camera movement"
                } else if reason == .insufficientFeatures {
                    description = "TRACKING LIMITED - Not enough surface detail"
                } else if reason == .initializing {
                    description = "INITIALIZING"
                }
            }
        }
        
        return description
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Call the method asynchronously to perform
        //  this heavy task without slowing down the UI
        DispatchQueue.main.async {
            self.measure(time: time)
        }
    }
    
    func measure(time: TimeInterval) {
        let screenCenter : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        let planeTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        if let result = planeTestResults.first {

            if mode == .measuring {
                let worldPosition = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                
                if startPosition == nil {
                    startPosition = worldPosition
                    box.position = worldPosition
                }
                
                distance = calculateDistance(from: startPosition!, to: worldPosition)
                box.resizeTo(extent: distance)
                
                let angleInRadians = calculateAngleInRadians(from: startPosition!, to: worldPosition)
                box.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -(angleInRadians + Float.pi))
                
                let zone:UIColor = measuringColor()
                box.updateMaterialColor(col: zone)
            }
        }
        updateDetails()
    }
    
    func calculateDistance(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let y = from.y - to.y
        let z = from.z - to.z
        
        return sqrtf( (x * x) + (y * y) + (z * z))
    }
    
    func calculateAngleInRadians(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let z = from.z - to.z
        
        return atan2(z, x)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func startTouch(_ sender: UIButton) {
        let screenCenter : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let planeTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        let result = planeTestResults.first

        self.view.bringSubviewToFront(measurementView)
//
//        // Make sure planeTest got a result
//        if result !== nil {
//            startBtn.setImage(mode == .measuring ? Icons.Add: Icons.Tick, for: .normal)
            
            startBtn.setTitle("Stop", for: .normal)
            measurementView.isHidden = false
            cancelBtn.isHidden = false
            infoBtn.isHidden = false

        
            #if !targetEnvironment(simulator)
            if (mode == .waitingForMeasuring) {
                
                resultBtn.isHidden = true
                doneMeasuring = false
                mode = .measuring
                return
            }
            
            resultBtn.titleLabel?.textColor = measuringTextColor()
            resultBtn.backgroundColor = measuringColor()
            resultBtn.isHidden = false
        
            startBtn.isHidden = true
            
            
            let image = UIImage(named: "reset")?.withRenderingMode(.alwaysTemplate)
            cancelBtn.setImage(image, for: .normal)
            cancelBtn.tintColor = UIColor.white
            
            doneMeasuring = true
            mode = .waitingForMeasuring
            cursorBtn.isHidden = true;
            
            // doneBtn.isHidden = false
            // startBtn.isHidden = true
            // measurementView.isHidden = false
            
            // cancelBtn.titleLabel?.text = "Cancel"
            // doneBtn.setTitle("Done", for: UIControl.State.normal)
            // cancelBtn.setTitle("Cancel", for: UIControl.State.normal)
            // mode = .measuring;
            // doneMeasuring = false
            #endif
//        }
    }
    
    
    
    @IBAction func cancelTouch(_ sender: UIButton) {
//        startBtn.setImage(Icons.Add, for: .normal)
        
        startBtn.isHidden = false
        startBtn.setTitle("Start", for: .normal)
        measurementView.isHidden = true
        cursorBtn.isHidden = false
        resultBtn.isHidden = true
       
//        let image = UIImage(named: "cross")?.withRenderingMode(.alwaysTemplate)
//        sender.setImage(image, for: .normal)
        sender.tintColor = UIColor.white
        
        mode = .waitingForMeasuring
        box.isHidden = true
        measurementView.isHidden = true
        
//        startBtn.isHidden = false
        cancelBtn.isHidden = true
        
        startPosition = nil
        distance = 0.0
        doneMeasuring = false
        
    }
    
    @IBAction func doneTouch(_ sender: UIButton) {
        if(doneMeasuring) {
            let strCol = measuringStringColor()
            let zone = measuringZone()
            
            let btVC:BrosloeTapeViewController = BrosloeTapeViewController(_stringColor: strCol, _zone: zone)
            let navCtrl:UINavigationController = UINavigationController(rootViewController: btVC)
            
            // navCtrl.isNavigationBarHidden = true
            
            self.navigationController?.present(navCtrl, animated: true, completion: nil)
            
            mode = .waitingForMeasuring
            startPosition = nil
            distance = 0.0
            box.isHidden = true
            startBtn.isHidden = false
            cancelBtn.isHidden = true
            doneBtn.isHidden = true
            return;
        }
        
        doneMeasuring = true
//        doneBtn.setTitle("View", for: UIControl.State.normal)
//        cancelBtn.setTitle("Retry", for: UIControl.State.normal)
        
        mode = .waitingForMeasuring
    }
    
    @IBAction func resultTouch(_ sender: UIButton) {
        let strCol:String = measuringStringColor()
        let zone:Int = measuringZone()
        
        if (zone == 0) {
            return
        }
        
        let btVC:BrosloeTapeViewController = BrosloeTapeViewController(_stringColor: strCol, _zone: zone)
        let navCtrl:UINavigationController = UINavigationController(rootViewController: btVC)
        self.navigationController?.present(navCtrl, animated: true, completion: nil)
        
        mode = .waitingForMeasuring
        startPosition = nil
        distance = 0.0
    }
    
    @IBAction func okTouch(_ sender: UIButton) {
        if (okBtn.tag == 100) {
            // Remember to disable the hint
            UserDefaults.standard.set(true, forKey: Hint.key)
        }
        hintView.isHidden = true
        okBtn.tag = 100
    }
    
    @IBAction func infoTouch(_ sender: UIButton) {
        let qinfVC:BroselowInfoListController = BroselowInfoListController()
        let navCtrl:UINavigationController = UINavigationController(rootViewController: qinfVC)
        self.navigationController?.present(navCtrl, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hintView.isHidden = Hint.isHidden
        
        adjustButtonColors()
        #if !targetEnvironment(simulator)
        box = Box()
        box.isHidden = true;
        sceneView.scene.rootNode.addChildNode(box)

        // Set the initial mode
        mode = .waitingForMeasuring

        startPosition = nil
        // Set the initial distance
        distance = 0.0

        // Display the initial status
        updateDetails()
       #endif
    }
    
    override func viewWillLayoutSubviews() {
//        startBtn.imageEdgeInsets = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
//        startBtn.setImage(Icons.Add, for: .normal)
//        startBtn.tintColor = UIColor.white
        
        startBtn.layer.masksToBounds = true
        startBtn.layer.borderColor = UIColor.white.cgColor
        resultBtn.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        cancelTouch(cancelBtn)
    
        #if !targetEnvironment(simulator)
        // Create a session configuration with plane detection
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

         if #available(iOS 11.3, *) {
            configuration.planeDetection = [.horizontal, .vertical]
         }
        
        // Run the view's session
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
        #endif
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!Hint.isHidden) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                UserDefaults.standard.set(true, forKey: Hint.key)
                self.hintView.isHidden = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.standard.set(true, forKey: Hint.key)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func adjustButtonColors() {
        for btn:UIButton in [cancelBtn, infoBtn] {
            
            let image = btn.imageView?.image?.withRenderingMode(.alwaysTemplate)
            btn.setImage(image, for: .normal)
            btn.tintColor = UIColor.white
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
