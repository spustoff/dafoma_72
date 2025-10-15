//
//  LanguageModel.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

// MARK: - Language Module Models
struct LanguageModule: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let language: String
    let difficulty: Difficulty
    let estimatedTime: Int // in minutes
    let lessons: [Lesson]
    let quizzes: [Quiz]
    let isCompleted: Bool
    let progress: Double // 0.0 to 1.0
    let badgeEarned: Badge?
    
    init(id: UUID = UUID(), title: String, description: String, language: String, difficulty: Difficulty, estimatedTime: Int, lessons: [Lesson], quizzes: [Quiz], isCompleted: Bool = false, progress: Double = 0.0, badgeEarned: Badge? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.language = language
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.lessons = lessons
        self.quizzes = quizzes
        self.isCompleted = isCompleted
        self.progress = progress
        self.badgeEarned = badgeEarned
    }
}

struct Lesson: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let type: LessonType
    let vocabulary: [VocabularyItem]
    let exercises: [Exercise]
    let isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, content: String, type: LessonType, vocabulary: [VocabularyItem], exercises: [Exercise], isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.type = type
        self.vocabulary = vocabulary
        self.exercises = exercises
        self.isCompleted = isCompleted
    }
}

struct Quiz: Identifiable, Codable {
    let id: UUID
    let title: String
    let questions: [Question]
    let passingScore: Int
    let isCompleted: Bool
    let userScore: Int?
    
    init(id: UUID = UUID(), title: String, questions: [Question], passingScore: Int, isCompleted: Bool = false, userScore: Int? = nil) {
        self.id = id
        self.title = title
        self.questions = questions
        self.passingScore = passingScore
        self.isCompleted = isCompleted
        self.userScore = userScore
    }
}

struct Question: Identifiable, Codable {
    let id: UUID
    let text: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    
    init(id: UUID = UUID(), text: String, options: [String], correctAnswer: Int, explanation: String) {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
    }
}

struct VocabularyItem: Identifiable, Codable {
    let id: UUID
    let word: String
    let translation: String
    let pronunciation: String
    let example: String
    let isLearned: Bool
    
    init(id: UUID = UUID(), word: String, translation: String, pronunciation: String, example: String, isLearned: Bool = false) {
        self.id = id
        self.word = word
        self.translation = translation
        self.pronunciation = pronunciation
        self.example = example
        self.isLearned = isLearned
    }
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let instruction: String
    let type: ExerciseType
    let content: String
    let correctAnswer: String
    let isCompleted: Bool
    
    init(id: UUID = UUID(), instruction: String, type: ExerciseType, content: String, correctAnswer: String, isCompleted: Bool = false) {
        self.id = id
        self.instruction = instruction
        self.type = type
        self.content = content
        self.correctAnswer = correctAnswer
        self.isCompleted = isCompleted
    }
}

struct Badge: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let color: String
    let dateEarned: Date?
    
    init(id: UUID = UUID(), name: String, description: String, iconName: String, color: String, dateEarned: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.color = color
        self.dateEarned = dateEarned
    }
}

struct UserProgress: Codable {
    let totalModulesCompleted: Int
    let totalLessonsCompleted: Int
    let totalQuizzesCompleted: Int
    let totalTimeSpent: Int // in minutes
    let currentStreak: Int
    let longestStreak: Int
    let badgesEarned: [Badge]
    let lastActivityDate: Date?
    let weeklyGoal: Int // lessons per week
    let weeklyProgress: Int
    
    init(totalModulesCompleted: Int = 0, totalLessonsCompleted: Int = 0, totalQuizzesCompleted: Int = 0, totalTimeSpent: Int = 0, currentStreak: Int = 0, longestStreak: Int = 0, badgesEarned: [Badge] = [], lastActivityDate: Date? = nil, weeklyGoal: Int = 5, weeklyProgress: Int = 0) {
        self.totalModulesCompleted = totalModulesCompleted
        self.totalLessonsCompleted = totalLessonsCompleted
        self.totalQuizzesCompleted = totalQuizzesCompleted
        self.totalTimeSpent = totalTimeSpent
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.badgesEarned = badgesEarned
        self.lastActivityDate = lastActivityDate
        self.weeklyGoal = weeklyGoal
        self.weeklyProgress = weeklyProgress
    }
}

// MARK: - Enums
enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "#4CAF50"
        case .intermediate: return "#FF9800"
        case .advanced: return "#F44336"
        }
    }
}

enum LessonType: String, CaseIterable, Codable {
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case conversation = "Conversation"
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    
    var iconName: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .grammar: return "textformat"
        case .conversation: return "bubble.left.and.bubble.right.fill"
        case .listening: return "ear.fill"
        case .reading: return "doc.text.fill"
        case .writing: return "pencil"
        }
    }
}

enum ExerciseType: String, CaseIterable, Codable {
    case fillInTheBlank = "Fill in the Blank"
    case multipleChoice = "Multiple Choice"
    case translation = "Translation"
    case matching = "Matching"
    case speaking = "Speaking"
    case listening = "Listening"
    
    var iconName: String {
        switch self {
        case .fillInTheBlank: return "square.and.pencil"
        case .multipleChoice: return "list.bullet.circle"
        case .translation: return "arrow.left.arrow.right"
        case .matching: return "link"
        case .speaking: return "mic.fill"
        case .listening: return "speaker.wave.2.fill"
        }
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    let selectedLanguages: [String]
    let learningGoals: [LearningGoal]
    let dailyReminderTime: Date?
    let soundEnabled: Bool
    let hapticFeedbackEnabled: Bool
    let darkModeEnabled: Bool
    let onboardingCompleted: Bool
    
    init(selectedLanguages: [String] = [], learningGoals: [LearningGoal] = [], dailyReminderTime: Date? = nil, soundEnabled: Bool = true, hapticFeedbackEnabled: Bool = true, darkModeEnabled: Bool = false, onboardingCompleted: Bool = false) {
        self.selectedLanguages = selectedLanguages
        self.learningGoals = learningGoals
        self.dailyReminderTime = dailyReminderTime
        self.soundEnabled = soundEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.darkModeEnabled = darkModeEnabled
        self.onboardingCompleted = onboardingCompleted
    }
}

enum LearningGoal: String, CaseIterable, Codable {
    case travel = "Travel"
    case business = "Business"
    case academic = "Academic"
    case personal = "Personal Interest"
    case career = "Career Development"
    
    var description: String {
        switch self {
        case .travel: return "Learn for traveling and tourism"
        case .business: return "Professional communication"
        case .academic: return "Academic studies and research"
        case .personal: return "Personal enrichment and culture"
        case .career: return "Career advancement opportunities"
        }
    }
    
    var iconName: String {
        switch self {
        case .travel: return "airplane"
        case .business: return "briefcase.fill"
        case .academic: return "graduationcap.fill"
        case .personal: return "heart.fill"
        case .career: return "chart.line.uptrend.xyaxis"
        }
    }
}
