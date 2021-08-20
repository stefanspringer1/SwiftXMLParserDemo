//
//  EventHandlers.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLParser
import SwiftXMLInterfaces

public class XMLEventPrinter: SwiftXMLInterfaces.DefaultXMLEventHandler {
    
    public override func documentStart() {
        print("document start")
    }
    
    public override func xmlDeclaration(version: String, encoding: String?, standalone: String?) {
        print("XML declaration: version=\"\(version)\", encoding=\"\(encoding != nil ? "\"\(encoding ?? "")\"" : "-")\", standalone=\(standalone != nil ? "\"\(standalone ?? "")\"" : "-")")
    }
    
    public override func documentTypeDeclaration(type: String, publicID: String?, systemID: String?) {
        print("document type declaration for \"\(type)\": public ID \(publicID != nil ? "\"\(publicID ?? "")\"" : "-"), system ID \(systemID != nil ? "\"\(systemID ?? "")\"" : "-")")
    }
    
    public override func text(text: String, isWhitespace: Bool) {
        print("text (whitespace=\(isWhitespace)) \"\(text)\"")
    }
    
    public override func cdataSection(text: String) {
        print("cdataSection \"\(text)\"")
    }
    
    public override func comment(text: String) {
        print("comment \"\(text)\"")
    }
    
    public override func elementStart(name: String, attributes: inout [String:String], combineTexts: Bool) {
        print("element \"\(name)\" start, attributes \(attributes), combineText = \(combineTexts)")
    }
    
    public override func elementEnd(name: String) {
        print("element \"\(name)\" end")
    }
    
    public override func processingInstruction(target: String, content: String?) {
        print("processing instruction for \"\(target)\": \(content != nil ? "\"\(content ?? "")\"" : "-")")
    }

    public override func internalEntityDeclaration(name: String, value: String) {
        print("internal entity declaration for \"\(name)\": \"\(value)\"")
    }
    
    public override func parameterEntityDeclaration(name: String, value: String) {
        print("parameter entity declaration for \"\(name)\": \"\(value)\"")
    }
    
    public override func externalEntityDeclaration(name: String, publicID:  String?, systemID: String) {
        print("external entity declaration for \"\(name)\": public ID \(publicID != nil ? "\"\(publicID ?? "")\"" : "-"), system ID \"\(systemID)\"")
    }
    
    public override func unparsedEntityDeclaration(name: String, publicID:  String?, systemID: String, notation: String) {
        print("unparsed entity declaration for \"\(name)\": public ID \(publicID != nil ? "\"\(publicID ?? "")\"" : "-"), system ID \"\(systemID)\", notation \"\(notation)\"")
    }
    
    public override func notationDeclaration(name: String, publicID: String?, systemID: String?) {
        print("notation declaration for \"\(name)\": public ID \(publicID != nil ? "\"\(publicID ?? "")\"" : "-"), system ID \(systemID != nil ? "\"\(systemID ?? "")\"" : "-")")
    }
    
    public override func internalEntity(name: String) {
        print("internal entity \"\(name)\"")
    }
    
    public override func externalEntity(name: String) {
        print("external entity \"\(name)\"")
    }
    
    public override func elementDeclaration(name: String, text: String) {
        print("element type definition for \"\(name)\": \(text)")
    }
    
    public override func attributeListDeclaration(elementName: String, text: String) {
        print("attribute list definition for \"\(elementName)\": \(text)")
    }
    
    public override func parsingTime(seconds: Double) {
        print("parsing time: \(seconds) s")
    }
    
    public override func documentEnd() {
        print("document end")
    }
}

public class XMLEventFileWriter: SwiftXMLInterfaces.DefaultXMLEventHandler {

    private let fileHandle: FileHandle
    private let fullEscapes: Bool
    private let useWindowsNewlines: Bool
    private let path: String

