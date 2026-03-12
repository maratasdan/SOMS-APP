//
//  NFCView.swift
//  SOMS
//
//  Created by Dan XD on 3/6/26.
//

import SwiftUI

struct NFCView: View {

    let reader = NFCReader()

    var body: some View {

        VStack(spacing: 20) {

            Image(systemName: "wave.3.right.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Scan NFC Card")
                .font(.title)

            Button("Start Scan") {
                reader.startScan()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

        }
    }
}
