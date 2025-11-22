import Foundation

@propertyWrapper
struct Injected<Value> {
    var wrappedValue: Value {
        Container.current.resolveOrDie()
    }
}
