import UIKit

var things = Any[]()

things.append(0)
things.append(0.0)
things.append(42)
things.append(3.14159)
things.append("hello")
things.append((3.0, 5.0))

func stuff(thing: Any) -> String {
    switch thing {
    case 0 as Int:
        return "zero as an Int"
    case 0 as Double:
        return "zero as a Double"
    case let someInt as Int:
        return "an integer value of \(someInt)"
    case let someDouble as Double where someDouble > 0:
        return "a positive double value of \(someDouble)"
    case is Double:
        return "some other double value that I don't want to print"
    case let someString as String:
        return "a string value of \"\(someString)\""
    case let (x, y) as (Double, Double):
        return "an (x, y) point at \(x), \(y)"
    case let obj as NSObject:
        return "an object protocol"
    default:
        return "something else"
    }
}

stuff(things[4])

let v = 12
let i = Int.self
let a = stuff

protocol blarg {}

NSNumber.numberWithInteger(1).conformsToProtocol(NSObjectProtocol)

