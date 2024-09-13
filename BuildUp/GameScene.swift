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
    
    var isCheckingLevel = false
    
    var currentLevelNumber : Int = 1
    
    let levels : [GameLevel] = [GameLevel(levelNumber: 1, nodeSize: BoxSize.square(80).size),
                               GameLevel(levelNumber: 2, nodeSize: BoxSize.square(80).size),
                                GameLevel(levelNumber: 3, nodeSize: BoxSize.square(80).size)
                                ]
    
    var isLevelCleared : Bool = false
    
                                
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
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        guard let touch = touches.first else {return}
//        let touchPoint = touch.location(in: self)
//
//        if let currentLevel = loadLevel(levelNumber: currentLevelNumber) {
//
//            let boxStroke = createBoxStroke(for: currentLevel)
//            boxStroke.position = touchPoint
//            boxStroke.physicsBody?.density = 3.0
//            print("currentLevelNumber",currentLevelNumber)
//
//            if !isOverLapping(newNode: boxStroke) {
//                addChild(boxStroke)
//                createdNodes.append(boxStroke)
//                self.logBoxStrokePositions()
//                print("createdNodes", createdNodes.count)
//            } else {
//                print("Node is overlapping, can't add!")
//            }
//
//        }
//
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)

        // Loop through the levels array
        for currentLevel in levels {
            
            // Extract the levelNumber from the current level
            let levelNumber = currentLevel.levelNumber
            
            // Load the level using the levelNumber (which is an Int)
            for myLevel in  1...levelNumber {
                
                if let loadedLevel = loadLevel(levelNumber: myLevel) {
                    
                    let boxStroke = createBoxStroke(for: loadedLevel)
                    boxStroke.position = touchPoint
                    boxStroke.physicsBody?.density = 3.0
                    print("loadedLevel", loadedLevel)
                    
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
    
//    func createBoxStroke() -> SKShapeNode {
//        
//        let size = BoxSize.rectangle(70, 70).size
//        let height = size.height
//        self.nodeHeight = height
//        
//        let boxStroke = globalFunctions.createCustomShapeNode(
//            rectOfSize: size,
//            fillColor: .clear,
//            strokeColor: randomNeonColor(),
//            lineWidth: 4,
//            affectedByGravity: true,
//            isDynamic: true,
//            allowsRotation: true,
//            linearDamping: 0.1,
//            friction: 0.5,
//            restitution: 0.1
//        )
//        
//        let contactBitMask: UInt32 = stageCategory | boxStrokeCategory
//        
//        boxStroke.physicsBody = SKPhysicsBody(rectangleOf: boxStroke.frame.size)
//        boxStroke.physicsBody?.categoryBitMask = boxStrokeCategory
//        boxStroke.physicsBody?.contactTestBitMask = contactBitMask
//        boxStroke.physicsBody?.collisionBitMask = contactBitMask
//        
//        return boxStroke
//    }
    
    func createBoxStroke(for level : GameLevel) -> SKShapeNode {
        
        let size = level.nodeSize
        let height = size.height
        self.nodeHeight = height
        
        let boxStroke = globalFunctions.createCustomShapeNode(
            rectOfSize: size,
            fillColor: .black,
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
        
        
        if intThirdLastTop >= intThirdTargetPosition {
            if intSecondLastTop >= intSecondTargetPosition {
                if intCurrentTop >= intTargetYPosition {
                    
                    if !isLevelCleared {
                        print("Level Cleared...")
                        finishBar.strokeColor = .green
                        isLevelCleared = true
                        
                        self.addDelay()
                    }
                      
                }
            }
        }
        
    }
    
// Add this flag to track if checking is in progress
    
//    func logBoxStrokePositions() {
//        // Prevent multiple checks from happening simultaneously
//        guard !isCheckingLevel else { return }
//
//        isCheckingLevel = true  // Set the flag to true when checking starts
//
//        guard createdNodes.count >= 2 else {
//            isCheckingLevel = false // Reset the flag if not enough nodes
//            return
//        }
//
//        guard let lastNode = self.createdNodes.last else {
//            isCheckingLevel = false // Reset the flag if last node is missing
//            return
//        }
//
//        let secondLastNode = self.createdNodes[self.createdNodes.count - 2]
//
//        let currentTop = lastNode.frame.origin.y + lastNode.frame.size.height
//        let secondLastTop = secondLastNode.frame.origin.y + secondLastNode.frame.size.height
//
//        let targetYPosition = self.size.height - 125
//        let secondTargetPosition: CGFloat = targetYPosition - self.nodeHeight
//
//        // Convert to Int to ignore floating-point precision issues
//        let intCurrentTop = Int(currentTop)
//        let intSecondLastTop = Int(secondLastTop)
//        let intTargetYPosition = Int(targetYPosition)
//        let intSecondTargetPosition = Int(secondTargetPosition)
//
//        // Execute logic with delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//            if intSecondLastTop >= intSecondTargetPosition {
//                if intCurrentTop >= intTargetYPosition {
//
//                    self.finishBar.strokeColor = .green
//
//                    self.currentLevelNumber += 1
//                    let currentLevel = self.currentLevelNumber
//                    print("currentLevel",currentLevel)
//                    self.levelCleared(currentLevel: currentLevel)
//
//
//                } else {
//                    print("Just a little left")
//                    self.isCheckingLevel = false
//                }
//            } else {
//                self.isCheckingLevel = false
//                print("Try again, still left after delay!")
//            }
//
//        }
//    }

    func loadLevel(levelNumber: Int) -> GameLevel? {
        return levels.first { $0.levelNumber == levelNumber}
    }
    
    func levelCleared(currentLevel : Int) {
        finishBar.strokeColor = .white
        print("Level Cleared, Congrats!")
        
        print("Attempting to load level: \(currentLevel)")
         if let nextLevel = loadLevel(levelNumber: currentLevel){
            print("nextLevel",nextLevel)
            print("Successfully loaded level \(currentLevel)")
            setupScene(for: nextLevel)

        }else{
            print("No More Levels!")
        }
    }
    
    func setupScene(for level: GameLevel){
        self.removeAllChildren()
        self.addChild(stage)
        self.addChild(finishBar)
    }
    
    func addDelay(){
        // Create the delay action
        let delayAction = SKAction.wait(forDuration: 2.0)
        // Create the action to remove all children
        let removeChildrenAction = SKAction.run {
            self.removeAllBoxStrokes()
            self.createdNodes.removeAll()
            print("currentLevelNumber", self.currentLevelNumber)
        }
        
        self.restartLevel()
        
        // Sequence the actions: delay then remove children
        let sequence = SKAction.sequence([delayAction, removeChildrenAction])
        // Run the sequence on the scene
        self.run(sequence)
        
    }
    
    func removeAllBoxStrokes() {
        for node in createdNodes {
            node.removeFromParent()
        }
        createdNodes.removeAll()
    }
    
    func restartLevel() {
        // Step 1: Remove all created nodes from the scene
        for node in createdNodes {
            node.removeFromParent()
        }
        
        self.currentLevelNumber += 1
        print("FinalcurrentLevelNumber",self.currentLevelNumber)
        // Clear the createdNodes array
        createdNodes.removeAll()
        
        // Step 2: Reset any necessary state
        isLevelCleared = false
        finishBar.strokeColor = .white // Or set it to its initial color
        
        // Step 3: Optionally restart the scene (if you want a full scene reset)
        let newScene = GameScene(size: self.size)
        newScene.backgroundColor = .clear
        newScene.scaleMode = self.scaleMode
        let transition = SKTransition.crossFade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: transition)
       
    }


    
}



