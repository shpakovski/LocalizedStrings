import Foundation

/// Wrapping object for each entity in the .strings file
class LocalizedString {
    
    // Full source string including \n
    let source: String
    
    init(source: String) {
        self.source = source
    }
}
