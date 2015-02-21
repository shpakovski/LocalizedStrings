import Foundation

/// Wrapping object for each entity in the .strings file
struct LocalizedString {
    let sourceString: NSString
    let keyRange: NSRange
    let valueRange: NSRange
    let commentRange: NSRange
}
