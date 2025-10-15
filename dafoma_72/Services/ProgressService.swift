//
//  ProgressService.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

class ProgressService: ObservableObject {
    static let shared = ProgressService()
    
    @Published var userProgress: UserProgress
    @Published var userPreferences: UserPreferences
    
    private let progressKey = "UserProgress"
    private let preferencesKey = "UserPreferences"
    
    private init() {
        // Load saved progress and preferences
        self.userProgress = ProgressService.loadUserProgress()
        self.userPreferences = ProgressService.loadUserPreferences()
    }
    
    // MARK: - Progress Management
    func updateProgress(
        modulesCompleted: Int? = nil,
        lessonsCompleted: Int? = nil,
        quizzesCompleted: Int? = nil,
        timeSpent: Int? = nil
    ) {
        var updatedProgress = userProgress
        
        if let modules = modulesCompleted {
            updatedProgress = UserProgress(
                totalModulesCompleted: modules,
                totalLessonsCompleted: updatedProgress.totalLessonsCompleted,
                totalQuizzesCompleted: updatedProgress.totalQuizzesCompleted,
                totalTimeSpent: updatedProgress.totalTimeSpent,
                currentStreak: updatedProgress.currentStreak,
                longestStreak: updatedProgress.longestStreak,
                badgesEarned: updatedProgress.badgesEarned,
                lastActivityDate: Date(),
                weeklyGoal: updatedProgress.weeklyGoal,
                weeklyProgress: updatedProgress.weeklyProgress
            )
        }
        
        if let lessons = lessonsCompleted {
            updatedProgress = UserProgress(
                totalModulesCompleted: updatedProgress.totalModulesCompleted,
                totalLessonsCompleted: updatedProgress.totalLessonsCompleted + lessons,
                totalQuizzesCompleted: updatedProgress.totalQuizzesCompleted,
                totalTimeSpent: updatedProgress.totalTimeSpent,
                currentStreak: updatedProgress.currentStreak,
                longestStreak: updatedProgress.longestStreak,
                badgesEarned: updatedProgress.badgesEarned,
                lastActivityDate: Date(),
                weeklyGoal: updatedProgress.weeklyGoal,
                weeklyProgress: updatedProgress.weeklyProgress + lessons
            )
        }
        
        if let quizzes = quizzesCompleted {
            updatedProgress = UserProgress(
                totalModulesCompleted: updatedProgress.totalModulesCompleted,
                totalLessonsCompleted: updatedProgress.totalLessonsCompleted,
                totalQuizzesCompleted: updatedProgress.totalQuizzesCompleted + quizzes,
                totalTimeSpent: updatedProgress.totalTimeSpent,
                currentStreak: updatedProgress.currentStreak,
                longestStreak: updatedProgress.longestStreak,
                badgesEarned: updatedProgress.badgesEarned,
                lastActivityDate: Date(),
                weeklyGoal: updatedProgress.weeklyGoal,
                weeklyProgress: updatedProgress.weeklyProgress
            )
        }
        
        if let time = timeSpent {
            updatedProgress = UserProgress(
                totalModulesCompleted: updatedProgress.totalModulesCompleted,
                totalLessonsCompleted: updatedProgress.totalLessonsCompleted,
                totalQuizzesCompleted: updatedProgress.totalQuizzesCompleted,
                totalTimeSpent: updatedProgress.totalTimeSpent + time,
                currentStreak: updatedProgress.currentStreak,
                longestStreak: updatedProgress.longestStreak,
                badgesEarned: updatedProgress.badgesEarned,
                lastActivityDate: Date(),
                weeklyGoal: updatedProgress.weeklyGoal,
                weeklyProgress: updatedProgress.weeklyProgress
            )
        }
        
        // Update streak
        updatedProgress = updateStreak(progress: updatedProgress)
        
        self.userProgress = updatedProgress
        saveUserProgress()
    }
    
    func addBadge(_ badge: Badge) {
        var updatedBadges = userProgress.badgesEarned
        updatedBadges.append(badge)
        
        let updatedProgress = UserProgress(
            totalModulesCompleted: userProgress.totalModulesCompleted,
            totalLessonsCompleted: userProgress.totalLessonsCompleted,
            totalQuizzesCompleted: userProgress.totalQuizzesCompleted,
            totalTimeSpent: userProgress.totalTimeSpent,
            currentStreak: userProgress.currentStreak,
            longestStreak: userProgress.longestStreak,
            badgesEarned: updatedBadges,
            lastActivityDate: userProgress.lastActivityDate,
            weeklyGoal: userProgress.weeklyGoal,
            weeklyProgress: userProgress.weeklyProgress
        )
        
        self.userProgress = updatedProgress
        saveUserProgress()
    }
    
