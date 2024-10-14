//
//  GlobalFunctions.swift
//  BuildUp
//
//  Created by IIC on 02/09/24.
//

import SwiftUI
import SpriteKit

class globalFunctions{
    
    static func createCustomShapeNode(rectOfSize size: CGSize,
                                      fillColor: UIColor,
                                      strokeColor: UIColor,
                                      lineWidth: CGFloat,
                                      affectedByGravity isAffectedByGravity: Bool,
                                      isDynamic isDynamic: Bool,
                                      allowsRotation isAllowedRotation : Bool,
                                      linearDamping linearDampingValue : CGFloat,
                                      friction frictionValue : CGFloat,
                                      restitution restitutionValue: CGFloat ) -> SKShapeNode {
        
        let shapeNode = SKShapeNode(rectOf: size)
        shapeNode.fillColor = fillColor
        shapeNode.strokeColor = strokeColor
        shapeNode.lineWidth = lineWidth
        
        shapeNode.physicsBody = SKPhysicsBody(rectangleOf: (shapeNode.frame.size))
        shapeNode.physicsBody?.affectedByGravity = isAffectedByGravity
        shapeNode.physicsBody?.isDynamic = isDynamic
        
        shapeNode.physicsBody?.allowsRotation = isAllowedRotation
        shapeNode.physicsBody?.linearDamping = linearDampingValue
        shapeNode.physicsBody?.friction = frictionValue
        shapeNode.physicsBody?.restitution = restitutionValue
        
        
        // Add more custom properties if needed
        return shapeNode
    }

    
    //RandomColour
    static func randomNeonColor() -> SKColor {
        let randomColorComponent = { CGFloat.random(in: 0.5...1.0) }
        let red = randomColorComponent()
        let green = randomColorComponent()
        let blue = randomColorComponent()
        
        let components = [red, green, blue].shuffled()
        return SKColor(red: components[0], green: components[1], blue: components[2], alpha: 1.0)
    }
    
    
}




