//
//  BBUSB.swift
//
//
//  Created by Spotlight Deveaux on 2023-01-01.
//
import IOKit
import IOUSBHost

public enum BBUSBErrors: Error {
    case kernelError(kern_return_t)
    case noDevicesFound
}

public struct BBUSB {
    let RIM_VENDOR = 0x0FCA
    // There appear to be several product IDs.
    // TODO: Complete list
    let RIM_PRODUCT_IDS = [
        0x8004, // Mass storage disabled
        0x8007, // Mass storage enabled
    ]
    let LOADER_SUB_CLASS = 0x1
    let LOADER_PROTOCOL = 0xFF

    public init() {}

    public func enumerate() throws {
        // In Objective-C, IOUSBHostDevice/IOUSBHostInterface provide a very handy function
        // titled createMatchingDictionary with parameters to specify vendor, product, etc:
        // https://developer.apple.com/documentation/iousbhost/iousbhostinterface/3181699-creatematchingdictionarywithvend?language=objc
        //
        // Unfortunately, Apple decided that this IOUSBHostMatchingPropertyKey-based
        // dictionary method is better, and has marked it as "refined" in Swift despite
        // not having a replacement. This puts us in an unfortunate predicament: we're given
        // no matching property key to limit matching to only USB.
        //
        // It appears that this function simply calls IOServiceMatching with its class
        // name, and then sets properties. We can simply set IOProviderClass to IOUSBHostInterface directly.
        //
        // XXX: If this breaks in future releases of macOS, please check if additional properties are set.
        let searchDictionary: [IOUSBHostMatchingPropertyKey: Any] = [
            .init(rawValue: kIOProviderClassKey): kIOUSBHostInterfaceClassName,
            .vendorID: RIM_VENDOR,
            .productIDArray: RIM_PRODUCT_IDS,
            // idVendor + bInterfaceSubClass + bInterfaceProtocol, per key table in docs linked above
            .interfaceSubClass: LOADER_SUB_CLASS,
            .interfaceProtocol: LOADER_PROTOCOL,
        ]

        // We may have multiple devices available.
        var iterator: io_iterator_t = 0
        let matchResult = IOServiceGetMatchingServices(kIOMainPortDefault, searchDictionary as CFDictionary, &iterator)
        guard matchResult == KERN_SUCCESS else {
            throw BBUSBErrors.kernelError(matchResult)
        }

        // Attempt to create an IOUSBHostInterface for all interfaces.
        var devices: [IOUSBHostInterface] = []
        while true {
            let matchedService = IOIteratorNext(iterator)
            if matchedService == 0 {
                // The iterator has ended (or is invalid).
                break
            }

            let currentInterface = try IOUSBHostInterface(__ioService: matchedService, options: [], queue: .main, interestHandler: nil)
            devices.append(currentInterface)
        }

        if devices.isEmpty {
            throw BBUSBErrors.noDevicesFound
        }

        print("Found \(devices.count) device(s).")
    }
}
