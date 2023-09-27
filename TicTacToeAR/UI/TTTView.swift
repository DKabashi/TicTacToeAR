//
//  TTTView.swift
//  TicTacToeAR
//
//  Created by Donat Kabashi on 8/21/23.
//

import SwiftUI

struct TTTView: View {
    @StateObject var viewModel = TTTViewModel()
    
    var body: some View {
        ZStack {
            TTTARViewRepresentable(viewModel: viewModel)
            topBarElements
        }
        .ignoresSafeArea()
    }
    
    var topBarElements: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 50, height: 50)
                Spacer()
                gameOverText
                Spacer()
                reloadButton
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
        
    var gameOverText: some View {
        Text("Game over!")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding()
            .background(
                Capsule()
                    .fill(Color.gray.opacity(0.4)))
            .padding(.top, viewModel.isGameOver ? 60 : -60)
            .opacity(viewModel.isGameOver ? 1 : 0)
    }
    
    var reloadButton: some View {
        Button(action: viewModel.restartGame, label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 25))
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.4))
                .frame(width: 50, height: 50)
                .cornerRadius(5)
                .padding(.top, 60)
        })
    }
}

struct TTTView_Previews: PreviewProvider {
    static var previews: some View {
        TTTView()
    }
}
