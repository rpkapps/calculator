//
//  ViewController.swift
//  Unit Calculator V3
//
//  Created by Ruslan Kolesnik on 12/9/14.
//  Copyright (c) 2014 Ruslan Kolesnik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var operand1: Double = 0
    var operand2: Double = 0
    var operatr: String = ""    // operator is a reserved word
    var passiveDisplayArray: [String] = []
    var expression: Expression = Expression()
    var previousOperatorButton: UIButton?
    var expressionArray: [String] = []
    var operatorArray: [String] = []
    
    var state: CalcState = CalcState.Clear
    
    @IBOutlet weak var activeCalcDisplay: UILabel!
    @IBOutlet weak var passiveDisplay: UITableView!
    @IBOutlet weak var numpadView: UIView!
    @IBOutlet weak var numpadContainerView: UIView!
    @IBOutlet weak var numpadContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var unitsButton: UIButton!
    @IBOutlet weak var numpadArrowImage: UIImageView!
    
    
    @IBAction func unitsButtonTapped(sender: UIButton)
    {
        println("UNITS TAPPED")
    }

    @IBAction func numpadArrowTapped(sender: UITapGestureRecognizer)
    {
        var startingConstraint = -self.numpadView.frame.height - self.unitsButton.frame.height/1.5
        var endingConstraint: CGFloat = 0
        if self.numpadContainerViewBottomConstraint.constant == startingConstraint
        {
            animateNumpadView(initialVelocity: 20, animationDirection: Direction.Up, endingConstraintPosition: endingConstraint)
        }
    }

    @IBAction func dragNumpad(recognizer: UIPanGestureRecognizer)
    {
        var yVelocity = recognizer.velocityInView(self.view).y
        var yVelocityThreshold: CGFloat = 200
        var endConstraint = -self.numpadView.frame.height - self.unitsButton.frame.height/1.5
        var startConstraint: CGFloat = 0
        let translation = recognizer.translationInView(self.view)
        
        self.numpadContainerViewBottomConstraint.constant +=  -translation.y
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        // Interpolate alpha value of unitsButton
        self.unitsButton.alpha = (self.numpadContainerViewBottomConstraint.constant - endConstraint) / ((3 * (endConstraint - startConstraint) / 4) - endConstraint)
        
        if(yVelocity > 0)
        {
            self.numpadArrowImage.image =  UIImage(named: "ArrowDown")
        }
        else
        {
            self.numpadArrowImage.image = UIImage(named: "ArrowUp")
        }
        // Add spring animation when view is dragged down
        if  (
                (self.numpadContainerViewBottomConstraint.constant < endConstraint / 4 || yVelocity > yVelocityThreshold)
                && recognizer.state == UIGestureRecognizerState.Ended
                && (yVelocity > 0 || (self.numpadContainerViewBottomConstraint.constant < 3 * endConstraint / 4 && yVelocity > -yVelocityThreshold))
            )
            || self.numpadContainerViewBottomConstraint.constant < endConstraint
        {
            animateNumpadView(initialVelocity: yVelocity/60, animationDirection: Direction.Down, endingConstraintPosition: endConstraint)
            return
        }
        // Add spring animation when view is dragged up
        if  (
                (self.numpadContainerViewBottomConstraint.constant > 3 * endConstraint / 4 || yVelocity < -yVelocityThreshold)
                && recognizer.state == UIGestureRecognizerState.Ended
                && (yVelocity < 0 || (self.numpadContainerViewBottomConstraint.constant > endConstraint / 4 && yVelocity < yVelocityThreshold))
            )
            || self.numpadContainerViewBottomConstraint.constant > startConstraint + 50
            
        {
            animateNumpadView(initialVelocity: yVelocity/60, animationDirection: Direction.Up, endingConstraintPosition: startConstraint)
            return
        }
    }
    
    @IBAction func percentTapped(sender: UIButton)
    {
        var percentValue: Double = 0;
        switch self.state
        {
            case CalcState.Result:
                fallthrough
            case CalcState.Operand1:
                fallthrough
            case CalcState.Operand1Percent:
                fallthrough
            case CalcState.Operand1Dot:
                percentValue = (self.activeCalcDisplay.text! as NSString).doubleValue / 100
                self.activeCalcDisplay.text = "\(percentValue as NSNumber)"
                self.expression.addToken((type: TokenType.Operator, value: "%"))
                self.state = CalcState.Operand1Percent
            case CalcState.Operand2:
                fallthrough
            case CalcState.Operand2Percent:
                fallthrough
            case CalcState.Operand2Dot:
                if self.operatr == "×" || self.operatr == "÷"
                {
                    percentValue = (self.activeCalcDisplay.text! as NSString).doubleValue / 100
                    self.activeCalcDisplay.text = "\(percentValue as NSNumber)"
                }
                else
                {
                    percentValue = ((self.activeCalcDisplay.text! as NSString).doubleValue  / 100) * self.operand1
                    self.activeCalcDisplay.text = "\(percentValue as NSNumber)"
                }
                self.operand2 = percentValue
                self.expression.addToken((type: TokenType.Operator, value: "%"))
                self.state = CalcState.Operand2Percent
            case CalcState.OpEntered:
                /*
                if self.operatr == "×" || self.operatr == "÷"
                {
                    percentValue = self.operand1 / 100
                    self.activeCalcDisplay.text = "\(percentValue as NSNumber)"
                }
                else
                {
                    percentValue = (self.operand1 / 100) * self.operand1
                    self.activeCalcDisplay.text = "\(percentValue as NSNumber)"
                }
                self.operand2 = percentValue
                self.expression += "%"
                self.state = CalcState.Operand2Percent*/
                break
            default:
                break
        }
    }
    
    @IBAction func numberTapped(sender: UIButton)
    {
        var digit: String = ""
        
        if sender.currentTitle != nil
        {
            digit = sender.currentTitle!
        }
        
        // Unhighlight last touched operator button
        if let operatorButton = self.previousOperatorButton
        {
            operatorButton.selected = false
        }
        
        switch self.state
        {
            case CalcState.Clear:
                self.activeCalcDisplay.text = digit
                self.expression.addToken((type: TokenType.Number, value: digit))
                self.state = CalcState.Operand1
            case CalcState.Operand1:
                fallthrough
            case CalcState.Operand1Dot:
                fallthrough
            case CalcState.Operand2Dot:
                fallthrough
            case CalcState.Operand2:
                self.activeCalcDisplay.text = self.activeCalcDisplay.text! + digit
                self.expression.appendToLastToken(digit)
            case CalcState.Result:
                self.activeCalcDisplay.text = digit
                self.expression.addToken((type: TokenType.Number, value: digit))
                self.state = CalcState.Operand1
            case CalcState.OpEntered:
                self.activeCalcDisplay.text = digit
                self.expression.addToken((type: TokenType.Number, value: digit))
                self.state = CalcState.Operand2
            case CalcState.Operand1Percent:
                fallthrough
            case CalcState.Operand2Percent:
                self.activeCalcDisplay.text = digit
                self.state = CalcState.Operand1
            default:
                break
        }
    }
    
    @IBAction func dotTapped(sender: UIButton)
    {
        // Unhighlight last touched operator button
        if let operatorButton = self.previousOperatorButton
        {
            operatorButton.selected = false
        }
        
        switch self.state
        {
            case CalcState.Operand1:
                self.activeCalcDisplay.text = self.activeCalcDisplay.text! + "."
                self.expression.appendToLastToken(".")
                self.state = CalcState.Operand1Dot
            case CalcState.Operand1Dot:
                break
            case CalcState.Operand2Dot:
                break
            case CalcState.Operand2:
                fallthrough
            case CalcState.OpEntered:
                self.activeCalcDisplay.text = "0."
                self.expression.addToken((type: TokenType.Number, value: "0."))
                self.state = CalcState.Operand2Dot
            case CalcState.Clear:
                fallthrough
            case CalcState.Operand1Percent:
                fallthrough
            case CalcState.Operand2Percent:
                fallthrough
            case CalcState.Result:
                self.activeCalcDisplay.text = "0."
                self.expression.addToken((type: TokenType.Number, value: "0."))
                self.state = CalcState.Operand1Dot
            default:
                break
        }
    }
    
    
    @IBAction func clearTapped(sender: UIButton)
    {
        // Unhighlight last touched operator button
        if let operatorButton = self.previousOperatorButton
        {
            operatorButton.selected = false
        }
        
        self.activeCalcDisplay.text = "0"
        self.operand1 = 0
        self.operand2 = 0
        self.operatr = ""
        self.expression.clearTokens()
        self.state = CalcState.Clear
        passiveDisplayClear()
        passiveDisplayAddLine("")
    }

    @IBAction func arithmeticOperandTapped(sender: UIButton)
    {
        var arithmeticOperand: String = ""
        
        if sender.currentTitle != nil
        {
            arithmeticOperand = sender.currentTitle!
        }
        
        // Highlight the last touched arithmetic operator button
        if let operatorButton = self.previousOperatorButton
        {
            operatorButton.selected = false
        }
        self.previousOperatorButton = sender
        
        switch self.state
        {
            case CalcState.Clear:
                break
            case CalcState.Operand1:
                fallthrough
            case CalcState.Operand1Percent:
                fallthrough
            case CalcState.Operand1Dot:
                self.operatr = arithmeticOperand
                self.operand1 = (self.activeCalcDisplay.text! as NSString).doubleValue
                self.expression.addToken((type: TokenType.Operator, value: arithmeticOperand))
                self.state = CalcState.OpEntered
                sender.selected = true
            case CalcState.Operand2:
                fallthrough
            case CalcState.Operand2Percent:
                fallthrough
            case CalcState.Operand2Dot:
                self.operand2 = (self.activeCalcDisplay.text! as NSString).doubleValue
                self.activeCalcDisplay.text = self.expression.evaluate()
                self.operatr = arithmeticOperand
                self.operand1 = (self.activeCalcDisplay.text! as NSString).doubleValue
                self.expression.addToken((type: TokenType.Operator, value: arithmeticOperand))
                self.state = CalcState.OpEntered
                sender.selected = true
            case CalcState.OpEntered:
                self.operatr = arithmeticOperand
                self.expression.changeLastToken((type: TokenType.Operator, value: arithmeticOperand))
                sender.selected = true
            case CalcState.Result:
                self.operatr = sender.currentTitle!
                self.operand1 = (self.activeCalcDisplay.text! as NSString).doubleValue
                self.expression.addToken((type: TokenType.Number, value: self.activeCalcDisplay.text!))
                self.expression.addToken((type: TokenType.Number, value: arithmeticOperand))
                self.state = CalcState.OpEntered
                sender.selected = true
            default:
                break
        }
        passiveDisplayUpdateLastLine(self.expression.getStringRepresentation())
    }
    
    
    @IBAction func equalsTapped(sender: UIButton)
    {
        // Unhighlight last touched operator button
        if let operatorButton = self.previousOperatorButton
        {
            operatorButton.selected = false
        }
        
        switch self.state
        {
            case CalcState.Clear:
                self.expression.addToken((type: TokenType.Number, value: "0"))
                self.state = CalcState.Result
            case CalcState.Operand1:
                fallthrough
            case CalcState.Operand1Percent:
                fallthrough
            case CalcState.Operand1Dot:
                self.state = CalcState.Result
            case CalcState.Operand2:
                fallthrough
            case CalcState.Operand2Percent:
                fallthrough
            case CalcState.Operand2Dot:
                self.operand2 = (self.activeCalcDisplay.text! as NSString).doubleValue
                self.activeCalcDisplay.text = self.expression.evaluate()
                self.state = CalcState.Result
            case CalcState.Result:
                self.expression.addToken((type: TokenType.Number, value: self.activeCalcDisplay.text!))
                self.activeCalcDisplay.text = self.expression.evaluate()
            case CalcState.OpEntered:
                self.expression.removeLastToken()
                self.state = CalcState.Result
            default:
                break
        }
        //self.expression += "=" + self.activeCalcDisplay.text!;
        let equation = self.expression.getStringRepresentation() + "=" + self.expression.evaluate()
        passiveDisplayUpdateLastLine(equation)
        passiveDisplayAddLine("")
        self.expression.clearTokens()
    }
    
    func computeExpression()
    {
        var result: Double = 0
        
        switch self.operatr
        {
            case "+":
                result = self.operand1 + self.operand2
            case "-":
                result = self.operand1 - self.operand2
            case "÷":
                result = self.operand1 / self.operand2
            case "×":
                result = self.operand1 * self.operand2
            default:
                result = (self.activeCalcDisplay.text! as NSString).doubleValue;
            }
        self.activeCalcDisplay.text = "\(result as NSNumber)"
    }
    
    func animateNumpadView(initialVelocity velocity:CGFloat, animationDirection direction: Direction, endingConstraintPosition endingConstraint: CGFloat)
    {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.95, initialSpringVelocity: abs(velocity), options: nil, animations: {
            self.numpadContainerViewBottomConstraint.constant = endingConstraint
            println(endingConstraint)
            switch direction
            {
            case Direction.Down:
                self.unitsButton.alpha = 0
                self.numpadArrowImage.image = UIImage(named: "ArrowUp")
            case Direction.Up:
                self.unitsButton.alpha = 1
                self.numpadArrowImage.image = UIImage(named: "ArrowDown")
            default:
                break
            }
            
            self.view.layoutIfNeeded()
            }, completion: {(value: Bool) in
                
                println("COMPLETE")})
    }
    
    
    func passiveDisplayAddLine(content : String)
    {
        self.passiveDisplayArray.append(content)
        let indexPath = NSIndexPath(forRow: self.passiveDisplayArray.count - 1, inSection: 0)
        self.passiveDisplay.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.passiveDisplay.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func passiveDisplayUpdateLastLine(content : String)
    {
        let lastLineIndex = self.passiveDisplayArray.count - 1;
        self.passiveDisplayArray[lastLineIndex] = content
        let indexPath = NSIndexPath(forRow: lastLineIndex, inSection: 0)
        self.passiveDisplay.cellForRowAtIndexPath(indexPath)?.textLabel?.text = content
        self.passiveDisplay.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func passiveDisplayClear()
    {
        self.passiveDisplayArray.removeAll(keepCapacity: true)
        self.passiveDisplay.reloadData()
    }
    
    func passiveDisplayScrollToBottom()
    {
        let lastLineIndex = self.passiveDisplayArray.count - 1;
        let indexPath = NSIndexPath(forRow: lastLineIndex, inSection: 0)
        self.passiveDisplay.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        passiveDisplayAddLine("")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.passiveDisplayArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.passiveDisplayArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Right
        cell.textLabel?.font = UIFont(name: "Simplifica", size: 40)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


}

