//
//  ContentView.swift
//  alchemy-demo-ios
//
//  Created by Amaury WEI on 05.12.22.
//

import SwiftUI

/// Core view of the application
struct NftListView: View {
    @Environment(\.openURL) var openURL
    
    /// Stored NFTs list
    @ObservedObject var nftList = NftListViewModel()
    
    /// Example of an ETH wallet address owning multiple NFTs
    static let defaultEthAddress = "0x928c2909847B884ba5Dd473568De6382b028F7b8"
    
    /// ETH wallet address (modified by the ethAddressForm)
    @State private var ethAddress: String = defaultEthAddress
    /// Set to true to dismiss the keyboard from the ETH address TextField
    @FocusState private var ethAddressIsFocused: Bool
    
    /// Set to true to show the NFTs fetching failed alert
    @State private var nftsFetchingFailed = false
    /// Alert message in case the NFTs cannot be fetched
    @State private var nftsFetchingFailedMessage: String = ""
    /// Alert title in case the NFTs cannot be fetched
    let failedFetchingAlertTitle: String = "Failed to fetch NFTs"
    
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
            
            Section {
                fetchButton
            }.disabled(ethAddress.isEmpty)
            
            Section {
                nftsList
            } header: {
                if nftList.nfts.count > 0 {
                    Text("Fetched NFTs: \(nftList.nfts.count)")
                }
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
        }.alert(failedFetchingAlertTitle, isPresented: $nftsFetchingFailed) {
            Button("Dismiss", role: .cancel) {
                nftsFetchingFailed = false
            }
        } message: {
            Text(nftsFetchingFailedMessage)
        }
    }
    
    /// List of fetched NFTs
    var nftsList: some View {
        List{
            ForEach(nftList.nfts) { nft in
                NftView(nft: nft).onTapGesture {
                    openURL(nft.image)
                }
            }
        }
    }
    
    /// Fetch the NFTs
    func fetchNfts() {
        // Dismiss the keyboard of the ETH Address TextField
        ethAddressIsFocused = false
        
        // Create a dedicated Task as fetchNfts() is asynchronous
        Task {
            do {
                try await nftList.fetchNfts(ethWalletAddress: ethAddress)
            } catch FetchNftsError.dummyAlchemyApiKey {
                nftsFetchingFailed = true
                nftsFetchingFailedMessage = "Please update ALCHEMY_API_KEY in NftListViewModel.swift"
            } catch FetchNftsError.invalidUrl {
                nftsFetchingFailed = true
                nftsFetchingFailedMessage = "Invalid ALCHEMY_API_KEY or ETH wallet address"
            } catch FetchNftsError.requestFailed {
                nftsFetchingFailed = true
                nftsFetchingFailedMessage = "Request to Alchemy API failed. Potential causes are: no network, invalid ALCHEMY_API_KEY, invalid ETH wallet address"
            } catch let error {
                nftsFetchingFailed = true
                nftsFetchingFailedMessage = error.localizedDescription
            }
        }
    }
}

struct NftListView_Previews: PreviewProvider {
    static var previews: some View {
        NftListView()
    }
}
