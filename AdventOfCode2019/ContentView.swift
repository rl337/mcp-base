//
//  ContentView.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        var output = ""
        let solutions = SolutionController.getInstance();
        let elements = solutions.execute()
        for element in elements {

            if let label = element.label {
                output = output + label + ": "
            }

            if element.isError {
                output = output + "ERROR! -- "
            }
            output = output + element.message + "\n"
        }
        return Text(output).font(.system(.body, design: .monospaced))
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
