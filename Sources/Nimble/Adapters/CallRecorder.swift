import Foundation

// MARK: Helper Objects

public enum Argument: CustomStringConvertible, GloballyEquatable, Equatable {
    case anything
    case nonNil
    case nil_
    case instanceOf(type: Any.Type)

    public var description: String {
        switch self {
        case .anything:
            return "Argument.anything"
        case .nonNil:
            return "Argument.nonNil"
        case .nil_:
            return "Argument.nil_"
        case .instanceOf(let type):
            return "Argument.instanceOf(\(type))"
        }
    }

    public static func == (lhs: Argument, rhs: Argument) -> Bool {
        switch (lhs, rhs) {
        case (.anything, .anything):
            return true
        case (.nonNil, .nonNil):
            return true
        case (.nil_, .nil_):
            return true
        case (let .instanceOf(lhsType), let .instanceOf(rhsType)):
            return lhsType == rhsType
        default:
            return false
        }
    }
}

public struct DidCallResult {
    public let success: Bool
    public let recordedCallsDescription: String
}

public enum CountSpecifier {
    case exactly(Int)
    case atLeast(Int)
    case atMost(Int)
}

// MARK: CallRecorder Protocol

public protocol CallRecorder: class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var called = (functionList: [String](), argumentsList: [[GloballyEquatable]]())
    var called: (functionList: [String], argumentsList: [[GloballyEquatable]]) {get set}

    // **MUST** call in every method you want to spy
    func recordCall(function: String, arguments: GloballyEquatable...)

    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()

    // For Internal Use ONLY
    func didCall(function: String, withArguments arguments: Array<GloballyEquatable>, countSpecifier: CountSpecifier) -> DidCallResult
}

public extension CallRecorder {
    func recordCall(function: String = #function, arguments: GloballyEquatable...) {
        self.called.functionList.append(function)
        self.called.argumentsList.append(arguments)
    }

    func clearRecordedLists() {
        self.called.functionList = Array<String>()
        self.called.argumentsList = Array<Array<GloballyEquatable>>()
    }

    func didCall(function: String, withArguments arguments: Array<GloballyEquatable> = [GloballyEquatable](), countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
        case .exactly(let count): success = timesCalled(function, with: arguments) == count
        case .atLeast(let count): success = timesCalled(function, with: arguments) >= count
        case .atMost(let count): success = timesCalled(function, with: arguments) <= count
        }

        let recordedCallsDescription = descriptionOfCalls(functionList: self.called.functionList, argumentsList: self.called.argumentsList)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }

    // MARK: Protocol Extention Helper Functions

    private func timesCalled(_ function: String, with arguments: Array<GloballyEquatable>) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.called.functionList, argsList: arguments, argsLists: self.called.argumentsList)
    }
}

// MARK: Private Helper Functions

private func numberOfMatchingCalls(function: String, functions: Array<String>, argsList: Array<GloballyEquatable>, argsLists: Array<Array<GloballyEquatable>>) -> Int {
    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    guard argsList.count != 0 else {
        return functions.reduce(0) { $1 == function ? $0 + 1 : $0 }
    }

    let potentialMatchIndexes = matchingIndexesFor(functionName: function, functionList: functions)
    var correctCallsCount = 0

    for index in potentialMatchIndexes {
        let recordedArgsList = argsLists[index]
        if isEqualArgsLists(passedArgs: argsList, recordedArgs: recordedArgsList) {
            correctCallsCount += 1
        }
    }

    return correctCallsCount
}

private func matchingIndexesFor(functionName: String, functionList: Array<String>) -> [Int] {
    return functionList.enumerated().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
}

private func isEqualArgsLists(passedArgs: Array<GloballyEquatable>, recordedArgs: Array<GloballyEquatable>) -> Bool {
    if passedArgs.count != recordedArgs.count {
        return false
    }

    for index in 0..<recordedArgs.count {
        let passedArg = passedArgs[index]
        let recordedArg = recordedArgs[index]

        if !isEqualArgs(passedArg: passedArg, recordedArg: recordedArg) {
            return false
        }
    }

    return true
}

private func isEqualArgs(passedArg: GloballyEquatable, recordedArg: GloballyEquatable) -> Bool {
    if let passedArgAsArgumentEnum = passedArg as? Argument {
        switch passedArgAsArgumentEnum {
        case .anything:
            return true
        case .nonNil:
            return !isNil(recordedArg)
        case .nil_:
            return isNil(recordedArg)
        case .instanceOf(let type):
            let cleanedType = "\(type)".replaceMatching(regex: "\\.Type+$", withString: "")
            let cleanedRecordedArgType = "\(type(of: recordedArg))"

            return cleanedType == cleanedRecordedArgType
        }
    } else {
        return passedArg.isEqualTo(recordedArg)
    }
}

private func isNil(_ value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    let hasAValue = mirror.children.first?.value != nil

    return mirror.displayStyle == .optional && !hasAValue
}

private func descriptionOfCalls(functionList: Array<String>, argumentsList: Array<Array<GloballyEquatable>>) -> String {
    if functionList.isEmpty {
        return "<>"
    }

    return zip(functionList, argumentsList).reduce("") { (concatenatedString, element: (function: String, argumentList: Array<GloballyEquatable>)) -> String in
        var entry = element.function

        let parameterListStringRepresentation = element.argumentList.stringRepresentation()
        if !parameterListStringRepresentation.isEmpty {
            entry += " with " + parameterListStringRepresentation
        }
        entry = "<" + entry + ">"

        return concatenatedString.isEmpty ? entry : concatenatedString + ", " + entry
    }
}

// MARK: Private Extensions

private extension String {
    func replaceMatching(regex: String, withString string: String) -> String {
        return self.replacingOccurrences(of: regex, with: string, options: .regularExpression, range: nil)
    }
}

private extension Array {
    func stringRepresentation() -> String {
        return self.map { "\($0)" }.joined(separator: ", ")
    }
}
