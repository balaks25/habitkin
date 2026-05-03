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
    @AppStorage("parentPIN") var savedPIN: String = ""
    @AppStorage("isPINSet") var isPINSet: Bool = false
    
    func lock() {
        isUnlocked = false
    }
    
    func unlock() {
        isUnlocked = true
        // Auto-lock after 5 minutes of inactivity
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
            self.isUnlocked = false
        }
    }
    
    func verify(_ pin: String) -> Bool {
        return pin == savedPIN
    }
    
    func setPIN(_ pin: String) {
        savedPIN = pin
        isPINSet = true
        isUnlocked = true
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
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Number Pad
                    PINPad(
                        enteredPIN: $enteredPIN,
                        theme: theme,
                        onComplete: { pin in
                            verifyPIN(pin)
                        }
                    )
                } else {
                    // No PIN set yet - show setup button
                    Button(action: { showSetPIN = true }) {
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
    }
    
    private func verifyPIN(_ pin: String) {
        if session.verify(pin) {
            session.unlock()
            onSuccess()
        } else {
            errorMessage = "Incorrect PIN. Try again."
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
    }
    
    private func tapKey(_ key: String) {
        guard enteredPIN.count < 4 else { return }
        enteredPIN += key
        if enteredPIN.count == 4 {
            onComplete(enteredPIN)
        }
    }
    
    private func deleteLast() {
        guard !enteredPIN.isEmpty else { return }
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
                session.setPIN(confirmPIN)
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
