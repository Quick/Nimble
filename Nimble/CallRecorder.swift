
// Implementation Example:


public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty when conforming to protocol
    var calledFunctionList: Array<String> {get set}
    // Implementation Example:
    // var calledFunctionList = Array<String>()
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, parameters: Any...)
}

public extension CallRecorder {
    func recordCall(function function: String, parameters: Any...) {
        self.calledFunctionList.append(function)
    }
}
