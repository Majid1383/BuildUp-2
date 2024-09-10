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
    
    private let motionManager = CMMotionManager()
    
    var rectangleYPosition: CGFloat = 0.0
    
    let stageCategory: UInt32 = 0x1 << 0
    let boxStrokeCategory: UInt32 = 0x1 << 1
    
    var finishBarYPosition : CGFloat = 0.0
    
    var nodeHeight: CGFloat = 0.0
    var createdNodes: [SKShapeNode] = []
    
    var finishBar = SKShapeNode()
    
    var currentLevelNumber : Int = 1
    
    let levels : [GameLevel] = [GameLevel(levelNumber: 01, nodeSize: BoxSize.square(10).size),
                                GameLevel(levelNumber: 02, nodeSize: BoxSize.rectangle(20,40).size),
                                GameLevel(levelNumber: 03, nodeSize: BoxSize.square(40).size)]
   
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        motionManager.startAccelerometerUpdates()
        
        let screenBounds = UIScreen.main.bounds
        let screenWidth = UIScreen.main.bounds.width
        self.size = screenBounds.size
        
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
        
//        let stageWidth = self.size.width - 5
//        stage.scene?.size = CGSize(width: stageWidth, height: stage.frame.size.height)
//        
//        let stagePosition = CGPoint(x: self.size.width / 2 , y: stage.frame.size.height / 2 + 5)
//        stage.position = stagePosition
        
        let stagePosition = CGPoint(x: self.size.width / 2 , y: stage.frame.size.height / 2 + 5)
        stage.position = stagePosition
        
        
        finishBar = SKShapeNode(rectOf: CGSize(width: screenWidth ,height: 1))
        finishBar.strokeColor = .white
        finishBar.position = CGPoint(x: screenWidth / 2 ,
                                     y: self.size.height - 125)
        
                
        self.finishBarYPosition = finishBar.position.y
        print("self.finishBarYPosition",self.finishBarYPosition)
        
        self.addChild(stage)
        self.addChild(finishBar)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        let touchPoint = touch.location(in: self)
         
        guard let level = loadLevel(myLevelNumber: currentLevelNumber) else {return}
        
        let boxStroke = createBoxStroke()
        boxStroke.position = touchPoint
        boxStroke.physicsBody?.density = 3.0
        
        if !isOverLapping(newNode: boxStroke) {
            addChild(boxStroke)
            createdNodes.append(boxStroke)
            print("createdNodes", createdNodes.count)
        } else {
//            print("Node is overlapping, can't add!")
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
                    //print("Node removed, current count:", createdNodes.count)
                }
            }
        }
        
        logBoxStrokePositions()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == stageCategory && bodyB.categoryBitMask == boxStrokeCategory) ||  (bodyA.categoryBitMask == boxStrokeCategory && bodyB.categoryBitMask == stageCategory) {
//            print("Stage and BoxStroke have contacted!")
        }else if bodyA.categoryBitMask == boxStrokeCategory && bodyB.categoryBitMask == boxStrokeCategory {
//            print("Two BoxStroke nodes have contacted!")
            
            guard let nodeA = bodyA.node as? SKShapeNode,
                  let nodeB = bodyB.node as? SKShapeNode else {return}
            
            if isNodeOnTop(of: nodeA, on: nodeB){
//                print("Node \(nodeA.name ?? "A") is on top of Node \(nodeB.name ?? "B")")
                nodeA.position.y = nodeB.frame.maxY + nodeA.frame.height / 2
            }else if isNodeOnTop(of: nodeB, on: nodeA) {
//                print("Node \(nodeB.name ?? "B") is on top of Node \(nodeA.name ?? "A")")
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
        //        print("self.nodeHeight",self.nodeHeight)
        
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
    
    func logBoxStrokePositions() {
        guard createdNodes.count >= 2 else { return }
        
        // Delay checking positions to ensure nodes are placed properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Adjust delay as needed
            guard let lastNode = self.createdNodes.last else { return }
            let secondLastNode = self.createdNodes[self.createdNodes.count - 2]
            
            let currentTop = lastNode.frame.origin.y + lastNode.frame.size.height
            let secondLastTop = secondLastNode.frame.origin.y + secondLastNode.frame.size.height
            
            let targetYPosition = self.size.height - 125
            let secondTargetPosition: CGFloat = targetYPosition - self.nodeHeight
            
            // Convert to Int to ignore floating-point precision issues
            let intCurrentTop = Int(currentTop)
            let intSecondLastTop = Int(secondLastTop)
            let intTargetYPosition = Int(targetYPosition)
            let intSecondTargetPosition = Int(secondTargetPosition)
            
            // Debug output to see exact values after the delay
            print("intCurrentTop after delay:", intCurrentTop)
            print("intTargetYPosition after delay:", intTargetYPosition)
            print("intsecondTargetPosition after delay:", intSecondTargetPosition)
            
            // Check if the top of the last node and second last node match the target positions
            if intCurrentTop >= intTargetYPosition {
                if intSecondLastTop >= intSecondTargetPosition {
                    self.finishBar.strokeColor = .green
                    self.advanceToNextLevel()
                    print("Level Cleared after delay")
                } else {
                    print("Try again, still left after delay!")
                }
            }
        }
    }
    
    
    func advanceToNextLevel() {
        let nextLevelNumber = currentLevelNumber + 1
        if let nextLevel = loadLevel(myLevelNumber: nextLevelNumber) {
            currentLevelNumber = nextLevelNumber
            setupScene(for: nextLevel)
        }else {
            print("No more levels. Game Over!")
        }
    }
    
    
    func loadLevel(myLevelNumber: Int) -> GameLevel? {
        return levels.first{ $0.levelNumber == myLevelNumber} ??  GameLevel(levelNumber: 01, nodeSize: CGSize(width: 80, height: 80))
    }
    
    
    func setupScene(for level: GameLevel){
        self.scene?.removeAllChildren()
        self.scene?.removeAllActions()
    }
    
 
}



