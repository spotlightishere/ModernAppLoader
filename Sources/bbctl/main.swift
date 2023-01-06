//
//  main.swift
//  
//
//  Created by Spotlight Deveaux on 2023-01-06.
//

import BBLib
import Foundation

// TODO: Avoid this entire mess.
let semaphore = DispatchSemaphore(value: 0)

Task {
    do {
        try await BBUSB().enumerate()
    } catch let e {
        print("Encountered an error: \(e)")
    }
    
    semaphore.signal()
}
semaphore.wait()
