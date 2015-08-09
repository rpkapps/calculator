//
//  Enums.swift
//  Unit Calculator V3
//
//  Created by Ruslan Kolesnik on 12/20/14.
//  Copyright (c) 2014 Ruslan Kolesnik. All rights reserved.
//

import Foundation

enum CalcState
{
    case Clear, Operand1, Operand2, Result, OpEntered, Operand1Dot, Operand2Dot, Error, Operand1Percent, Operand2Percent
}

enum Direction
{
    case Up, Down, Left, Right
}

enum TokenType
{
    case Number, Operator
}

enum Associativity
{
    case Right, Left
}