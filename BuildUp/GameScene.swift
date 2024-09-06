//
//  GameSceneView.swift
//  BuildUp
//
//  Created by AbdulMajid Shaikh on 02/09/24.
//

import SwiftUI
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    private let skView = SKView()
    private let motionManager = CMMotionManager()
    
    var rectangleYPosition: CGFloat = 0.0
    
    let stageCategory: UInt32 = 0x1 << 0
    let boxStrokeCategory: UInt32 = 0x1 << 1
    
    var nodeHeight: CGFloat = 0.0
    var createdNodes: [SKShapeNode] = []
    
    func updateRectanglePosition(yPosition: CGFloat) {
        
        self.rectangleYPosition = yPosition
        print("Rectangle y-position in GameScene: \(rectangleYPosition)")
    }
   
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        motionManager.startAccelerometerUpdates()
        //        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        skView.layer.borderWidth = 5.0
        skView.layer.borderColor = UIColor.magenta.cgColor
//        view.addSubview(skView)
        self.physicsWorld.contactDelegate = self
        
        let stage = globalFunctions.createCustomShapeNode(rectOfSize: BoxSize.rectangle(150, 1).size,
                                                          fillColor: .clear,
                                                          strokeColor: .red,
                                                          lineWidth: 2,
                                                          affectedByGravity: false,
                                                          isDynamic: false,
                                                          allowsRotation: false,
                                                          linearDamping: 0.1,
                                                          friction: 0.5,
                                                          restitution: 0.1)
        
        stage.physicsBody?.categoryBitMask = stageCategory
        stage.physicsBody?.contactTestBitMask = boxStrokeCategory
        stage.physicsBody?.collisionBitMask = boxStrokeCategory
        
        let stageWidth = self.size.width - 5
        stage.scene?.size = CGSize(width: stageWidth, height: stage.frame.size.height)
        
        let stagePosition = CGPoint(x: self.size.width / 2 , y: stage.frame.size.height / 2 + 5)
        stage.position = stagePosition
        
        let screenHeight = UIScreen.main.bounds.height; print("uiScreen", screenHeight)
        
        
        let stageHeight = stage.frame.size.height
        let yOffset: CGFloat = 600

        let finishBar = SKShapeNode(rectOf: BoxSize.rectangle(UIScreen.main.bounds.width, 1).size)

        // Set position relative to stage
        finishBar.position = CGPoint(x: UIScreen.main.bounds.width / 2,
                                     y: stage.position.y + stageHeight / 2 + yOffset)
        
        print("finishBar",finishBar.position.y)

        self.addChild(finishBar)
        self.addChild(stage)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        
        let touchPoint = touch.location(in: self)
        
        let boxStroke = createBoxStroke()
        boxStroke.position = touchPoint
        boxStroke.physicsBody?.density = 3.0
        
        if !isOverLapping(newNode: boxStroke) {
            addChild(boxStroke)
            createdNodes.append(boxStroke)
            print("createdNodes", createdNodes.count)
        } else {
            print("Node is overlapping, can't add!")
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if let accelerometerData = motionManager.accelerometerData {
            let gravityX = CGFloat(accelerometerData.acceleration.x * 9.8)
            let gravityY = CGFloat(accelerometerData.acceleration.y * 9.8)
            physicsWorld.gravity = CGVector(dx: gravityX, dy: gravityY)
        }
        
        for node in createdNodes {
            if node.position.y < -node.frame.height || node.position.x < -node.frame.width || node.position.x > size.width + node.frame.width {
                
                node.removeFromParent()
                
                if let index = createdNodes.firstIndex(of: node){
                    createdNodes.remove(at: index)
                    print("Node removed, current count:", createdNodes.count)
                }
            }
        }
        
        logBoxStrokePositions()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == stageCategory && bodyB.categoryBitMask == boxStrokeCategory) ||  (bodyA.categoryBitMask == boxStrokeCategory && bodyB.categoryBitMask == stageCategory) {
            print("Stage and BoxStroke have contacted!")
        }else if bodyA.categoryBitMask == boxStrokeCategory && bodyB.categoryBitMask == boxStrokeCategory {
            print("Two BoxStroke nodes have contacted!")
            
            guard let nodeA = bodyA.node as? SKShapeNode,
                  let nodeB = bodyB.node as? SKShapeNode else {return}
            
            if isNodeOnTop(of: nodeA, on: nodeB){
                print("Node \(nodeA.name ?? "A") is on top of Node \(nodeB.name ?? "B")")
                nodeA.position.y = nodeB.frame.maxY + nodeA.frame.height / 2
            }else if isNodeOnTop(of: nodeB, on: nodeA) {
                print("Node \(nodeB.name ?? "B") is on top of Node \(nodeA.name ?? "A")")
                // Example: Snap nodeB into place above nodeA
                nodeB.position.y = nodeA.frame.maxY + nodeB.frame.height / 2
            }
            
        }
    }
    
}

