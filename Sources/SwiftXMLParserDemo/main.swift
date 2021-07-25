//
//  main.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLParser
import XMLInterfaces

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

if let theSourcePath = sourcePath {
    do {
        var eventHandler: XMLInterfaces.XMLEventHandler? = nil
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
            try SwiftXMLParser.parse(path: theSourcePath, eventHandler: theEventHandler) {
                entityName, attributeContext, attributeName in
                if let theAttributeContext = attributeContext, let theAttributeName = attributeName {
                    return "[entity \(entityName) in \(theAttributeContext)/\(theAttributeName))]"
                }
                else {
                    return "[entity \(entityName)]"
                }
            }
            if let eventCounter = eventHandler as? XMLEventCounter {
                print("\(eventCounter.elementCount) elements with \(eventCounter.allEvents) parse event in total")
            }
        }
    }
    catch {
        print(error)
    }
}
else {
    print("nothing to do")
}

let end = DispatchTime.now()
let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
let timeInterval = Double(nanoTime) / 1_000_000_000
print("program ended after \(timeInterval) s")
