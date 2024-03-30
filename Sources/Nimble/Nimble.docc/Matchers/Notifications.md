# Notifications

```swift
// Swift
let testNotification = Notification(name: Notification.Name("Foo"), object: nil)

// Passes if the closure in expect { ... } posts a notification to the default
// notification center.
expect {
    NotificationCenter.default.post(testNotification)
}.to(postNotifications(equal([testNotification])))

// Passes if the closure in expect { ... } posts a notification to a given
// notification center
let notificationCenter = NotificationCenter()
expect {
    notificationCenter.post(testNotification)
}.to(postNotifications(equal([testNotification]), from: notificationCenter))

// Passes if the closure in expect { ... } posts a notification with the provided names to a given
// notification center. Make sure to use this when running tests on Catalina, 
// using DistributedNotificationCenter as there is currently no way 
// of observing notifications without providing specific names.
let distributedNotificationCenter = DistributedNotificationCenter()
expect {
    distributedNotificationCenter.post(testNotification)
}.to(postDistributedNotifications(equal([testNotification]),
                                  from: distributedNotificationCenter,
                                  names: [testNotification.name]))
```

> This matcher is only available in Swift.
