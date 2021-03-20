//
//  ContentView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/11/20.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowing = false
    
    init() {
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    var body: some View {
        
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }.tag(0)
            
            Text("First")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("My Schedule")
                }.tag(1)
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }.tag(2)
            
            Text("Help")
                .tabItem {
                    Image(systemName: "questionmark")
                    Text("Help Me")
                }.tag(3)
            
            Text("Tips")
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Tips")
                }.tag(4)
            
            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }.tag(5)
        }
        .accentColor(.black)
        
        NavigationView {
            ZStack {
                Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                
                Text("Hello, World!")
                    .padding()
            }
            .navigationBarItems(leading: Button(action: {
                print("DEBUG: Show menu here...")
            }, label: {
                Image(systemName: "list.bullet")
                    .foregroundColor(.black)
            }))
            .navigationTitle("Home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
