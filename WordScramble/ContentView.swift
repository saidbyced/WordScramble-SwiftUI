//
//  ContentView.swift
//  WordScramble
//
//  Created by Chris Eadie on 25/06/2020.
//  Copyright © 2020 ChrisEadieDesigns. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var totalScore = 0
    @State private var wordScore = 0
    @State private var showingScoringInfo = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Text("Your score")
                    .fontWeight(.bold)
                    .onTapGesture {
                        self.showingScoringInfo = true
                }
                HStack {
                    Text("This word: \(wordScore)")
                    Spacer(minLength: 5)
                    Text("Total: \(totalScore)")
                }
                .padding()
                List(usedWords.reversed(), id: \.self) {
                    Text($0)
                    Spacer()
                    Image(systemName: "\($0.count).circle")
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: { self.startGame() }) { Text("New Word") })
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
            .alert(isPresented: $showingScoringInfo, content: {
                Alert(title: Text("Scoring based on word length"), message: Text("2-4 letters: (length) points\n5-6 letters: (length + 1) points\n7 letters: 10 points\n8 letters: 15 points!"), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognised", message: "Use ONLY the letters from the word up top.")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "Yeah, that's not a real word.")
            return
        }
        
        guard isNotRootWord(word: answer) else {
            wordError(title: "Cheeky!", message: "You can just use the original word!")
            return
        }
        
        usedWords.append(answer)
        wordScore += scoreFor(answer)
        totalScore += scoreFor(answer)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                wordScore = 0
                
                return
            }
        }
        
        fatalError("Could not load start.txt from Bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isNotRootWord(word: String) -> Bool {
        !(word == rootWord)
    }
    
    func scoreFor(_ word: String) -> Int {
        switch word.count {
        case 2...4:
            return word.count
        case 5...6:
            return word.count + 1
        case 7:
            return word.count + 3
        case 8:
            return 15
        default:
            return 0
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
