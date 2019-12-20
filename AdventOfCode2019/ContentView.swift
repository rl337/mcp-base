//
//  ContentView.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import SwiftUI



struct OutputText: View {
    var entry: UIEntry
    
    var body: some View {
        Text(entry.message).font(.system(size: CGFloat(entry.size), design: entry.isMonospaced ? .monospaced : .default))
    }
}

struct LabeledText: View {
    var entry: UIEntry
    
    var body: some View {
        HStack{
            Text(entry.label!).bold()
            OutputText(entry: entry)
        }
    }
}


struct ErrorLabeledText: View {
    var entry: UIEntry
    
    var body: some View {
        HStack{
            Text("💣")
            Text(entry.label!).bold()
            OutputText(entry: entry)
        }
    }
}

struct ErrorText: View {
    var entry: UIEntry
    
    var body: some View {
        HStack{
            Text("💣")
            OutputText(entry: entry)
        }
    }
}

struct SolutionNavigationBar: View {
    @State var parent: ContentView
    
    var body: some View {
        let solutions = SolutionController.getInstance()
        return HStack {
            if solutions.hasPrev() {
                Button(action: {
                    solutions.selectPrev()
                    self.parent.solutionContent = solutions.execute()
                    self.parent.headerContent = solutions.heading()
                }) {
                    Text("⬅️")
                }
            } else {
                Text("⏹")
            }
            
            if solutions.hasNext() {
                Button(action: {
                    solutions.selectNext()
                    self.parent.solutionContent = solutions.execute()
                    self.parent.headerContent = solutions.heading()
                }) {
                    Text("➡️")
                }
            } else {
                Text("⏹")
            }
        }
    }
}

struct UIEntryList: View {
    var entries: [UIEntry]

    var body: some View {
        
        List {
            ForEach(entries) { entry in
                if entry.label != nil {
                    if entry.isError {
                        ErrorLabeledText(entry: entry)
                    } else {
                        LabeledText(entry: entry)
                    }
                } else {
                    if entry.isError {
                        ErrorText(entry: entry)
                    } else {
                        OutputText(entry: entry)
                    }
                }
            }
        }


    }
}

struct ContentView: View {
    @State var solutionContent: [UIEntry] =
        SolutionController.getInstance().execute()
    @State var headerContent: [UIEntry] =
        SolutionController.getInstance().heading()

    var body: some View {
        VStack {
            SolutionNavigationBar(parent: self)
            UIEntryList(entries: headerContent).frame(height: 100)
            Spacer()
            UIEntryList(entries: solutionContent)
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
