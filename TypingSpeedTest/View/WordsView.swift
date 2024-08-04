//
//  ContentView.swift
//  TypingSpeedTest
//
//  Created by Mehmet Jiyan Atalay on 29.07.2024.
//

import SwiftUI

struct WordsView: View {
    
    @ObservedObject var viewModel = WordsViewModel()
    @State private var isLoading = false
    
    @State private var text = ""
    @State private var isEditable = false
    
    @State private var truthsList: [String] = []
    @State private var wrongsList: [String] = []
    
    @State private var truths = 0
    @State private var wrongs = 0
    @State private var rate: Double = 0
    
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    
    @State private var timer : Timer? = nil
    @State private var timeRemaining = 60
    
    @State private var showAlert = false
    @State private var showRefresh = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    GroupBox {
                        VStack {
                            Text("Timer")
                            Text(timeRemaining.description)
                                .padding(.horizontal)
                                .bold()
                        }.frame(width: 60)
                    }
                    GroupBox {
                        VStack {
                            Text("Truths")
                            Text(truths.description)
                                .padding(.horizontal)
                                .bold()
                        }.frame(width: 60)
                    }
                    GroupBox {
                        VStack {
                            Text("Wrongs")
                            Text(wrongs.description)
                                .padding(.horizontal)
                                .bold()
                        }.frame(width: 60)
                    }
                }
                TextField("Type here", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .padding()
                    .disabled(isEditable)
                
                ScrollView(.vertical) {
                    
                    GroupBox {
                        if isLoading {
                            ProgressView("Loading...")
                            Spacer()
                        } else {
                            VStack {
                                if !showRefresh {
                                    ForEach(viewModel.words, id: \.self) { word in
                                        Text(word)
                                            .padding(.vertical, 5)
                                            .bold()
                                            .font(.title2)
                                    }
                                } else {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading) {
                                            Text("Truths")
                                                .font(.headline)
                                                .padding(.bottom, 5)
                                            
                                            ForEach(truthsList, id: \.self) { word in
                                                Text(word)
                                                    .padding(.vertical, 5)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Wrongs")
                                                .font(.headline)
                                                .padding(.bottom, 5)
                                            
                                            ForEach(wrongsList, id: \.self) { word in
                                                Text(word)
                                                    .padding(.vertical, 5)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                }
                            }.frame(maxWidth: .infinity, alignment: .center)
                        }
                    }.frame(maxWidth: .infinity)
                }.ignoresSafeArea()
                
                if showFeedback {
                    Text(feedbackMessage)
                        .font(.title)
                        .foregroundColor(feedbackMessage == "Correct!" ? .green : .red)
                        .transition(.scale)
                        .padding()
                }
            }
            .toolbar {
                if showRefresh {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {
                                Task {
                                    truthsList = []
                                    wrongsList = []
                                    isEditable = true
                                    isLoading = true
                                    await viewModel.downloadWords(url: Urls.wordsByNumber(number: 300))
                                    isLoading = false
                                    isEditable = false
                                }
                                
                                truths = 0
                                wrongs = 0
                                rate = 0
                                
                                timeRemaining = 60
                                
                                showRefresh = false
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            })
                        }
                    }
                }
            }
        }.onAppear {
            Task {
                isEditable = true
                isLoading = true
                await viewModel.downloadWords(url: Urls.wordsByNumber(number: 300))
                isLoading = false
                isEditable = false
            }
        }.onChange(of: text) {
            if text.rangeOfCharacter(from: CharacterSet.letters) != nil {
                startTimerIfNeeded()
                
                text = text.prefix(1).lowercased() + text.dropFirst()
                
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
            } else {
                text = ""
            }
        }.alert("Time's up!", isPresented: $showAlert) {
            Button(action: {
                Task {
                    isEditable = true
                    isLoading = true
                    await viewModel.downloadWords(url: Urls.wordsByNumber(number: 300))
                    isLoading = false
                    isEditable = false
                }
                
                let currentRecord = UserDefaults.standard.double(forKey: "rate")
                
                if rate > currentRecord {
                    UserDefaults.standard.set(truths, forKey: "rate")
                }
                
                truths = 0
                wrongs = 0
                rate = 0
                
                timeRemaining = 60
                
                showRefresh = false
                
            }, label: {
                Text("Play again!")
            })
            
            Button("OK!", role: .cancel) {
                isEditable = true
                showRefresh = true
                self.text = ""
                
                let currentRecord = UserDefaults.standard.double(forKey: "rate")
                if rate > currentRecord {
                    UserDefaults.standard.set(truths, forKey: "rate")
                }
            }
        } message: {
            let currentRecord = UserDefaults.standard.double(forKey: "rate")
            
            if rate <= currentRecord {
                Text("The time is over!\nTruths : \(truths)\tWrongs : \(wrongs)\tRate : \(String(format: "%.2f", rate))\nRecord : \(String(format: "%.2f", currentRecord))")
            } else {
                Text("The time is over!\nTruths : \(truths)\tWrongs : \(wrongs)\tRate : \(String(format: "%.2f", rate))\nCongratulations, you broke the record!\nRecord : \(String(format: "%.2f", rate))")
            }
        }

        
    }
    
    func startTimerIfNeeded() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    
                    showAlert = true
                    self.text = ""
                    if wrongs > 0 {
                        rate = Double(truths)/Double(wrongs)
                    } else {
                        rate = Double(truths)
                    }
                }
            }
        }
    }
}

#Preview {
    WordsView()
}
