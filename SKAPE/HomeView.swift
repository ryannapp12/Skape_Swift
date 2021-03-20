//
//  HomeView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/11/20.
//

import SwiftUI

struct HomeView: View {
    
    let screen = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            //Main VStack
            ScrollView(showsIndicators: false) {
                
                LazyVStack {
                    HomepageLogoView()
                        .frame(width: screen.width, alignment: .topLeading)
                        .padding(.top, -55)
                        .padding(.bottom, 2)
                }
                VStack {
                    
                }
                HStack(alignment: .center) {
                    Text("")
                    .padding(.top, 2)
                }
                Buttons(text: "Request A Skaper", imageName: "plus") {

                }
                .frame(width: 300, height: 100, alignment: .bottom)
            }
            
        }
        .foregroundColor(.black)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .background(Color.white)
    }
}
