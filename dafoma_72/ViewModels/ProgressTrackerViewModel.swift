//
//  ProgressTrackerViewModel.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation
import SwiftUI

class ProgressTrackerViewModel: ObservableObject {
    @Published var chartData: [ChartDataPoint] = []
    @Published var weeklyData: [WeeklyProgressData] = []
    @Published var selectedTimeRange: TimeRange = .week
    @Published var isLoading = false
    
    private let progressService = ProgressService.shared
    private let dataService = DataService.shared
    
    init() {
        loadChartData()
        loadWeeklyData()
    }
    
    // MARK: - Data Loading
    func loadChartData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.chartData = self.generateChartData(for: self.selectedTimeRange)
            self.isLoading = false
        }
    }
    
    func loadWeeklyData() {
        weeklyData = generateWeeklyData()
    }
    
    func updateTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
        loadChartData()
    }
    
    // MARK: - Progress Statistics
    func getTotalLessonsCompleted() -> Int {
        return progressService.userProgress.totalLessonsCompleted
    }
    
    func getTotalModulesCompleted() -> Int {
        return progressService.userProgress.totalModulesCompleted
    }
    
    func getTotalQuizzesCompleted() -> Int {
        return progressService.userProgress.totalQuizzesCompleted
    }
    
    func getTotalTimeSpent() -> Int {
        return progressService.userProgress.totalTimeSpent
    }
    
    func getCurrentStreak() -> Int {
        return progressService.userProgress.currentStreak
    }
    
    func getLongestStreak() -> Int {
        return progressService.userProgress.longestStreak
    }
    
    func getWeeklyGoal() -> Int {
        return progressService.userProgress.weeklyGoal
    }
    
    func getWeeklyProgress() -> Int {
        return progressService.userProgress.weeklyProgress
    }
    
    func getWeeklyProgressPercentage() -> Double {
        return progressService.getWeeklyProgressPercentage()
    }
    
    func getBadgesEarned() -> [Badge] {
        return progressService.userProgress.badgesEarned
    }
    
    func getAverageTimePerLesson() -> Double {
        return progressService.getAverageTimePerLesson()
    }
    
    // MARK: - Chart Data Generation
    private func generateChartData(for timeRange: TimeRange) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        
        switch timeRange {
        case .week:
            return generateWeeklyChartData(from: today, calendar: calendar)
        case .month:
            return generateMonthlyChartData(from: today, calendar: calendar)
        case .year:
            return generateYearlyChartData(from: today, calendar: calendar)
        }
    }
    
    private func generateWeeklyChartData(from date: Date, calendar: Calendar) -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        
        for i in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: -i, to: date) ?? date
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: targetDate) - 1]
            
            // Simulate progress data - in a real app, this would come from stored data
            let lessonsCompleted = Int.random(in: 0...5)
            
            data.append(ChartDataPoint(
                date: targetDate,
                label: dayName,
                value: Double(lessonsCompleted),
                category: "Lessons"
            ))
        }
        
        return data.reversed()
    }
    
    private func generateMonthlyChartData(from date: Date, calendar: Calendar) -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        
        for i in 0..<30 {
            let targetDate = calendar.date(byAdding: .day, value: -i, to: date) ?? date
            let dayNumber = calendar.component(.day, from: targetDate)
            
            // Simulate progress data
            let lessonsCompleted = Int.random(in: 0...3)
            
            data.append(ChartDataPoint(
                date: targetDate,
                label: "\(dayNumber)",
                value: Double(lessonsCompleted),
                category: "Lessons"
            ))
        }
        
        return data.reversed()
    }
    
    private func generateYearlyChartData(from date: Date, calendar: Calendar) -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        
        for i in 0..<12 {
            let targetDate = calendar.date(byAdding: .month, value: -i, to: date) ?? date
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: targetDate) - 1]
            
            // Simulate progress data
            let lessonsCompleted = Int.random(in: 10...50)
            
            data.append(ChartDataPoint(
                date: targetDate,
                label: monthName,
                value: Double(lessonsCompleted),
                category: "Lessons"
            ))
        }
        
        return data.reversed()
    }
    
    private func generateWeeklyData() -> [WeeklyProgressData] {
        let calendar = Calendar.current
        let today = Date()
        var data: [WeeklyProgressData] = []
        
        for i in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: targetDate) - 1]
            
            // Check if this is today or a past day
            let isToday = calendar.isDate(targetDate, inSameDayAs: today)
            let isPast = targetDate < today
            
            // Simulate completion status
            let isCompleted = isPast ? Bool.random() : (isToday ? getWeeklyProgress() > i : false)
            
            data.append(WeeklyProgressData(
                day: dayName,
                date: targetDate,
                isCompleted: isCompleted,
                isToday: isToday
            ))
        }
        
        return data.reversed()
    }
    
    // MARK: - Goal Management
    func updateWeeklyGoal(_ newGoal: Int) {
        progressService.setWeeklyGoal(newGoal)
        loadWeeklyData()
    }
    
    // MARK: - Achievements
    func getRecentAchievements() -> [Badge] {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        return getBadgesEarned().filter { badge in
            guard let dateEarned = badge.dateEarned else { return false }
            return dateEarned >= oneWeekAgo
        }.sorted { ($0.dateEarned ?? Date.distantPast) > ($1.dateEarned ?? Date.distantPast) }
    }
    
    func getTotalBadgesCount() -> Int {
        return getBadgesEarned().count
    }
    
    // MARK: - Motivational Messages
    func getMotivationalMessage() -> String {
        let streak = getCurrentStreak()
        let weeklyProgress = getWeeklyProgressPercentage()
        
        if streak >= 7 {
            return "🔥 Amazing! You're on a \(streak)-day streak!"
        } else if weeklyProgress >= 1.0 {
            return "🎉 Congratulations! You've reached your weekly goal!"
        } else if weeklyProgress >= 0.8 {
            return "💪 You're so close to your weekly goal!"
        } else if weeklyProgress >= 0.5 {
            return "📚 Great progress! Keep it up!"
        } else if streak > 0 {
            return "⭐ Nice work! You're building a great habit!"
        } else {
            return "🌟 Ready to start your learning journey?"
        }
    }
    
    func getProgressColor() -> Color {
        let percentage = getWeeklyProgressPercentage()
        
        if percentage >= 1.0 {
            return Color.green
        } else if percentage >= 0.7 {
            return Color.blue
        } else if percentage >= 0.4 {
            return Color.orange
        } else {
            return Color.red
        }
    }
}

// MARK: - Supporting Data Structures
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let label: String
    let value: Double
    let category: String
}

struct WeeklyProgressData: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
}

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var displayName: String {
        return self.rawValue
    }
}
