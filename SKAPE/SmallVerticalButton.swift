//
//  SmallVerticalButton.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/12/20.
//

import SwiftUI

struct SmallVerticalButton: View {
    var text: String
    
    var isOnImage: String
    var isOffImage: String
    
    var isOn: Bool
    
    var imageName: String {
        if isOn {
            return isOnImage
        } else {
            return isOffImage
        }
    }
    
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(.black)
                
                Text(text)
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                    .bold()
            }
        })
    }
}

struct SmallVerticalButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            SmallVerticalButton(text: "My Home",
                                isOnImage: "house",
                                isOffImage: "house",
                                isOn: true) {
                print("Tapped")
            }
        }
    }
}
