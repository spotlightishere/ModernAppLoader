//
//  BBDevice.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-01.
//

import Foundation
import IOUSBHost
import OSLog

let bbLogger = Logger(subsystem: "space.joscomputing.BBLib", category: "USB")

public struct BBDevice {
    let transport: BBTransport

    init(via interface: IOUSBHostInterface) {
        let configurationDescriptor = interface.configurationDescriptor
        let interfaceDescriptor = interface.interfaceDescriptor
        bbLogger.info("Utilizing interface \(interface) with \(interfaceDescriptor.pointee.bNumEndpoints) endpoints")

//        // Enumerate until we find one bulk read and bulk write endpoint.
//        // We'll begin with nil - the first endpoint descriptor.
//        var endpointDescriptor = IOUSBGetNextEndpointDescriptor(configurationDescriptor, interfaceDescriptor, nil)
//
//        // Iterate until we find one bulk read and bulk write endpoint.
//        while let currentEndpoint = endpointDescriptor {
//            // The docs for this claims that it returns a tEndpointType "indicating the type found".
//            // tIOUSBEndpointType seems to represent the same values.
//            let endpointType = tIOUSBEndpointType(rawValue: UInt32(IOUSBGetEndpointType(currentEndpoint)))
//
//            if endpointType == kIOUSBEndpointTypeBulk {
//                print("Bulk interface @ \(IOUSBGetEndpointAddress(currentEndpoint))")
//            }
//
//            let direction = tIOUSBEndpointDirection(rawValue: UInt32(IOUSBGetEndpointDirection(currentEndpoint)))
//
//            if direction == kIOUSBEndpointDirectionIn {
//                print("Direction: IN")
//            } else if direction == kIOUSBEndpointDirectionOut {
//                print("Direction: OUT")
//            } else {
//                print("Direction: UNKNOWN")
//            }
//
//            // Obtain the next endpoint.
//            // We must cast from IOUSBEndpointDescriptor to IOUSBDescriptorHeader because it expects that.
//            endpointDescriptor = currentEndpoint.withMemoryRebound(to: IOUSBDescriptorHeader.self, capacity: 1) { usbDescriptor in
//                IOUSBGetNextEndpointDescriptor(configurationDescriptor, interfaceDescriptor, usbDescriptor)
//            }
//        }

        // TODO: Properly enumerate endpoints, error handling, etc
        transport = BBTransport(interface: interface, inAddress: 0x82, outAddress: 0x2)!
    }

    public func sendHandshake() async throws {
        print(try await transport.write(Data([0x00, 0x00, 0x18, 0x00, 0x07, 0xFF, 0x00, 0x00, 0x52, 0x49, 0x4D, 0x5F, 0x4A, 0x61, 0x76, 0x61, 0x4C, 0x6F, 0x61, 0x64, 0x65, 0x72, 0x00, 0x00])))
    }
}
