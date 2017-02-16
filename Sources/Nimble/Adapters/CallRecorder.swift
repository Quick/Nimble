import Foundation

// MARK: OptionalType

public protocol OptionalType {}
extension Optional: OptionalType {}

// MARK: GloballyEquatable

// In order to use GloballyEquatable, conform to Equatable
public protocol GloballyEquatable {
    func isEqualTo(other: GloballyEquatable) -> Bool
}

public extension GloballyEquatable where Self : Equatable {
    public func isEqualTo(other: GloballyEquatable) -> Bool {
        // if 'self' is non-optional and 'other' is optional and other's .Some's associated value's type equals self's type
        // then the if let below will auto unwrap 'other' to be the non-optional version of self's type
        if self.dynamicType != other.dynamicType {
            return false
        }
        
        if let other = other as? Self {
            return self == other
        }
        
        return false
    }
}

public extension GloballyEquatable where Self : OptionalType {
    public func isEqualTo(other: GloballyEquatable) -> Bool {
        if self.dynamicType != other.dynamicType {
            return false
        }
        
        let selfMirror = Mirror(reflecting: self)
        let otherMirror = Mirror(reflecting: other)
        
        guard selfMirror.displayStyle == .Optional else {
            assertionFailure("\(self.dynamicType) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }
        guard otherMirror.displayStyle == .Optional else {
            assertionFailure("\(other.dynamicType) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }
        
        let selfsWrappedValue = selfMirror.children.first?.value
        let othersWrappedValue = otherMirror.children.first?.value
        
        if selfsWrappedValue == nil && othersWrappedValue == nil {
            return true
        }
        if selfsWrappedValue == nil || othersWrappedValue == nil {
            return false
        }
        
        guard let selfsContainedValueAsGE = selfsWrappedValue as? GloballyEquatable else {
            assertionFailure("\(selfsWrappedValue.dynamicType) does NOT conform to GloballyEquatable")
            return false
        }
        guard let othersContainedValueAsGE = othersWrappedValue as? GloballyEquatable else {
            assertionFailure("\(othersWrappedValue.dynamicType) does NOT conform to GloballyEquatable")
            return false
        }
        
        return selfsContainedValueAsGE.isEqualTo(othersContainedValueAsGE)
    }
}

// MARK: Helper Objects

public enum Argument : CustomStringConvertible, GloballyEquatable, Equatable {
    case Anything
    case NonNil
    case Nil
    case InstanceOf(type: Any.Type)
    case InstanceOfWith(type: Any.Type, option: ArgumentOption)
    case KindOf(type: AnyClass)
    
    public var description: String {
        switch self {
        case .Anything:
            return "Argument.Anything"
        case .NonNil:
            return "Argument.NonNil"
        case .Nil:
            return "Argument.Nil"
        case .InstanceOf(let type):
            return "Argument.InstanceOf(\(type))"
        case .InstanceOfWith(let input):
            return "Argument.InstanceOfWith(\(input.type), \(input.option))"
        case .KindOf(let type):
            return "Argument.KindOf(\(type))"
        }
    }
}

public func ==(lhs: Argument, rhs: Argument) -> Bool {
    switch (lhs, rhs) {
    case (.Anything, .Anything):
        return true
    case (.NonNil, .NonNil):
        return true
    case (.Nil, .Nil):
        return true
    case (let .InstanceOf(lhsType), let .InstanceOf(rhsType)):
        return lhsType == rhsType
    case (let .InstanceOfWith(lhsInput), let .InstanceOfWith(rhsInput)):
        return lhsInput.type == rhsInput.type && lhsInput.option == rhsInput.option
    case (let .KindOf(lhsType), let .KindOf(rhsType)):
        return lhsType == rhsType
    default:
        return false
    }
}

public enum ArgumentOption : CustomStringConvertible, GloballyEquatable {
    case Anything
    case NonOptional
    case Optional
    
    public var description: String {
        switch self {
        case .Anything:
            return "ArgumentOption.Anything"
        case .NonOptional:
            return "ArgumentOption.NonOptional"
        case .Optional:
            return "ArgumentOption.Optional"
        }
    }
}

public struct DidCallResult {
    public let success: Bool
    public let recordedCallsDescription: String
}

public enum CountSpecifier {
    case Exactly(Int)
    case AtLeast(Int)
    case AtMost(Int)
}

// MARK: CallRecorder Protocol

public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var called = (functionList: [String](), argumentsList: [[GloballyEquatable]]())
    var called: (functionList: [String], argumentsList: [[GloballyEquatable]]) {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: GloballyEquatable...)
    
    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()
    
    
    // For Internal Use ONLY
    func didCall(function function: String, withArguments arguments: Array<GloballyEquatable>, countSpecifier: CountSpecifier) -> DidCallResult
}

public extension CallRecorder {
    func recordCall(function function: String = #function, arguments: GloballyEquatable...) {
        self.called.functionList.append(function)
        self.called.argumentsList.append(arguments)
    }
    
    func clearRecordedLists() {
        self.called.functionList = Array<String>()
        self.called.argumentsList = Array<Array<GloballyEquatable>>()
    }
    
    func didCall(function function: String, withArguments arguments: Array<GloballyEquatable> = [GloballyEquatable](), countSpecifier: CountSpecifier = .AtLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
            case .Exactly(let count): success = timesCalled(function, arguments: arguments) == count
            case .AtLeast(let count): success = timesCalled(function, arguments: arguments) >= count
            case .AtMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }
        
        let recordedCallsDescription = descriptionOfCalls(functionList: self.called.functionList, argumentsList: self.called.argumentsList)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }
    
    // MARK: Protocol Extention Helper Functions
    
    private func timesCalled(function: String, arguments: Array<GloballyEquatable>) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.called.functionList, argsList: arguments, argsLists: self.called.argumentsList)
    }
}

