//
//  PacketDecoderTests.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-07.
//

@testable import BBLib
import XCTest

final class BBLibTests: XCTestCase {
    func testHandshakeDecode() throws {
        let handshake = Data([0x00, 0x00, 0x18, 0x00, 0x07, 0xFF, 0x00, 0x00, 0x52, 0x49, 0x4D, 0x5F, 0x4A, 0x61, 0x76, 0x61, 0x4C, 0x6F, 0x61, 0x64, 0x65, 0x72, 0x00, 0x00])

        let decoder = BBPacketDecoder(contents: handshake)
        let parsedPacket = try BBPacket<HandshakeRequest>(from: decoder)

        // This packet should be:
        // - Unknown of zero
        XCTAssertEqual(parsedPacket.unknown, 0)
        // - 0x18 in length
        XCTAssertEqual(parsedPacket.packetLength, 0x18)
        // - Type of 0x7
        XCTAssertEqual(parsedPacket.packetType, 7)
        // - Unknown of 0xFF
        XCTAssertEqual(parsedPacket.unknown2, 0xFF)
        // - Sequence of 0
        XCTAssertEqual(parsedPacket.sequence, 0)

        // Lastly, the parsed handshake should be correct.
        let parsedHandshake = parsedPacket.packetContents
        let expectedHandshake = HandshakeRequest(channel: .javaLoader)
        XCTAssertEqual(parsedHandshake, expectedHandshake)
    }
}
