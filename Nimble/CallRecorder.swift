
// Implementation Example:


public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var calledFunctionList = Array<String>()
    // var calledArgumentsList = Array<Array<Any>>()
    var calledFunctionList: Array<String> {get set}
    var calledArgumentsList: Array<Array<Any>> {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: Any...)
    
    // Used if you want to reset the called function/parameters lists
    func clearRecordedLists()
    
    
    // For Internal Use ONLY
    func didCall(function function: String) -> Bool
}

public extension CallRecorder {
    func recordCall(function function: String, arguments: Any...) {
        self.calledFunctionList.append(function)
        self.calledArgumentsList.append(arguments)
    }
    
    func clearRecordedLists() {
        self.calledFunctionList = Array<String>()
        self.calledArgumentsList = Array<Array<Any>>()
    }
    
    func didCall(function function: String) -> Bool {
        return timesCalled(function) > 0
    }
    
    // MARK: Protocol Helper Functions
    
    private func timesCalled(function: String) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.calledFunctionList)
    }
}

// MARK: Helper Functions

private func numberOfMatchingCalls(function function: String, functions: Array<String>) -> Int {
    return functions.reduce(0) { $1 == function ? $0 + 1 : $0 }
}
