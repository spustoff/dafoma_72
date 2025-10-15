//
//  LearningModuleView.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct LearningModuleView: View {
    let module: LanguageModule
    @StateObject private var viewModel = LearningModuleViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            if viewModel.currentLesson != nil {
                LessonView()
            } else if viewModel.currentQuiz != nil {
                QuizView()
            } else if viewModel.showResults {
                ResultsView()
            } else {
                ModuleOverviewView()
            }
        }
        .navigationBarBackButtonHidden(viewModel.currentLesson != nil || viewModel.currentQuiz != nil)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadModule(module)
        }
    }
    
    // MARK: - Module Overview
    @ViewBuilder
    private func ModuleOverviewView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(module.language)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(primaryColor)
                                .cornerRadius(12)
                            
                            Text(module.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text(module.difficulty.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: module.difficulty.color))
                                .cornerRadius(8)
                            
                            Text("\(module.estimatedTime) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(module.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    // Progress indicator
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(Int(module.progress * 100))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(primaryColor)
                        }
                        
                        ProgressView(value: module.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                }
                .padding(.horizontal)
                
                // Lessons Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Lessons")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(viewModel.getCompletedLessonsCount())/\(viewModel.getTotalLessonsCount())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(Array(module.lessons.enumerated()), id: \.element.id) { index, lesson in
                            LessonCard(
                                lesson: lesson,
                                index: index + 1,
                                isLocked: index > 0 && !module.lessons[index - 1].isCompleted
                            ) {
                                viewModel.startLesson(lesson)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Quizzes Section
                if !module.quizzes.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Quizzes")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(viewModel.getCompletedQuizzesCount())/\(viewModel.getTotalQuizzesCount())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(Array(module.quizzes.enumerated()), id: \.element.id) { index, quiz in
                                QuizCard(
                                    quiz: quiz,
                                    index: index + 1,
                                    isLocked: viewModel.getCompletedLessonsCount() < viewModel.getTotalLessonsCount()
                                ) {
                                    viewModel.startQuiz(quiz)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Lesson View
    @ViewBuilder
    private func LessonView() -> some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button("Exit") {
                    viewModel.resetCurrentSession()
                }
                .foregroundColor(primaryColor)
                
                Spacer()
                
                if let lesson = viewModel.currentLesson {
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button("Skip") {
                    viewModel.nextExercise()
                }
                .foregroundColor(primaryColor)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            if let exercise = viewModel.currentExercise {
                ExerciseView(exercise: exercise) {
                    viewModel.nextExercise()
                }
            }
        }
    }
    
    // MARK: - Quiz View
    @ViewBuilder
    private func QuizView() -> some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button("Exit") {
                    viewModel.resetCurrentSession()
                }
                .foregroundColor(primaryColor)
                
                Spacer()
                
                if let quiz = viewModel.currentQuiz {
                    Text(quiz.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.currentQuiz?.questions.count ?? 0)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Progress bar
            if let quiz = viewModel.currentQuiz {
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1) / Double(quiz.questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                    .padding(.horizontal)
            }
            
            if let quiz = viewModel.currentQuiz,
               viewModel.currentQuestionIndex < quiz.questions.count {
                QuestionView(
                    question: quiz.questions[viewModel.currentQuestionIndex],
                    questionIndex: viewModel.currentQuestionIndex,
                    selectedAnswer: viewModel.userAnswers.indices.contains(viewModel.currentQuestionIndex) ? viewModel.userAnswers[viewModel.currentQuestionIndex] : ""
                ) { answer in
                    viewModel.selectAnswer(answer, for: viewModel.currentQuestionIndex)
                }
            }
            
            // Navigation buttons
            HStack {
                if viewModel.currentQuestionIndex > 0 {
                    Button("Previous") {
                        viewModel.previousQuestion()
                    }
                    .foregroundColor(primaryColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(primaryColor, lineWidth: 2)
                    )
                }
                
                Spacer()
                
                Button(viewModel.currentQuestionIndex == (viewModel.currentQuiz?.questions.count ?? 0) - 1 ? "Finish" : "Next") {
                    viewModel.nextQuestion()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(viewModel.canProceedToNextQuestion() ? primaryColor : Color.gray)
                )
                .disabled(!viewModel.canProceedToNextQuestion())
            }
            .padding()
        }
    }
    
    // MARK: - Results View
    @ViewBuilder
    private func ResultsView() -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("Great Job!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if viewModel.currentLesson != nil {
                    Text("You've completed the lesson!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                } else if let quiz = viewModel.currentQuiz {
                    Text("Quiz completed!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    if let score = quiz.userScore {
                        Text("Your score: \(score)%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(score >= quiz.passingScore ? .green : .orange)
                    }
                }
            }
            
            Spacer()
            
            Button("Continue") {
                viewModel.resetCurrentSession()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(primaryColor)
            .cornerRadius(25)
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct LessonCard: View {
    let lesson: Lesson
    let index: Int
    let isLocked: Bool
    let action: () -> Void
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        Button(action: isLocked ? {} : action) {
            HStack(spacing: 16) {
                // Lesson number
                ZStack {
                    Circle()
                        .fill(lesson.isCompleted ? .green : (isLocked ? Color.gray.opacity(0.3) : primaryColor))
                        .frame(width: 40, height: 40)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    } else {
                        Text("\(index)")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isLocked ? .gray : .primary)
                    
                    HStack {
                        Image(systemName: lesson.type.iconName)
                            .foregroundColor(isLocked ? .gray : primaryColor)
                        
                        Text(lesson.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(isLocked ? .gray : .secondary)
                        
                        Spacer()
                        
                        Text("\(lesson.exercises.count) exercises")
                            .font(.caption)
                            .foregroundColor(isLocked ? .gray : .secondary)
                    }
                }
                
                Spacer()
                
                if !isLocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuizCard: View {
    let quiz: Quiz
    let index: Int
    let isLocked: Bool
    let action: () -> Void
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        Button(action: isLocked ? {} : action) {
            HStack(spacing: 16) {
                // Quiz icon
                ZStack {
                    Circle()
                        .fill(quiz.isCompleted ? .green : (isLocked ? Color.gray.opacity(0.3) : primaryColor))
                        .frame(width: 40, height: 40)
                    
                    if quiz.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    } else {
                        Image(systemName: "questionmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isLocked ? .gray : .primary)
                    
                    HStack {
                        Text("\(quiz.questions.count) questions")
                            .font(.subheadline)
                            .foregroundColor(isLocked ? .gray : .secondary)
                        
                        Spacer()
                        
                        if let score = quiz.userScore {
                            Text("Score: \(score)%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(score >= quiz.passingScore ? .green : .orange)
                        } else {
                            Text("Passing: \(quiz.passingScore)%")
                                .font(.caption)
                                .foregroundColor(isLocked ? .gray : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                if !isLocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    let onComplete: () -> Void
    @State private var userAnswer = ""
    @State private var showFeedback = false
    @State private var isCorrect = false
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text(exercise.instruction)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                switch exercise.type {
                case .fillInTheBlank:
                    FillInTheBlankView(content: exercise.content, userAnswer: $userAnswer)
                case .multipleChoice:
                    MultipleChoiceView(content: exercise.content, userAnswer: $userAnswer)
                case .translation:
                    TranslationView(content: exercise.content, userAnswer: $userAnswer)
                default:
                    Text("Exercise type not implemented")
                        .foregroundColor(.secondary)
                }
            }
            
            if showFeedback {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Text(isCorrect ? "Correct!" : "Not quite right")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                    }
                    
                    if !isCorrect {
                        Text("Correct answer: \(exercise.correctAnswer)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
            
            Button(showFeedback ? "Continue" : "Check Answer") {
                if showFeedback {
                    onComplete()
                } else {
                    checkAnswer()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(userAnswer.isEmpty ? Color.gray : primaryColor)
            .cornerRadius(25)
            .disabled(userAnswer.isEmpty)
        }
        .padding()
    }
    
    private func checkAnswer() {
        isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == 
                   exercise.correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        showFeedback = true
    }
}

struct FillInTheBlankView: View {
    let content: String
    @Binding var userAnswer: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(content.replacingOccurrences(of: "____", with: "_____"))
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            TextField("Your answer", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
        }
    }
}

struct MultipleChoiceView: View {
    let content: String
    @Binding var userAnswer: String
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(spacing: 16) {
            let options = content.components(separatedBy: "|")
            
            ForEach(options, id: \.self) { option in
                Button(option) {
                    userAnswer = option
                }
                .foregroundColor(userAnswer == option ? .white : .primary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(userAnswer == option ? primaryColor : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(userAnswer == option ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
        }
    }
}

struct TranslationView: View {
    let content: String
    @Binding var userAnswer: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Translate:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(content)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            TextField("Your translation", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
        }
    }
}

struct QuestionView: View {
    let question: Question
    let questionIndex: Int
    let selectedAnswer: String
    let onAnswerSelected: (String) -> Void
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(question.text)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(question.options, id: \.self) { option in
                    Button(option) {
                        onAnswerSelected(option)
                    }
                    .foregroundColor(selectedAnswer == option ? .white : .primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedAnswer == option ? primaryColor : Color.gray.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedAnswer == option ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        LearningModuleView(module: LanguageModule(
            title: "Spanish Basics",
            description: "Learn fundamental Spanish vocabulary and phrases for everyday conversations.",
            language: "Spanish",
            difficulty: .beginner,
            estimatedTime: 45,
            lessons: [],
            quizzes: []
        ))
    }
}
