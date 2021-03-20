//
//  StartButton.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/13/20.
//

import SwiftUI

struct StartButton: View {
    
    var text: String
    var imageName: String
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            HStack {
                Spacer()
                Image(systemName: imageName)
                    .font(.headline)
                
                Text(text)
                    .bold()
                    .font(.system(size: 16))
                
                Spacer()
            }
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(7.0)
        } )
    }
}

struct StartButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            StartButton(text: "Request A Skaper", imageName: "mappin.and.ellipse") {
                
            }
        }
    }
}