//MARK: Custom Functions
extension GameScene{
    //Stop OverLapping
    func isOverLapping(newNode: SKShapeNode) -> Bool {
        for node in self.children where node is SKShapeNode {
            if node.frame.intersects(newNode.frame){
                return true
            }
        }
        return false
    }
     
 
    //RandomColour
    func randomNeonColor() -> SKColor {
        let randomColorComponent = { CGFloat.random(in: 0.5...1.0) }
        
        let red = randomColorComponent()
        let green = randomColorComponent()
        let blue = randomColorComponent()
        
        let components = [red, green, blue].shuffled()
        return SKColor(red: components[0], green: components[1], blue: components[2], alpha: 1.0)
    }
    
    func createBoxStroke() -> SKShapeNode {
        
        let size = BoxSize.rectangle(70, 70).size
        let height = size.height
        self.nodeHeight = height
        print("self.nodeHeight",self.nodeHeight)
            
            let boxStroke = globalFunctions.createCustomShapeNode(
                rectOfSize: size,
                fillColor: .clear,
                strokeColor: randomNeonColor(),
                lineWidth: 4,
                affectedByGravity: true,
                isDynamic: true,
                allowsRotation: true,
                linearDamping: 0.1,
                friction: 0.5,
                restitution: 0.1
            )
        
        let contactBitMask: UInt32 = stageCategory | boxStrokeCategory
        
            boxStroke.physicsBody = SKPhysicsBody(rectangleOf: boxStroke.frame.size)
            boxStroke.physicsBody?.categoryBitMask = boxStrokeCategory
            boxStroke.physicsBody?.contactTestBitMask = contactBitMask
            boxStroke.physicsBody?.collisionBitMask = contactBitMask
           
            return boxStroke
        }
    
    
    func isNodeOnTop(of nodeA: SKShapeNode, on nodeB: SKShapeNode) -> Bool {
        
        let nodeABottom = nodeA.frame.minY
        let nodeATop = nodeA.frame.maxY
        
        let nodeBBottom = nodeB.frame.minY
        let nodeBTop = nodeB.frame.maxY
        
        let isHorizontalAligned = nodeA.frame.intersects(CGRect(x: nodeB.frame.minX,
                                                                y: nodeBTop,
                                                                width: nodeB.frame.width,
                                                                height: 1))
        
        let isOnTop = nodeABottom <= nodeBTop && nodeATop > nodeBTop && isHorizontalAligned
        
        return isOnTop
    }
    
     
//    func logBoxStrokePositions() {
//        for (index, node) in createdNodes.enumerated() {
//            let position = node.position
//            print("BoxStroke \(index + 1): Position = (\(position.x), \(position.y))")
//        }
//        
//        // Check the position of the last node
//        if let lastNode = createdNodes.last {
//            let lastArrayPosition = lastNode.position.y
//            print("lastArrayPosition:", lastArrayPosition)
//            
//            // Adjust the tolerance as needed
//            let targetPosition: CGFloat = 651
//            let tolerance: CGFloat = 1.0 // Increase tolerance if needed
//            
//            let roundedLastArrayPosition = round(lastArrayPosition * 100) / 100
//            let roundTargestPostion = round(targetPosition * 100 ) / 100
//            
//            if abs(roundedLastArrayPosition - roundTargestPostion) <= tolerance {
//                print("Level cleared!")
//            } else {
//                print("Condition not met: Difference is greater than tolerance")
//            }
//        }
//    }
    
    func logBoxStrokePositions() {
        
        for (index, node) in createdNodes.enumerated() {
            let position = node.position
            print("BoxStroke \(index + 1): Position = (\(position.x), \(position.y))")
            
            // Check if there's a next node to compare
            if index < createdNodes.count - 1 {
                
                let currentTop = node.frame.origin.y + node.frame.size.height; print("currentTop",currentTop)
                
                let nextNode = createdNodes[index + 1]; print("nextNode",nextNode)
                let nextBottom = nextNode.frame.origin.y; print("nextBottom",nextBottom)
                let tolerance: CGFloat = 1.0
                
                let roundCurrentTop = round(currentTop * 100) / 100 ; print("roundCurrentTop",roundCurrentTop)
                let roundNextBottom = round(nextBottom * 100) / 100 ; print("roundNextBottom",roundNextBottom)
                
                let targetPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: self.rectangleYPosition); print("targetPosition",targetPosition)
                let screenHeight = UIScreen.main.bounds.height; print("screenHeight", screenHeight)
                let yPosition : CGFloat = targetPosition.y ; print("yPosition", yPosition)
                let finalPoint = screenHeight - yPosition; print("finalPoint",finalPoint)
                
                
                let secondTargetPosition : CGFloat = finalPoint - self.nodeHeight; print("secondTargetPosition",secondTargetPosition)
                
                if abs(roundNextBottom - roundCurrentTop) <= tolerance {
                    print("BoxStroke \(index + 1) top matches BoxStroke \(index + 2) bottom.")
                    if roundNextBottom >= finalPoint && roundCurrentTop >= secondTargetPosition  {
                        print("Level Cleared")
                    }else {
                        print("TryAgain!")
                    }
                    
                } else {
                    print("BoxStroke \(index + 1) top does NOT match BoxStroke \(index + 2) bottom.")
                }
            }
        }
        
    }

}


