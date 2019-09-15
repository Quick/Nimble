#ifdef __APPLE__
#import "TargetConditionals.h"
#if TARGET_OS_OSX || TARGET_OS_IOS

#include <assert.h>
#include <dispatch/dispatch.h>
#include <mach/mach.h>

#include "mach_excServer.h"

const mach_msg_size_t maxMessageSize = 1024;

mach_port_t startMachExceptionHandlerThread()
{
    static mach_port_t exceptionPort;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kern_return_t kr = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &exceptionPort);
        assert(kr == KERN_SUCCESS);

        kr = mach_port_insert_right(mach_task_self(), exceptionPort, exceptionPort, MACH_MSG_TYPE_MAKE_SEND);
        assert(kr == KERN_SUCCESS);

        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_MACH_RECV, exceptionPort, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
        assert(source);

        dispatch_source_set_event_handler(source, ^{
            kern_return_t kr = mach_msg_server_once(mach_exc_server, maxMessageSize, exceptionPort, MACH_MSG_TIMEOUT_NONE);
            assert(kr == KERN_SUCCESS);
        });

        dispatch_resume(source);
    });
    return exceptionPort;
}

#endif /* TARGET_OS_OSX || TARGET_OS_IOS */
#endif /* __APPLE__ */
