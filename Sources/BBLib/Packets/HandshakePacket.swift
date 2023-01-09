//
//  File.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-08.
//

import Foundation

enum HandshakeError: Error {
    case invalidChannel
}

enum HandshakeType: String {
    case javaLoader = "RIM_JavaLoader"
}

struct HandshakeRequest: Codable, Equatable {
    let channel: HandshakeType

    init(channel: HandshakeType) {
        self.channel = channel
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let rawChannel = try container.decode(SixteenCharString.self)
        guard let channelType = HandshakeType(rawValue: rawChannel.description) else {
            throw HandshakeError.invalidChannel
        }
        channel = channelType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        let rawChannel = try SixteenCharString(channel.rawValue)
        try container.encode(rawChannel)
    }
}
