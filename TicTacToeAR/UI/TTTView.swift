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
            tapScreenText
            startGameElements
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
                if viewModel.isAdjustBoardPresented {
                    startButton
                        .padding(.trailing)
                }
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
            .background(Color.gray.opacity(0.6))
            .cornerRadius(5)
            .padding(.top, viewModel.isGameOver ? 60 : -60)
            .opacity(viewModel.isGameOver ? 1 : 0)
    }
    
    var tapScreenText: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack{
                Image(systemName: "hand.tap")
                    .font(.system(size: 40))
                    .padding()
                Text("Tap a horizontal surface where you want to place the board")
                    .font(.system(size: 20))
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(5)
            }
                .foregroundColor(.white)
                .padding(.bottom, viewModel.isTapScreenPresented ? 60 : -60)
                .opacity(viewModel.isTapScreenPresented ? 1 : 0)
        }
        .padding(.horizontal, 20)
    }
    
    var startGameElements: some View {
        VStack(spacing: 0) {
            Spacer()
            adjustBoardText
        }
        .padding(.horizontal, 20)
    }
    
    var adjustBoardText: some View {
        VStack {
            Image(systemName: "hand.draw")
                .font(.system(size: 40))
                .padding()
            Text("Resize, rotate, or reposition the board according to your liking. Press start button when you are ready.")
                .font(.system(size: 20))
                .padding()
                .background(Color.gray.opacity(0.6))
                .cornerRadius(5)
        }
        .foregroundColor(.white)
        .padding(.bottom, viewModel.isAdjustBoardPresented ? 60 : -60)
        .opacity(viewModel.isAdjustBoardPresented ? 1 : 0)
    }
    
    var reloadButton: some View {
        Button(action: viewModel.restartGame, label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 25))
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.6))
                .frame(width: 50, height: 50)
                .cornerRadius(5)
                .padding(.top, 60)
        })
    }
    
    var startButton: some View {
        Button(action: viewModel.startGame, label: {
            Image(systemName: "play")
                .font(.system(size: 25))
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.6))
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
