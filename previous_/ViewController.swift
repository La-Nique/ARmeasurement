//
//  ViewController.swift
//  ARmeasurement
//
//  Created by ラニク on 9/26/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // measuring node to node
    var dotNodes = [SCNNode]()
    // will display text of measurement
    var textNode = SCNNode()
    // will measure in meters, later on can convert to another measurement unit
    var meterValue : Double?
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // touch gesture, for when you open the app
    // touch from which point to which point you'd like to calculate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // if you touch more than twice, the nodes will be removed.
        if dotNodes.count >= 2
        {
            for dot in dotNodes
            {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        dotNodes = [SCNNode]()
        
        if let touchLocation = touches.first?.location(in: sceneView){
            // non-Apple code:
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first{
                addDot(at: hitResult)
            }
            
// Apple Code:
//            let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
//            let alignment: ARRaycastQuery.TargetAlignment = .any
//
//            // calucating the measurement from end to start position:
//            let query: ARRaycastQuery? = sceneView.raycastQuery(from: touchLocation,
//                                                                allowing: estimatedPlane,
//                                                                alignment: alignment)
//
//            if let nonOptQuery: ARRaycastQuery = query
//            {
//                let result: [ARRaycastResult] = sceneView.session.raycast(nonOptQuery)
//
//                guard let rayCast: ARRaycastResult = result.first
//                else { return }
//
//                addDot(at: rayCast)
//            }
            // end of Apple Code
      }
    }
    
    // adding red dots to screen
    // non-Apple code:
    func addDot(at hitResult: ARHitTestResult)
    // Apple Code:
    //func addDot(at hitResult: ARRaycastResult)
    {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2
        {
            calculate()
        }
    }
    
    // given the two dots on the screen, calculate the distance between them
    // from meters to inches
    func calculate()
    {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2))
        
        meterValue = Double(abs(distance))
        
        let heightMeter = Measurement(value: meterValue ?? 0, unit: UnitLength.meters)
        // convert to inches
        let heightInches = heightMeter.converted(to: UnitLength.inches)
        // convert to centimeters
        // let heightCentimeters = heightMeter.converted(to: UnitLength.centimeters)
        
        let value = "\(heightInches)"
        // shortens the digits of the displayed measurement so it doesn't run off the phone's screen:
        let finalMeasurement = String(value.prefix(6))
        
        updateText(text: finalMeasurement+"in", atPosition: end.position)
    }
    
    // displays distance between dots in text
    func updateText(text: String, atPosition position: SCNVector3)
    {
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text,
                                   extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: position.x,
                                       y: position.y + 0.01,
                                       z: position.z)
        
        textNode.scale = SCNVector3(x: 0.01,
                                    y: 0.01,
                                    z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