    func setWeeklyGoal(_ goal: Int) {
        let updatedProgress = UserProgress(
            totalModulesCompleted: userProgress.totalModulesCompleted,
            totalLessonsCompleted: userProgress.totalLessonsCompleted,
            totalQuizzesCompleted: userProgress.totalQuizzesCompleted,
            totalTimeSpent: userProgress.totalTimeSpent,
            currentStreak: userProgress.currentStreak,
            longestStreak: userProgress.longestStreak,
            badgesEarned: userProgress.badgesEarned,
            lastActivityDate: userProgress.lastActivityDate,
            weeklyGoal: goal,
            weeklyProgress: userProgress.weeklyProgress
        )
        
        self.userProgress = updatedProgress
        saveUserProgress()
    }
    
    func resetWeeklyProgress() {
        let updatedProgress = UserProgress(
            totalModulesCompleted: userProgress.totalModulesCompleted,
            totalLessonsCompleted: userProgress.totalLessonsCompleted,
            totalQuizzesCompleted: userProgress.totalQuizzesCompleted,
            totalTimeSpent: userProgress.totalTimeSpent,
            currentStreak: userProgress.currentStreak,
            longestStreak: userProgress.longestStreak,
            badgesEarned: userProgress.badgesEarned,
            lastActivityDate: userProgress.lastActivityDate,
            weeklyGoal: userProgress.weeklyGoal,
            weeklyProgress: 0
        )
        
        self.userProgress = updatedProgress
        saveUserProgress()
    }
    
    // MARK: - Preferences Management
    func updatePreferences(
        selectedLanguages: [String]? = nil,
        learningGoals: [LearningGoal]? = nil,
        dailyReminderTime: Date? = nil,
        soundEnabled: Bool? = nil,
        hapticFeedbackEnabled: Bool? = nil,
        darkModeEnabled: Bool? = nil,
        onboardingCompleted: Bool? = nil
    ) {
        var updatedPreferences = userPreferences
        
        if let languages = selectedLanguages {
            updatedPreferences = UserPreferences(
                selectedLanguages: languages,
                learningGoals: updatedPreferences.learningGoals,
                dailyReminderTime: updatedPreferences.dailyReminderTime,
                soundEnabled: updatedPreferences.soundEnabled,
                hapticFeedbackEnabled: updatedPreferences.hapticFeedbackEnabled,
                darkModeEnabled: updatedPreferences.darkModeEnabled,
                onboardingCompleted: updatedPreferences.onboardingCompleted
            )
        }
        
        if let goals = learningGoals {
            updatedPreferences = UserPreferences(
                selectedLanguages: updatedPreferences.selectedLanguages,
                learningGoals: goals,
                dailyReminderTime: updatedPreferences.dailyReminderTime,
                soundEnabled: updatedPreferences.soundEnabled,
                hapticFeedbackEnabled: updatedPreferences.hapticFeedbackEnabled,
                darkModeEnabled: updatedPreferences.darkModeEnabled,
                onboardingCompleted: updatedPreferences.onboardingCompleted
            )
        }
        
        if let reminderTime = dailyReminderTime {
            updatedPreferences = UserPreferences(
                selectedLanguages: updatedPreferences.selectedLanguages,
                learningGoals: updatedPreferences.learningGoals,
                dailyReminderTime: reminderTime,
                soundEnabled: updatedPreferences.soundEnabled,
                hapticFeedbackEnabled: updatedPreferences.hapticFeedbackEnabled,
                darkModeEnabled: updatedPreferences.darkModeEnabled,
                onboardingCompleted: updatedPreferences.onboardingCompleted
            )
        }
        
        if let sound = soundEnabled {
            updatedPreferences = UserPreferences(
                selectedLanguages: updatedPreferences.selectedLanguages,
                learningGoals: updatedPreferences.learningGoals,
                dailyReminderTime: updatedPreferences.dailyReminderTime,
                soundEnabled: sound,
                hapticFeedbackEnabled: updatedPreferences.hapticFeedbackEnabled,
                darkModeEnabled: updatedPreferences.darkModeEnabled,
                onboardingCompleted: updatedPreferences.onboardingCompleted
            )
        }
        
        if let haptic = hapticFeedbackEnabled {
            updatedPreferences = UserPreferences(
                selectedLanguages: updatedPreferences.selectedLanguages,
                learningGoals: updatedPreferences.learningGoals,
                dailyReminderTime: updatedPreferences.dailyReminderTime,
                soundEnabled: updatedPreferences.soundEnabled,
                hapticFeedbackEnabled: haptic,
                darkModeEnabled: updatedPreferences.darkModeEnabled,
                onboardingCompleted: updatedPreferences.onboardingCompleted
            )
        }
        
        if let darkMode = darkModeEnabled {
            updatedPreferences = UserPreferences(
                selectedLanguages: updatedPreferences.selectedLanguages,
                learningGoals: updatedPreferences.learningGoals,
                dailyReminderTime: updatedPreferences.dailyReminderTime,
                soundEnabled: updatedPreferences.soundEnabled,
                hapticFeedbackEnabled: updatedPreferences.hapticFeedbackEnabled,
                darkModeEnabled: darkMode,
                onboardingCompleted: updatedPreferences.onboardingCompleted
            )
        }
        
        if let onboarding = onboardingCompleted {
            updatedPreferences = UserPreferences(
                selectedLanguages: updatedPreferences.selectedLanguages,
                learningGoals: updatedPreferences.learningGoals,
                dailyReminderTime: updatedPreferences.dailyReminderTime,
                soundEnabled: updatedPreferences.soundEnabled,
                hapticFeedbackEnabled: updatedPreferences.hapticFeedbackEnabled,
                darkModeEnabled: updatedPreferences.darkModeEnabled,
                onboardingCompleted: onboarding
            )
        }
        
        self.userPreferences = updatedPreferences
        saveUserPreferences()
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        // Reset progress
        self.userProgress = UserProgress()
        
        // Reset preferences but keep onboarding completed as false to show onboarding again
        self.userPreferences = UserPreferences()
        
        // Save the reset data
        saveUserProgress()
        saveUserPreferences()
    }
    
