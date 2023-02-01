//
//  SwiftUI_purchase_sampleApp.swift
//  SwiftUI-purchase-sample
//
//  Created by masaki on 2023/02/02.
//

import SwiftUI

@main
struct SwiftUI_purchase_sampleApp: App {
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}
