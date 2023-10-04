//
//  TTTARViewRepresentable.swift
//  TicTacToeAR
//
//  Created by Donat Kabashi on 8/21/23.
//

import SwiftUI

struct ARViewRepresentable: UIViewRepresentable {
    var viewModel: TicTacToeViewModel

    func makeUIView(context: Context) -> TicTacToeARView {
        return TicTacToeARView(viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: TicTacToeARView, context: Context) { }
}