    // MARK: - Analytics
    func getWeeklyProgressPercentage() -> Double {
        guard userProgress.weeklyGoal > 0 else { return 0.0 }
        return min(Double(userProgress.weeklyProgress) / Double(userProgress.weeklyGoal), 1.0)
    }
    
    func getDaysUntilWeeklyGoal() -> Int {
        let remaining = max(0, userProgress.weeklyGoal - userProgress.weeklyProgress)
        return remaining
    }
    
    func getAverageTimePerLesson() -> Double {
        guard userProgress.totalLessonsCompleted > 0 else { return 0.0 }
        return Double(userProgress.totalTimeSpent) / Double(userProgress.totalLessonsCompleted)
    }
    
    // MARK: - Private Methods
    private func updateStreak(progress: UserProgress) -> UserProgress {
        let calendar = Calendar.current
        let today = Date()
        
        var currentStreak = progress.currentStreak
        var longestStreak = progress.longestStreak
        
        if let lastActivity = progress.lastActivityDate {
            let daysSinceLastActivity = calendar.dateComponents([.day], from: lastActivity, to: today).day ?? 0
            
            if daysSinceLastActivity == 0 {
                // Same day, maintain streak
                currentStreak = max(1, currentStreak)
            } else if daysSinceLastActivity == 1 {
                // Consecutive day, increment streak
                currentStreak += 1
            } else {
                // Streak broken, reset to 1
                currentStreak = 1
            }
        } else {
            // First activity
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        
        return UserProgress(
            totalModulesCompleted: progress.totalModulesCompleted,
            totalLessonsCompleted: progress.totalLessonsCompleted,
            totalQuizzesCompleted: progress.totalQuizzesCompleted,
            totalTimeSpent: progress.totalTimeSpent,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            badgesEarned: progress.badgesEarned,
            lastActivityDate: progress.lastActivityDate,
            weeklyGoal: progress.weeklyGoal,
            weeklyProgress: progress.weeklyProgress
        )
    }
    
    // MARK: - Persistence
    private func saveUserProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    private func saveUserPreferences() {
        if let encoded = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    private static func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: "UserProgress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress()
        }
        return progress
    }
    
    private static func loadUserPreferences() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: "UserPreferences"),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        return preferences
    }
}
