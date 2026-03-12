//
//  NFCReader.swift
//  SOMS
//
//  Created by Dan XD on 3/6/26.
//

import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {

    var session: NFCNDEFReaderSession?

    func startScan() {
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: true)
        session?.alertMessage = "Tap NFC card"
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetectNDEFs messages: [NFCNDEFMessage]) {

        for message in messages {
            for record in message.records {

                let data = record.payload
                let text = String(data: data, encoding: .utf8) ?? ""

                print("NFC Data: \(text)")
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didInvalidateWithError error: Error) {
        print("Session ended")
    }
}
