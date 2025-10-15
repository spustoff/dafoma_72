//
//  LearningModuleViewModel.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation
import SwiftUI

class LearningModuleViewModel: ObservableObject {
    @Published var currentModule: LanguageModule?
    @Published var currentLesson: Lesson?
    @Published var currentQuiz: Quiz?
    @Published var currentExercise: Exercise?
    @Published var currentQuestionIndex = 0
    @Published var userAnswers: [String] = []
    @Published var showResults = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let dataService = DataService.shared
    private let progressService = ProgressService.shared
    
    // MARK: - Module Management
    func loadModule(_ module: LanguageModule) {
        currentModule = module
        currentLesson = nil
        currentQuiz = nil
        currentExercise = nil
        currentQuestionIndex = 0
        userAnswers = []
        showResults = false
        errorMessage = nil
    }
    
    func startLesson(_ lesson: Lesson) {
        currentLesson = lesson
        currentQuiz = nil
        currentExercise = lesson.exercises.first
        currentQuestionIndex = 0
        userAnswers = []
        showResults = false
    }
    
    func startQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        currentLesson = nil
        currentExercise = nil
        currentQuestionIndex = 0
        userAnswers = Array(repeating: "", count: quiz.questions.count)
        showResults = false
    }
    
    // MARK: - Exercise Navigation
    func nextExercise() {
        guard let lesson = currentLesson else { return }
        
        if let currentExercise = currentExercise,
           let currentIndex = lesson.exercises.firstIndex(where: { $0.id == currentExercise.id }) {
            
            if currentIndex < lesson.exercises.count - 1 {
                self.currentExercise = lesson.exercises[currentIndex + 1]
            } else {
                // Lesson completed
                completeLesson()
            }
        }
    }
    
    func previousExercise() {
        guard let lesson = currentLesson else { return }
        
        if let currentExercise = currentExercise,
           let currentIndex = lesson.exercises.firstIndex(where: { $0.id == currentExercise.id }) {
            
            if currentIndex > 0 {
                self.currentExercise = lesson.exercises[currentIndex - 1]
            }
        }
    }
    
    // MARK: - Quiz Navigation
    func nextQuestion() {
        guard let quiz = currentQuiz else { return }
        
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            // Quiz completed
            completeQuiz()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func selectAnswer(_ answer: String, for questionIndex: Int) {
        guard questionIndex < userAnswers.count else { return }
        userAnswers[questionIndex] = answer
    }
    
    // MARK: - Completion Handlers
    private func completeLesson() {
        guard let module = currentModule,
              let lesson = currentLesson else { return }
        
        // Update lesson completion in data service
        dataService.completeLesson(lesson.id, in: module.id)
        
        // Update progress
        progressService.updateProgress(lessonsCompleted: 1, timeSpent: 15) // Assume 15 minutes per lesson
        
        // Check if module is completed
        if let updatedModule = dataService.getModule(by: module.id) {
            currentModule = updatedModule
            
            if updatedModule.isCompleted {
                // Award completion badge
                if let badge = updatedModule.badgeEarned {
                    progressService.addBadge(badge)
                }
            }
        }
        
        showResults = true
    }
    
    private func completeQuiz() {
        guard let module = currentModule,
              let quiz = currentQuiz else { return }
        
        let score = calculateQuizScore()
        
        // Update quiz completion in data service
        dataService.completeQuiz(quiz.id, in: module.id, score: score)
        
        // Update progress
        progressService.updateProgress(quizzesCompleted: 1, timeSpent: 10) // Assume 10 minutes per quiz
        
        // Check if quiz passed
        if score >= quiz.passingScore {
            // Award quiz badge if applicable
            let quizBadge = Badge(
                name: "Quiz Master",
                description: "Passed \(quiz.title) with \(score)%",
                iconName: "checkmark.seal.fill",
                color: "#4CAF50",
                dateEarned: Date()
            )
            progressService.addBadge(quizBadge)
        }
        
        showResults = true
    }
    
    // MARK: - Quiz Scoring
    private func calculateQuizScore() -> Int {
        guard let quiz = currentQuiz else { return 0 }
        
        var correctAnswers = 0
        
        for (index, question) in quiz.questions.enumerated() {
            if index < userAnswers.count {
                let userAnswer = userAnswers[index]
                let correctOption = question.options[question.correctAnswer]
                
                if userAnswer == correctOption {
                    correctAnswers += 1
                }
            }
        }
        
        return Int((Double(correctAnswers) / Double(quiz.questions.count)) * 100)
    }
    
    // MARK: - Utility Methods
    func getProgressPercentage() -> Double {
        guard let module = currentModule else { return 0.0 }
        return module.progress
    }
    
    func getCompletedLessonsCount() -> Int {
        guard let module = currentModule else { return 0 }
        return module.lessons.filter { $0.isCompleted }.count
    }
    
    func getTotalLessonsCount() -> Int {
        guard let module = currentModule else { return 0 }
        return module.lessons.count
    }
    
    func getCompletedQuizzesCount() -> Int {
        guard let module = currentModule else { return 0 }
        return module.quizzes.filter { $0.isCompleted }.count
    }
    
    func getTotalQuizzesCount() -> Int {
        guard let module = currentModule else { return 0 }
        return module.quizzes.count
    }
    
    func isQuestionAnswered(_ questionIndex: Int) -> Bool {
        guard questionIndex < userAnswers.count else { return false }
        return !userAnswers[questionIndex].isEmpty
    }
    
    func canProceedToNextQuestion() -> Bool {
        return isQuestionAnswered(currentQuestionIndex)
    }
    
    func resetCurrentSession() {
        currentLesson = nil
        currentQuiz = nil
        currentExercise = nil
        currentQuestionIndex = 0
        userAnswers = []
        showResults = false
        errorMessage = nil
    }
}
