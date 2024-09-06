//
//  ContentView.swift
//  BuildUp
//
//  Created by AbdulMajid Shaikh on 02/09/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showAlert = false
    @State private var showGameScene = false
    
    var body: some View {
//        GameSceneView()
        
        NavigationView {
            
            VStack {
                Spacer(minLength: 100)
                
                Text("BuildUp")
                    .font(.largeTitle).bold()
               
                Button(action: {
                    showGameScene = true
                }) {
                    Text("Play Now!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(width: 160, height: 50)
                        .padding()
                        .frame(height: 350)
                        .position(x: UIScreen.main.bounds.width / 2, y: 0)
                        .padding(.top, 30)
                }
                .fullScreenCover(isPresented: $showGameScene) {
                    GameSceneView() // Present the GameSceneView from the bottom
                }

                
//                NavigationLink(destination: GameSceneView()){
//                    Text("Play Now!").font(.title2).fontWeight(.semibold)
//                        .frame(width: 160, height: 50)
//                        .padding()
//                        .frame(height: 350)
//                        .position(x: UIScreen.main.bounds.width / 2, y: 0)
//                        .padding(.top, 30)
//                }
                
                Button("Exit") {
                    showAlert = true
                }
                .foregroundColor(Color.blue)
                .frame(width: 100, height: 50)
                .position(x: UIScreen.main.bounds.width / 2, y: 0)
                Spacer(minLength: 450)
            }
            .alert(isPresented: $showAlert){
                Alert(
                    title: Text("Exit Application"),
                    message: Text("Are you sure you want to exit?"),
                    primaryButton: .destructive(Text("Exit")){
                        exit(0)
                    },
                    secondaryButton: .cancel()
                    
                )
            }
            
            
        }
            
    }
}

struct ContentView_Preview: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
