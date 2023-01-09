//
//  File.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-08.
//

import Foundation

// https://stackoverflow.com/a/47764694
private extension ContiguousBytes {
    func object<T>() -> T {
        withUnsafeBytes { $0.load(as: T.self) }
    }
}

/// Bare-bones buffer class to assist with reading in data.
struct PacketBuffer {
    let contents: Data
    var startIndex: Int
    var offset: Int = 0

    init(for contents: Data) {
        self.contents = contents
        startIndex = contents.startIndex
    }

    mutating func read<T>(count: Int) throws -> T {
        if offset + count > contents.count {
            throw BBPacketError.reachedEOF
        }

        let bytes = contents[startIndex + offset ... startIndex + offset + count - 1]
        offset += count

        // https://stackoverflow.com/a/47764694
        return bytes.object()
    }
}

/// Allows implementing a decoder for BlackBerry's USB-based loader protocol.
///
/// Only unkeyed containers may be decoded, solely due to the binary protocol
/// not permitting for key names in any fashion.
class BBPacketDecoder: Decoder {
    // TODO: This should probably be used.
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    var buffer: PacketBuffer
    init(buffer: PacketBuffer) {
        self.buffer = buffer
    }

    init(contents: Data) {
        buffer = PacketBuffer(for: contents)
    }

    func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
        KeyedDecodingContainer(KeyedPacketDecoder<Key>(buffer: buffer))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        PacketDecoder(buffer: buffer)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw BBPacketError.notSupported("Single-value container decoding is not supported.")
    }
}

class PacketDecoder: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int? = 0
    var isAtEnd: Bool = false
    var currentIndex: Int = 0

    var buffer: PacketBuffer
    init(buffer: PacketBuffer) {
        self.buffer = buffer
    }

    func decodeNil() throws -> Bool {
        // This protocol does not appear to allow values to be nil.
        false
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        throw BBPacketError.notImplemented
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw BBPacketError.notImplemented
    }

    func superDecoder() throws -> Decoder {
        throw BBPacketError.notImplemented
    }

    func decode(_: Bool.Type) throws -> Bool {
        throw BBPacketError.notImplemented
    }

    func decode(_: String.Type) throws -> String {
        throw BBPacketError.notImplemented
    }

    func decode(_: Double.Type) throws -> Double {
        throw BBPacketError.notImplemented
    }

    func decode(_: Float.Type) throws -> Float {
        throw BBPacketError.notImplemented
    }

    func decode(_: Int.Type) throws -> Int {
        throw BBPacketError.notSupported("Please specify an exact width for an integer type.")
    }

    func decode(_: Int8.Type) throws -> Int8 {
        try buffer.read(count: 1)
    }

    func decode(_: Int16.Type) throws -> Int16 {
        try buffer.read(count: 2)
    }

    func decode(_: Int32.Type) throws -> Int32 {
        try buffer.read(count: 4)
    }

    func decode(_: Int64.Type) throws -> Int64 {
        try buffer.read(count: 8)
    }

    func decode(_: UInt.Type) throws -> UInt {
        throw BBPacketError.notSupported("Please specify an exact width for an unsigned integer type.")
    }

    func decode(_: UInt8.Type) throws -> UInt8 {
        try buffer.read(count: 1)
    }

    func decode(_: UInt16.Type) throws -> UInt16 {
        try buffer.read(count: 2)
    }

    func decode(_: UInt32.Type) throws -> UInt32 {
        try buffer.read(count: 4)
    }

    func decode(_: UInt64.Type) throws -> UInt64 {
        try buffer.read(count: 8)
    }

    func decode<T>(_: T.Type) throws -> T where T: Decodable {
        let decoder = BBPacketDecoder(buffer: buffer)
        return try T(from: decoder)
    }
}

struct KeyedPacketDecoder<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] = []
    var allKeys: [Key] = []

    let unkeyedDecoder: PacketDecoder
    init(buffer: PacketBuffer) {
        unkeyedDecoder = PacketDecoder(buffer: buffer)
    }

    func contains(_: Key) -> Bool {
        // We have no concept of keys, so we will blindly accept this.
        true
    }

    func decodeNil(forKey _: Key) throws -> Bool {
        // This protocol does not appear to allow values to be nil.
        false
    }

    func decode(_ type: Bool.Type, forKey _: Key) throws -> Bool {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: String.Type, forKey _: Key) throws -> String {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Double.Type, forKey _: Key) throws -> Double {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Float.Type, forKey _: Key) throws -> Float {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Int.Type, forKey _: Key) throws -> Int {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Int8.Type, forKey _: Key) throws -> Int8 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Int16.Type, forKey _: Key) throws -> Int16 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Int32.Type, forKey _: Key) throws -> Int32 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: Int64.Type, forKey _: Key) throws -> Int64 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: UInt.Type, forKey _: Key) throws -> UInt {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: UInt8.Type, forKey _: Key) throws -> UInt8 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: UInt16.Type, forKey _: Key) throws -> UInt16 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: UInt32.Type, forKey _: Key) throws -> UInt32 {
        try unkeyedDecoder.decode(type)
    }

    func decode(_ type: UInt64.Type, forKey _: Key) throws -> UInt64 {
        try unkeyedDecoder.decode(type)
    }

    func decode<T>(_ type: T.Type, forKey _: Key) throws -> T where T: Decodable {
        try unkeyedDecoder.decode(type)
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey _: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        throw BBPacketError.notImplemented
    }

    func nestedUnkeyedContainer(forKey _: Key) throws -> UnkeyedDecodingContainer {
        throw BBPacketError.notImplemented
    }

    func superDecoder() throws -> Decoder {
        throw BBPacketError.notImplemented
    }

    func superDecoder(forKey _: Key) throws -> Decoder {
        throw BBPacketError.notImplemented
    }
}
