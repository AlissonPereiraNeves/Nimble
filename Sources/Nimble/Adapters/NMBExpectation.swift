import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

fileprivate func from(objcPredicate: NMBPredicate) -> Predicate<NSObject> {
    return Predicate { actualExpression in
        let result = objcPredicate.satisfies(({ try! actualExpression.evaluate() }),
                                             location: actualExpression.location)
        return result.toSwift()
    }
}

internal struct ObjCMatcherWrapper: Matcher {
    let matcher: NMBMatcher

    func matches(_ actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        return matcher.matches(
            ({ try! actualExpression.evaluate() }),
            failureMessage: failureMessage,
            location: actualExpression.location)
    }

    func doesNotMatch(_ actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        return matcher.doesNotMatch(
            ({ try! actualExpression.evaluate() }),
            failureMessage: failureMessage,
            location: actualExpression.location)
    }
}

// Equivalent to Expectation, but for Nimble's Objective-C interface
public class NMBExpectation: NSObject {
    internal let _actualBlock: () -> NSObject!
    internal var _negative: Bool
    internal let _file: FileString
    internal let _line: UInt
    internal var _timeout: TimeInterval = 1.0

    public init(actualBlock: @escaping () -> NSObject!, negative: Bool, file: FileString, line: UInt) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    private var expectValue: Expectation<NSObject> {
        return expect(_file, line: _line) {
            self._actualBlock() as NSObject?
        }
    }

    public var withTimeout: (TimeInterval) -> NMBExpectation {
        return ({ timeout in self._timeout = timeout
            return self
        })
    }

    public var to: (NMBMatcher) -> Void {
        return ({ matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.to(from(objcPredicate: pred))
            } else {
                self.expectValue.to(ObjCMatcherWrapper(matcher: matcher))
            }
        })
    }

    public var toWithDescription: (NMBMatcher, String) -> Void {
        return ({ matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.to(from(objcPredicate: pred), description: description)
            } else {
                self.expectValue.to(ObjCMatcherWrapper(matcher: matcher), description: description)
            }
        })
    }

    public var toNot: (NMBMatcher) -> Void {
        return ({ matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toNot(from(objcPredicate: pred))
            } else {
                self.expectValue.toNot(ObjCMatcherWrapper(matcher: matcher))
            }
        })
    }

    public var toNotWithDescription: (NMBMatcher, String) -> Void {
        return ({ matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toNot(from(objcPredicate: pred), description: description)
            } else {
                self.expectValue.toNot(ObjCMatcherWrapper(matcher: matcher), description: description)
            }
        })
    }

    public var notTo: (NMBMatcher) -> Void { return toNot }

    public var notToWithDescription: (NMBMatcher, String) -> Void { return toNotWithDescription }

    public var toEventually: (NMBMatcher) -> Void {
        return ({ matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventually(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: nil
                )
            } else {
                self.expectValue.toEventually(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: nil
                )
            }
        })
    }

    public var toEventuallyWithDescription: (NMBMatcher, String) -> Void {
        return ({ matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventually(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: description
                )
            } else {
                self.expectValue.toEventually(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: description
                )
            }
        })
    }

    public var toEventuallyNot: (NMBMatcher) -> Void {
        return ({ matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventuallyNot(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: nil
                )
            } else {
                self.expectValue.toEventuallyNot(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: nil
                )
            }
        })
    }

    public var toEventuallyNotWithDescription: (NMBMatcher, String) -> Void {
        return ({ matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventuallyNot(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: description
                )
            } else {
                self.expectValue.toEventuallyNot(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: description
                )
            }
        })
    }

    public var toNotEventually: (NMBMatcher) -> Void { return toEventuallyNot }

    public var toNotEventuallyWithDescription: (NMBMatcher, String) -> Void { return toEventuallyNotWithDescription }

    public class func failWithMessage(_ message: String, file: FileString, line: UInt) {
        fail(message, location: SourceLocation(file: file, line: line))
    }
}

#endif
