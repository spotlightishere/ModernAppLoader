//
//  BBPacketCoder.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-06.
//

import Foundation

enum BBPacketError: Error {
    case notSupported(String)
    case notImplemented
    case reachedEOF
}

/// Base packet type for all BlackBerry packets.
/// Used to permit for packet length, type, and sequence coding.
struct BBPacket<T: Codable>: Codable {
    let unknown: UInt16
    let packetLength: UInt16
    let packetType: UInt8
    let unknown2: UInt8
    let sequence: UInt16

    let packetContents: T

    init(from decoder: Decoder) throws {
        // TODO: Is there we can have Codable handle us as a nested container/flatten
        // without needing to overwrite init(from:)/encode(to:)?
        var container = try decoder.unkeyedContainer()
        unknown = try container.decode(UInt16.self)
        packetLength = try container.decode(UInt16.self)
        packetType = try container.decode(UInt8.self)
        unknown2 = try container.decode(UInt8.self)
        sequence = try container.decode(UInt16.self)

        packetContents = try container.decode(T.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(unknown)
        try container.encode(packetLength)
        try container.encode(packetType)
        try container.encode(unknown2)
        try container.encode(sequence)

        try container.encode(packetContents)
    }
}
