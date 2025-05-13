import Nimble

import Testing

struct SimultaneousPollingTests {
    @Test("Multiple async polling expectations", arguments: 0..<10) func asyncPolling(argument: Int) async {
        await expect(argument).toAlways(equal(argument), until: .milliseconds(100))
    }

    @Test("Multiple synchronous polling expectations",
          .disabled("Simultaneous synchronous polling expectations are known to not work under Swift Testing"),
          arguments: 0..<10
    ) func syncPolling(argument: Int) {
        expect(argument).toAlways(equal(argument), until: .milliseconds(100))
    }
}
