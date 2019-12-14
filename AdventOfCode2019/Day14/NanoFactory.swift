//
//  NanoFactory.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/13/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

struct Ingredient: Hashable {
    var qty: Int
    var name: String
}

struct Recipe: Hashable {
    var inputs: [Ingredient]
    var output: Ingredient
}

class NanoFactory {
    var productions: [String:Recipe]
    var supply: [String:Int]
    var oreUsed: Int

    func trim(_ value: String) -> String {
        var copy = value
        while copy.first == " " || copy.first == "\n" {
            copy.removeFirst()
        }
        while copy.last == " " || copy.last == "\n" {
            copy.removeLast()
        }
        return copy
    }

    
    func parseIngredient(_ value: String) -> Ingredient {
        let parts = trim(value).components(separatedBy: " ")
        let qty = Int(parts[0])
        let name = parts[1]
        return Ingredient(qty: qty!, name: name)
    }
    
    init(recipes: String) {
        productions = [:]
        oreUsed = 0
        supply = [:]
        for recipeLine in trim(recipes).components(separatedBy: "\n") {
            let recipeParts = recipeLine.components(separatedBy: "=")
            var inputs: [Ingredient] = []
            for inputString in recipeParts[0].components(separatedBy: ",") {
                inputs.append(parseIngredient(inputString))
            }
            var outputString = recipeParts[1]
            outputString.removeFirst()
            let output: Ingredient = parseIngredient(outputString)
            productions[output.name] = Recipe(inputs: inputs, output: output)
        }
    }
    
    
    func get(_ ingredient: Ingredient) throws -> Int {
        var needed = ingredient.qty
        var usedSupply = 0
        if supply[ingredient.name] != nil {
            if supply[ingredient.name]! > needed {
                supply[ingredient.name]! -= needed
                return needed
            }
            usedSupply = supply[ingredient.name]!
            needed -= usedSupply
            supply.removeValue(forKey: ingredient.name)
        }
        
        guard let recipe = productions[ingredient.name] else {
            throw NanoFactoryError.ImpossibleProduction
        }
        
        var batchesToProduce = needed / recipe.output.qty
        if batchesToProduce * recipe.output.qty < needed {
            batchesToProduce += 1
        }
        
        for input in recipe.inputs {
            let inputToProduce = input.qty * batchesToProduce
            if input.name == "ORE" {
                oreUsed += inputToProduce
                continue
            }
            
            let produced = try get(Ingredient(qty: input.qty * batchesToProduce, name: input.name))
            if produced < inputToProduce {
                throw NanoFactoryError.ProductionQtyMathError
            }
            
            if produced > inputToProduce {
                supply[input.name] = produced - inputToProduce
            }
        }
        
        return batchesToProduce * recipe.output.qty + usedSupply
    }
        
    enum NanoFactoryError: Error {
        case ImpossibleProduction, ProductionQtyMathError

    }
}
