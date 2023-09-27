//
//  TTTView.swift
//  TicTacToeAR
//
//  Created by Donat Kabashi on 8/21/23.
//

import SwiftUI

struct TTTView: View {
    private let viewModel = TTTViewModel()

    var body: some View {
        ZStack {
            TTTARViewRepresentable(viewModel: viewModel)
            reloadButton
        }
    }
    
    var reloadButton: some View {
        VStack {
            Button(action: viewModel.restartGame, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 25))
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.top, .trailing], 20)
            })
            Spacer()
        }
    }
}

struct TTTView_Previews: PreviewProvider {
    static var previews: some View {
        TTTView()
    }
}
