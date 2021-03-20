//
//  Buttons.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/14/20.
//

import SwiftUI

struct Buttons: View {
    
    var text: String
    var imageName: String
    
    var action: () -> Void
    
    
    var body: some View {
        Button(action: action, label: {
            VStack {
                HStack {
                    Spacer()
                        .font(.headline)
                    Text("Request A Skaper")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(width: 200, height: 55, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(
                            ZStack {
                                Color(#colorLiteral(red: 0.4838286638, green: 0.4279839396, blue: 0, alpha: 1))
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .foregroundColor(Color(#colorLiteral(red: 0.4838286638, green: 0.4279839396, blue: 0, alpha: 1)))
                                    .blur(radius: 4)
                                    .offset(x: -8, y: -8)
                                
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4838286638, green: 0.4279839396, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.6772785783, green: 0.5913377404, blue: 0, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .padding(2)
                                    .blur(radius: 2)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), radius: 30, x: 20, y: 20)
                        .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 20, x: -20, y: -20)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
            .edgesIgnoringSafeArea(.all)
        } )
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons(text: "Request A Skaper", imageName: "plus") {
            //
        }
            .padding(.bottom, -200)
    }
}
