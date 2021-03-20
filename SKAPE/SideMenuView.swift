//
//  SideMenuView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 1/25/21.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                SideMenuHeaderView()
                    .frame(height: 240)
                
                ForEach(0..<7) { _ in
                    SideMenuOptionView()
                }
                
                Spacer()
            }
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView()
    }
}