    public init(path: String, fullEscapes: Bool = false, useWindowsNewlines: Bool = false) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            try fm.removeItem(atPath: path)
        }
        if !fm.fileExists(atPath: path) {
            fm.createFile(atPath: path,  contents:Data(" ".utf8), attributes: nil)
        }

        if let _fileHandle = FileHandle(forWritingAtPath: path) {
            fileHandle = _fileHandle
            self.path = path
            self.fullEscapes = fullEscapes
            self.useWindowsNewlines = useWindowsNewlines
        }
        else {
            throw SwiftXMLInterfaces.XMLEventHandlerError("could not open file \(path)(")
        }
    }
    
    private var inInternalSubset = false
    private var documentTypeDeclarationClosed = false
    private var startTagUnfinished = false
    
    private func ensureInternalSubset() {
        if !inInternalSubset {
            writeLine()
            writeLine("[")
            inInternalSubset = true
        }
    }
    
    private func considerPossibleElementContent() {
        if startTagUnfinished {
            write(">")
            startTagUnfinished = false
        }
    }
    
    private func closeDocumentTypeDeclaration() {
        if !documentTypeDeclarationClosed {
            if inInternalSubset {
                write("]")
                inInternalSubset = false
            }
            writeLine(">")
            documentTypeDeclarationClosed = true
        }
    }
    
    // assuming quote is QUOTATION MARK
    private func attributeEscape(_ text: String?) -> String {
        if let theText = text {
            if fullEscapes {
                return theText.replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                    .replacingOccurrences(of: "'", with: "&apos;")
            }
            else {
                return theText.replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
            }
        }
        else {
            return ""
        }
    }
    
    private func textEscape(_ text: String?) -> String {
        if let theText = text {
            if fullEscapes {
                return theText.replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                    .replacingOccurrences(of: "'", with: "&apos;")
            }
            else {
                return theText.replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
            }
        }
        else {
            return ""
        }
    }
    
    private func write(_ text: String) {
        fileHandle.write(text.data(using: .utf8)!)
    }
    
    private func writeLine() {
        if useWindowsNewlines {
            write("\r\n")
        }
        else {
            write("\n")
        }
    }
    
    private func writeLine(_ text: String) {
        write(text)
        writeLine()
    }
    
    public override func xmlDeclaration(version: String, encoding: String?, standalone: String?) {
        writeLine(String("<?xml version=\"\(attributeEscape(version))\" \(encoding != nil ? " encoding=\"\(attributeEscape(encoding))\"" : "")\(standalone != nil ? " encoding=\"\(attributeEscape(standalone))\"" : "")?>"))
    }
    
    public override func documentTypeDeclaration(type: String, publicID: String?, systemID: String?) {
        write("<!DOCTYPE \(type)\(publicID != nil ? " PUBLIC \"\(attributeEscape(publicID))\"" : "")\(systemID != nil ? " \"\(attributeEscape(systemID))\"" : "")")
    }
    
    public override func text(text: String, isWhitespace: Bool) {
        considerPossibleElementContent()
        write(textEscape(text))
    }
    
    public override func cdataSection(text: String) {
        considerPossibleElementContent()
        write("<![CDATA[\(text)]]>")
    }
    
    public override func comment(text: String) {
        considerPossibleElementContent()
        write("<!--\(textEscape(text))-->")
    }
    
    public override func elementStart(name: String, attributes: inout [String:String], combineTexts: Bool) {
        closeDocumentTypeDeclaration()
        considerPossibleElementContent()
        write("<\(name)")
        attributes.forEach{ name, value in
            write(" ")
            write(name)
            write("=\"")
            write(value)
            write("\"")
        }
        startTagUnfinished = true
    }
    
    public override func elementEnd(name: String) {
        if startTagUnfinished {
            write("/>")
            startTagUnfinished = false
        }
        else {
            write("</")
            write(name)
            write(">")
        }
    }
    
    public override func processingInstruction(target: String, content: String?) {
        considerPossibleElementContent()
        write("<?")
        write(target)
        if let theContent = content {
            write(" \"")
            write(attributeEscape(theContent))
            write("\"")
        }
        write("?>")
    }

    public override func internalEntityDeclaration(name: String, value: String) {
        ensureInternalSubset()
        write(" <!ENTITY \(name) \"");
        write(value)
        writeLine("\">")
    }
    
    public override func externalEntityDeclaration(name: String, publicID: String?, systemID: String) {
        ensureInternalSubset()
        if publicID != nil {
            writeLine(" <!ENTITY \(name) PUBLIC \"\(attributeEscape(publicID))\" \"\(attributeEscape(systemID))\">")
        }
        else {
            writeLine(" <!ENTITY \(name) SYSTEM \"\(attributeEscape(systemID))\">")
        }
    }
    
    public override func unparsedEntityDeclaration(name: String, publicID:  String?, systemID: String?, notation: String) {
        ensureInternalSubset()
        if publicID != nil {
            if systemID != nil {
                writeLine(" <!ENTITY \(name) PUBLIC \"\(attributeEscape(publicID))\" \"\(attributeEscape(systemID))\" NDATA \(notation)>")
            }
            else {
                writeLine(" <!ENTITY \(name) PUBLIC \"\(attributeEscape(publicID))\" NDATA \(notation)>")
            }
        }
        else {
            writeLine(" <!ENTITY \(name) SYSTEM \"\(attributeEscape(systemID))\" NDATA \(notation)>")
        }
    }
    
    public override func notationDeclaration(name: String, publicID: String?, systemID: String?) {
        ensureInternalSubset()
        if publicID != nil {
            if systemID != nil {
                writeLine(" <!NOTATION PUBLIC \"\(attributeEscape(publicID))\" \"\(attributeEscape(systemID))\">")
            }
            else {
                writeLine(" <!NOTATION PUBLIC \"\(attributeEscape(publicID))\">")
            }
        }
        else {
            writeLine(" <!NOTATION SYSTEM \"\(attributeEscape(systemID))\">")
        }
    }
    
    public override func internalEntity(name: String) {
        considerPossibleElementContent()
        write("&\(name);")
    }
    
    public override func externalEntity(name: String) {
        considerPossibleElementContent()
        write("&\(name);")
    }
    
    public override func elementDeclaration(name: String, text: String) {
        ensureInternalSubset()
        write(" ")
        writeLine(text)
    }
    
    public override func attributeListDeclaration(elementName: String, text: String) {
        ensureInternalSubset()
        write(" ")
        writeLine(text)
    }
    
    public override func parameterEntityDeclaration(name: String, value: String) {
        ensureInternalSubset()
        writeLine(" <!ENTITY \(name) \"\(attributeEscape(value))\">");
    }
    
    public override func documentEnd() {
        fileHandle.closeFile()
    }
}

