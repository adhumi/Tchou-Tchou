import Foundation
import AppKit

extension NSFont {
    var fixedWidthDigitsFont: NSFont? {
        var attributes = fontDescriptor.fontAttributes
        attributes[NSFontDescriptor.AttributeName.featureSettings] = [[kCTFontFeatureTypeIdentifierKey: kNumberSpacingType,
                                                                       kCTFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector],
                                                                      [kCTFontFeatureTypeIdentifierKey: kNumberCaseType,
                                                                       kCTFontFeatureSelectorIdentifierKey: kUpperCaseNumbersSelector]]
        return NSFont(descriptor: NSFontDescriptor(fontAttributes: attributes), size: 0)
    }
}

