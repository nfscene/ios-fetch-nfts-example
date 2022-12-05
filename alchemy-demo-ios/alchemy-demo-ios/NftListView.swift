//
//  ContentView.swift
//  alchemy-demo-ios
//
//  Created by Amaury WEI on 05.12.22.
//

import SwiftUI

/// Core view of the application
struct NftListView: View {
    /// Stored NFTs list
    @ObservedObject var nftList = NftListViewModel()
    
    /// Example of an ETH wallet address owning multiple NFTs
    static let defaultEthAddress = "0xbe6b5dBBA3d59Fa6a0C3d5bB787aa5D5ee4F535d"
    
    /// ETH wallet address (modified by the ethAddressForm)
    @State private var ethAddress: String = defaultEthAddress
    /// Set to true to dismiss the keyboard from the ETH address TextField
    @FocusState private var ethAddressIsFocused: Bool
    
    var body: some View {
        VStack {
            appTitle
            ethAddressForm
        }
    }
    
    /// Application title
    var appTitle: some View {
        Text("Alchemy Demo iOS")
            .font(.title)
            .fontWeight(.bold)
    }
    
    /// Form to input the ETH address and fetch the NFTs
    var ethAddressForm: some View {
        Form {
            Section {
                TextField(text: $ethAddress, prompt: Text("ETH Address")) {
                    Text("ETH Address")
                }
                .disableAutocorrection(true)
                .focused($ethAddressIsFocused)
            } header: {
                Text("ETH Wallet Address")
            } footer: {
                Text("Enter an ETH wallet address to fetch its NFTs")
            }
            
            Section{
                fetchButton
            }
        }
    }
    
    /// Button to fetch the NFTs
    var fetchButton: some View {
        Button(action: fetchNfts) {
            HStack{
                Spacer()
                Text("Fetch NFTs")
                Spacer()
            }
        }
    }
    
    /// Fetch the NFTs
    func fetchNfts() {
        // Dismiss the keyboard of the ETH Address TextField
        ethAddressIsFocused = false
        nftList.fetchNfts(ethWalletAddress: ethAddress)
    }
    
}

struct NftListView_Previews: PreviewProvider {
    static var previews: some View {
        NftListView()
    }
}
