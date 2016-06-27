//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground, let's code a Mortgage simulator app"

//MARK: - Helpers

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

extension NumberFormatter {
  func string(from float: Float) -> String {
    let number = NSNumber(value: float)
    if let string = self.string(from: number) {
      return string
    } else {
      return ""
    }
  }
}

infix operator ^^ { associativity left precedence 160 }
func ^^ (left: Float, right: Int) -> Float {
    return powf(left, Float(right))
}

//MARK: - Models

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
      //FIXME: Highly unefficient
        //    M = P[i(1+i)^n]/[(1+i)^n -1]
        return (amount * ((monthlyInterestRate * (1 + monthlyInterestRate)^^months) / ((1 + monthlyInterestRate)^^months - 1)))
    }

    func theoricalTotalInterestPaid() -> Float {
        let totalPayment = requiredMonthlyPayment() * Float(months)
        return totalPayment - amount;
    }
}

//MARK: Mortgage Payment

extension Mortgage {
  func next(extraPayment: Float) -> MortgagePayment {
    let requiredPayment = requiredMonthlyPayment()
    if (requiredPayment > balance) {
      return MortgagePayment(principal: balance, interest: 0)
    }

    let maximumPossiblePayment = min(requiredPayment+extraPayment, balance)
    let interestDue = balance * monthlyInterestRate
    return MortgagePayment(total: maximumPossiblePayment, interest: interestDue)
  }

  func apply(payment: MortgagePayment) {
    balance -= payment.principal
    actualInterestPaid += payment.interest
  }
}


//MARK: Mortgage Params
let homeValue: Float = 500000.00;
let interestRatePercentage: Float = 3.75/100
let durationInYears = 30
let downPaymentPercentage: Float = 20.0/100
let monthlyExtraPayment: Float = 0.00
let anuallyExtraPayment: Float = 0.00

let currencyFormatter = NumberFormatter()
currencyFormatter.numberStyle = .currency

let percentageFormatter = NumberFormatter()
percentageFormatter.numberStyle = .percent


func mortgageAmount(homeValue : Float, downPaymentPercentage: Float) -> Float {
    return (homeValue - homeValue*downPaymentPercentage)
}
let amount = mortgageAmount(homeValue: homeValue, downPaymentPercentage: downPaymentPercentage)
print("For a \(currencyFormatter.string(from: homeValue)) home, with a \(percentageFormatter.string(from:  downPaymentPercentage)) downpayment, your mortgage amount will be : \(currencyFormatter.string(from: amount)) \n")


let mortgage = Mortgage(amount: amount, years: durationInYears, yearlyInterestRate: interestRatePercentage)
let monthlyPayment = mortgage.requiredMonthlyPayment()
print("Your monthly payment will be \(currencyFormatter.string(from: monthlyPayment)) \n")


let totalInterestPaid = mortgage.theoricalTotalInterestPaid()
print("Your total interest paid (if you pay only the required payment) will be \(currencyFormatter.string(from: totalInterestPaid)) \n")


//MARK: Amortization

var month = 1
while (mortgage.balance > 0) {
    let extraPayment = (month % 12 == 0) ? monthlyExtraPayment + anuallyExtraPayment : monthlyExtraPayment

    let payment = mortgage.next(extraPayment: extraPayment)
    print("Payment : \(currencyFormatter.string(from: payment.principal)) + \(currencyFormatter.string(from: payment.interest)) = \(currencyFormatter.string(from: payment.total))")
    mortgage.apply(payment: payment)
    print("\(month.toYearAndMonths()) --- Balance is \(currencyFormatter.string(from: mortgage.balance)) \n")
    month = month+1
}

print("Your total interest paid are \(currencyFormatter.string(from: mortgage.actualInterestPaid)) \n")

if (mortgage.theoricalTotalInterestPaid() > mortgage.actualInterestPaid) {
    let interestSaving = mortgage.theoricalTotalInterestPaid()-mortgage.actualInterestPaid
    print("You saved \(currencyFormatter.string(from: interestSaving)) in interest with those extra payments\n")
}

