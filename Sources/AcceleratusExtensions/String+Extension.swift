//
//  String+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

//
// MARK: Misc
//

public extension String {

    @inlinable
    static func randomAlphanumeric(_ length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    @inlinable
    var isNumeric : Bool {
        return Double(self) != nil
    }

    /**
        If self is empty, returns the alternative.
        Otherwise returns self.
     */
    @inlinable
    func orIfEmpty(_ alternative: String) -> String {
        return isEmpty ? alternative : self
    }

    /**
        Returns a new copy of the string without any characters from
        the provided set.

        This is NOT mutating.
     */
    @inlinable
    func without(_ set: CharacterSet) -> String {
        return self.components(separatedBy: set).joined(separator: "")
    }

    /**
        Removes all instances of characters in provided set
        from the string.

        This is a mutating action.
     */
    @inlinable
    mutating func remove(_ set: CharacterSet) {
        self = self.without(set)
    }

    /**
        Returns a new copy of the string with only characters from
        the provided set.

        This is NOT mutating.
     */
    @inlinable
    func only(_ set: CharacterSet) -> String {
        return self.components(separatedBy: set.inverted).joined(separator: "")
    }

    /**
        Removes all instances of characters that do not belong
        in the provided set.

        This is a mutating action.
     */
    @inlinable
    mutating func keepOnly(_ set: CharacterSet) {
        self = self.only(set)
    }
}

//
// MARK: Accumulating
//

public extension String {
    enum StringError : Error {
        case indexOutOfBounds (String)
    }

    func getCharacters(_ srcBegin: Int,
                       _ srcEnd: Int,
                       _ dst: inout [Character?], _ dstBegin: Int) throws {
        try String.checkBoundsBeginEnd(srcBegin, srcEnd, count)
        try String.checkBoundsOffCount(dstBegin, srcEnd - srcBegin, dst.count)
        try String.getChars(self, srcBegin, srcEnd, &dst, dstBegin)
    }

    static func getChars(_ src: String,
                         _ srcBegin: Int,
                         _ srcEnd: Int,
                         _ dst: inout [Character?],
                         _ dstBegin: Int) throws {
        if (srcBegin < srcEnd) {
            try checkBoundsOffCount(srcBegin, srcEnd - srcBegin, src.count)
        }

        var i = srcBegin
        var x = dstBegin

        while i < srcEnd {
            dst[x] = src[i]
            x += 1
            i += 1
        }
    }

    private static func checkBoundsOffCount(_ offset: Int,
                                            _ count: Int,
                                            _ length: Int) throws {
        if (offset < 0 || count < 0 || offset > length - count) {
            throw StringError.indexOutOfBounds("offset \(offset), count \(count), length \(length)")
        }
    }

    private static func checkBoundsBeginEnd(_ begin: Int,
                                            _ end: Int,
                                            _ length: Int) throws {
        if (begin < 0 || begin > end || end > length) {
            throw StringError.indexOutOfBounds("begin \(begin), end \(end), length \(length)")
        }
    }
}

//
// MARK: Encoding/Decoding
//

public extension String {

    /// Encoding a String to Data using utf8
    var data: Data { return Data(utf8) }

    /// Encoding a String to Base64 Data
    var base64Encoded: Data  { return data.base64EncodedData() }

    /// Decoding a Base64 string to Data
    var base64Decoded: Data? { return Data(base64Encoded: self) }

    /// Encoding a String to Base64 String
    var base64EncodedString : String? {
        return self.data.base64EncodedString()
    }

    /// Decoding a Base64 String back into plaintext
    var base64DecodedString : String? {
        var str = self;

        if (self.count % 4 <= 2) {
            str += String(repeating: "=", count: (self.count % 4))
        }
        guard let data = Data(base64Encoded: str) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

//
// MARK: Ranges & Bounding
//

// Courtesy of 'Leo Dabus' from: https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
// and 'Changnam Hong' from: https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift

public extension StringProtocol {

    @inlinable
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }

    @inlinable
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }

    @inlinable
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }

