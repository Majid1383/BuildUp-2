//
//  GameSceneView.swift
//  BuildUp
//
//  Created by AbdulMajid Shaikh on 02/09/24.
//

import SwiftUI
import SpriteKit

struct GameSceneView: View {
    
    @StateObject private var gameScene = GameScene()
    @State private var rectangleYPosition: CGFloat = 60
    
    var scene: SKScene{
        
        let scene = GameScene()
        let screenSize = UIScreen.main.bounds.size
        scene.size = screenSize
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .gray
        scene.updateRectanglePosition(yPosition: rectangleYPosition)
        return scene
    }
    
        var body: some View {
            ZStack{
                 
                SpriteView(scene: scene)
                    .edgesIgnoringSafeArea(.all)
                
//                Rectangle()
//                    .stroke(
//                        Color.green, style: StrokeStyle(lineWidth: 1))
//                    .frame(width: UIScreen.main.bounds.width, height: 1)
//                    .position(x: UIScreen.main.bounds.width / 2 , y: 60)
         
                
//                Rectangle()
//                    .stroke(
//                        Color.green, style: StrokeStyle(lineWidth: 1))
//                    .frame(width: UIScreen.main.bounds.width, height: 1)
//                    .position(x: UIScreen.main.bounds.width / 2, y: rectangleYPosition)
            }
        }
}

struct GameSceneView_Preview: PreviewProvider{
    static var previews: some View{
        GameSceneView()
    }

}
