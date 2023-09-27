//
//  TTTARViewRepresentable.swift
//  TicTacToeAR
//
//  Created by Donat Kabashi on 8/21/23.
//

import SwiftUI

struct TTTARViewRepresentable: UIViewRepresentable {
    var viewModel: TTTViewModel

    func makeUIView(context: Context) -> TTTARView {
        return TTTARView(viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: TTTARView, context: Context) { }
}

