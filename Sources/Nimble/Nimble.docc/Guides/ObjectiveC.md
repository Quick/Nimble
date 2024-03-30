# Objective-C Support

Nimble has full support for Objective-C. However, there are two things
to keep in mind when using Nimble in Objective-C:

1. All parameters passed to the ``expect`` function, as well as matcher
   functions like ``equal``, must be Objective-C objects or can be converted into
   an `NSObject` equivalent:

   ```objc
   // Objective-C

   @import Nimble;

   expect(@(1 + 1)).to(equal(@2));
   expect(@"Hello world").to(contain(@"world"));

   // Boxed as NSNumber *
   expect(2).to(equal(2));
   expect(1.2).to(beLessThan(2.0));
   expect(true).to(beTruthy());

   // Boxed as NSString *
   expect("Hello world").to(equal("Hello world"));

   // Boxed as NSRange
   expect(NSMakeRange(1, 10)).to(equal(NSMakeRange(1, 10)));
   ```

2. To make an expectation on an expression that does not return a value,
   such as `-[NSException raise]`, use ``expectAction`` instead of
   ``expect``:

   ```objc
   // Objective-C

   expectAction(^{ [exception raise]; }).to(raiseException());
   ```

The following types are currently converted to an `NSObject` type:

 - **C Numeric types** are converted to `NSNumber *`
 - `NSRange` is converted to `NSValue *`
 - `char *` is converted to `NSString *`

For the following matchers:

- ``equal``
- ``beGreaterThan``
- ``beGreaterThanOrEqual``
- ``beLessThan``
- ``beLessThanOrEqual``
- ``beCloseTo``
- ``beTrue``
- ``beFalse``
- ``beTruthy``
- ``beFalsy``
- ``haveCount``


If you would like to see more, [file an issue](https://github.com/Quick/Nimble/issues).

## Disabling Objective-C Shorthand

Nimble provides a shorthand for expressing expectations using the
``expect`` function. To disable this shorthand in Objective-C, define the
``NIMBLE_DISABLE_SHORT_SYNTAX`` macro somewhere in your code before
importing Nimble:

```objc
#define NIMBLE_DISABLE_SHORT_SYNTAX 1

@import Nimble;

NMB_expect(^{ return seagull.squawk; }, __FILE__, __LINE__).to(NMB_equal(@"Squee!"));
```

> Disabling the shorthand is useful if you're testing functions with
  names that conflict with Nimble functions, such as ``expect`` or
  ``equal``. If that's not the case, there's no point in disabling the
  shorthand.
