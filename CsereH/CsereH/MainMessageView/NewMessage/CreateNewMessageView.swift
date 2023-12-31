//
//  CreateNewMessageView.swift
//  CsereH
//
//  Created by Himanshu Vinchurkar on 03/06/23.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collectionGroup("users")
            .getDocuments {
                documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users:\(error)"
                    print("Failed to fetch users:\(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({
                    snapshot in
                    let user = try? snapshot.data(as: ChatUser.self)
//                    let data = snapshot.data()
//                    let user = ChatUser(data: data)
                    if user?.uid !=
                        FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user!)
                    }
                    
                })
                
//                self.errorMessage = "Fetched users sucessfully"
            }
    }
}


struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) {
                    user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(.label),
                                            lineWidth:2 ))
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                            
                        } .padding(.horizontal)
                        Divider()
                            .padding(.vertical, 8)
                    }

                    
                }
                
            }.navigationTitle("Contacts")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                                
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        //CreateNewMessageView()
        MainMessagesView()
    }
}

