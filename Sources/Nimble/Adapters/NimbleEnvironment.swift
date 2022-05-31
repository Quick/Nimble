#if !os(WASI)
import Dispatch
import class Foundation.Thread
#endif
import class Foundation.NSObject

/// "Global" state of Nimble is stored here. Only DSL functions should access / be aware of this
/// class' existence
internal class NimbleEnvironment: NSObject {
    #if os(WASI)
    static var activeInstance: NimbleEnvironment = NimbleEnvironment()
    #else
    static var activeInstance: NimbleEnvironment {
        get {
            let env = Thread.current.threadDictionary["NimbleEnvironment"]
            if let env = env as? NimbleEnvironment {
                return env
            } else {
                let newEnv = NimbleEnvironment()
                self.activeInstance = newEnv
                return newEnv
            }
        }
        set {
            Thread.current.threadDictionary["NimbleEnvironment"] = newValue
        }
    }
    #endif

    // swiftlint:disable:next todo
    // TODO: eventually migrate the global to this environment value
    var assertionHandler: AssertionHandler {
        get { return NimbleAssertionHandler }
        set { NimbleAssertionHandler = newValue }
    }

    var suppressTVOSAssertionWarning: Bool = false
    var suppressWatchOSAssertionWarning: Bool = false
    #if !os(WASI)
    var awaiter: Awaiter
    #endif

    override init() {
        #if !os(WASI)
        let timeoutQueue = DispatchQueue.global(qos: .userInitiated)
        awaiter = Awaiter(
            waitLock: AssertionWaitLock(),
            asyncQueue: .main,
            timeoutQueue: timeoutQueue
        )
        #endif

        super.init()
    }
}
