//
//  Store.swift
//  SwiftUI-purchase-sample
//
//  Created by masaki on 2023/02/02.
//

import Foundation
import StoreKit

typealias FetchCompleteHandler = (([SKProduct]) -> Void)
typealias PurchasesCompleteHandler = ((SKPaymentTransaction) -> Void)
class Store: NSObject, ObservableObject {
    
    @Published var allBooks = [Books]()
    
    private let allIdendifiers = Set([
        "com.slothius.store.libro1",
        "com.slothius.store.libro2",
        "com.slothius.store.fullaccess"
    ])
    
    private var completeedPurchases = [String]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for index in self.allBooks.indices {
                    self.allBooks[index].lock = self.completeedPurchases.contains(self.allBooks[index].id)
                }
            }
        }
    }
    
    private var productsRequest: SKProductsRequest?
    private var fetchedProducs = [SKProduct]()
    private var fetchCompleteHandler: FetchCompleteHandler?
    private var purchasesCompleteHandler: PurchasesCompleteHandler?
    
}
