//
//  ParentSession.swift
//  habitkin
//
//  Created by Balaji K S on 03/05/26.
//


import SwiftUI
import Combine

// Shared state to track if parent is currently unlocked
class ParentSession: ObservableObject {
    static let shared = ParentSession()

    @Published var isUnlocked = false
    @Published private(set) var isPINSet: Bool

    /// Wrong attempts before the pad is refused for a while, so a child can't
    /// simply try all 10,000 combinations.
    static let maxAttempts = 5
    private static let lockoutSeconds: TimeInterval = 300

    @Published private(set) var failedAttempts = 0
    @Published private(set) var lockedOutUntil: Date?

    /// The PIN lives in the Keychain, not UserDefaults — a 4-digit parental
    /// control in an unencrypted backup isn't a control.
    private var savedPIN: String? {
        KeychainStore.get(KeychainStore.Key.parentPIN)
    }

    private var autoLockTask: DispatchWorkItem?

    private init() {
        isPINSet = KeychainStore.get(KeychainStore.Key.parentPIN) != nil
    }

    var isLockedOut: Bool {
        guard let until = lockedOutUntil else { return false }
        return until > Date()
    }

    var lockoutRemaining: Int {
        guard let until = lockedOutUntil else { return 0 }
        return max(0, Int(until.timeIntervalSinceNow.rounded(.up)))
    }

    /// Drives the lockout countdown. Published so the gate re-renders each tick
    /// instead of freezing on the first value it read.
    @Published private(set) var tick = 0

    private var countdownTimer: Timer?

    private func startCountdown() {
        countdownTimer?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.tick += 1
            if !self.isLockedOut {
                timer.invalidate()
                self.countdownTimer = nil
                self.lockedOutUntil = nil
            }
        }
        countdownTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func lock() {
        autoLockTask?.cancel()
        autoLockTask = nil
        isUnlocked = false
    }

    func unlock() {
        isUnlocked = true
        failedAttempts = 0
        lockedOutUntil = nil
        scheduleAutoLock()
    }

    /// Restarts the idle timer. Called whenever the parent does something, so
    /// an active parent isn't logged out mid-edit.
    func extendSession() {
        guard isUnlocked else { return }
        scheduleAutoLock()
    }

    func verify(_ pin: String) -> Bool {
        guard !isLockedOut else { return false }
        guard let savedPIN, pin == savedPIN else {
            failedAttempts += 1
            if failedAttempts >= Self.maxAttempts {
                lockedOutUntil = Date().addingTimeInterval(Self.lockoutSeconds)
                failedAttempts = 0
                startCountdown()
            }
            return false
        }
        return true
    }

    /// Returns false if the Keychain write failed. Assuming success here left
    /// `isPINSet == true` with no stored PIN, so every later attempt failed and
    /// the parent was locked out of a PIN they had just chosen.
    @discardableResult
    func setPIN(_ pin: String) -> Bool {
        guard KeychainStore.set(pin, for: KeychainStore.Key.parentPIN),
              KeychainStore.get(KeychainStore.Key.parentPIN) == pin else {
            isPINSet = KeychainStore.get(KeychainStore.Key.parentPIN) != nil
            return false
        }
        isPINSet = true
        unlock()
        return true
    }

    /// Clears the PIN so a new one can be set. Gated on re-entering the account
    /// password — see `ParentReauthSheet`.
    func clearPINForReset() {
        KeychainStore.remove(KeychainStore.Key.parentPIN)
        isPINSet = false
        failedAttempts = 0
        lockedOutUntil = nil
    }

    /// Clears the PIN along with the session — used on sign-out and account
    /// deletion so the next parent on this device isn't gated by an old PIN.
    func reset() {
        KeychainStore.remove(KeychainStore.Key.parentPIN)
        isPINSet = false
        failedAttempts = 0
        lockedOutUntil = nil
        lock()
    }

    private func scheduleAutoLock() {
        autoLockTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.isUnlocked = false
        }
        autoLockTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.lockoutSeconds, execute: task)
    }
}

// MARK: - Parent Gate View (PIN Entry)
struct ParentGateView: View {
    let theme: AppTheme
    let onSuccess: () -> Void
    let onDismiss: () -> Void
    
