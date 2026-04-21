import Foundation
import FirebaseAuth

class AuthenticationManager {
    static let shared = AuthenticationManager()

    private init() {}

    func signInWithApple(completion: @escaping (Result<User, Error>) -> Void) {
        // Implement Apple ID sign-in process
    }

    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        // Implement Google Sign-In process
    }

    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
}