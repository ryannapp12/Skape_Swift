//
//  HomepageLogoView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/11/20.
//

import SwiftUI
import KingfisherSwiftUI

struct HomepageLogoView: View {
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                HStack{
                    Spacer()
                    SmallVerticalButton(text: "My Home", isOnImage: "house", isOffImage: "house", isOn: true) {
                        //
                    }
                    
                    Spacer()
                    
                    StartButton(text: "Select Services", imageName: "plus.circle") {
                        //
                    }
                    
                    .frame(width: 180)
                    
                    Spacer()
                    
                    SmallVerticalButton(text: "Map Me", isOnImage: "hand.draw", isOffImage: "hand.draw", isOn: true) {
                        //
                    }
                    
                    Spacer()
                }
            }
            Image("LOGO-SCAPE").resizable()
                .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding(.vertical, 60)
            
        }
        .foregroundColor(.black)
    }
}

struct HomepageLogoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
