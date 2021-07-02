//
//  ContentView.swift
//  cameraOSF
//
//  Created by Kacper Mocarski on 7/1/21.
//

import SwiftUI
import FirebaseAuth

//handles firebase auth
//signs user in, signs user up, signs user out

class AppViewModel: ObservableObject {
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
        
    }
    
    //signs user in, should segue into different screen but that doesnt work for some reason. If you restart the app it will be on the signed in page
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error != nil else {
                return
            }
            
            DispatchQueue.main.async {
                //success
                self?.signedIn = true
            }
        }
    }
    
    //signs the user up, has the same issue as the function above
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error != nil else {
                return
            }
            
            DispatchQueue.main.async {
                //success
                self?.signedIn = true
            }
        }
    }
    
    //signs the user out
    //this function doesn't have an issue with returning the user back to the correct page
    func signOut() {
        try? auth.signOut()
        
        self.signedIn = false
    }
}

//main home page, where the user inputs his data and signs in.
//no validation implemented yet
struct SignInView: View {
    @State private var cmEmail = ""
    @State private var cmPassword = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
            VStack {
                Spacer()
                
                Text("Login Community Member")
                VStack{
                    TextField("email", text: $cmEmail)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    SecureField("password", text: $cmPassword)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    Button(action: {
                        guard !cmEmail.isEmpty, !cmPassword.isEmpty else {
                            return
                        }
                        
                        viewModel.signIn(email: cmEmail, password: cmPassword)
                        
                        
                    }, label: {
                        Text("Sign In")
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    })
                    .padding()
                
                    NavigationLink("Create new member account", destination: SignUpView())
                        .padding()
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Existing Member")
    }
}

//sign up view, takes the information inputted in the textfields and saves that login info in firebase
struct SignUpView: View {
    @State private var cmEmail = ""
    @State private var cmPassword = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("email", text: $cmEmail)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                SecureField("password", text: $cmPassword)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                Button(action: {
                    guard !cmEmail.isEmpty, !cmPassword.isEmpty else {
                        return
                    }
                    viewModel.signUp(email: cmEmail, password: cmPassword)
                    
                }, label: {
                    Text("Create member account")
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                })
                    
            }
        }
        .navigationTitle("New Community Member")
    }
}


//launch screen.
//if the user is signed in, the profile view is displayed
//if the user is not signed in, the sign in view is displayed
struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.signedIn {
                UserProfileView()
            }
            else {
                SignInView()
            }
        }
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

//page that has the user's info outputted for now.
//this is where I am planning on adding the camera to take a picture and generate the qrcode
//
//initial plan is to take different pictures of different colors, those different colors generate a different qrcode
//that qrcode will have information about a specific SDOH
//(i.e. Green will show Food pantries around the area that distribute free food)
//
//not perfect but I think this might be good to show the team a way to interact with the backend
struct UserProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    let user = Auth.auth().currentUser
    
    var body: some View {
        VStack {
            Text("You are signed in")
            
            Text("Email: \(user!.email!)")
                .padding()
            
            //each user automatically gets their own UID from firebase
            //swift also has a UUID() function that generates its own id, this can be useful to generate the qrcode id's needed to
            //access the qrcode, so it stays private for the user
            Text("UID: \(user!.uid)")
            
            Button(action: {
                viewModel.signOut()
            }, label: {
                Text("Sign out")
                    .foregroundColor(Color.blue)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}


