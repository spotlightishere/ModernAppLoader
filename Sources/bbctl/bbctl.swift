//
//  bbctl.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-06.
//

import BBLib
import Foundation

@main
public enum bbctl {
    static func main() async {
        do {
            try await BBUSB().enumerate()
        } catch let e {
            print("Encountered an error: \(e)")
        }
    }
}
