//
//  SideMenuHeaderView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 1/25/21.
//

import SwiftUI

struct SideMenuHeaderView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image("Skape_Website_Logo")
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding(.bottom, 5)
            
            Text("Ryan Napolitano")
                .font(.system(size: 24, weight: .semibold))
            
            HStack(spacing: 40) {
                HStack(spacing: 4) {
                    Text("Basic User")
                        .font(.system(size: 13, weight: .bold))
                }
                HStack(spacing: 4) {
                    Text("4.97")
                        .font(.system(size: 13, weight: .bold))
                    Image(systemName: "star.fill")
                }
                Spacer()
            }
            
            Spacer()
        }.padding()
    }
}
            
//            VStack(spacing: 20) {
//                HStack {
//                    Text("Messages")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image(systemName: "envelope")
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 243)
//                }
//
//                HStack {
//                    Text("Browse Landskapers")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image("Landscaper Truck 2")
//                        .resizable()
//                        .scaledToFill()
//                        .clipped()
//                        .frame(width: 25, height: 25)
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 142)
//                }
//
//                HStack {
//                    Text("Your Landskapers")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image("Landscaper Truck 2")
//                        .resizable()
//                        .scaledToFill()
//                        .clipped()
//                        .frame(width: 25, height: 25)
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 168)
//                }
//
//                HStack {
//                    Text("skape Rewards")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image(systemName: "gift")
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 198)
//                }
//
//                HStack {
//                    Text("About skape")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image(systemName: "newspaper")
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 221)
//                }
//
//                HStack {
//                    Text("Help")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image(systemName: "exclamationmark.triangle")
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 295)
//                }
//
//                HStack {
//                    Text("Settings")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.black)
//                    Image(systemName: "gear")
//                    Image(systemName: "chevron.right")
//                        .padding(.leading, 260)
//                }
//            }

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView()
    }
}
