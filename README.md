## Assert
#### Assertion extensions and utilities for [OCUnit]()

### Installation
Simply import the `EDAsset` headers and ensure that you have linked the [`OCHamcrest` framework](https://github.com/hamcrest/OCHamcrest) within your test target.

### EDAssertEventually
```objective-c
BOOL __block test = false;
    
[self doSomething:^() {
    test = true;
} failure:^() {
    test = false;
}];

assertEventuallyWithBlockAndTimeout(^{
    return test;
}, 10);
```