    @inlinable
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        self[index(startIndex, offsetBy: range.lowerBound)...]
    }

    @inlinable
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        self[...index(startIndex, offsetBy: range.upperBound)]
    }

    @inlinable
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        self[..<index(startIndex, offsetBy: range.upperBound)]
    }

    @inlinable
    subscript(bounds: CountableClosedRange<Int>) -> String {
        let lowerBound = Swift.max(0, bounds.lowerBound)
        guard lowerBound < self.count else { return "" }

        let upperBound = Swift.min(bounds.upperBound, self.count-1)
        guard upperBound >= 0 else { return "" }

        let i = index(startIndex, offsetBy: lowerBound)
        let j = index(i, offsetBy: upperBound-lowerBound)

        return String(self[i...j])
    }

    @inlinable
    subscript(bounds: CountableRange<Int>) -> String {
        let lowerBound = Swift.max(0, bounds.lowerBound)
        guard lowerBound < self.count else { return "" }

        let upperBound = Swift.min(bounds.upperBound, self.count)
        guard upperBound >= 0 else { return "" }

        let i = index(startIndex, offsetBy: lowerBound)
        let j = index(i, offsetBy: upperBound-lowerBound)

        return String(self[i..<j])
    }

    @inlinable
    func substring(_ beginIndex: Int, _ endIndex: Int) -> String {
        return self[beginIndex..<endIndex]
    }

    @inlinable
    func substring(_ beginIndex: Int) -> String {
        return String(self.dropFirst(beginIndex))
    }

    @inlinable
    func ranges(of targetString: Self,
                options: String.CompareOptions = [],
                locale: Locale? = nil) -> [Range<String.Index>] {

        let result: [Range<String.Index>] = self.indices.compactMap { startIndex in
            let targetStringEndIndex = index(startIndex, offsetBy: targetString.count, limitedBy: endIndex) ?? endIndex
            return range(of: targetString, options: options, range: startIndex..<targetStringEndIndex, locale: locale)
        }
        return result
    }

    @inlinable
    func range(of targetString: Self,
               options: String.CompareOptions = [],
               locale: Locale? = nil) -> Range<String.Index>? {
        return ranges(of: targetString).first
    }

    @inlinable
    func index(of targetString: Self,
               options: String.CompareOptions = [],
               locale: Locale? = nil) -> Int? {
        return range(of: targetString)?.lowerBound.encodedOffset
    }
}


//
// MARK: Regex
//

// Based entirely on the 'Fattie' solution from: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift

/*
 Justification:

 1 - it avoids the many terrible regex mistakes you often see in these suggestions

 2 - it does NOT allow stupid emails such as "x@x" which are thought to be valid under certain RFCs, but are completely silly, can't be used as emails, and which your support staff would reject instantly, and which all mailer services (mailchimp, google, aws, etc) simply reject. If (for some reason) you need a solution that allows strings such as 'x@x', use another solution.

 3 - the code is very, very, very understandable

 4 - it is KISS, reliable, and tested to destruction on commercial apps with enormous numbers of users

 5 - a technical point, the predicate is a global, as Apple says it should be (watch out for code suggestions which don't have this)

 Explanation:

 In the following description, "OC" means ordinary character - a letter or a digit.

 __firstpart ... has to start and end with an OC. For the characters in the middle you can have certain characters such as underscore, but the start and end have to be an OC. (However, it's ok to have only one OC and that's it, for example: j@blah.com)

 __serverpart ... You have sections like "blah." which repeat. (So mail.city.fcu.edu type of thing.) The sections have to start and end with an OC, but in the middle you can also have a dash "-". (If you want to allow other unusual characters in there, perhaps the underscore, simply add before the dash.) It's OK to have a section which is just one OC. (As in joe@w.campus.edu) You can have up to five sections, you have to have one. Finally the TLD (such as .com) is strictly 2 to 8 in size . Obviously, just change that "8" as preferred by your support department.
 */

public struct RegexHelper {
    public static let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
    public static let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
    public static let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,40}"
    public static let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)
}

//
// MARK: Data Detection
//

public extension String {

    @inlinable
    var isEmail : Bool {
        return RegexHelper.__emailPredicate.evaluate(with: self)
    }

    @inlinable
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    @inlinable
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self,
                                           options: [],
                                           range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }

    @inlinable
    var containsSpecialCharacters : Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[^a-z0-9 ]", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) {
                return true
            } else {
                return false
            }
        } catch {
            return true
        }
    }
}

@inlinable
public func +(lhs: NSMutableAttributedString, rhs: NSMutableAttributedString) -> NSMutableAttributedString {
    let result = NSMutableAttributedString()
    result.append(lhs)
    result.append(rhs)
    return result
}


