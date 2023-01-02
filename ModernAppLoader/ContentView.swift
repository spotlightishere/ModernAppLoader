//
//  ContentView.swift
//  ModernAppLoader
//
//  Created by Spotlight Deveaux on 2022-12-31.
//

import BBLib
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .onAppear {
                    do {
                        try BBUSB().enumerate()
                    } catch let e {
                        print("Error: \(e)")
                    }
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
