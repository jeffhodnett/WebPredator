//
//  JHWebPredatorViewController.swift
//  WebPredator
//
//  Created by Jeff Hodnett on 5/5/15.
//  Copyright (c) 2015 Jeff Hodnett. All rights reserved.
//

import Foundation
import UIKit

/**
 * Array extensions
 * Thanks Alex Wayne
 * http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
 */
extension Array {
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(index: Int) -> T? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

/**
 * String extensions
 */
extension String {
    static let Empty: String = ""
    static let Whitespace: String = " "
    var isEmptyOrWhiteSpace : Bool { return self.isEmpty || self.isWhiteSpace }
    var isWhiteSpace        : Bool { return !self.isEmpty && self.trim().isEmpty }
    
    // Clean the string of whitespace
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

/**
 * UIColor extensions
 */
extension UIColor {
    
    // Usage - UIColor(r: 110, g: 110, b: 110)
    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    // Usage - UIColor(r: 110, g: 110, b: 110, a: 1.0)
    convenience init(r: Int, g: Int, b: Int, a: Double) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a)
        )
    }
    
    // Usage - UIColor(hex: "#013E")
    // Thanks yeahdongcn
    // https://github.com/yeahdongcn/UIColor-Hex-Swift/blob/master/UIColorExtension.swift
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hex.hasPrefix("#") {
            let index   = advance(hex.startIndex, 1)
            let hex     = hex.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    // Usage - UIColor(rgb: "rgb(0,12,212)") or UIColor(rgba: "rgba(0,12,212,0.5)")
    convenience init(rgbString: String) {
        
        // Normalize the string
        var rgb = rgbString.lowercaseString
        
        // Cleanup the string
        var inputString = rgbString.trim()
        let illegalCharacters = [String.Whitespace, ";"]
        for illegal in illegalCharacters {
            inputString = inputString.stringByReplacingOccurrencesOfString(illegal, withString: String.Empty, options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        // Confirm the string contains rgb or rgba
        let rgbIndex = inputString.rangeOfString("rgb", options: .CaseInsensitiveSearch)
        let rgbaIndex = inputString.rangeOfString("rgba", options: .CaseInsensitiveSearch)
        
        // Function to parse out rgb or rgba color values
        func rgbaParser(str: String, hasAlpha: Bool) -> (red: Int, green: Int, blue: Int, alpha: Double) {
            
            // Color index in componentsSeparatedByString(",") array
            enum ColorIndex : Int {
                case Red = 0
                case Green = 1
                case Blue = 2
                case Alpha = 3
            }
            
            var r: Int = 0
            var g: Int = 0
            var b:  Int = 0
            var a: Double = 1.0
            
            let values = inputString.componentsSeparatedByString(",")
            
            let prefixDefinition = (hasAlpha) ? "rgba(" : "rgb("
            
            // r
            if let rString: String = values.get(ColorIndex.Red.rawValue) {
                if let prefixRange = rString.rangeOfString(prefixDefinition) {
                    let rValue = rString.substringFromIndex(prefixRange.endIndex)
                    if let red = rValue.toInt() {
                        r = red
                    }
                }
            }
            
            // g
            if let gString: String = values.get(ColorIndex.Green.rawValue) { // hah gString
                if let green = gString.toInt() {
                    g = green
                }
            }
            
            if (hasAlpha) {
                // b
                if let bString: String = values.get(ColorIndex.Blue.rawValue) {
                    if let blue = bString.toInt() {
                        b = blue
                    }
                }
                
                // a
                if let aString: String = values.get(ColorIndex.Alpha.rawValue) {
                    if let prefixRange = aString.rangeOfString(")") {
                        let aValue = aString.substringToIndex(prefixRange.startIndex)
                        if let alpha = NSNumberFormatter().numberFromString(aValue) {
                            a = Double(alpha)
                        }
                    }
                }
                
            } else {
                
                // b
                if let bString: String = values.get(ColorIndex.Blue.rawValue) {
                    if let prefixRange = bString.rangeOfString(")") {
                        let bValue = bString.substringToIndex(prefixRange.startIndex)
                        if let blue = bValue.toInt() {
                            b = blue
                        }
                    }
                }
            }
            
            return (r, g, b, a)
        }
        
        // Parse string
        let color = rgbaParser(inputString, (rgbaIndex != nil))
        
        self.init(r:color.red, g:color.green, b:color.blue, a:color.alpha)
    }
    
    // Usage - UIColor(cssColor: "red")
    // http://www.w3.org/TR/css3-color/#html4
    convenience init(cssColor: String) {
        // Default to white
        var hex = "#FFFFFF"
        
        // Setup CSS3 color data
        struct CSSColor {
            var name: String
            var hex: String
        }
        var colors = [
            CSSColor(name: "black", hex: "#000000"),
            CSSColor(name: "silver", hex: "#C0C0C0"),
            CSSColor(name: "gray", hex: "#808080"),
            CSSColor(name: "white", hex: "#FFFFFF"),
            CSSColor(name: "maroon", hex: "#800000"),
            CSSColor(name: "red", hex: "#FF0000"),
            CSSColor(name: "purple", hex: "#800080"),
            CSSColor(name: "fuchsia", hex: "#FF00FF"),
            CSSColor(name: "green", hex: "#008000"),
            CSSColor(name: "lime", hex: "#00FF00"),
            CSSColor(name: "olive", hex: "#808000"),
            CSSColor(name: "yellow", hex: "#FFFF00"),
            CSSColor(name: "navy", hex: "#000080"),
            CSSColor(name: "blue", hex: "#0000FF"),
            CSSColor(name: "teal", hex: "#008080"),
            CSSColor(name: "aqua", hex: "#00FFFF"),
        ]
        
        // Find a color match
        for color in colors {
            if (cssColor.lowercaseString == color.name) {
                hex = color.hex
                break
            }
        }
        self.init(hex: hex)
    }

    // Usage -
    // UIColor(rgba: "#013E") or
    // UIColor(cssColor: "red") or
    // UIColor(rgb: "rgb(0,12,212)") or
    // UIColor(rgba: "rgba(0,12,212,0.5)")
    convenience init(colorString: String) {
        // Determine what color values the string has
        let hexIndex = colorString.rangeOfString("#")
        let rgbIndex = colorString.rangeOfString("rgb", options: .CaseInsensitiveSearch)
        let rgbaIndex = colorString.rangeOfString("rgba", options: .CaseInsensitiveSearch)
        
        if (hexIndex != nil) { // Check if hex string
            self.init(hex: colorString)
            return
        } else if (rgbIndex != nil || rgbaIndex != nil) { // Check if rgb or rgb string
            self.init(rgbString: colorString)
            return
        } else {    // Check if matches a css color string and default to white if not
            self.init(cssColor: colorString)
            return
        }
    }
}

/**
 * JHWebPredatorViewController
 *
 * This view controller copies the webview's background color and matches its own
 * view's background color to blend in seamlessly
 */
class JHWebPredatorViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this to delegate so we can listen for webViewDidFinishLoad
        self.webView.delegate = self
    }
    
    // MARK: <UIWebViewDelegate>
    func webViewDidFinishLoad(webView: UIWebView) {
        
        // Parse background color using the window.getComputedStyle function
        if let bgColor = webView.stringByEvaluatingJavaScriptFromString("window.getComputedStyle(document.body).backgroundColor") {
            webView.backgroundColor = UIColor(colorString: bgColor)
        }
        
    }
}
