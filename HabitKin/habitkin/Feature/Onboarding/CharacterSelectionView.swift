import SwiftUI

struct CharacterSelectionView: View {
    @State private var currentStep = 0 // 0: Name, 1: Age/Avatar, 2: Character, 3: Theme
    @State private var childName = ""
    @State private var selectedAge = 7
    @State private var selectedAvatar = "person.fill"
    @State private var selectedCharacter: Character?
    @State private var selectedTheme: AppTheme?
    
    let avatarOptions = [
        ("person.fill", "Person"),
        ("person.crop.circle.fill", "Circle"),
        ("person.badge.plus.fill", "Plus"),
        ("person.2.fill", "Group"),
        ("figure.wave", "Wave"),
        ("figure.walk", "Walk"),
        ("figure.sit", "Sit"),
        ("figure.stand", "Stand")
    ]
    
    var filteredCharacters: [Character] {
        Character.all.filter { $0.ageRange.contains(selectedAge) }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            AuthBackground()
            
            VStack(spacing: 0) {
                // Progress bar
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color(hex: "#6366F1") : Color.white.opacity(0.2))
                            .frame(height: 4)
                    }
                }
                .padding(20)
                
                // Content
                VStack {
                    if currentStep == 0 {
                        Step0_Name(childName: $childName)
                    } else if currentStep == 1 {
                        Step1_AgeAvatar(selectedAge: $selectedAge, selectedAvatar: $selectedAvatar, avatarOptions: avatarOptions)
                    } else if currentStep == 2 {
                        Step2_Character(filteredCharacters: filteredCharacters, selectedCharacter: $selectedCharacter)
                    } else {
                        Step3_Theme(selectedTheme: $selectedTheme)
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        if currentStep < 3 {
                            currentStep += 1
                        } else {
                            // All steps complete - navigate to home
                            print("✅ Complete: \(childName), Age \(selectedAge), \(selectedAvatar), \(selectedCharacter?.name ?? ""), \(selectedTheme?.name ?? "")")
                        }
                    }) {
                        Text(currentStep == 3 ? "Start Adventure" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#6366F1"))
                            .cornerRadius(12)
                    }
                    .disabled(!isStepValid())
                    .opacity(isStepValid() ? 1 : 0.5)
                }
                .padding(20)
            }
        }
    }
    
    private func isStepValid() -> Bool {
        switch currentStep {
        case 0:
            return !childName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1:
            return true
        case 2:
            return selectedCharacter != nil
        case 3:
            return selectedTheme != nil
        default:
            return false
        }
    }
}

// MARK: - Step 0: Name
struct Step0_Name: View {
    @Binding var childName: String
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Welcome to HabitKin")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Let's create your child's journey")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("What's your child's name?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("Enter name", text: $childName)
                    .padding(16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.words)
                    .accentColor(Color(hex: "#6366F1"))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Step 1: Age & Avatar
struct Step1_AgeAvatar: View {
    @Binding var selectedAge: Int
    @Binding var selectedAvatar: String
    let avatarOptions: [(String, String)]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Age & Avatar")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("How old is your child?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            // Age slider
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Age")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(selectedAge) years")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#6366F1"))
                }
                
                Slider(value: Binding(
                    get: { Double(selectedAge) },
                    set: { selectedAge = Int($0) }
                ), in: 4...10, step: 1)
                .tint(Color(hex: "#6366F1"))
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Avatar selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose Avatar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(avatarOptions, id: \.0) { icon, label in
                        Button(action: { selectedAvatar = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(selectedAvatar == icon ? Color(hex: "#6366F1") : Color.white.opacity(0.7))
                                .frame(height: 70)
                                .frame(maxWidth: .infinity)
                                .background(selectedAvatar == icon ? Color(hex: "#6366F1").opacity(0.15) : Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAvatar == icon ? Color(hex: "#6366F1") : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

// MARK: - Step 2: Character Selection
struct Step2_Character: View {
    let filteredCharacters: [Character]
    @Binding var selectedCharacter: Character?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Choose Character")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("What challenges does your child face?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(filteredCharacters) { character in
                        CharacterOptionCard(
                            character: character,
                            isSelected: selectedCharacter?.id == character.id,
                            action: { selectedCharacter = character }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

struct CharacterOptionCard: View {
    let character: Character
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: character.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color(hex: character.color))
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(character.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: character.color))
                }
            }
            .padding(14)
            .background(isSelected ? Color(hex: character.color).opacity(0.12) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: character.color) : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Step 3: Theme Selection
struct Step3_Theme: View {
    @Binding var selectedTheme: AppTheme?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Choose Your World")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Where will the journey begin?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(AppTheme.all) { theme in
                        ThemeOptionCard(
                            theme: theme,
                            isSelected: selectedTheme?.id == theme.id,
                            action: { selectedTheme = theme }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Image(systemName: theme.icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(Color(hex: theme.primaryColor))
                        .frame(width: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(theme.world)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: theme.primaryColor))
                    }
                }
                
                // Creatures evolution preview
                HStack(spacing: 12) {
                    ForEach(["egg", "hatch", "evolve", "ultimate"], id: \.self) { stage in
                        VStack(spacing: 4) {
                            Image(systemName: theme.creatures[stage])
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text(stage)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .padding(14)
            .background(isSelected ? Color(hex: theme.primaryColor).opacity(0.12) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: theme.primaryColor) : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    CharacterSelectionView()
}
