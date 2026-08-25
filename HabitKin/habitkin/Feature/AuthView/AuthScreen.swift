//
//  AuthScreen.swift
//  habitkin
//
//  Created by Balaji K S on 03/05/26.
//

import SwiftUI

// MARK: - Auth Flow Container
struct AuthView: View {
    /// e.g. "Your session expired." Shown once so a forced sign-out isn't
    /// silent — the parent used to just reappear on the landing screen.
    var notice: String?
    let onSignedIn: () -> Void
    @State private var screen: AuthScreen = .landing

    enum AuthScreen { case landing, signIn, signUp }

    init(notice: String? = nil, onSignedIn: @escaping () -> Void) {
        self.notice = notice
        self.onSignedIn = onSignedIn
        _screen = State(initialValue: notice == nil ? .landing : .signIn)
    }

    var body: some View {
        ZStack {
            switch screen {
            case .landing:
                AuthLandingView(onSignIn: { screen = .signIn }, onSignUp: { screen = .signUp })
                    .transition(.opacity)
            case .signIn:
                SignInView(notice: notice, onBack: { screen = .landing }, onSignedIn: onSignedIn, onGoToSignUp: { screen = .signUp })
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
            .padding(.horizontal)
        }
    }
}

// MARK: - Sign In
struct SignInView: View {
    var notice: String?
    let onBack: () -> Void
    let onSignedIn: () -> Void
    let onGoToSignUp: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var infoMessage = ""
    @State private var isSendingReset = false

    var canSubmit: Bool {
        Validators.isValidEmail(email) && Validators.isValidPassword(password)
    }

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

                        // Fields
                        VStack(spacing: 14) {
                            AuthField(icon: "envelope.fill", placeholder: "Email address", text: $email,
                                      isSecure: false, keyboardType: .emailAddress,
                                      capitalization: .never, contentType: .username,
                                      errorText: Validators.isValidEmail(email) ? nil : "Enter a valid email address.")
                            AuthField(icon: "lock.fill", placeholder: "Password (min \(Validators.minimumPasswordLength) chars)",
                                      text: $password, isSecure: !showPassword,
                                      showToggle: true, showPassword: $showPassword,
                                      capitalization: .never, contentType: .password,
                                      errorText: Validators.isValidPassword(password) ? nil : "At least \(Validators.minimumPasswordLength) characters.")

                            if let notice, errorMessage.isEmpty, infoMessage.isEmpty {
                                AuthInfoBanner(message: notice)
                            }
                            if !errorMessage.isEmpty { AuthErrorBanner(message: errorMessage) }
                            if !infoMessage.isEmpty { AuthInfoBanner(message: infoMessage) }

                            HStack {
                                Spacer()
                                Button(isSendingReset ? "Sending…" : "Forgot password?") {
                                    sendPasswordReset()
                                }
                                .font(.caption)
                                .foregroundColor(Color(hex: "#A78BFA"))
                                .disabled(isSendingReset)
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
            .padding(.horizontal)
        }
    }

    private func sendPasswordReset() {
        guard Validators.isValidEmail(email) else {
            errorMessage = "Enter your email address first, then tap Forgot password."
            return
        }
        isSendingReset = true; errorMessage = ""; infoMessage = ""
        Task {
            do {
                try await ServiceLocator.auth.requestPasswordReset(email: email)
                await MainActor.run {
                    isSendingReset = false
                    // Worded to avoid confirming whether the address is
                    // registered — that would be an enumeration leak.
                    infoMessage = "If that email has an account, a reset link is on its way."
                }
            } catch {
                // A transport failure is a different thing from "we won't say",
                // and the parent needs to know the request never left the device.
                await MainActor.run {
                    isSendingReset = false
                    errorMessage = "Couldn't send the reset email. \(error.localizedDescription)"
                }
            }
        }
    }

