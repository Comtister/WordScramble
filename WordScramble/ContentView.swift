//
//  ContentView.swift
//  WordScramble
//
//  Created by Oguzhan Ozturk on 11.04.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords: [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Type your word",text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .toolbar(content: {
                Button("Start New Game") { startGame() }
            })
            .navigationTitle(rootWord)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onSubmit(addNewWord)
        .onAppear(perform: startGame)
        .alert(errorTitle, isPresented: $showError, actions: {
            Button("OK") {}
        }) {
            Text(errorMessage)
        }
    }
    
    private func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer != rootWord else {
            errorMessage = "This word is root word"
            showError = true
            return
        }
        guard answer.count > 3 else {
            errorMessage = "This Not Word"
            showError = true
            return }
        guard isOriginal(word: answer) else {
            errorMessage = "This word is not original"
            showError = true
            return }
        guard isPossible(word: answer) else {
            errorMessage = "This word is not possible"
            showError = true
            return }
        guard isReal(word: answer) else {
            errorMessage = "This word is not real"
            showError = true
            return }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
    }
    
    private func startGame() {
        
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let dataString = try? String(contentsOf: fileUrl) {
                let dataArray = dataString.components(separatedBy: "\n")
                rootWord = dataArray.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("File not read")
    }
    
    private func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isPossible(word: String) -> Bool {
        var tempWord = word
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    private func isReal(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        let result = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return result.location == NSNotFound
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
