import Foundation

/// "Global" state of Nimble is stored here. Only DSL functions should access / be aware of this
/// class' existance
internal class NimbleEnvironment {
    static var activeInstance: NimbleEnvironment {
        get {
            #if _runtime(_ObjC) // Xcode 8 beta 2
                let env = Thread.current.threadDictionary["NimbleEnvironment"]
            #else
                let env = Thread.current().threadDictionary["NimbleEnvironment"]
            #endif
            if let env = env as? NimbleEnvironment {
                return env
            } else {
                let newEnv = NimbleEnvironment()
                self.activeInstance = newEnv
                return newEnv
            }
        }
        set {
            #if _runtime(_ObjC) // Xcode 8 beta 2
                Thread.current.threadDictionary["NimbleEnvironment"] = newValue
            #else
                Thread.current().threadDictionary["NimbleEnvironment"] = newValue
            #endif
        }
    }

    // TODO: eventually migrate the global to this environment value
    var assertionHandler: AssertionHandler {
        get { return NimbleAssertionHandler }
        set { NimbleAssertionHandler = newValue }
    }

#if _runtime(_ObjC)
    var awaiter: Awaiter

    init() {
        let timeoutQueue: DispatchQueue
        if #available(OSX 10.10, *) {
            timeoutQueue = DispatchQueue.global(qos: .userInitiated)
        } else {
            timeoutQueue = DispatchQueue.global(priority: .high)
        }

        awaiter = Awaiter(
            waitLock: AssertionWaitLock(),
            asyncQueue: .main,
            timeoutQueue: timeoutQueue)
    }
#endif
}
