//
//  GameSceneView.swift
//  BuildUp
//
//  Created by AbdulMajid Shaikh on 02/09/24.
//

import SwiftUI
import SpriteKit

struct GameSceneView: View {
    
//    @StateObject private var gameScene = GameScene()
    
    var scene: SKScene{
        let scene = GameScene()
        let screenSize = UIScreen.main.bounds.size
        scene.size = screenSize
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        return scene
    }
    
    var body: some View {
        ZStack{
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.vertical)
        }
    }
    
    struct GameSceneView_Preview: PreviewProvider{
        static var previews: some View{
            GameSceneView()
        }
    }
}
