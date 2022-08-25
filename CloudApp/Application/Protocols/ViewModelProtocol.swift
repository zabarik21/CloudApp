//
//  ViewModelProtocol.swift
//  CloudApp
//
//  Created by Timofey on 15/8/22.
//

import Foundation

class Output<Event> {

    var handlers = [(Event) -> Void]()

    func send(_ event: Event) {
        for handler in handlers {
            handler(event)
        }
    }
}

protocol ViewModel {
    associatedtype ViewEvent
    associatedtype ViewModelEvent

    var output: Output<ViewModelEvent> { get }

    func handle(event: ViewEvent)
    func start()
}

protocol ViewModelContainer: AnyObject {
    associatedtype ViewModelEvent
    associatedtype ViewEvent

    var output: Output<ViewEvent> { get }

    func setupBindings()
    func handle(event: ViewModelEvent)
}
