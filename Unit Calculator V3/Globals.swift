//
//  Globals.swift
//  Unit Calculator V3
//
//  Created by Ruslan Kolesnik on 1/10/15.
//  Copyright (c) 2015 Ruslan Kolesnik. All rights reserved.
//

import Foundation

// Retuns an array of units given a unit category
func getUnitsList(unitCategory : String) -> [String]
{
    var units: [String] = []
    switch unitCategory
    {
        case "Area":
            units = ["Square Mile", "Square Yard", "Square Foot", "Square Inch", "Hectare", "Acre", "Square Kilometer", "Square Meter", "Square Centimeter", "Square Millimeter"]
        case "Length":
            units = ["Mile (nautical)", "Mile", "Yard", "Foot", "Inch", "Kilometer", "Meter", "Centimeter", "Millimeter"]
        case "Energy":
            units = ["Btus", "Calories", "Ergs", "Foot-Pounds", "Joules", "Kilogram-Calories", "Kilowatt-Hours", "Newton-Meters", "Watt-Hours"]
        case "Power":
            units = ["Btus/Minute", "Foot-Pounds/Minute", "Foot-Pounds/Second", "Horsepower", "kilowatts", "Watts"]
        case "Pressure":
            units = ["Pounds/Squaret Foot", "Pounds/Square Inch", "Atmospheres", "Bars", "Inches of Mercury", "Centimeters of Mercury", "Kilograms/Square Meter", "Pascals"]
        case "Speed":
            units = ["Knots", "Miles/Hour", "Miles/Minute", "Feet/Second", "Kilometers/Hour", "Kilometers/Minute", "Meters/Second"]
        case "Temperature":
            units = ["Celsius", "Fahrenheit", "Kelvin"]
        case "Time":
            units = ["Years", "Weeks", "Days", "Hours", "Minutes", "Seconds", "Miliseconds", "Microseconds", "Nanoseconds"]
        case "Weight":
            units = ["Short Ton (US)", "Pound (US)", "Ounce (US)", "Stone", "Long Ton (UK)", "Kilogram", "Gram"]
        case "Volume":
            units = ["Cubic Feet", "Gallon (Imperial)", "Gallon (US)", "Quart (US)", "Pint (US)", "Fluid Ounces (US)", "Cup", "Tablespoon", "Teaspoon", "Dram (US)", "Cubic Meter", "Liter"]
        default:
            units = []
    }
    
    return units
}