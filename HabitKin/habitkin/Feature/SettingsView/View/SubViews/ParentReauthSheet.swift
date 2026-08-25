//
//  ParentReauthSheet.swift
//  habitkin
//
//  Confirms the account password before a first PIN is set or an existing one
//  is reset. Without it, "Set Up Parent PIN" was self-serve: any child could
//  invent a PIN and walk straight into Delete Account.
//

import SwiftUI

struct ParentReauthSheet: View {
    let theme: AppTheme
    let onVerified: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var password = ""
    @State private var showPassword = false
    @State private var isVerifying = false
    @State private var errorMessage = ""

    private var email: String { ServiceLocator.auth.currentUser?.email ?? "" }

    private var canSubmit: Bool {
        !email.isEmpty && Validators.isValidPassword(password) && !isVerifying
    }

    var body: some View {
        ZStack {
            Color(hex: theme.secondaryColor).ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.white.opacity(0.3))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Color(hex: theme.primaryColor))
                    .frame(width: 88, height: 88)
                    .background(Color(hex: theme.primaryColor).opacity(0.15))
                    .clipShape(Circle())

                VStack(spacing: 8) {
                    Text("Confirm it's you")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Text(email.isEmpty
                         ? "No account is signed in on this device."
                         : "Enter the password for \(email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                if !email.isEmpty {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: theme.primaryColor))
                                .frame(width: 20)

                            Group {
                                if showPassword {
                                    TextField("Account password", text: $password)
                                        .textInputAutocapitalization(.never)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Account password", text: $password)
                                        .textContentType(.password)
                                }
                            }
                            .foregroundColor(.white)
                            .disableAutocorrection(true)

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(Color(hex: "#EF4444"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button(action: verify) {
                            HStack(spacing: 8) {
                                if isVerifying { ProgressView().tint(.white) }
                                Text(isVerifying ? "Checking…" : "Continue")
                                    .font(.headline).fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(canSubmit ? Color(hex: theme.primaryColor) : Color.white.opacity(0.15))
                            .cornerRadius(12)
                        }
                        .disabled(!canSubmit)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
        .presentationDetents([.medium])
    }

    private func verify() {
        isVerifying = true
        errorMessage = ""
        Task {
            do {
                _ = try await ServiceLocator.auth.signIn(email: email, password: password)
                await MainActor.run {
                    isVerifying = false
                    onVerified()
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    password = ""
                    errorMessage = "That password didn't match. Please try again."
                }
            }
        }
    }
}