// MARK: Private Helper Functions

private func numberOfMatchingCalls(function function: String, functions: Array<String>, argsList: Array<GloballyEquatable>, argsLists: Array<Array<GloballyEquatable>>) -> Int {
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

private func matchingIndexesFor(functionName functionName: String, functionList: Array<String>) -> [Int] {
    return functionList.enumerate().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
}

private func isEqualArgsLists(passedArgs passedArgs: Array<GloballyEquatable>, recordedArgs: Array<GloballyEquatable>) -> Bool {
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

private func isEqualArgs(passedArg passedArg: GloballyEquatable, recordedArg: GloballyEquatable) -> Bool {
    if let passedArgAsArgumentEnum = passedArg as? Argument {
        switch passedArgAsArgumentEnum {
        case .Anything:
            return true
        case .NonNil:
            return !isNil(recordedArg)
        case .Nil:
            return isNil(recordedArg)
        case .InstanceOf(let type):
            let cleanedType = "\(type)".replaceMatching(regex: "\\.Type+$", withString: "")
            let cleanedRecordedArgType = "\(recordedArg.dynamicType)"

            return cleanedType == cleanedRecordedArgType
        case .InstanceOfWith(let input):
            let isRecordedArgAnOptional = isOptional(recordedArg)
            let passesOptionCheck = (input.option == ArgumentOption.Anything) ||
                                    (input.option == ArgumentOption.NonOptional && !isRecordedArgAnOptional) ||
                                    (input.option == ArgumentOption.Optional && isRecordedArgAnOptional)

            if !passesOptionCheck {
                return false
            }

            let cleanedType = "\(input.type)".replaceMatching(regex: "\\.Type+$", withString: "")
            let cleanedRecordedArgType = "\(recordedArg.dynamicType)".replaceMatching(regex: "^Optional<", withString: "")
                .replaceMatching(regex: ">+$", withString: "")

            return cleanedType == cleanedRecordedArgType
        case .KindOf(let type):
            if let recordedArgAsObject = recordedArg as? NSObject {
                return recordedArgAsObject.isKindOfClass(type)
            }
            
            assertionFailure("Arguments passed to .KindOf must inherit from NSObject. <\(recordedArg)> of type <\(recordedArg.dynamicType)> does NOT inherit from NSObject.")
            return false
        }
    } else {
        return passedArg.isEqualTo(recordedArg)
    }
}

private func isNil(value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    let hasAValue = mirror.children.first?.value != nil
    
    return mirror.displayStyle == .Optional && !hasAValue
}

private func isOptional(value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    
    return mirror.displayStyle == .Optional
}

private func descriptionOfCalls(functionList functionList: Array<String>, argumentsList: Array<Array<GloballyEquatable>>) -> String {
    if functionList.isEmpty {
        return "<>"
    }
    
    return zip(functionList, argumentsList).reduce("", combine: { (concatenatedString, element: (function: String, argumentList: Array<GloballyEquatable>)) -> String in
        var entry = element.function
        
        let parameterListStringRepresentation = element.argumentList.stringRepresentation()
        if !parameterListStringRepresentation.isEmpty {
            entry += " with " + parameterListStringRepresentation
        }
        entry = "<" + entry + ">"
        
        return concatenatedString.isEmpty ? entry : concatenatedString + ", " + entry
    })
}

// MARK: Private Extensions

private extension String {
    private func replaceMatching(regex regex: String, withString string: String) -> String {
        return self.stringByReplacingOccurrencesOfString(regex, withString: string, options: .RegularExpressionSearch, range: nil)
    }
}

private extension Array {
    private func stringRepresentation() -> String {
        return self.map{ "\($0)" }.joinWithSeparator(", ")
    }
}
