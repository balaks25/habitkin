//
//  AuthScreen.swift
//  habitkin
//
//  Created by Balaji K S on 03/05/26.
//

import SwiftUI
import AuthenticationServices

// MARK: - Auth Flow Container
struct AuthView: View {
    let onSignedIn: () -> Void
    @State private var screen: AuthScreen = .landing

    enum AuthScreen { case landing, signIn, signUp }

    var body: some View {
        ZStack {
            switch screen {
            case .landing:
                AuthLandingView(onSignIn: { screen = .signIn }, onSignUp: { screen = .signUp })
                    .transition(.opacity)
            case .signIn:
                SignInView(onBack: { screen = .landing }, onSignedIn: onSignedIn, onGoToSignUp: { screen = .signUp })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .signUp:
                SignUpView(onBack: { screen = .landing }, onSignedUp: onSignedIn, onGoToSignIn: { screen = .signIn })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
    }
}

// MARK: - Shared Background
struct AuthBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "#07071A").ignoresSafeArea()

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#6C3FF5").opacity(0.35), Color.clear],
                    center: .center, startRadius: 0, endRadius: 220
                ))
                .frame(width: 440, height: 440)
                .offset(x: -80, y: -280)
                .blur(radius: 10)

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "#2563EB").opacity(0.2), Color.clear],
                    center: .center, startRadius: 0, endRadius: 180
                ))
                .frame(width: 360, height: 360)
                .offset(x: 130, y: 320)
                .blur(radius: 10)
        }
    }
}

// MARK: - Logo
struct HabitKinLogo: View {
    enum LogoSize { case small, medium, large }
    var size: LogoSize = .medium

    var iconSize: CGFloat    { size == .small ? 28 : size == .medium ? 42 : 60 }
    var containerSize: CGFloat { size == .small ? 52 : size == .medium ? 78 : 108 }
    var titleFont: Font      { size == .small ? .title3 : size == .medium ? .title2 : .largeTitle }

