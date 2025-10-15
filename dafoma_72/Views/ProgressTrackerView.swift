//
//  ProgressTrackerView.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct ProgressTrackerView: View {
    @StateObject private var viewModel = ProgressTrackerViewModel()
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats Overview
                        StatsOverviewSection()
                        
                        // Progress Chart
                        ProgressChartSection()
                        
                        // Weekly Goal
                        WeeklyGoalSection()
                        
                        // Achievements
                        AchievementsSection()
                        
                        // Streak Information
                        StreakSection()
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Stats Overview
    @ViewBuilder
    private func StatsOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Lessons",
                    value: "\(viewModel.getTotalLessonsCompleted())",
                    icon: "book.fill",
                    color: primaryColor
                )
                
                StatCard(
                    title: "Modules",
                    value: "\(viewModel.getTotalModulesCompleted())",
                    icon: "graduationcap.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Quizzes",
                    value: "\(viewModel.getTotalQuizzesCompleted())",
                    icon: "questionmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Time Spent",
                    value: formatTime(viewModel.getTotalTimeSpent()),
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Progress Chart
    @ViewBuilder
    private func ProgressChartSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Learning Activity")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else {
                // Simple bar chart alternative for iOS 15.6
                VStack(spacing: 8) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(viewModel.chartData) { dataPoint in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(primaryColor)
                                    .frame(width: 30, height: max(20, CGFloat(dataPoint.value) * 10))
                                    .cornerRadius(4)
                                
                                Text(dataPoint.label)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 200, alignment: .bottom)
                    
                    HStack {
                        Text("0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Lessons")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .onChange(of: viewModel.selectedTimeRange) { _ in
            viewModel.loadChartData()
        }
    }
    
    // MARK: - Weekly Goal
    @ViewBuilder
    private func WeeklyGoalSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Goal")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Edit") {
                    // TODO: Show goal editing sheet
                }
                .font(.subheadline)
                .foregroundColor(primaryColor)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("\(viewModel.getWeeklyProgress())")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Text("/ \(viewModel.getWeeklyGoal()) lessons")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                ProgressView(value: viewModel.getWeeklyProgressPercentage())
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                
                HStack {
                    Text(viewModel.getMotivationalMessage())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    let percentage = Int(viewModel.getWeeklyProgressPercentage() * 100)
                    Text("\(percentage)%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(primaryColor)
                }
            }
            
            // Weekly progress dots
            HStack {
                ForEach(viewModel.weeklyData) { day in
                    VStack(spacing: 6) {
                        Text(day.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(day.isCompleted ? primaryColor : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(day.isToday ? primaryColor : Color.clear, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Achievements
    @ViewBuilder
    private func AchievementsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.getTotalBadgesCount()) earned")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.getBadgesEarned().isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No badges yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Complete lessons and quizzes to earn your first badge!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.getBadgesEarned()) { badge in
                            BadgeDetailCard(badge: badge)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Streak Section
    @ViewBuilder
    private func StreakSection() -> some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                
                Text("\(viewModel.getCurrentStreak())")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                
                Text("Current Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            VStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                Text("\(viewModel.getLongestStreak())")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                
                Text("Best Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct BadgeDetailCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.iconName)
                .font(.title)
                .foregroundColor(Color(hex: badge.color))
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let dateEarned = badge.dateEarned {
                Text(dateEarned, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(width: 100, height: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ProgressTrackerView()
}
