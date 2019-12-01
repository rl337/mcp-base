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
        let currentPath = FileManager.default.currentDirectoryPath
        let bundlePath = Bundle.main.resourceURL!
        
        // let x = FileManager.default.urls(for: ., in: .userDomainMask)
        var day1InputFile = bundlePath


        do {
         var y = try FileManager.default.contentsOfDirectory(at: day1InputFile, includingPropertiesForKeys: nil, options: .init(arrayLiteral: .includesDirectoriesPostOrder))
         var z = 4
        } catch {
            
        }

        
        //day1InputFile.appendPathComponent("Day1", isDirectory: true)
        day1InputFile.appendPathComponent("input.txt")

        
        let i = IntFileIterator(contentsOf: day1InputFile)
        var sum = 0;
        for x in i {
            var xtotal = calculateFuel(ofMass: x)
            var fuelMass = calculateFuel(ofMass: xtotal)
            while fuelMass > 0 {
                xtotal += fuelMass
                fuelMass = calculateFuel(ofMass: fuelMass)
            }
            
            sum = sum + xtotal
        }

        
        return Text("Hello, World! " + String(sum))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