    var body: some View {
        VStack(spacing: size == .large ? 16 : 10) {
            ZStack {
                RoundedRectangle(cornerRadius: containerSize * 0.28)
                    .fill(LinearGradient(
                        colors: [Color(hex: "#7C3AED"), Color(hex: "#4F46E5")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: containerSize, height: containerSize)
                    .shadow(color: Color(hex: "#6C3FF5").opacity(0.6), radius: 20, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: iconSize * 0.5, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.25))
                    .offset(x: iconSize * 0.26, y: -iconSize * 0.28)

                Image(systemName: "hare.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 3) {
                Text("HabitKin")
                    .font(titleFont)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(
                        colors: [Color.white, Color(hex: "#C4B5FD")],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .tracking(size == .large ? 1.5 : 0.5)

                if size == .large {
                    Text("Raise · Reward · Repeat")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#A78BFA").opacity(0.7))
                        .tracking(2.5)
                        .textCase(.uppercase)
                }
            }
        }
    }
}

// MARK: - Landing
struct AuthLandingView: View {
    let onSignIn: () -> Void
    let onSignUp: () -> Void

    var body: some View {
        ZStack {
            AuthBackground()

            VStack(spacing: 0) {
                Spacer()

                HabitKinLogo(size: .large)

                Text("Turn everyday habits into\na magical adventure")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.top, 14)

                Spacer()

                // Decorative icon strip
                HStack(spacing: 16) {
                    ForEach(["hare.fill", "star.fill", "sparkles", "flame.fill", "heart.fill"], id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#7C3AED").opacity(0.45))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "#7C3AED").opacity(0.08))
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 48)

                VStack(spacing: 12) {
                    Button(action: onSignUp) {
                        Text("Get Started — It's Free")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(LinearGradient(
                                colors: [Color(hex: "#7C3AED"), Color(hex: "#4F46E5")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(14)
                            .shadow(color: Color(hex: "#6C3FF5").opacity(0.45), radius: 18, y: 8)
                    }

                    Button(action: onSignIn) {
                        Text("I already have an account")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#A78BFA"))
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color(hex: "#7C3AED").opacity(0.1))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "#7C3AED").opacity(0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Sign In
struct SignInView: View {
    let onBack: () -> Void
    let onSignedIn: () -> Void
    let onGoToSignUp: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""

    var canSubmit: Bool { !email.isEmpty && password.count >= 6 }

    var body: some View {
        ZStack {
            AuthBackground()

            VStack(spacing: 0) {
                AuthNavBar(onBack: onBack)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HabitKinLogo(size: .small)
                            .padding(.top, 24)
                            .padding(.bottom, 32)

                        VStack(spacing: 6) {
                            Text("Welcome back")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            Text("Sign in to continue your journey")
                                .font(.subheadline).foregroundColor(Color.white.opacity(0.4))
                        }
                        .padding(.bottom, 36)

                        // Social buttons
                        VStack(spacing: 12) {
                            SocialButton(label: "Continue with Apple",   icon: "apple.logo",  gradient: nil,              action: onSignedIn)
                            SocialButton(label: "Continue with Google",  icon: nil,           gradient: nil,              action: onSignedIn, isGoogle: true)
                        }
                        .padding(.horizontal, 24)

                        AuthDivider()

                        // Fields
                        VStack(spacing: 14) {
                            AuthField(icon: "envelope.fill",   placeholder: "Email address",        text: $email,    isSecure: false, keyboardType: .emailAddress)
                            AuthField(icon: "lock.fill",       placeholder: "Password",              text: $password, isSecure: !showPassword, showToggle: true, showPassword: $showPassword)

                            if !errorMessage.isEmpty { AuthErrorBanner(message: errorMessage) }

                            HStack {
                                Spacer()
                                Button("Forgot password?") {}
                                    .font(.caption).foregroundColor(Color(hex: "#A78BFA"))
                            }
                        }
                        .padding(.horizontal, 24)

                        AuthPrimaryButton(label: "Sign In", isLoading: isLoading, isEnabled: canSubmit, action: signIn)
                            .padding(.horizontal, 24).padding(.top, 20)

                        AuthSwitchRow(prompt: "Don't have an account?", actionLabel: "Sign up", action: onGoToSignUp)
                            .padding(.top, 20).padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private func signIn() {
        isLoading = true; errorMessage = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { isLoading = false; onSignedIn() }
    }
}

// MARK: - Sign Up
struct SignUpView: View {
    let onBack: () -> Void
    let onSignedUp: () -> Void
    let onGoToSignIn: () -> Void

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var agreedToTerms = false
    @State private var isLoading = false
    @State private var errorMessage = ""

    var canSubmit: Bool { !fullName.isEmpty && !email.isEmpty && password.count >= 6 && agreedToTerms }

    var body: some View {
        ZStack {
            AuthBackground()

            VStack(spacing: 0) {
                AuthNavBar(onBack: onBack)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HabitKinLogo(size: .small)
                            .padding(.top, 24)
                            .padding(.bottom, 32)

                        VStack(spacing: 6) {
                            Text("Create account")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            Text("Start your child's magical journey")
                                .font(.subheadline).foregroundColor(Color.white.opacity(0.4))
                        }
                        .padding(.bottom, 36)

                        VStack(spacing: 12) {
                            SocialButton(label: "Continue with Apple",  icon: "apple.logo", action: onSignedUp)
                            SocialButton(label: "Continue with Google", icon: nil,          action: onSignedUp, isGoogle: true)
                        }
                        .padding(.horizontal, 24)

                        AuthDivider()

                        VStack(spacing: 14) {
                            AuthField(icon: "person.fill",    placeholder: "Full name",              text: $fullName,  isSecure: false)
                            AuthField(icon: "envelope.fill",  placeholder: "Email address",          text: $email,     isSecure: false, keyboardType: .emailAddress)
                            AuthField(icon: "lock.fill",      placeholder: "Password (min 6 chars)", text: $password,  isSecure: !showPassword, showToggle: true, showPassword: $showPassword)

                            if !errorMessage.isEmpty { AuthErrorBanner(message: errorMessage) }
                        }
                        .padding(.horizontal, 24)

                        // Terms
                        Button(action: { agreedToTerms.toggle() }) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(agreedToTerms ? Color(hex: "#7C3AED") : Color.clear)
                                        .frame(width: 22, height: 22)
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(agreedToTerms ? Color(hex: "#7C3AED") : Color.white.opacity(0.2), lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    if agreedToTerms {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                Group {
                                    Text("I agree to the ").foregroundColor(Color.white.opacity(0.4))
                                    + Text("Terms of Service").foregroundColor(Color(hex: "#A78BFA"))
                                    + Text(" and ").foregroundColor(Color.white.opacity(0.4))
                                    + Text("Privacy Policy").foregroundColor(Color(hex: "#A78BFA"))
                                }
                                .font(.caption)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        AuthPrimaryButton(label: "Create Account", isLoading: isLoading, isEnabled: canSubmit, action: signUp)
                            .padding(.horizontal, 24).padding(.top, 20)

                        AuthSwitchRow(prompt: "Already have an account?", actionLabel: "Sign in", action: onGoToSignIn)
                            .padding(.top, 20).padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private func signUp() {
        isLoading = true; errorMessage = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { isLoading = false; onSignedUp() }
    }
}

// MARK: - Reusable Auth Components

struct AuthNavBar: View {
    let onBack: () -> Void
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#A78BFA"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "#7C3AED").opacity(0.1))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var showToggle: Bool = false
    var showPassword: Binding<Bool> = .constant(false)
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(text.isEmpty ? Color.white.opacity(0.25) : Color(hex: "#A78BFA"))
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                        .disableAutocorrection(true)
                }
            }
            .font(.body)
            .foregroundColor(.white)

            if showToggle {
                Button(action: { showPassword.wrappedValue.toggle() }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color.white.opacity(0.25))
                        .font(.system(size: 16))
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(text.isEmpty ? Color.white.opacity(0.08) : Color(hex: "#7C3AED").opacity(0.5), lineWidth: 1))
    }
}

struct SocialButton: View {
    let label: String
    var icon: String?
    var gradient: LinearGradient? = nil
    let action: () -> Void
    var isGoogle: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isGoogle {
                    Text("G")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(hex: "#EA4335"), Color(hex: "#4285F4")],
                            startPoint: .top, endPoint: .bottom
                        ))
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text(label)
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color.white.opacity(isGoogle ? 0.06 : 0.08))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct AuthDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            Text("or").font(.caption).foregroundColor(Color.white.opacity(0.3))
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
}

struct AuthPrimaryButton: View {
    let label: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(label).font(.headline).fontWeight(.bold).foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                isEnabled
                ? LinearGradient(colors: [Color(hex: "#7C3AED"), Color(hex: "#4F46E5")], startPoint: .leading, endPoint: .trailing)
                : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(14)
            .shadow(color: isEnabled ? Color(hex: "#6C3FF5").opacity(0.35) : Color.clear, radius: 16, y: 6)
        }
        .disabled(!isEnabled || isLoading)
    }
}

struct AuthSwitchRow: View {
    let prompt: String
    let actionLabel: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(prompt).font(.subheadline).foregroundColor(Color.white.opacity(0.4))
            Button(actionLabel, action: action)
                .font(.subheadline).fontWeight(.semibold).foregroundColor(Color(hex: "#A78BFA"))
        }
    }
}

struct AuthErrorBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14)).foregroundColor(Color(hex: "#EF4444"))
            Text(message).font(.caption).foregroundColor(Color(hex: "#EF4444"))
            Spacer()
        }
        .padding(12)
        .background(Color(hex: "#EF4444").opacity(0.1))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#EF4444").opacity(0.2), lineWidth: 1))
    }
}

#Preview("Landing") { AuthView(onSignedIn: {}) }
#Preview("Sign In") { SignInView(onBack: {}, onSignedIn: {}, onGoToSignUp: {}) }
#Preview("Sign Up") { SignUpView(onBack: {}, onSignedUp: {}, onGoToSignIn: {}) }
