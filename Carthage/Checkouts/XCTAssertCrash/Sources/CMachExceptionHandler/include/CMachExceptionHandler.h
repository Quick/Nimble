#ifdef __APPLE__
#import "TargetConditionals.h"
#if TARGET_OS_OSX || TARGET_OS_IOS

#include "mach_excServer.h"

#ifdef __cplusplus
extern "C" {
#endif

mach_port_t startMachExceptionHandlerThread();

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* TARGET_OS_OSX || TARGET_OS_IOS */
#endif /* __APPLE__ */
