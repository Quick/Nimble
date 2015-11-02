
// Implementation Example:


public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty when conforming to protocol
    var calledFunctionList: Array<String> {get set}
    var calledArgumentsList: Array<Array<Any>> {get set}
    // Implementation Example:
    // var calledFunctionList = Array<String>()
    // var calledArgumentsList = Array<Array<Any>>()

    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: Any...)
    
    // Used if you want to reset the called function/parameters lists
    func clearRecordedLists()
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
}
