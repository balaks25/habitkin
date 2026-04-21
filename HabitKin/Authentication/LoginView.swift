import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct LoginView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Welcome to HabitKin")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding()

                // Apple Sign-In Button
                SignInWithAppleButton(
                    onRequest: { request in
                        // Configure the Sign In request
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        // Handle the Sign In result
                        switch result {
                        case .success(let authResults):
                            // Handle success
                            print(authResults)
                        case .failure(let error):
                            // Handle error
                            print(error)
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 200, height: 44)
                .padding()

                // Google Sign-In Button
                Button(action: {
                    GIDSignIn.sharedInstance.signIn(with: GIDSignIn.sharedInstance,.currentUser) { user, error in
                        if let error = error {
                            // Handle error
                            print(error.localizedDescription)
                        } else {
                            // Handle successful sign in
                            guard let idToken = user?.authentication.idToken else { return }
                            print("Google User signed in: \(idToken)")
                        }
                    }
                }) {
                    Text("Sign in with Google")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}