    private func signIn() {
        isLoading = true; errorMessage = ""; infoMessage = ""
        Task {
            do {
                _ = try await ServiceLocator.auth.signIn(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                    onSignedIn()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Sign Up
struct SignUpView: View {
    let onBack: () -> Void
    let onSignedUp: () -> Void
    let onGoToSignIn: () -> Void

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var agreedToTerms = false
    @State private var isLoading = false
    @State private var errorMessage = ""

    private var passwordsMatch: Bool { password == confirmPassword }

    var canSubmit: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
            && Validators.isValidEmail(email)
            && Validators.isValidPassword(password)
            && passwordsMatch
            && Validators.isValidPhone(phone)
            && agreedToTerms
    }

    /// Spelled out under the button, so a disabled button is never a dead end.
    private var blockingReason: String? {
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty { return "Enter your name." }
        if !Validators.isValidEmail(email) { return "Enter a valid email address." }
        if !Validators.isValidPhone(phone) { return "That phone number doesn't look right — or leave it blank." }
        if !Validators.isValidPassword(password) { return "Password needs at least \(Validators.minimumPasswordLength) characters." }
        if !passwordsMatch { return "Passwords don't match." }
        if !agreedToTerms { return "Please accept the Terms and Privacy Policy." }
        return nil
    }

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

                        VStack(spacing: 14) {
                            AuthField(icon: "person.fill", placeholder: "Full name", text: $fullName,
                                      isSecure: false, capitalization: .words, contentType: .name,
                                      maxLength: 60)
                            AuthField(icon: "envelope.fill", placeholder: "Email address", text: $email,
                                      isSecure: false, keyboardType: .emailAddress,
                                      capitalization: .never, contentType: .username,
                                      errorText: Validators.isValidEmail(email) ? nil : "Enter a valid email address.")
                            // Optional: guideline 5.1.1(ix) forbids demanding
                            // personal data the app doesn't need to function.
                            AuthField(icon: "phone.fill", placeholder: "Phone number (optional)", text: $phone,
                                      isSecure: false, keyboardType: .phonePad,
                                      capitalization: .never, contentType: .telephoneNumber,
                                      maxLength: 20,
                                      errorText: Validators.isValidPhone(phone) ? nil : "Use 7-15 digits, or leave this blank.")
                            AuthField(icon: "lock.fill", placeholder: "Password (min \(Validators.minimumPasswordLength) chars)",
                                      text: $password, isSecure: !showPassword,
                                      showToggle: true, showPassword: $showPassword,
                                      capitalization: .never, contentType: .newPassword,
                                      errorText: Validators.isValidPassword(password) ? nil : "At least \(Validators.minimumPasswordLength) characters.")
                            AuthField(icon: "lock.rotation", placeholder: "Confirm password",
                                      text: $confirmPassword, isSecure: !showPassword,
                                      capitalization: .never, contentType: .newPassword,
                                      errorText: passwordsMatch ? nil : "Passwords don't match.")

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
                                Text("I agree to the Terms of Service and Privacy Policy")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.4))
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Separate from the checkbox: these used to be styled as
                        // links inside the button, so tapping them just toggled
                        // the box and the documents were unreachable.
                        HStack(spacing: 16) {
                            Link("Terms of Service", destination: LegalLinks.terms)
                            Text("·").foregroundColor(Color.white.opacity(0.25))
                            Link("Privacy Policy", destination: LegalLinks.privacy)
                        }
                        .font(.caption)
                        .foregroundColor(Color(hex: "#A78BFA"))
                        .padding(.top, 10)

                        AuthPrimaryButton(label: "Create Account", isLoading: isLoading, isEnabled: canSubmit, action: signUp)
                            .padding(.horizontal, 24).padding(.top, 20)

                        if let blockingReason, !isLoading {
                            Text(blockingReason)
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.45))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.top, 8)
                        }

                        AuthSwitchRow(prompt: "Already have an account?", actionLabel: "Sign in", action: onGoToSignIn)
                            .padding(.top, 20).padding(.bottom, 40)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func signUp() {
        isLoading = true; errorMessage = ""
        Task {
            do {
                _ = try await ServiceLocator.auth.signUp(
                    name: fullName.trimmingCharacters(in: .whitespaces),
                    email: email,
                    phone: phone.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                await MainActor.run {
                    isLoading = false
                    onSignedUp()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Legal

enum LegalLinks {
    // TODO: point these at the real hosted documents before submitting.
    // App Review requires both to be reachable, and storing data about minors
    // requires a published privacy policy.
    static let terms   = URL(string: "https://habitkin.app/terms")!
    static let privacy = URL(string: "https://habitkin.app/privacy")!
}

// MARK: - Reusable Auth Components

struct AuthInfoBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 13, weight: .semibold))
            Text(message)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .foregroundColor(Color(hex: "#A78BFA"))
        .padding(12)
        .background(Color(hex: "#7C3AED").opacity(0.12))
        .cornerRadius(10)
    }
}

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
    /// Explicit, because deriving it from `keyboardType` silently applied
    /// `.words` to the password field — revealing the password then
    /// capitalised it and the sign-in failed for no visible reason.
    var capitalization: TextInputAutocapitalization = .never
    var contentType: UITextContentType?
    var maxLength: Int = 120
    /// Shown under the field once the user has typed something invalid.
    var errorText: String?

    /// Only complain once they've actually typed something.
    private var visibleError: String? {
        guard let errorText, !text.isEmpty else { return nil }
        return errorText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(text.isEmpty ? Color.white.opacity(0.25) : Color(hex: "#A78BFA"))
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(contentType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(capitalization)
                        .textContentType(contentType)
                        .disableAutocorrection(true)
                }
            }
            .font(.body)
            .foregroundColor(.white)
            .onChange(of: text) { value in
                if value.count > maxLength { text = String(value.prefix(maxLength)) }
            }

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
            .stroke(strokeColor, lineWidth: 1))

            if let visibleError {
                Text(visibleError)
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#EF4444"))
                    .padding(.leading, 4)
            }
        }
    }

    private var strokeColor: Color {
        if visibleError != nil { return Color(hex: "#EF4444").opacity(0.6) }
        return text.isEmpty ? Color.white.opacity(0.08) : Color(hex: "#7C3AED").opacity(0.5)
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
