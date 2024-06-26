//
//  ContentView.swift
//  BenlyWrite
//
//  Created by David Pilarčík on 22. 06. 2024.
//

import SwiftUI
import SwiftData
import CodeScanner

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var ndefmsg = ""
    @State private var lastWrite = "?"
    @State private var lastScan = "?"
    
    @State var isScannerShowing = false

    var body: some View {
        VStack {
            Image(systemName: "apple.cash")
            HStack {
                TextField("$ndefmsg", text: $ndefmsg)
                Button("Get from QR Code", systemImage: "qrcode.viewfinder") { // 􀎻
                    isScannerShowing.toggle()
                }
                .labelStyle(.iconOnly)
                .sheet(isPresented: $isScannerShowing, content: {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "https://benly.sk") { response in
                        switch response {
                        case .success(let result):
                            lastScan = ndefmsg
                            print("Found code: \(result.string)")
                            ndefmsg = result.string
                            isScannerShowing.toggle()
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                })
                Button("Get from Clipboard", systemImage: "doc.on.clipboard") { // 􀎻
                    if let string = UIPasteboard.general.string {
                        ndefmsg = string
                    }
                }
                .labelStyle(.iconOnly)
            }
            
            Button("Write to tag") {
                writeToTag(url: ndefmsg)
                lastWrite = ndefmsg
            }
            .padding()

            Divider()
            
            HStack {
                Text("Last Write")
                Text(lastWrite)
            }
            HStack {
                Text("Last Scan")
                Text(lastScan)
            }
                        
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
