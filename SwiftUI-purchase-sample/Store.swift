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
    private var fetchedProducts = [SKProduct]()
    private var fetchCompleteHandler: FetchCompleteHandler?
    private var purchasesCompleteHandler: PurchasesCompleteHandler?
    
    override init() {
        super.init()
        startObservingPayment()
        fetchProducts { products in
            self.allBooks = products.map { Books(product: $0) }
            
        }
    }
    
    private func startObservingPayment() {
        SKPaymentQueue.default().add(self)
    }
    
    private func fetchProducts(_ completion: @escaping FetchCompleteHandler) {
        guard self.productsRequest == nil else { return }
        fetchCompleteHandler = completion
        productsRequest = SKProductsRequest(productIdentifiers: allIdendifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    private func buy(_ product: SKProduct, completion: @escaping PurchasesCompleteHandler) {
        purchasesCompleteHandler = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension Store: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let loadedProducts = response.products
        let invalidProducts = response.invalidProductIdentifiers
        
        guard !loadedProducts.isEmpty else {
            print("can't load the products")
            if !invalidProducts.isEmpty {
                print("invalid products found: \(invalidProducts)")
            }
            productsRequest = nil
            return
        }
        
        fetchedProducts = loadedProducts
        DispatchQueue.main.async {
            self.fetchCompleteHandler?(loadedProducts)
            self.fetchCompleteHandler = nil
            self.productsRequest = nil
        }
    }
}

extension Store: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            var finishTransaction = false
            
            switch transaction.transactionState {
                
                case .purchased, .restored:
                    completeedPurchases.append(transaction.payment.productIdentifier)
                    finishTransaction = true
                case .failed:
                    finishTransaction = true
                case .deferred, .purchasing:
                    break;
                @unknown default:
                    break;
                }
            
            if finishTransaction {
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.purchasesCompleteHandler?(transaction)
                    self.purchasesCompleteHandler = nil
                }
                
            }
        }
    }
}

extension Store {
    func product(for identifier: String) -> SKProduct? {
        return fetchedProducts.first(where: { $0.productIdentifier == identifier })
    }
    
    func purchaseProduct(product: SKProduct) {
        startObservingPayment()
        buy(product) { _ in }
    }
    
    func restorePurchase() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
