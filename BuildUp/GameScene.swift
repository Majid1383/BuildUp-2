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
    var stage = SKShapeNode()
        
    var isLevelCleared : Bool = false
    
    var currentLevelNumber: Int = 1
     
    let levelManager = LevelManager()
    var currentLevel: GameLevel? {   //Added Level in separate LevelManager
        guard currentLevelNumber > 0 && currentLevelNumber <= levelManager.levels.count else {
            return nil
        }
        return levelManager.levels[currentLevelNumber - 1]
    }
 
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        motionManager.startAccelerometerUpdates()
        
        let screenBounds = UIScreen.main.bounds
        let screenWidth = UIScreen.main.bounds.width
        self.size = screenBounds.size
        
        self.physicsWorld.contactDelegate = self
        
        self.stage = globalFunctions.createCustomShapeNode(rectOfSize: BoxSize.rectangle(150, 1).size,
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

        if let currentLevel = loadLevel(levelNumber: currentLevelNumber) {

            let boxStroke = createBoxStroke(for: currentLevel)
            boxStroke.position = touchPoint
            boxStroke.physicsBody?.density = 3.0
            print("currentLevelNumber",currentLevelNumber)

            if !isOverLapping(newNode: boxStroke) {
                addChild(boxStroke)
                createdNodes.append(boxStroke)
                self.logBoxStrokePositions()
                print("createdNodes", createdNodes.count)
            } else {
                print("Node is overlapping, can't add!")
            }

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
        
        if isLevelCleared {
            handleLevelCleared()
            print("DEBUG: isLevel Cleared!")
        }
    }
    
    func handleLevelCleared() {
        // Step 1: Remove all existing nodes
//        clearBoxNodes()
        // Step 2: Update level and adjust game difficulty
        currentLevelNumber += 1 ; print("DEBUG: currentLevelNumber += 1 ", currentLevelNumber)
        // Step 4: Reset the level cleared flag
        finishBar.strokeColor = .white
        isLevelCleared = false ;  print("DEBUG: isLevelCleared ", isLevelCleared)
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
    
 
    func createBoxStroke(for level : GameLevel) -> SKShapeNode {
        
        let size = level.nodeSize
        let height = size.height
        self.nodeHeight = height
        
        let boxStroke = globalFunctions.createCustomShapeNode(
            rectOfSize: size,
            fillColor: .black,
            strokeColor: globalFunctions.randomNeonColor(),
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
        
        guard createdNodes.count >= 3 else { return }
        // Adjust delay as needed
        guard let lastNode = self.createdNodes.last else { return }
        let secondLastNode = self.createdNodes[self.createdNodes.count - 2]
        let thirdLastNode  = self.createdNodes[self.createdNodes.count - 3]
        
        let currentTop = lastNode.frame.origin.y + lastNode.frame.size.height
        let secondLastTop = secondLastNode.frame.origin.y + secondLastNode.frame.size.height
        let thirdLastTop = thirdLastNode.frame.origin.y + thirdLastNode.frame.size.height
        
        let targetYPosition = self.size.height - 125
        let secondTargetPosition: CGFloat = targetYPosition - self.nodeHeight
        let thirdTargetPosition: CGFloat = targetYPosition - self.nodeHeight - self.nodeHeight
        
        // Convert to Int to ignore floating-point precision issues
        let intCurrentTop = Int(currentTop)
        print("intCurrentTop",intCurrentTop)
        let intTargetYPosition = Int(targetYPosition)
        print("intTargetYPosition",intTargetYPosition)
        
        let intSecondLastTop = Int(secondLastTop)
        print("intSecondLastTop",intSecondLastTop)
        let intSecondTargetPosition = Int(secondTargetPosition)
        print("intSecondTargetPosition",intSecondTargetPosition)
        
        
        let intThirdLastTop = Int(thirdLastTop)
        print("intThirdLastTop",intThirdLastTop)
        let intThirdTargetPosition = Int(thirdTargetPosition)
        print("intThirdTargetPosition",intThirdTargetPosition)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            if intThirdLastTop >= intThirdTargetPosition {
                if intSecondLastTop >= intSecondTargetPosition {
                    if intCurrentTop >= intTargetYPosition {
                        if !self.isLevelCleared {
                            print("Level Cleared...")
                            self.finishBar.strokeColor = .green
                            self.isLevelCleared = true
                            
                            // Loop through each created node and apply the bust effect
                            for node in self.createdNodes {
                                if let shapeNode = node as? SKShapeNode {
                                    shapeNode.fallingEffect()
                                } // Assuming bustEffect is defined in the SKShapeNode extension
                            }
                            
                            // Optionally, remove all nodes after the bust effect
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Wait for effect duration
                                for node in self.createdNodes {
                                    node.removeFromParent() // Remove each node from the scene
                                }
                                self.createdNodes.removeAll() // Clear the array
                            }
                        }
                    }
                }
            }
        }

        
        finishBar.strokeColor = .white
        
    }

    func loadLevel(levelNumber: Int) -> GameLevel? {
        return levelManager.levels.first { $0.levelNumber == levelNumber}
    }
    
}

extension GameScene {
    
    func clearBoxNodes() {
        self.removeChildren(in: self.createdNodes)
        print("DEBUG: Clearing BoxNodesNow!")
    }
    
}

extension SKShapeNode {
    
    func fallingEffect() {
        // Ensure the path is valid
        guard let path = self.path else { return }
        
        // Create a bounding box from the path
        let boundingBox = path.boundingBox
        
        // Apply gravity by enabling physics with the bounding box
        self.physicsBody = SKPhysicsBody(rectangleOf: boundingBox.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = 1 // Set a category if needed
        self.physicsBody?.collisionBitMask = 1 // Set collision mask if needed
        self.physicsBody?.contactTestBitMask = 1 // Set contact mask if needed
        
        // Optional: Add a small random torque for a more dynamic falling effect
        let randomTorque = CGFloat.random(in: -0.5...0.5)
        self.physicsBody?.applyTorque(randomTorque)
        
        self.physicsBody?.velocity = CGVector(dx: 0, dy: -700)
    }
}




//extension SKShapeNode {
//    func bustEffect() {
//        // Scale up slowly
//        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2) // Increased duration
//        // Rotate slowly
//        let rotate = SKAction.rotate(byAngle: CGFloat.pi / 4, duration: 0.2) // Increased duration
//        // Scale down slowly
//        let scaleDown = SKAction.scale(to: 0.5, duration: 0.2) // Increased duration
//        
//        // Fade out slowly
//        let fadeOut = SKAction.fadeOut(withDuration: 0.3) // Increased duration
//        
//        // Move up slightly
//        let moveUp = SKAction.moveBy(x: 0, y: 15, duration: 0.2) // Increased upward movement for more effect
//
//        // Combine actions
//        let bustSequence = SKAction.sequence([
//            SKAction.group([scaleUp, rotate, moveUp]), // Scale up, rotate, and move up together
//            scaleDown,
//            fadeOut
//        ])
//        
//        // Remove the node after the effect
//        self.run(bustSequence) {
//            self.removeFromParent() // Remove the node after the effect
//        }
//    }
//}



