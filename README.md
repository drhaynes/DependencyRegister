## Dependecy Register

A simple service for managing dependencies in a lightweight and simple way that also facilitates testing.


#### To register a Service:
```swift
DependencyContainer.shared.register(ExampleService(), for: ExampleProtocol.self)
```
or using a closure:

```swift
DependencyContainer.shared.register(service: ExampleService.type) {
	return ExampleService()
}
```

Services are cached by default. To not cache, specify `cacheService: false` when registering.

#### To obtain (resolve) a service:

For convenience, `resolve()` is a global free function that wraps `DependencyContainer.shared.resolve()`

```swift
let service = resolve(ExampleProtocol.self)
```

#### Testing

Multiple services can be registered against the same service protocol type. This is useful when testing, to replace a dependency with a mock, e.g.

```swift
// Replace existing service for this protocol with our mock
DependencyContainer.shared.register(MockService(), ExampleProtocol.self)
// Do testing
...

```