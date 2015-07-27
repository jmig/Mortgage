//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground, let's code a Mortgage simulator app"

//MARK: Helpers

//: We add a method on Int to easily display from a number of months, the number of year & months it represents.
extension Int {
    func toYearAndMonths() -> String {
        let years = self / 12
        let months = self % 12
        switch (years, months) {
        case _ where years > 0 && months > 0:
            return "\(years) Year(s) & \(months) Month(s)"
        case _ where years > 0:
            return "\(years) Year(s)"
        case _ where months > 0:
            return "\(months) Month(s)"
        default:
            return "Unknown"
        }
    }
}

infix operator ^^ { }
func ^^ (radix: Float, power: Int) -> Float {
    return Float(pow(Double(radix), Double(power)))
}

//MARK: Models

struct MortgagePayment {
    let principal: Float
    let interest: Float
    var total: Float {
        return principal + interest
    }

    init(principal: Float, interest: Float) {
        self.principal = principal
        self.interest = interest
    }

    init(total: Float, interest: Float) {
        self.principal = total - interest
        self.interest = interest
    }
}

class Mortgage {
    let yearlyInterestRate: Float
    var monthlyInterestRate: Float {
        return yearlyInterestRate / 12
    }
    let years: Int
    var months: Int {
        return years * 12
    }
    let amount: Float
    var balance: Float
    var actualInterestPaid: Float

    init(amount: Float, years: Int, yearlyInterestRate: Float) {
        self.amount = amount
        self.years = years
        self.yearlyInterestRate = yearlyInterestRate
        self.balance = amount
        self.actualInterestPaid = 0
    }

    func requiredMonthlyPayment() -> Float {
        //    M = P[i(1+i)^n]/[(1+i)^n -1]
        let oneplusipown = (1 + monthlyInterestRate)^^months
        return (amount * ((monthlyInterestRate * oneplusipown) / (oneplusipown - 1)))
    }

    func theoricalTotalInterestPaid() -> Float {
        let totalPayment = requiredMonthlyPayment() * Float(months)
        return totalPayment - amount;
    }

    func nextPayment(extraPayment: Float) -> MortgagePayment {
        let interestDue = balance * monthlyInterestRate
        let requiredPayment = requiredMonthlyPayment()

        if (requiredPayment > balance) {
            return MortgagePayment(principal: balance, interest: 0)
        }

        return MortgagePayment(total: requiredPayment + extraPayment, interest: interestDue)
    }

    func applyPayment(payment: MortgagePayment) {
        balance -= payment.principal
        actualInterestPaid += payment.interest
    }
}


//MARK: Mortgage Params
let homeValue: Float = 500000.00;
let interestRatePercentage: Float = 3.9/100
let durationInYears = 30
let downPaymentPercentage: Float = 20.0/100
let monthlyExtraPayment: Float = 750.00
let anuallyExtraPayment: Float = 1000.00

let currencyFormatter = NSNumberFormatter()
currencyFormatter.numberStyle = .CurrencyStyle

let percentageFormatter = NSNumberFormatter()
percentageFormatter.numberStyle = .PercentStyle


func mortgageAmount(homeValue : Float, downPaymentPercentage: Float) -> Float {
    return (homeValue - homeValue*downPaymentPercentage)
}
let amount = mortgageAmount(homeValue, downPaymentPercentage)
println("For a \(currencyFormatter.stringFromNumber(NSNumber(float: homeValue))!) home, with a \(percentageFormatter.stringFromNumber(NSNumber(float: downPaymentPercentage))!) downpayment, your mortgage amount will be : \(currencyFormatter.stringFromNumber(NSNumber(float: amount))!) \n")


let mortgage = Mortgage(amount: amount, years: durationInYears, yearlyInterestRate: interestRatePercentage)
let monthlyPayment = mortgage.requiredMonthlyPayment()
println("Your monthly payment will be \(currencyFormatter.stringFromNumber(NSNumber(float: monthlyPayment))!) \n")


let totalInterestPaid = mortgage.theoricalTotalInterestPaid()
println("Your total interest paid (if you pay only the required payment) will be \(currencyFormatter.stringFromNumber(NSNumber(float: totalInterestPaid))!) \n")


//MARK: Amortization

var month = 1
while (mortgage.balance > 0) {
    let extraPayment = (month % 12 == 0) ? monthlyExtraPayment + anuallyExtraPayment : monthlyExtraPayment

    let payment = mortgage.nextPayment(extraPayment)
    println("Payment : \(currencyFormatter.stringFromNumber(NSNumber(float: payment.principal))!) + \(currencyFormatter.stringFromNumber(NSNumber(float: payment.interest))!) = \(currencyFormatter.stringFromNumber(NSNumber(float: payment.total))!)")
    mortgage.applyPayment(payment)
    println("\(month.toYearAndMonths()) --- Balance is \(currencyFormatter.stringFromNumber(NSNumber(float: mortgage.balance))!) \n")
    month++
}

println("Your total interest paid are \(currencyFormatter.stringFromNumber(NSNumber(float: mortgage.actualInterestPaid))!) \n")

if (mortgage.theoricalTotalInterestPaid() > mortgage.actualInterestPaid) {
    let interestSaving = mortgage.theoricalTotalInterestPaid()-mortgage.actualInterestPaid
    println("You saved  \(currencyFormatter.stringFromNumber(NSNumber(float: interestSaving))!) in interest with those extra  payments\n")
}

