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
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
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
    
    // when you open app, "touch gesture" from point to point
    // that you'd like to calculate in 3D space
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // if you touch more than twice, the nodes will be removed.
        if dotNodes.count >= 2
        {
            resetDots()
        }

         if let touchLocation = touches.first?.location(in: sceneView)
         {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
             
            if let hitResult = hitTestResults.first
            {
                addDot(at: hitResult)
            }
             
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
    
    // adding red dots to screen
    // non-Apple code:
    func addDot( at hitResult: ARHitTestResult ) {
        // the size of the green circle
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemGreen
        
        dotGeometry.materials = [material]

        // the "dot" element
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)

        // if 2 dots on screen, calculate distance
        if dotNodes.count >= 2
        {
            calculateDistance()
        }
    }
    
    // given the two dots on the screen, calculate the distance between them
    // from meters to inches
    func calculateDistance() {
         let start = dotNodes.first! // dotNodes[0]
         let end = dotNodes.last! // dotNodes[1]
         
         var distance = sqrt(
             pow(end.position.x - start.position.x, 2) +
             pow(end.position.y - start.position.y, 2) +
             pow(end.position.z - start.position.z, 2)
         )
         
         // convert to cm
         distance *= 100
//        let heightMeter = Measurement(value: meterValue ?? 0, unit: UnitLength.meters)
//        // convert to inches
//        let heightInches = heightMeter.converted(to: UnitLength.inches)
//        // convert to centimeters
//        // let heightCentimeters = heightMeter.converted(to: UnitLength.centimeters)
     
         let distanceFormatted = String(format: "%.2f cm", abs(distance))
         updateText(text: distanceFormatted, atPosition: end.position)
     }
    
    // displays distance between dots in text
    func updateText( text: String, atPosition: SCNVector3 )
    {
         textNode.removeFromParentNode()
     
         let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
         textGeometry.firstMaterial?.diffuse.contents = UIColor.systemRed
         
         textNode = SCNNode(geometry: textGeometry)
         textNode.position = SCNVector3(
             atPosition.x,
             atPosition.y + 0.01,
             atPosition.z
         )
     
         textNode.scale = SCNVector3(0.01, 0.01, 0.01)
         sceneView.scene.rootNode.addChildNode(textNode)
     }
    
    
    func resetDots() {
         for dot in dotNodes {
             dot.removeFromParentNode()
         }
         dotNodes = [SCNNode]()
    }
}
