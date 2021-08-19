//
//  main.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLParser
import SwiftXMLInterfaces

let start = DispatchTime.now()

var sourcePath: String? = nil
var targetPath: String? = nil
var onlyCount = false

if CommandLine.arguments.count > 3 {
    print("too many arguments"); exit(1)
}

CommandLine.arguments.dropFirst().forEach { argument in
    if argument.hasPrefix("-") {
        if argument == "-c" {
            onlyCount = true
        }
        else {
            print("unkown argument \"\(argument)\""); exit(1)
        }
    }
    else if sourcePath == nil {
        sourcePath = argument
        print("source: \(sourcePath ?? "")")
    }
    else if targetPath == nil {
        targetPath = argument
        print("target: \(targetPath ?? "")")
    }
    else {
        print("too many arguments!"); exit(1)
    }
}

class SimpleInternalEntityResolver: InternalEntityResolver {
    func resolve(entityName: String, attributeContext: String?, attributeName: String?) -> String? {
        return attributeContext != nil ? "[\(entityName)]" : nil
    }
}

if let theSourcePath = sourcePath {
    do {
        var eventHandler: SwiftXMLInterfaces.XMLEventHandler? = nil
        if onlyCount {
            eventHandler = XMLEventCounter()
        }
        else if let thetargetPath = targetPath {
            eventHandler = try XMLEventFileWriter(path: thetargetPath, fullEscapes: true, useWindowsNewlines: true)
        }
        else {
            eventHandler = XMLEventPrinter()
        }
        if let theEventHandler = eventHandler {
            try SwiftXMLParser.parse(path: theSourcePath, eventHandler: theEventHandler, internalEntityResolver: SimpleInternalEntityResolver())
            if let eventCounter = eventHandler as? XMLEventCounter {
                print("\(eventCounter.elementCount) elements with \(eventCounter.allEvents) parse events in total")
            }
        }
    }
    catch {
        print("ERROR: \(error.localizedDescription)")
    }
}
else {
    print("nothing to do")
}

let end = DispatchTime.now()
let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
let timeInterval = Double(nanoTime) / 1_000_000_000
print("program ended after \(timeInterval) s")
