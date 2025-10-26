//
//  OnboardingView.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @StateObject private var progressService = ProgressService.shared
    
    @State private var currentPage = 0
    @State private var selectedLanguages: Set<String> = []
    @State private var selectedGoals: Set<LearningGoal> = []
    @State private var weeklyGoal = 5
    
    private let totalPages = 4
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPage ? primaryColor : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    WelcomePage()
                        .tag(0)
                    
                    // Page 2: Language Selection
                    LanguageSelectionPage(selectedLanguages: $selectedLanguages)
                        .tag(1)
                    
                    // Page 3: Goals Setup
                    GoalsSetupPage(selectedGoals: $selectedGoals, weeklyGoal: $weeklyGoal)
                        .tag(2)
                    
                    // Page 4: Demo Module
                    DemoModulePage()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(primaryColor)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(primaryColor, lineWidth: 2)
                        )
                    }
                    
                    Spacer()
                    
                    Button(currentPage == totalPages - 1 ? "Get Started" : "Next") {
                        if currentPage == totalPages - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(canProceed() ? primaryColor : Color.gray)
                    )
                    .disabled(!canProceed())
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentPage {
        case 0: return true
        case 1: return !selectedLanguages.isEmpty
        case 2: return !selectedGoals.isEmpty
        case 3: return true
        default: return false
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        progressService.updatePreferences(
            selectedLanguages: Array(selectedLanguages),
            learningGoals: Array(selectedGoals),
            onboardingCompleted: true
        )
        
        // Set weekly goal
        progressService.setWeeklyGoal(weeklyGoal)
        
        // Mark onboarding as completed
        onboardingCompleted = true
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon/logo
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 80))
                .foregroundColor(primaryColor)
            
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("LinguaSyncTipi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                
                Text("Your personalized language learning companion")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 20) {
                FeatureRow(icon: "brain.head.profile", title: "Interactive Learning", description: "Engage with real-life scenarios")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Visual insights into your journey")
                FeatureRow(icon: "trophy.fill", title: "Earn Badges", description: "Celebrate your achievements")
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Language Selection Page
struct LanguageSelectionPage: View {
    @Binding var selectedLanguages: Set<String>
    private let primaryColor = Color(hex: "#C80F2E")
    
    private let availableLanguages = [
        ("Spanish", "🇪🇸"),
        ("French", "🇫🇷"),
        ("German", "🇩🇪"),
        ("Italian", "🇮🇹"),
        ("Portuguese", "🇵🇹"),
        ("Japanese", "🇯🇵"),
        ("Korean", "🇰🇷"),
        ("Chinese", "🇨🇳")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Text("Choose Your Languages")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        Text("Select the languages you want to learn. You can always add more later.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(availableLanguages, id: \.0) { language, flag in
                            LanguageCard(
                                language: language,
                                flag: flag,
                                isSelected: selectedLanguages.contains(language)
                            ) {
                                if selectedLanguages.contains(language) {
                                    selectedLanguages.remove(language)
                                } else {
                                    selectedLanguages.insert(language)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

struct LanguageCard: View {
    let language: String
    let flag: String
    let isSelected: Bool
    let action: () -> Void
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(flag)
                    .font(.system(size: 40))
                
                Text(language)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? primaryColor : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goals Setup Page
struct GoalsSetupPage: View {
    @Binding var selectedGoals: Set<LearningGoal>
    @Binding var weeklyGoal: Int
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Text("Set Your Goals")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        Text("Tell us why you want to learn languages and set your weekly target.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why are you learning?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(LearningGoal.allCases, id: \.self) { goal in
                            GoalCard(
                                goal: goal,
                                isSelected: selectedGoals.contains(goal)
                            ) {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Goal")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("I want to complete")
                                .foregroundColor(.secondary)
                            
                            Picker("Weekly Goal", selection: $weeklyGoal) {
                                ForEach(1...20, id: \.self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(primaryColor)
                            
                            Text("lessons per week")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}

struct GoalCard: View {
    let goal: LearningGoal
    let isSelected: Bool
    let action: () -> Void
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: goal.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : primaryColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryColor : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? primaryColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Demo Module Page
struct DemoModulePage: View {
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("Ready to Learn!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                
                Text("Here's a preview of what your learning experience will look like.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            // Demo lesson preview
            VStack(spacing: 20) {
                DemoLessonCard()
                DemoProgressCard()
                DemoBadgeCard()
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct DemoLessonCard: View {
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(primaryColor)
                
                Text("Spanish Basics")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("45 min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text("Learn fundamental Spanish vocabulary and phrases for everyday conversations.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: 0.3)
                .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
            
            Text("3 of 10 lessons completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DemoProgressCard: View {
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(primaryColor)
                
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("3")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    Text("Lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("5")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("2h 15m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    Text("Time Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DemoBadgeCard: View {
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(primaryColor)
                
                Text("Latest Achievement")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading) {
                    Text("First Steps")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Completed your first lesson!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}
