//
//  BBTransport.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-01.
//

import Foundation
import IOUSBHost
import OSLog

public enum BBTransportError: Error {
    case insufficientWrite
    case writeTransport(IOReturn)
    case readTransport(IOReturn)
    case insufficientRead
}

public struct BBTransport {
    let inPipe: IOUSBHostPipe
    let outPipe: IOUSBHostPipe
    let minimumReadSize: Int

    let logger = Logger(subsystem: "space.joscomputing.BBLib", category: "Transport")

    init?(interface: IOUSBHostInterface, inAddress: Int, outAddress: Int) {
        do {
            inPipe = try interface.copyPipe(withAddress: inAddress)
            outPipe = try interface.copyPipe(withAddress: outAddress)
            minimumReadSize = Int(inPipe.descriptors.pointee.descriptor.wMaxPacketSize)
        } catch let e {
            print(e)
            return nil
        }
    }

    public func write(_ data: Data) async throws -> Data {
        // Write...
        logger.trace("Writing to BlackBerry: \(data.hex())")
        let writeRequest = NSMutableData(data: data)
        let (writeResult, writeAmount) = try await outPipe.enqueueIORequest(with: writeRequest, completionTimeout: 5)
        guard writeResult == kIOReturnSuccess else {
            throw BBTransportError.writeTransport(writeResult)
        }
        guard writeAmount == data.count else {
            throw BBTransportError.insufficientWrite
        }
        logger.trace("Wrote \(writeAmount) bytes to BlackBerry.")

        // Finally, read back.
        logger.trace("Beginning to read from BlackBerry...")
        let responseData = NSMutableData(length: Int(inPipe.descriptors.pointee.descriptor.wMaxPacketSize))!
        let (readResult, readAmount) = try await inPipe.enqueueIORequest(with: responseData, completionTimeout: 5)
        guard readResult == kIOReturnSuccess else {
            throw BBTransportError.readTransport(readResult)
        }

        // We need to cut down the response to the read amount.
        guard minimumReadSize >= readAmount else {
            throw BBTransportError.insufficientRead
        }
        let response = responseData.subdata(with: NSRange(0 ... readAmount))
        logger.trace("Read from BlackBerry: \(response.hex())")

        return response
    }
}

extension Data {
    func hex() -> String {
        map { String(format: "%02hx", $0) }.joined()
    }
}
