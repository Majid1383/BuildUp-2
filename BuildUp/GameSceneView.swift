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
    
    var scene: SKScene{
        
        let scene = GameScene()
        let screenSize = UIScreen.main.bounds.size
        scene.size = screenSize
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .black
        return scene
    }
    
        var body: some View {
            ZStack{
                SpriteView(scene: scene)
                    .edgesIgnoringSafeArea(.all)
    
                Rectangle()
                    .stroke(
                        Color.white, style: StrokeStyle(lineWidth: 2))
                    .frame(width: UIScreen.main.bounds.width, height: 10)
                    .position(x: UIScreen.main.bounds.width / 2, y: 55)
            }
        }
}

struct GameSceneView_Preview: PreviewProvider{
    static var previews: some View{
        GameSceneView()
    }

}