    @State private var enteredPIN = ""
    @State private var shakeError = false
    @State private var errorMessage = ""
    @State private var showSetPIN = false
    @State private var showReauth = false
    @StateObject private var session = ParentSession.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: theme.secondaryColor),
                    Color(hex: theme.secondaryColor).opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Lock Icon
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: theme.primaryColor).opacity(0.15))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: session.isPINSet ? "lock.shield.fill" : "lock.open.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                    }
                    
                    Text("Parent Zone")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(session.isPINSet ? "Enter your PIN to continue" : "Set up a PIN to protect parent controls")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                if session.isPINSet {
                    // PIN Dots Display
                    HStack(spacing: 20) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < enteredPIN.count ? Color(hex: theme.primaryColor) : Color.white.opacity(0.2))
                                .frame(width: 18, height: 18)
                        }
                    }
                    .offset(x: shakeError ? -10 : 0)
                    .animation(shakeError ? .default.repeatCount(3, autoreverses: true).speed(5) : .default, value: shakeError)
                    
                    // Lockout wins over the transient "wrong PIN" text, and
                    // stays on screen for as long as the lockout lasts.
                    if session.isLockedOut {
                        Text("Too many attempts. Try again in \(session.lockoutRemaining)s.")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Number Pad
                    PINPad(
                        enteredPIN: $enteredPIN,
                        theme: theme,
                        isDisabled: session.isLockedOut,
                        onComplete: { pin in
                            verifyPIN(pin)
                        }
                    )

                    Button("Forgot PIN?") { showReauth = true }
                        .font(.caption)
                        .foregroundColor(Color(hex: theme.primaryColor))
                } else {
                    // First-time setup needs the account password. Without this
                    // gate any child could invent their own PIN and walk into
                    // the destructive actions behind it.
                    Button(action: { showReauth = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "key.fill")
                            Text("Set Up Parent PIN")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color(hex: theme.primaryColor))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)

                    Text("You'll confirm your account password first.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showSetPIN) {
            SetPINView(theme: theme, onComplete: {
                showSetPIN = false
                onSuccess()
            })
        }
        .sheet(isPresented: $showReauth) {
            ParentReauthSheet(theme: theme) {
                session.clearPINForReset()
                showReauth = false
                showSetPIN = true
            }
        }
    }
    
    private func verifyPIN(_ pin: String) {
        guard !session.isLockedOut else { enteredPIN = ""; return }
        if session.verify(pin) {
            session.unlock()
            onSuccess()
        } else {
            errorMessage = session.isLockedOut
                ? "Too many attempts. Try again in \(session.lockoutRemaining)s."
                : "Incorrect PIN. Try again."
            shakeError = true
            enteredPIN = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeError = false
                errorMessage = ""
            }
        }
    }
}

// MARK: - Number Pad
struct PINPad: View {
    @Binding var enteredPIN: String
    let theme: AppTheme
    var isDisabled: Bool = false
    let onComplete: (String) -> Void
    
    let rows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(row, id: \.self) { key in
                        if key == "" {
                            Spacer()
                                .frame(width: 72, height: 72)
                        } else if key == "⌫" {
                            Button(action: { deleteLast() }) {
                                Image(systemName: "delete.left.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                    .frame(width: 72, height: 72)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(36)
                            }
                        } else {
                            Button(action: { tapKey(key) }) {
                                Text(key)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 72, height: 72)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(36)
                            }
                        }
                    }
                }
            }
        }
        .opacity(isDisabled ? 0.35 : 1)
        .allowsHitTesting(!isDisabled)
    }
    
    private func tapKey(_ key: String) {
        guard !isDisabled, enteredPIN.count < 4 else { return }
        enteredPIN += key
        if enteredPIN.count == 4 {
            onComplete(enteredPIN)
        }
    }
    
    private func deleteLast() {
        guard !isDisabled, !enteredPIN.isEmpty else { return }
        enteredPIN.removeLast()
    }
}

// MARK: - Set PIN View
struct SetPINView: View {
    let theme: AppTheme
    let onComplete: () -> Void
    
    @State private var step: SetPINStep = .enter
    @State private var firstPIN = ""
    @State private var confirmPIN = ""
    @State private var shakeError = false
    @State private var errorMessage = ""
    @StateObject private var session = ParentSession.shared
    @Environment(\.dismiss) var dismiss
    
    enum SetPINStep {
        case enter, confirm
    }
    
    var currentPIN: Binding<String> {
        step == .enter ? $firstPIN : $confirmPIN
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: theme.secondaryColor),
                    Color(hex: theme.secondaryColor).opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(Color(hex: theme.primaryColor))
                        .frame(width: 90, height: 90)
                        .background(Color(hex: theme.primaryColor).opacity(0.15))
                        .clipShape(Circle())
                    
                    Text(step == .enter ? "Create Parent PIN" : "Confirm PIN")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(step == .enter ? "Choose a 4-digit PIN only you know" : "Enter the same PIN again")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        let pin = step == .enter ? firstPIN : confirmPIN
                        Circle()
                            .fill(index < pin.count ? Color(hex: theme.primaryColor) : Color.white.opacity(0.2))
                            .frame(width: 18, height: 18)
                    }
                }
                .offset(x: shakeError ? -10 : 0)
                .animation(shakeError ? .default.repeatCount(3, autoreverses: true).speed(5) : .default, value: shakeError)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                PINPad(
                    enteredPIN: currentPIN,
                    theme: theme,
                    onComplete: { pin in
                        handlePINEntry(pin)
                    }
                )
                
                Spacer()
            }
        }
    }
    
    private func handlePINEntry(_ pin: String) {
        if step == .enter {
            step = .confirm
        } else {
            if confirmPIN == firstPIN {
                guard session.setPIN(confirmPIN) else {
                    errorMessage = "Couldn't save your PIN securely. Please try again."
                    confirmPIN = ""
                    firstPIN = ""
                    step = .enter
                    return
                }
                onComplete()
            } else {
                errorMessage = "PINs don't match. Try again."
                shakeError = true
                confirmPIN = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    shakeError = false
                    step = .enter
                    firstPIN = ""
                    errorMessage = ""
                }
            }
        }
    }
}
