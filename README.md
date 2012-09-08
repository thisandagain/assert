## Assert
#### Assertion extensions and utilities for [OCUnit]()

### Installation
Simply import the `EDAssert` headers and ensure that you have linked the [`OCHamcrest` framework](https://github.com/hamcrest/OCHamcrest) within your test target.

### EDAssertEventually
While building integration or functional tests with `OCUnit`, one common issue is that asyncronous blocks are not supported. To resolve this, you can use the `EDAssertEventually` class to perform tests that poll against an async event over time:
```objective-c
BOOL __block test = false;
    
[self doSomethingAsync:^() {
    test = true;
} failure:^() {
    test = false;
}];

assertEventuallyWithBlockAndTimeout(^{
    return test;
}, 10);
```

---

### EDFuzz
```objective-c
NSString *fuzz = [EDFuzz withLength:30];
NSLog(@"Fuzz: %@", fuzz); 	// C4W,qndN4a{Bv9I4&B^oVr7usJTTmQ
```
