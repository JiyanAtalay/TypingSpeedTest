//
//  ContentView.swift
//  TypingSpeedTest
//
//  Created by Mehmet Jiyan Atalay on 29.07.2024.
//

import SwiftUI

struct WordsView: View {
    
    @ObservedObject var viewModel = WordsViewModel()
    
    @State private var text = ""
    
    @State private var truthsList: [String] = []
    @State private var wrongsList: [String] = []
    
    @State private var truths = 0
    @State private var wrongs = 0
    
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack {
                        Text("Truths")
                        Text(truths.description)
                            .padding(.horizontal)
                            .bold()
                    }
                    VStack {
                        Text("Wrongs")
                        Text(wrongs.description)
                            .padding(.horizontal)
                            .bold()
                    }
                }
                TextField("Type here", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.words, id: \.self) { word in
                            Text(word)
                                .padding(.vertical, 5)
                                .bold()
                                .font(.title2)
                        }
                    }
                }
                
                if showFeedback {
                    Text(feedbackMessage)
                        .font(.title)
                        .foregroundColor(feedbackMessage == "Correct!" ? .green : .red)
                        .transition(.scale)  // Animasyon türü
                        .padding()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.downloadWords(url: Urls.wordsByNumber(number: 300))
            }
        }
        .onChange(of: text) {
            if text.contains(" ") {
                let noSpaces = text.trimmingCharacters(in: .whitespaces).lowercased()
                
                if noSpaces == viewModel.words[0] {
                    withAnimation {
                        feedbackMessage = "Correct!"
                        self.truthsList.append(text)
                        self.truths += 1
                    }
                } else {
                    withAnimation {
                        feedbackMessage = "Wrong!"
                        self.wrongsList.append(text)
                        self.wrongs += 1
                    }
                }
                
                withAnimation {
                    viewModel.words.removeFirst()
                    text = ""
                    showFeedback = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showFeedback = false
                    }
                }
            }
        }
    }
}

#Preview {
    WordsView()
}
