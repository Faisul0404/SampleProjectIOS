//
//  Extentions.swift
//  Copyright © 2019 Elegant Media Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

extension Dictionary {
    // To Update Parameter dictionary
    mutating func updateDictionary(otherValues: Dictionary) {
        for (key, value) in otherValues {
            self.updateValue(value, forKey: key)
        }
    }
    
    func nullKeyRemoval() -> Dictionary {
        var dict = self
        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull || ((dict[$0] as? Int) == 0) || ((dict[$0] as? String) == "") }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        return dict
    }
}

extension UITextField {
    func setBottomBorder(color: UIColor = .lightGray, height: CGFloat = 1.0) {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: height)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UISearchBar {
    
    func tfBackgroundColor(color: UIColor){
        for view in self.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = color
                }
            }
        }
    }
}

extension UIView {
    func addLayerEffects(with borderColor: UIColor? = nil, borderWidth: CGFloat = 0.0, cornerRadius: CGFloat = 0.0) {
        self.layer.borderColor = borderColor?.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addShadow(offSet: CGFloat = 2.0, color: UIColor = .lightGray) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: offSet, height: offSet)
        self.layer.shadowOpacity = 1
        self.layer.shouldRasterize = false
        self.layer.masksToBounds = false
    }
    
    func convertToImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImageFromMyView!
    }
    
    func applyGradient(isTopBottom: Bool, colorArray: [UIColor]) {
        if let sublayers = layer.sublayers {
            let _ = sublayers.filter({ $0 is CAGradientLayer }).map({ $0.removeFromSuperlayer() })
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isTopBottom {
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //leftRight
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        backgroundColor = .clear
        gradientLayer.frame = self.bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
//
//    func removingAllWhitespaces() -> String {
//        return removingCharacters(from: .whitespaces)
//    }
//
//    func removingCharacters(from set: CharacterSet) -> String {
//        var newString = self
//        newString.removeAll { char -> Bool in
//            guard let scalar = char.unicodeScalars.first else { return false }
//            return set.contains(scalar)
//        }
//        return newString
//    }
//
    //get Date string and split it
    func getDateString() -> String {
        let dateStr = self
        let dateValue = dateStr.components(separatedBy: " ")
        let date = dateValue[0]
        return date
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    func htmlAttributedString(family: String?, size: CGFloat, hexString: String) -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(size)pt !important;" +
                "color: #\(hexString) !important;" +
                "font-family: \(family ?? "Helvetica"), Helvetica !important;" +
            "}</style> \(self)"
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
}

extension Double {
    func seperateSecondstoTime() -> String {
        let _hours = String(format: "%02d", Int(self) / 3600)
        let _mins = String(format: "%02d", Int(Int(self) % 3600) / 60)
        let _seconds = String(format: "%02d", Int(Int(self) % 3600) % 60)
        
        return ("\(_hours):\(_mins):\(_seconds)")
    }
}

extension UIImageView {
    func setImageWithUrl(_ urlString: String, placeholderImage: UIImage = UIImage()) {
        if let url = URL(string: urlString) {
            self.af_setImage(withURL: url, placeholderImage: placeholderImage, progressQueue: .global())
        }
    }
}

extension UIButton {
    func setImageWithUrl(_ urlString: String, isBackground: Bool = false, state: UIControl.State = .normal, placeholderImage: UIImage = UIImage()) {
        if let url = URL(string: urlString) {
            switch isBackground {
            case true:
                self.af_setBackgroundImage(for: state, url: url, placeholderImage: placeholderImage, progressQueue: .global())
            default:
                self.af_setImage(for: state, url: url, placeholderImage: placeholderImage, progressQueue: .global())
            }
        }
    }
}

extension UIImage {
    func convertImageToData(quality: CGFloat = 0.5) -> Data? {
        if let imageData = self.jpegData(compressionQuality: quality) {
            return imageData
        }
        return nil
    }
    
    func cropsToSquare() -> UIImage {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        
        let x = (refWidth - cropSize) / 2.0
        let y = (refHeight - cropSize) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }
    
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}

extension UIStoryboard {
    ///The uniform place where we state all the storyboard we have in our application
    enum StoryBoard: String {
        case Auth
        case Home
        case Tabs
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    //MARK: Convenience Initializer
    convenience init(storyboard: StoryBoard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    //MARK: Class Functions
    class func storyboard(_ storyboard: StoryBoard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.filename, bundle: bundle)
    }
    
    //MARK: ViewController Instantiation from Generics
    func instantiateViewController<T>(withIdentifire identifire: T.Type) -> T where T: UIViewController {
        let className = String(describing: identifire)
        guard let vc = self.instantiateViewController(withIdentifier: className) as? T else {
            fatalError("cannot find controler with identifire \(className)")
        }
        return vc
    }
}

extension UIViewController {
    internal enum NavigationBarVisibility {
        case show
        case hide
    }
    
    func toggleNavigationBarVisibility(_ visibility: NavigationBarVisibility) {
        switch visibility {
        case .show:
            navigationController?.navigationBar.isHidden = false
        case .hide:
            navigationController?.navigationBar.isHidden = true
        }
    }
}

extension Bundle {
    var appName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
    
    var bundleId: String? {
        return bundleIdentifier
    }
    
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
