//
//  Expression.swift
//  Unit Calculator V3
//
//  Created by Ruslan Kolesnik on 12/20/14.
//  Copyright (c) 2014 Ruslan Kolesnik. All rights reserved.
//

import Foundation

class Expression
{
    var tokens: [(type: TokenType, value: NSString)] = []
    
    func addToken(token: (type: TokenType, value: NSString))
    {
        self.tokens.append(token)
    }
    
    func changeLastToken(token: (type: TokenType, value: NSString))
    {
        if self.tokens.count > 0
        {
            self.tokens[self.tokens.count - 1] = token
        }
    }
    
    func appendToLastToken(value: NSString)
    {
        if self.tokens.count > 0
        {
            self.tokens[self.tokens.count - 1].value = self.tokens[self.tokens.count - 1].value + value
        }
    }
    
    func removeLastToken()
    {
        if self.tokens.count > 0
        {
            self.tokens.removeLast()
        }
    }
    
    func clearTokens()
    {
        self.tokens.removeAll(keepCapacity: true)
    }
    
    // Evaluates reverse polish notation expresion using postfix algorithm http://en.wikipedia.org/wiki/Reverse_Polish_notation
    func evaluate() -> String
    {
        let rpnTokens: [(type: TokenType, value: NSString)] = getRpnTokens()
        var numberStack: [Double] = []
    
        for token in rpnTokens
        {
            if token.type == .Number
            {
                numberStack.append(token.value.doubleValue)
            }
            else
            {
                let operatr: (value: NSString, presedence: Int, associativity: Associativity, priori: Int) = getOperatorInfo(token.value)!
                if numberStack.count < operatr.priori
                {
                    // ERROR
                    println("ERROR: insufficient values in expression")
                }
                else
                {
                    
                    if let result = evaluateExpression(argument1: numberStack[numberStack.count - 2], argument2: numberStack[numberStack.count - 1], op: operatr.value)
                    {
                        for var i = 0; i < operatr.priori; i++
                        {
                            numberStack.removeLast()
                            println("Removing from RPN Stack")
                        }
                        numberStack.append(result)
                    }
                }
            }
        }
        
        if numberStack.count == 1
        {
            return "\(numberStack.last! as NSNumber)"
        }
        else
        {
            // ERROR
            return ""
        }
    }
    
    private func evaluateExpression(argument1 arg1: Double, argument2 arg2: Double, op operatr: NSString) -> Double?
    {
        println("ARG1 = \(arg1)     OP = \(operatr)       ARG2 = \(arg2)")
        switch operatr
        {
        case "+":
            return arg1 + arg2
        case "-":
            return arg1 - arg2
        case "÷":
            return arg1 / arg2
        case "×":
            return arg1 * arg2
        default:
            return nil
        }

    }
    
    // Returns tokens in Reverse Polish Notation (using shunting yard algorithm)
    private func getRpnTokens() -> [(type: TokenType, value: NSString)]
    {
        var rpnTokens: [(type: TokenType, value: NSString)] = []
        var operatorStack: [(value: NSString, presedence: Int, associativity: Associativity, prioiri: Int )] = []
        for token in self.tokens
        {
            if token.type == TokenType.Number
            {
                rpnTokens.append(type: .Number, value: token.value)
            }
            if token.type == TokenType.Operator
            {
                let operatr: (value: NSString, presedence: Int, associativity: Associativity, priori: Int) = getOperatorInfo(token.value)!
                
                
                while  !operatorStack.isEmpty &&
                    ((operatr.associativity == .Left && operatr.presedence <= operatorStack.last!.presedence)
                    ||
                    (operatr.associativity == .Right && operatr.presedence < operatorStack.last!.presedence))
                {
                    rpnTokens.append(type: .Operator, value: operatorStack.last!.value)
                    operatorStack.removeLast()
                    
                }
                operatorStack += [operatr]
            }
        }
        while(!operatorStack.isEmpty)
        {
            rpnTokens.append(type: .Operator, value: operatorStack.last!.value)
            operatorStack.removeLast()
        }
        return rpnTokens
    }
    
    func getOperatorInfo(operatr: NSString) -> (value: NSString, presedence: Int, associativity: Associativity, priori: Int)?
    {
        switch operatr
        {
            case "+":
                return (value: operatr, presedence: 2, associativity: .Left, priori: 2)
            case "-":
                return (value: operatr, presedence: 2, associativity: .Left, priori: 2)
            case "÷":
                return (value: operatr, presedence: 3, associativity: .Left, priori: 2)
            case "×":
                return (value: operatr, presedence: 3, associativity: .Left, priori: 2)
            default:
                return nil
            
        }
    }
    
    func getStringRepresentation() -> NSString
    {
        var str = ""
        for token in self.tokens
        {
            str += token.value
        }
        return str
    }

    private func isOperator(c: Character) -> Bool
    {
        return c == "×" || c == "÷" || c == "+" || c == "-" || c == "%"
    }
    
    private func isDigit(c : Character) -> Bool
    {
        return c >= "0" && c <= "9"
    }
    
}