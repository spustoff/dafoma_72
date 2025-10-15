//
//  DataService.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var languageModules: [LanguageModule] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        loadLanguageModules()
    }
    
    // MARK: - Public Methods
    func loadLanguageModules() {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading from local JSON or create sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.languageModules = self.createSampleLanguageModules()
            self.isLoading = false
        }
    }
    
    func getModule(by id: UUID) -> LanguageModule? {
        return languageModules.first { $0.id == id }
    }
    
    func updateModuleProgress(_ moduleId: UUID, progress: Double) {
        if let index = languageModules.firstIndex(where: { $0.id == moduleId }) {
            var updatedModule = languageModules[index]
            updatedModule = LanguageModule(
                id: updatedModule.id,
                title: updatedModule.title,
                description: updatedModule.description,
                language: updatedModule.language,
                difficulty: updatedModule.difficulty,
                estimatedTime: updatedModule.estimatedTime,
                lessons: updatedModule.lessons,
                quizzes: updatedModule.quizzes,
                isCompleted: progress >= 1.0,
                progress: progress,
                badgeEarned: progress >= 1.0 ? createCompletionBadge(for: updatedModule) : updatedModule.badgeEarned
            )
            languageModules[index] = updatedModule
        }
    }
    
    func completeLesson(_ lessonId: UUID, in moduleId: UUID) {
        if let moduleIndex = languageModules.firstIndex(where: { $0.id == moduleId }),
           let lessonIndex = languageModules[moduleIndex].lessons.firstIndex(where: { $0.id == lessonId }) {
            
            var updatedModule = languageModules[moduleIndex]
            var updatedLessons = updatedModule.lessons
            
            let lesson = updatedLessons[lessonIndex]
            updatedLessons[lessonIndex] = Lesson(
                id: lesson.id,
                title: lesson.title,
                content: lesson.content,
                type: lesson.type,
                vocabulary: lesson.vocabulary,
                exercises: lesson.exercises,
                isCompleted: true
            )
            
            // Calculate new progress
            let completedLessons = updatedLessons.filter { $0.isCompleted }.count
            let totalLessons = updatedLessons.count
            let newProgress = Double(completedLessons) / Double(totalLessons)
            
            updatedModule = LanguageModule(
                id: updatedModule.id,
                title: updatedModule.title,
                description: updatedModule.description,
                language: updatedModule.language,
                difficulty: updatedModule.difficulty,
                estimatedTime: updatedModule.estimatedTime,
                lessons: updatedLessons,
                quizzes: updatedModule.quizzes,
                isCompleted: newProgress >= 1.0,
                progress: newProgress,
                badgeEarned: newProgress >= 1.0 ? createCompletionBadge(for: updatedModule) : updatedModule.badgeEarned
            )
            
            languageModules[moduleIndex] = updatedModule
        }
    }
    
    func completeQuiz(_ quizId: UUID, in moduleId: UUID, score: Int) {
        if let moduleIndex = languageModules.firstIndex(where: { $0.id == moduleId }),
           let quizIndex = languageModules[moduleIndex].quizzes.firstIndex(where: { $0.id == quizId }) {
            
            var updatedModule = languageModules[moduleIndex]
            var updatedQuizzes = updatedModule.quizzes
            
            let quiz = updatedQuizzes[quizIndex]
            updatedQuizzes[quizIndex] = Quiz(
                id: quiz.id,
                title: quiz.title,
                questions: quiz.questions,
                passingScore: quiz.passingScore,
                isCompleted: score >= quiz.passingScore,
                userScore: score
            )
            
            updatedModule = LanguageModule(
                id: updatedModule.id,
                title: updatedModule.title,
                description: updatedModule.description,
                language: updatedModule.language,
                difficulty: updatedModule.difficulty,
                estimatedTime: updatedModule.estimatedTime,
                lessons: updatedModule.lessons,
                quizzes: updatedQuizzes,
                isCompleted: updatedModule.isCompleted,
                progress: updatedModule.progress,
                badgeEarned: updatedModule.badgeEarned
            )
            
            languageModules[moduleIndex] = updatedModule
        }
    }
    
    // MARK: - Private Methods
    private func createCompletionBadge(for module: LanguageModule) -> Badge {
        return Badge(
            name: "\(module.language) \(module.difficulty.rawValue)",
            description: "Completed \(module.title)",
            iconName: "star.fill",
            color: "#FFD700",
            dateEarned: Date()
        )
    }
    
    private func createSampleLanguageModules() -> [LanguageModule] {
        return [
            // Spanish Module
            LanguageModule(
                title: "Spanish Basics",
                description: "Learn fundamental Spanish vocabulary and phrases for everyday conversations.",
                language: "Spanish",
                difficulty: .beginner,
                estimatedTime: 45,
                lessons: createSampleLessons(for: "Spanish"),
                quizzes: createSampleQuizzes(for: "Spanish")
            ),
            
            // French Module
            LanguageModule(
                title: "French Essentials",
                description: "Master essential French grammar and vocabulary for travel and business.",
                language: "French",
                difficulty: .intermediate,
                estimatedTime: 60,
                lessons: createSampleLessons(for: "French"),
                quizzes: createSampleQuizzes(for: "French")
            ),
            
            // German Module
            LanguageModule(
                title: "German Fundamentals",
                description: "Explore German language structure and common expressions.",
                language: "German",
                difficulty: .beginner,
                estimatedTime: 50,
                lessons: createSampleLessons(for: "German"),
                quizzes: createSampleQuizzes(for: "German")
            ),
            
            // Italian Module
            LanguageModule(
                title: "Italian Conversation",
                description: "Practice Italian through real-life scenarios and cultural contexts.",
                language: "Italian",
                difficulty: .intermediate,
                estimatedTime: 55,
                lessons: createSampleLessons(for: "Italian"),
                quizzes: createSampleQuizzes(for: "Italian")
            )
        ]
    }
    
    private func createSampleLessons(for language: String) -> [Lesson] {
        let vocabularyItems = createSampleVocabulary(for: language)
        let exercises = createSampleExercises(for: language)
        
        return [
            Lesson(
                title: "Basic Greetings",
                content: "Learn how to greet people and introduce yourself in \(language). This lesson covers formal and informal greetings, appropriate responses, and cultural context.",
                type: .vocabulary,
                vocabulary: Array(vocabularyItems.prefix(5)),
                exercises: Array(exercises.prefix(3))
            ),
            Lesson(
                title: "Numbers and Time",
                content: "Master numbers from 1-100 and learn to tell time in \(language). Practice with real-world scenarios like shopping and scheduling.",
                type: .vocabulary,
                vocabulary: Array(vocabularyItems.dropFirst(5).prefix(5)),
                exercises: Array(exercises.dropFirst(3).prefix(3))
            ),
            Lesson(
                title: "Daily Conversations",
                content: "Engage in everyday conversations about weather, food, and activities. Build confidence in speaking through interactive dialogues.",
                type: .conversation,
                vocabulary: Array(vocabularyItems.dropFirst(10).prefix(5)),
                exercises: Array(exercises.dropFirst(6).prefix(3))
            )
        ]
    }
    
    private func createSampleQuizzes(for language: String) -> [Quiz] {
        return [
            Quiz(
                title: "\(language) Basics Quiz",
                questions: createSampleQuestions(for: language),
                passingScore: 70
            )
        ]
    }
    
    private func createSampleQuestions(for language: String) -> [Question] {
        switch language {
        case "Spanish":
            return [
                Question(
                    text: "How do you say 'Hello' in Spanish?",
                    options: ["Hola", "Adiós", "Gracias", "Por favor"],
                    correctAnswer: 0,
                    explanation: "'Hola' is the most common way to say hello in Spanish."
                ),
                Question(
                    text: "What does 'Gracias' mean?",
                    options: ["Please", "Sorry", "Thank you", "Excuse me"],
                    correctAnswer: 2,
                    explanation: "'Gracias' means 'thank you' in Spanish."
                ),
                Question(
                    text: "How do you say 'Good morning' in Spanish?",
                    options: ["Buenas noches", "Buenos días", "Buenas tardes", "Hasta luego"],
                    correctAnswer: 1,
                    explanation: "'Buenos días' means 'good morning' in Spanish."
                )
            ]
        case "French":
            return [
                Question(
                    text: "How do you say 'Hello' in French?",
                    options: ["Bonjour", "Au revoir", "Merci", "S'il vous plaît"],
                    correctAnswer: 0,
                    explanation: "'Bonjour' is the standard greeting in French."
                ),
                Question(
                    text: "What does 'Merci' mean?",
                    options: ["Please", "Sorry", "Thank you", "Excuse me"],
                    correctAnswer: 2,
                    explanation: "'Merci' means 'thank you' in French."
                )
            ]
        case "German":
            return [
                Question(
                    text: "How do you say 'Hello' in German?",
                    options: ["Hallo", "Auf Wiedersehen", "Danke", "Bitte"],
                    correctAnswer: 0,
                    explanation: "'Hallo' is a common way to say hello in German."
                ),
                Question(
                    text: "What does 'Danke' mean?",
                    options: ["Please", "Sorry", "Thank you", "Excuse me"],
                    correctAnswer: 2,
                    explanation: "'Danke' means 'thank you' in German."
                )
            ]
        case "Italian":
            return [
                Question(
                    text: "How do you say 'Hello' in Italian?",
                    options: ["Ciao", "Arrivederci", "Grazie", "Prego"],
                    correctAnswer: 0,
                    explanation: "'Ciao' is a casual way to say hello in Italian."
                ),
                Question(
                    text: "What does 'Grazie' mean?",
                    options: ["Please", "Sorry", "Thank you", "Excuse me"],
                    correctAnswer: 2,
                    explanation: "'Grazie' means 'thank you' in Italian."
                )
            ]
        default:
            return []
        }
    }
    
    private func createSampleVocabulary(for language: String) -> [VocabularyItem] {
        switch language {
        case "Spanish":
            return [
                VocabularyItem(word: "Hola", translation: "Hello", pronunciation: "OH-lah", example: "Hola, ¿cómo estás?"),
                VocabularyItem(word: "Gracias", translation: "Thank you", pronunciation: "GRAH-see-ahs", example: "Gracias por tu ayuda."),
                VocabularyItem(word: "Por favor", translation: "Please", pronunciation: "por fah-VOR", example: "Un café, por favor."),
                VocabularyItem(word: "Adiós", translation: "Goodbye", pronunciation: "ah-DYOHS", example: "Adiós, hasta mañana."),
                VocabularyItem(word: "Sí", translation: "Yes", pronunciation: "see", example: "Sí, me gusta."),
                VocabularyItem(word: "No", translation: "No", pronunciation: "noh", example: "No, no quiero."),
                VocabularyItem(word: "Agua", translation: "Water", pronunciation: "AH-gwah", example: "Quiero agua, por favor."),
                VocabularyItem(word: "Comida", translation: "Food", pronunciation: "koh-MEE-dah", example: "La comida está deliciosa."),
                VocabularyItem(word: "Casa", translation: "House", pronunciation: "KAH-sah", example: "Mi casa es grande."),
                VocabularyItem(word: "Tiempo", translation: "Time/Weather", pronunciation: "TYEM-poh", example: "¿Qué tiempo hace?")
            ]
        case "French":
            return [
                VocabularyItem(word: "Bonjour", translation: "Hello", pronunciation: "bon-ZHOOR", example: "Bonjour, comment allez-vous?"),
                VocabularyItem(word: "Merci", translation: "Thank you", pronunciation: "mer-SEE", example: "Merci beaucoup!"),
                VocabularyItem(word: "S'il vous plaît", translation: "Please", pronunciation: "seel voo PLEH", example: "Un café, s'il vous plaît."),
                VocabularyItem(word: "Au revoir", translation: "Goodbye", pronunciation: "oh ruh-VWAHR", example: "Au revoir, à bientôt!"),
                VocabularyItem(word: "Oui", translation: "Yes", pronunciation: "wee", example: "Oui, c'est correct."),
                VocabularyItem(word: "Non", translation: "No", pronunciation: "nohn", example: "Non, merci."),
                VocabularyItem(word: "Eau", translation: "Water", pronunciation: "oh", example: "Je voudrais de l'eau."),
                VocabularyItem(word: "Nourriture", translation: "Food", pronunciation: "noo-ree-TOOR", example: "J'aime cette nourriture."),
                VocabularyItem(word: "Maison", translation: "House", pronunciation: "meh-ZOHN", example: "Ma maison est belle."),
                VocabularyItem(word: "Temps", translation: "Time/Weather", pronunciation: "tahn", example: "Quel temps fait-il?")
            ]
        case "German":
            return [
                VocabularyItem(word: "Hallo", translation: "Hello", pronunciation: "HAH-loh", example: "Hallo, wie geht es dir?"),
                VocabularyItem(word: "Danke", translation: "Thank you", pronunciation: "DAHN-keh", example: "Danke schön!"),
                VocabularyItem(word: "Bitte", translation: "Please", pronunciation: "BIT-teh", example: "Ein Kaffee, bitte."),
                VocabularyItem(word: "Auf Wiedersehen", translation: "Goodbye", pronunciation: "owf VEE-der-zayn", example: "Auf Wiedersehen, bis morgen!"),
                VocabularyItem(word: "Ja", translation: "Yes", pronunciation: "yah", example: "Ja, das ist richtig."),
                VocabularyItem(word: "Nein", translation: "No", pronunciation: "nine", example: "Nein, danke."),
                VocabularyItem(word: "Wasser", translation: "Water", pronunciation: "VAH-ser", example: "Ich möchte Wasser."),
                VocabularyItem(word: "Essen", translation: "Food", pronunciation: "ES-sen", example: "Das Essen schmeckt gut."),
                VocabularyItem(word: "Haus", translation: "House", pronunciation: "house", example: "Mein Haus ist groß."),
                VocabularyItem(word: "Zeit", translation: "Time", pronunciation: "tsight", example: "Wie spät ist es?")
            ]
        case "Italian":
            return [
                VocabularyItem(word: "Ciao", translation: "Hello/Bye", pronunciation: "chow", example: "Ciao, come stai?"),
                VocabularyItem(word: "Grazie", translation: "Thank you", pronunciation: "GRAH-tsee-eh", example: "Grazie mille!"),
                VocabularyItem(word: "Prego", translation: "Please/You're welcome", pronunciation: "PREH-goh", example: "Un caffè, prego."),
                VocabularyItem(word: "Arrivederci", translation: "Goodbye", pronunciation: "ah-ree-veh-DEHR-chee", example: "Arrivederci, a presto!"),
                VocabularyItem(word: "Sì", translation: "Yes", pronunciation: "see", example: "Sì, è vero."),
                VocabularyItem(word: "No", translation: "No", pronunciation: "noh", example: "No, grazie."),
                VocabularyItem(word: "Acqua", translation: "Water", pronunciation: "AH-kwah", example: "Vorrei dell'acqua."),
                VocabularyItem(word: "Cibo", translation: "Food", pronunciation: "CHEE-boh", example: "Il cibo è delizioso."),
                VocabularyItem(word: "Casa", translation: "House", pronunciation: "KAH-sah", example: "La mia casa è bella."),
                VocabularyItem(word: "Tempo", translation: "Time/Weather", pronunciation: "TEM-poh", example: "Che tempo fa?")
            ]
        default:
            return []
        }
    }
    
    private func createSampleExercises(for language: String) -> [Exercise] {
        switch language {
        case "Spanish":
            return [
                Exercise(
                    instruction: "Fill in the blank with the correct greeting",
                    type: .fillInTheBlank,
                    content: "_____, ¿cómo estás?",
                    correctAnswer: "Hola"
                ),
                Exercise(
                    instruction: "Choose the correct translation for 'Thank you'",
                    type: .multipleChoice,
                    content: "Gracias|Por favor|Adiós|Hola",
                    correctAnswer: "Gracias"
                ),
                Exercise(
                    instruction: "Translate to Spanish: 'Please'",
                    type: .translation,
                    content: "Please",
                    correctAnswer: "Por favor"
                )
            ]
        case "French":
            return [
                Exercise(
                    instruction: "Fill in the blank with the correct greeting",
                    type: .fillInTheBlank,
                    content: "_____, comment allez-vous?",
                    correctAnswer: "Bonjour"
                ),
                Exercise(
                    instruction: "Choose the correct translation for 'Thank you'",
                    type: .multipleChoice,
                    content: "Merci|S'il vous plaît|Au revoir|Bonjour",
                    correctAnswer: "Merci"
                ),
                Exercise(
                    instruction: "Translate to French: 'Please'",
                    type: .translation,
                    content: "Please",
                    correctAnswer: "S'il vous plaît"
                )
            ]
        default:
            return []
        }
    }
}
