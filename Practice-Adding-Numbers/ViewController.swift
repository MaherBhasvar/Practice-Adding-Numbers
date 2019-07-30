//
//  ViewController.swift
//  Practice-Adding-Numbers
//
//  Created by Maher Bhavsar on 29/07/19.
//  Copyright © 2019 Seven Dots. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var displayNumbers : [Int] = [0, 0]
    var tileNames : [String] = ["t1", "t2"]
    var selectedTile : String = ""
    
    var rememberPosition : SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        addGestures ()
        
        initialSetup ()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Initial Code
    
    func initialSetup () {
        for i in tileNames {
            
            let number = displayNumbers[tileNames.firstIndex(of: i)!]
            
            displayTile (parentNodeName: i , displayText: String(number), startVector : SCNVector3 (x: Float(0 + (Double(tileNames.firstIndex(of: i)!) * 0.01)), y: 0, z: -0.1))
        }
    }
    
    //MARK: - Tile Code
    func displayTile (parentNodeName: String, displayText: String, startVector : SCNVector3) {
        let parentNode = SCNNode()
        parentNode.position = startVector
        parentNode.name = parentNodeName
        
        let plane = SCNPlane(width: 0.01, height: 0.01)
        let tile = SCNNode(geometry: plane)
        
        tile.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        tile.opacity = 0.5
        tile.name = "Tile"
        
        let textGeometry = SCNText(string: displayText, extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 10)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        textNode.opacity = 1
        // scale down the size of the text
        textNode.simdScale = SIMD3(repeating: 0.0005)
        //textNode.position = SCNVector3(x: 0 , y: 0, z: -0.1)
        textNode.centerAlign()
        
        parentNode.addChildNode(tile)
        parentNode.addChildNode(textNode)
        
        sceneView.scene.rootNode.addChildNode(parentNode)
        
    }
    

    
    // MARK: - Gesture Code
    func addGestures () {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func pan (sender: UIPanGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(location)
        for hitTestResult in hitTest {
            print(hitTestResult.node.name as Any)
            if hitTestResult.node.name == "circleTile" {
                print("Velocity x",sender.velocity(in: sceneView).x)
                print("Velocity y",sender.velocity(in: sceneView).y)
                let velocity = -sender.velocity(in: sceneView).y / 1000
                let action2 = SCNAction.rotateBy(x: -CGFloat(velocity), y: 0 , z: 0, duration: 0.5)
                let node = sceneView.scene.rootNode.childNode(withName: "NumberCircle", recursively: true)
                node?.runAction(action2)
                break
            }
        }
    }
    
    @objc func tapped (sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location)
        if hitTest.isEmpty {
            print("no virtual object tapped")
            return
        } else {
            let node = hitTest.first?.node
            print(node?.name)
            print( hitTest.first?.node.position)
            if node?.name == "Tile" {
                
                if sceneView.scene.rootNode.childNode(withName: "NumberCircle", recursively: false) != nil {
                    destroyNumberCircles()
                    displayTile(parentNodeName: selectedTile, displayText: String(displayNumbers[tileNames.firstIndex(of: selectedTile)!]), startVector: rememberPosition)
                }
                
                
                
                //rememberPosition = SCNVector3(x: (hitTest.first?.worldCoordinates.x)!, y: (hitTest.first?.worldCoordinates.y)!, z: (hitTest.first?.worldCoordinates.z)!)
                //rememberPosition = node!.position
                print( node!.position)
                selectedTile = String((node?.parent!.name)!)
                rememberPosition = (node?.parent!.position)!
                let change = displayNumbers[tileNames.firstIndex(of: selectedTile) ?? 0]
                
                sceneView.scene.rootNode.childNode(withName: selectedTile, recursively: false)?.removeFromParentNode()
                
                setNumbers2(change: change, startVector: rememberPosition)
                
                
                
            } else if hitTest.first?.node.name == "circleTile" {
                let numberOnTile = Int((hitTest.first?.node.parent!.name)!)
                
                displayNumbers[tileNames.firstIndex(of: selectedTile)!] = numberOnTile!
                
                displayTile(parentNodeName: selectedTile, displayText: String(numberOnTile!), startVector: rememberPosition)
                
                destroyNumberCircles()
                
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Custom Functions
    
    func setNumbers2 (change: Int, startVector: SCNVector3) {
        let masterParentNode = SCNNode()
        masterParentNode.name = "NumberCircle"
        masterParentNode.position = startVector
        masterParentNode.eulerAngles = SCNVector3( 0, 0, 0 )
        sceneView.scene.rootNode.addChildNode(masterParentNode)
        // range = [position, position, angle, angle]
        // range = [position, angle ]
        
        let range2 = [
            [
                SCNVector3(0, 0, 0.01),
                SCNVector3(0,0,0)
            ],
            [
                SCNVector3(0,Float(sin(36.degreesToradians)) * 0.01 ,Float(cos(36.degreesToradians)) * 0.01),
                SCNVector3(-36.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(72.degreesToradians)) * 0.01 ,Float(cos(72.degreesToradians)) * 0.01),
                SCNVector3(-72.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(108.degreesToradians)) * 0.01 ,Float(cos(108.degreesToradians)) * 0.01),
                SCNVector3(-108.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(144.degreesToradians)) * 0.01 ,Float(cos(144.degreesToradians)) * 0.01),
                SCNVector3(-144.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(180.degreesToradians)) * 0.01 ,Float(cos(180.degreesToradians)) * 0.01),
                SCNVector3(-180.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(216.degreesToradians)) * 0.01 ,Float(cos(216.degreesToradians)) * 0.01),
                SCNVector3(-216.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(252.degreesToradians)) * 0.01 ,Float(cos(252.degreesToradians)) * 0.01),
                SCNVector3(-252.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(288.degreesToradians)) * 0.01 ,Float(cos(288.degreesToradians)) * 0.01),
                SCNVector3(-288.degreesToradians, 0, 0)
            ],
            [
                SCNVector3(0,Float(sin(324.degreesToradians)) * 0.01 ,Float(cos(324.degreesToradians)) * 0.01),
                SCNVector3(-324.degreesToradians, 0, 0)
            ]
        ]
        
        
        
        for i in 0...9 {
            let parentNode = SCNNode()
            parentNode.name = String(i)
            
            
            if (i - change) >= 0 {
                parentNode.position = range2[i - change][0]
                parentNode.eulerAngles = range2[i - change][1]
            } else {
                parentNode.position = range2[(i - change) + 10 ][0]
                parentNode.eulerAngles = range2[(i - change) + 10][1]
            }
            
            let node1 = SCNNode(geometry: SCNPlane(width: 0.01, height: 0.01))
            
            node1.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            node1.opacity = 0.5
            node1.name = "circleTile"
            
            node1.geometry?.firstMaterial?.isDoubleSided = true
            
            parentNode.addChildNode(node1)
            
            let textGeometry = SCNText(string: String(i), extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 9)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            textNode.opacity = 1
            
            textNode.simdScale = SIMD3(repeating: 0.0005)
            
            textNode.centerAlign()
            parentNode.addChildNode(textNode)
            
            masterParentNode.addChildNode(parentNode)
        }
    }
    
    func setNumbers (change: Int, startVector: SCNVector3) {
        
        print("set Numbers called")
        
        let masterParentNode = SCNNode()
        masterParentNode.name = "NumberCircle"
        masterParentNode.position = startVector
        masterParentNode.eulerAngles = SCNVector3( 0, 0, 90.degreesToradians )
        sceneView.scene.rootNode.addChildNode(masterParentNode)
        
        let range = [
            [0.01, 0, 0, 0],
            [Float(cos(-36.degreesToradians)) * 0.01 , Float(sin(-36.degreesToradians)) * 0.01 ,  36 , 0 ],
            [Float(cos(-72.degreesToradians)) * 0.01, Float(sin(-72.degreesToradians)) * 0.01, 72, 0],
            [Float(cos(-108.degreesToradians)) * 0.01, Float(sin(-108.degreesToradians)) * 0.01, 108, 0],
            [Float(cos(-144.degreesToradians)) * 0.01, Float(sin(-144.degreesToradians)) * 0.01, 144, 0],
            [Float(cos(-180.degreesToradians)) * 0.01, Float(sin(-180.degreesToradians)) * 0.01, 180, 0],
            [Float(cos(-216.degreesToradians)) * 0.01, Float(sin(-216.degreesToradians)) * 0.01, 216, 0],
            [Float(cos(-252.degreesToradians)) * 0.01, Float(sin(-252.degreesToradians)) * 0.01, 252, 0],
            [Float(cos(-288.degreesToradians)) * 0.01, Float(sin(-288.degreesToradians)) * 0.01, 288, 0],
            [Float(cos(-324.degreesToradians)) * 0.01, Float(sin(-324.degreesToradians)) * 0.01, 324, 0]
            ] as [[Float]]
        
        
        for i in 0...9 {
            let parentNode = SCNNode()
            parentNode.name = String(i)
            
            if (10 - i) + change <= 9 {
                parentNode.eulerAngles = SCNVector3( range[(10 - i) + change][2].degreesToradians , range[(10 - i) + change][3].degreesToradians, -90.degreesToradians )
                parentNode.position = SCNVector3(x: range[(10 - i) + change][1], y: 0, z: range[(10 - i) + change][0])
            } else {
                parentNode.eulerAngles = SCNVector3( range[(10 - i) + change - 10][2].degreesToradians , range[(10 - i) + change - 10][3].degreesToradians, -90.degreesToradians )
                parentNode.position = SCNVector3(x: range[(10 - i) + change - 10][1], y: 0, z: range[(10 - i) + change - 10][0])
            }
            
            let node1 = SCNNode(geometry: SCNPlane(width: 0.01, height: 0.01))
            
            node1.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            node1.opacity = 0.5
            node1.name = "circleTile"
            
            node1.geometry?.firstMaterial?.isDoubleSided = true
            
            parentNode.addChildNode(node1)
            
            let textGeometry = SCNText(string: String(i), extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 9)
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            textNode.opacity = 1
            
            textNode.simdScale = SIMD3(repeating: 0.0005)
            
            textNode.centerAlign()
            parentNode.addChildNode(textNode)
            
            masterParentNode.addChildNode(parentNode)
            
        }
    }
    
    func destroyNumberCircles () {
        sceneView.scene.rootNode.childNode(withName: "NumberCircle", recursively: false)?.removeFromParentNode()
    }
}


extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = ((max) - (min))
        simdPivot = float4x4(translation: SIMD3((extents / 2) + (min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
func / (left: SCNVector3, right: Int) -> SCNVector3 {
    return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
}

func == (left: SCNVector3, right:SCNVector3) -> Bool {
    if (left.x == right.x && left.y == right.y && left.z == right.z) {
        return true
    } else {
        return false
    }
}

extension Int {
    var degreesToradians : Double {return Double(self) * .pi/180}
}
extension Float {
    var degreesToradians : Double {return Double(self) * .pi/180}
}
