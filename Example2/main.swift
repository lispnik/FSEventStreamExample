//
//  main.swift
//  Example2
//
//  Created by Matthew Kennedy on 4/18/20.
//  Copyright © 2020 Matthew Kennedy. All rights reserved.
//

import Foundation

var context = FSEventStreamContext()
let flags = FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
let latency: Double = 1.0
let pathsToWatch = CommandLine.arguments as CFArray

let callback: FSEventStreamCallback = { (streamRef, clientCallbackInfo, numEvents, eventPaths, eventFlags, eventIds)  in
    print("""
        streamRef: \(streamRef)
        clientCallbackInfo: \(String(describing: clientCallbackInfo))
        numEvents: \(numEvents)
        eventPaths: \(eventPaths)
        eventFlags: \(eventFlags)
        eventIds: \(eventIds)
        """)
    // https://github.com/eonil/FSEvents/blob/master/Sources/EonilFSEvents/EonilFSEventStream.swift#L98
    guard let eventPaths = Unmanaged.fromOpaque(eventPaths).takeUnretainedValue() as NSArray as? [NSString] as [String]? else {
        fatalError("Can't convert to event paths to [String]")
    }
    
    for i in 0..<numEvents {
        let eventPath = eventPaths[i]
        let eventFlags = eventFlags[i]
        let eventId = eventIds[i]
        print("""
            eventPath: \(eventPath)
            eventFlags: \(eventFlags)
            eventId: \(eventId)
            """)
    }
    
    // CFRunLoopStop
}

guard var stream = FSEventStreamCreate(
    nil,
    callback,
    &context,
    pathsToWatch,
    FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
    latency,
    flags)
    else {
        fatalError("Can't create a stream")
}

let runLoop: CFRunLoop = CFRunLoopGetCurrent()
FSEventStreamScheduleWithRunLoop(stream, runLoop, CFRunLoopMode.defaultMode.rawValue)
FSEventStreamStart(stream);

NSLog("Starting event log...")
CFRunLoopRun()

FSEventStreamStop(stream)
FSEventStreamInvalidate(stream)
FSEventStreamRelease(stream)