class XMLEventCounter: SwiftXMLInterfaces.DefaultXMLEventHandler {

    var elementCount = 0
    
    var allEvents = 0
    
    public override func documentStart() {
        allEvents += 1
    }
    
    public override func xmlDeclaration(version: String, encoding: String?, standalone: String?) {
        allEvents += 1
    }
    
    public override func documentTypeDeclaration(type: String, publicID: String?, systemID: String?) {
        allEvents += 1
    }
    
    public override func text(text: String, isWhitespace: Bool) {
        allEvents += 1
    }
    
    public override func cdataSection(text: String) {
        allEvents += 1
    }
    
    public override func comment(text: String) {
        allEvents += 1
    }
    
    public override func elementStart(name: String, attributes: inout [String:String], combineTexts: Bool) {
        allEvents += 1
        elementCount += 1
    }
    
    public override func elementEnd(name: String) {
        allEvents += 1
    }
    
    public override func processingInstruction(target: String, content: String?) {
        allEvents += 1
    }
    
    public override func internalEntityDeclaration(name: String, value: String) {
        allEvents += 1
    }
    
    public override func externalEntityDeclaration(name: String, publicID: String?, systemID: String) {
        allEvents += 1
    }
    
    public override func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String) {
        allEvents += 1
    }
    
    public override func notationDeclaration(name: String, publicID: String?, systemID: String?) {
        allEvents += 1
    }
    
    public override func internalEntity(name: String) {
        allEvents += 1
    }
    
    public override func externalEntity(name: String) {
        allEvents += 1
    }
    
    public override func elementDeclaration(name: String, text: String) {
        allEvents += 1
    }
    
    public override func attributeListDeclaration(elementName: String, text: String) {
        allEvents += 1
    }
    
    public override func parameterEntityDeclaration(name: String, value: String) {
        allEvents += 1
    }
    
    public override func documentEnd() {
        allEvents += 1
    }
}
