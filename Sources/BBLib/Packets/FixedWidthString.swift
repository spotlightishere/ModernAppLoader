//
//  FixedWidthString.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-09.
//

import Foundation

enum FixedWidthError: Error {
    case invalidString
    case tooWide
}

/// As it is tedious to create a fixed-width array in Swift, let alone one regarding CChar,
/// utilize a SixteenCharString to enforce a specific width when decoding or encoding.
struct SixteenCharString: Codable {
    let internalString: [CChar]

    init(_ contents: String) throws {
        guard let cString = contents.cString(using: .ascii) else {
            throw FixedWidthError.invalidString
        }

        if cString.count > 16 {
            throw FixedWidthError.tooWide
        }

        var intermediateString = [CChar](repeating: 0x00, count: 16)
        intermediateString.insert(contentsOf: cString, at: 0)

        internalString = intermediateString
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var building = [CChar](repeating: 0x00, count: 16)
        for i in 0 ... 15 {
            building[i] = try container.decode(CChar.self)
        }
        internalString = building
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0 ... 15 {
            try container.encode(internalString[i])
        }
    }
}

extension SixteenCharString: CustomStringConvertible {
    var description: String {
        String(cString: internalString)
    }
}
