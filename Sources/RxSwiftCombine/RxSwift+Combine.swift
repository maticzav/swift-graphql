@_exported import RxSwift
import struct Foundation.URLError


public extension Disposable {
    func store(in collection: inout Set<DisposeBag>) {
        let bag = DisposeBag()
        collection.insert(bag)
        self.disposed(by: bag)
    }
}

public extension Observable {
    func merge(with other: Observable<Element>) -> Observable<Element> {
        Observable.merge(self, other)
    }

    func eraseToAnyPublisher() -> Observable<Element> { self }

    func switchToLatest() -> Observable<Element.Element> where Element: ObservableConvertibleType { switchLatest() }

    func `catch`(_ handler: @escaping (URLError) -> Observable<Element>) -> Observable<Element> {
        self.catch({ (error: Error) -> Observable<Element> in
            if let error = error as? URLError {
                handler(error)
            } else {
                throw error
            }
        })
    }
}

public extension PublishSubject {
    func send(_ element: Element) {
        onNext(element)
    }

    enum Completion {
        /// The subject finished normally.
        case finished
    }

    func send(completion: Completion) {
        switch completion {
            case .finished:
                onCompleted()
        }
    }
}

public extension Observable {
    func first() async throws -> Element {
        try await take(1).asSingle().values.first(where: { _ in true })!
    }

    func first() -> Observable<Element> {
        take(1).asSingle().asObservable()
    }
}


extension DisposeBag: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension DisposeBag: Equatable {
    public static func ==(_ lhs: DisposeBag, _ rhs: DisposeBag) -> Bool { lhs === rhs }
}

public typealias AnyPublisher<Element, Error> = Observable<Element>
public typealias PassthroughSubject<Element, Error> = PublishSubject<Element>
public typealias AnyCancellable = DisposeBag
public func Just<Element>(_ element: Element) -> Observable<Element> { Observable.just(element) }

