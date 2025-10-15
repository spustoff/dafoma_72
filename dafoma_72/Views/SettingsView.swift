//
//  SettingsView.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var progressService = ProgressService.shared
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    @State private var showingDeleteAlert = false
    @State private var showingLanguageSelection = false
    @State private var showingGoalEditor = false
    @State private var showingReminderPicker = false
    
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                List {
                    // Profile Section
                    ProfileSection()
                    
                    // Learning Preferences
                    LearningPreferencesSection()
                    
                    // App Settings
                    AppSettingsSection()
                    
                    // Data & Privacy
                    DataPrivacySection()
                    
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingLanguageSelection) {
            LanguageSelectionSheet()
        }
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditorSheet()
        }
        .sheet(isPresented: $showingReminderPicker) {
            ReminderPickerSheet()
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete all your progress and data. This action cannot be undone.")
        }
    }
    
    // MARK: - Profile Section
    @ViewBuilder
    private func ProfileSection() -> some View {
        Section {
            HStack(spacing: 16) {
                // Profile picture placeholder
                Circle()
                    .fill(primaryColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(primaryColor)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Language Learner")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Learning \(progressService.userPreferences.selectedLanguages.count) languages")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("\(progressService.userProgress.currentStreak) day streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Learning Preferences
    @ViewBuilder
    private func LearningPreferencesSection() -> some View {
        Section("Learning Preferences") {
            // Selected Languages
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Languages")
                        .foregroundColor(.primary)
                    
                    Text(progressService.userPreferences.selectedLanguages.isEmpty ? 
                         "None selected" : 
                         progressService.userPreferences.selectedLanguages.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Edit") {
                    showingLanguageSelection = true
                }
                .font(.subheadline)
                .foregroundColor(primaryColor)
            }
            
            // Learning Goals
            HStack {
                Image(systemName: "target")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Learning Goals")
                        .foregroundColor(.primary)
                    
                    Text(progressService.userPreferences.learningGoals.isEmpty ? 
                         "None selected" : 
                         progressService.userPreferences.learningGoals.map { $0.rawValue }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button("Edit") {
                    showingGoalEditor = true
                }
                .font(.subheadline)
                .foregroundColor(primaryColor)
            }
            
            // Weekly Goal
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Weekly Goal")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(progressService.userProgress.weeklyGoal) lessons")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Edit") {
                    showingGoalEditor = true
                }
                .font(.subheadline)
                .foregroundColor(primaryColor)
            }
            
            // Daily Reminder
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Daily Reminder")
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let reminderTime = progressService.userPreferences.dailyReminderTime {
                    Text(reminderTime, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Off")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Button("Edit") {
                    showingReminderPicker = true
                }
                .font(.subheadline)
                .foregroundColor(primaryColor)
            }
        }
    }
    
    // MARK: - App Settings
    @ViewBuilder
    private func AppSettingsSection() -> some View {
        Section("App Settings") {
            // Sound Effects
            HStack {
                Image(systemName: "speaker.wave.2")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Sound Effects")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { progressService.userPreferences.soundEnabled },
                    set: { newValue in
                        progressService.updatePreferences(soundEnabled: newValue)
                    }
                ))
                .tint(primaryColor)
            }
            
            // Haptic Feedback
            HStack {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Haptic Feedback")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { progressService.userPreferences.hapticFeedbackEnabled },
                    set: { newValue in
                        progressService.updatePreferences(hapticFeedbackEnabled: newValue)
                    }
                ))
                .tint(primaryColor)
            }
            
            // Dark Mode
            HStack {
                Image(systemName: "moon")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Dark Mode")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { progressService.userPreferences.darkModeEnabled },
                    set: { newValue in
                        progressService.updatePreferences(darkModeEnabled: newValue)
                    }
                ))
                .tint(primaryColor)
            }
        }
    }
    
    // MARK: - Data & Privacy
    @ViewBuilder
    private func DataPrivacySection() -> some View {
        Section("Data & Privacy") {
            // Export Data
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Export Data")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Reset Progress
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                Text("Reset Progress")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Delete Account
            Button(action: {
                showingDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 20)
                    
                    Text("Delete Account")
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - About Section
    @ViewBuilder
    private func AboutSection() -> some View {
        Section("About") {
            // App Version
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Version")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Privacy Policy
            HStack {
                Image(systemName: "hand.raised")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Privacy Policy")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Terms of Service
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Terms of Service")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Contact Support
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(primaryColor)
                    .frame(width: 20)
                
                Text("Contact Support")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Actions
    private func deleteAccount() {
        // Reset all data
        progressService.resetAllData()
        
        // Reset onboarding to show it again
        onboardingCompleted = false
    }
}

// MARK: - Sheet Views
struct LanguageSelectionSheet: View {
    @StateObject private var progressService = ProgressService.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedLanguages: Set<String> = []
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
        NavigationView {
            VStack(spacing: 20) {
                Text("Select the languages you want to learn")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
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
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Languages")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    progressService.updatePreferences(selectedLanguages: Array(selectedLanguages))
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedLanguages.isEmpty)
            )
        }
        .onAppear {
            selectedLanguages = Set(progressService.userPreferences.selectedLanguages)
        }
    }
}

struct GoalEditorSheet: View {
    @StateObject private var progressService = ProgressService.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedGoals: Set<LearningGoal> = []
    @State private var weeklyGoal = 5
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Learning Goals")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Why are you learning languages?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
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
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    progressService.updatePreferences(learningGoals: Array(selectedGoals))
                    progressService.setWeeklyGoal(weeklyGoal)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            selectedGoals = Set(progressService.userPreferences.learningGoals)
            weeklyGoal = progressService.userProgress.weeklyGoal
        }
    }
}

struct ReminderPickerSheet: View {
    @StateObject private var progressService = ProgressService.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Reminder")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Get reminded to practice your languages every day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Toggle("Enable Daily Reminder", isOn: $reminderEnabled)
                        .tint(primaryColor)
                    
                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    progressService.updatePreferences(
                        dailyReminderTime: reminderEnabled ? reminderTime : nil
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            if let existingTime = progressService.userPreferences.dailyReminderTime {
                reminderEnabled = true
                reminderTime = existingTime
            } else {
                reminderEnabled = false
                reminderTime = Date()
            }
        }
    }
}

#Preview {
    SettingsView()
}
