//
//  CoreNFCHelper.swift
//  BenlyWrite
//
//  Created by David Pilarčík on 22. 06. 2024.
//

import Foundation
import CoreNFC
import SimplyNFC

let nfcManager = NFCManager()
let encoder = NFCMessageEncoder()

class NFCMessageEncoder {
    
    func message(with urls: [URL], and texts: [String]) -> NFCNDEFMessage? {
        let payloads = self.payloads(from: urls) + self.payloads(from: texts)
        return (payloads.count > 0) ? NFCNDEFMessage(records: payloads) : nil
    }
    
    // MARK: - Private
    
    private func payloads(from texts: [String]) -> [NFCNDEFPayload] {
        return texts.compactMap { text in
            return NFCNDEFPayload.wellKnownTypeTextPayload(
                string: text,
                locale: Locale(identifier: "En")
            )
        }
    }
    
    private func payloads(from urls: [URL]) -> [NFCNDEFPayload] {
        return urls.compactMap { url in
            return NFCNDEFPayload.wellKnownTypeURIPayload(url: url)
        }
    }
}

func writeToTag(url: String) {
    let convertedUri = URL(string: url)
    
    print("trying to get to write", convertedUri)
    
    nfcManager.write(message: encoder.message(with: [convertedUri!], and: ["  try out benly!"])!) { manager in
        // Session did become active
        manager.setMessage("👀 Place iPhone near the tag to be written on")
    } didDetect: { manager, result in
        switch result {
        case .failure:
            manager.setMessage("👎 Failed to write tag")
        case .success:
            manager.setMessage("🙌 Tag successfully written")
       }
    }

}
