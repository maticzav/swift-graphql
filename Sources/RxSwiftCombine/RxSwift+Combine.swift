@_exported import RxSwift


public extension Disposable {
    func store(in collection: inout Set<DisposeBag>) {
        let bag = DisposeBag()
        collection.insert(bag)
        self.disposed(by: bag)
    }
}

public extension Observable {
    func first() async throws -> Element {
        try await take(1).asSingle().values.first(where: { _ in true })!
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


