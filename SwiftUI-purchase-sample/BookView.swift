//
//  BookView.swift
//  SwiftUI-purchase-sample
//
//  Created by masaki on 2023/02/02.
//

import SwiftUI
import StoreKit

struct BookView: View {
    
    @EnvironmentObject private var store: Store
    
    var body: some View {
        NavigationView {
            List(store.allBooks, id:\.self) { book in
                Group {
                    if !book.lock {
                        NavigationLink(destination: BookView()) {
                            BookRow(book: book) {}
                        }
                    } else {
                        BookRow(book: book) {
                            if let product = store.product(for: book.id) {
                                store.purchaseProduct(product: product)
                            }
                        }
                    }
                }
            }.navigationTitle("Book Store")
            .toolbar {
                Button("Restore Purchase") {
                    store.restorePurchase()
                }
            }
        }
    }
}

struct BookRow: View {
    
    let book : Books
    let action : () -> Void
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(book.title).font(.title).bold()
                Text(book.description).font(.subheadline).bold()
            }
            Spacer()
            if let price = book.price, book.lock {
                Button(action: action) {
                    Text(price)
                }
            }
        }
    }
}
