//
//  HesseKit.swift
//  HesseKit
//
//  Created by Hesse on 17/04/18.
//  Copyright © 2017年 HesseKit. All rights reserved.
//

import UIKit
import AudioToolbox

// ====================================================
//
// MARK: - Global Variables
//
// ====================================================
public var appVersion: String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
}
public var systemLanguages: [String] {
    return UserDefaults.standard.stringArray(forKey: "AppleLanguages") ?? []
}

// ====================================================
//
// MARK: - Global Functions
//
// ====================================================
public func sleep(duration: TimeInterval) {
    #if DEBUG
        Thread.sleep(forTimeInterval: duration)
    #endif
}

/// Swift still calls `print()` and/or `debugPrint()` in shipped apps.
/// We use a method described in onevcat's post (https://onevcat.com/2016/02/swift-performance/)
/// to optimaze the performance.
///
/// - Parameter item: items to print
public func dprint(_ item: @autoclosure () -> Any) {
    #if DEBUG
        print(item())
    #endif
}

// ====================================================
//
// MARK: - Swift Standard Library
//
// ====================================================

public extension Int {
    
    /// Whether self is an odd number
    var isOdd: Bool {
        return !isEven
    }
    
    /// Whether self is an even number
    var isEven: Bool {
        return self % 2 == 0
    }
    
    /// Treats 0 as nil
    var nilIfZero: Int? {
        if self == 0 { return nil }
        return self
    }
    
    /// Make the number to string
    var string: String {
        return String(self)
    }
    
    /// Make a range from zero to self
    var range: CountableRange<Int> {
        return 0..<self
    }
    
    /// Return a number of instances
    ///
    /// - Parameter creation: The initialization of the object
    /// - Returns: An array containing the objects
    func instances<T>(of creation: @autoclosure () throws -> T) rethrows -> [T] {
        return try (0 ..< self).map { _ in
            try creation()
        }
    }
    
    /// Return if `self` is in the given range.
    ///
    /// - Parameter range: Target range.
    /// - Returns: `true` if self is in the range, otherwise `false`.
    func inRange(_ range: Range<Int>) -> Bool {
        return range.contains(self)
    }
    
    
    // minutes to seconds
    var minutes: Int {
        return self * 60
    }
    
    // hours to seconds
    var hours: Int {
        return (self * 60).minutes
    }
    
    var days: Int {
        return (self * 24).hours
    }
    
    var months: Int {
        return (self * 30).days
    }
    
    var years: Int {
        return (self * 12).months
    }
    
}

public extension Double {
    
    /// Represent a double value as price.
    var priceText: String {
        return String(format: "%.2f", self)
    }
    
}

public extension Bool {
    mutating func toggle() {
        self = !self
    }
}

public extension Collection {
    
    /// Safe indexing.
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    /// ref: https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
    ///
    /// - Parameter index: The index used to retrieve a value / an object.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element: Equatable {
    
    /// Removes the given element in the array.
    ///
    /// - Parameter element: The element to be removed.
    /// - Returns: The element got removed, or `nil` if the element doesn't exist.
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        if let index = self.firstIndex(of: element) {
            return self.remove(at: index)
        }
        return nil
    }
    
    /// Returns an array where repeating elements of the receiver got removed.
    var removingRepeatElements: Array<Element> {
        var arr = Array<Element>()
        forEach {
            if !arr.contains($0) {
                arr.append($0)
            }
        }
        return arr
    }
}

public extension String {
    /// 验证手机号
    var isChinesePhoneNumber: Bool {
        /**
         * 手机号码
         * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
         * 联通：130,131,132,152,155,156,185,186
         * 电信：133,1349,153,180,189,177
         */
        //        let mobile = "^1(3[0-9]|5[0-35-9]|77|8[0125-9])\\d{8}$"
        
        /**
         * 中国移动：China Mobile
         * 移动号段有134,135,136,137, 138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
         */
        let chinaMobile = "^1(34[0-8]|(3[5-9]|5[0127-9]|78|8[23478])\\d)\\d{7}$"
        
        /**
         * 中国联通：China Unicom
         * 联通号段有130，131，132，155，156，185，186，145，176
         */
        let chinaUnicom = "^1(3[0-2]|45|5[256]|76|8[56])\\d{8}$"
        
        /**
         * 中国电信：China Telecom
         * 电信号段有133，153，177，180，181，189, 1349
         */
        let chinaTelecom = "^1((33|53|77|8[019])[0-9]|349)\\d{7}$"
        
        //        let regextestMobile: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobile)
        let regextestCM = NSPredicate(format: "SELF MATCHES %@", chinaMobile)
        let regextestCU = NSPredicate(format: "SELF MATCHES %@", chinaUnicom)
        let regextestCT = NSPredicate(format: "SELF MATCHES %@", chinaTelecom)
        return (/*regextestMobile.evaluateWithObject(mobileNum) || */regextestCM.evaluate(with: self) || regextestCU.evaluate(with: self) || regextestCT.evaluate(with: self))
    }
    
    /// 验证邮箱
    var isEmail: Bool {
        let emailRegax = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegax)
        return emailTest.evaluate(with: self)
    }
    /// 验证身份证
    var isIDCardNumber: Bool {
        let regex2 = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        let identityCardPredicate = NSPredicate(format: "SELF MATCHES %@", regex2)
        return identityCardPredicate.evaluate(with: self)
    }
    /// 银行卡
    var isBankCardNumber: Bool {
        let regex2 = "^(\\d{15,30})"
        let bankCardPredicate = NSPredicate(format: "SELF MATCHES %@", regex2)
        return bankCardPredicate.evaluate(with: self)
    }
    /// 全是数字
    var areNumbers: Bool {
        let allnumRegex = "^[0-9]*$"
        let numPredicate = NSPredicate(format: "SELF MATCHES %@", allnumRegex)
        return numPredicate.evaluate(with: self)
    }
    /// 提现金额的验证
    var isCashbackAmount: Bool {
        let regex = "^[0-9]+(.[0-9]{1,2})?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// 字符串中皆为汉字
    var areChinese: Bool {
        let regex = "\\p{script=Han}+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
}


public extension String {
    
    /// Cast to Int
    var toInt: Int? { Int(self) }
    /// Cast to Double
    var toDouble: Double? { Double(self) }
    
    /// Trimming ".0"
    var trimmingZeroDecimal: String {
        if let double = Double(self), double.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", double)
        }
        return self
    }
    
    /// Adding "+" at the very beginning.
    var addingPlusSymbol: String { "+" + self }
    /// Adding "-" at the very beginning.
    var addingMinusSymbol: String { "-" + self }
    
    /// Returns the CGSize that the string being layout on screen.
    ///
    /// - Parameter font: The given font.
    /// - Returns: The result CGSize.
    func layoutSize(with font: UIFont) -> CGSize {
        self.size(withAttributes: [.font: font])
    }
    
    /// Convert to a price format, e.g. “56.00” -> “￥56.00”
    var priceText: String {
        Double(self)?.priceText ?? self
    }
        
    /// Hide some digits for the phone number. Only Chinese mobile phone number is supported.
    var securedPhone: String {
        if isChinesePhoneNumber {
            let firstFourDigit = self[..<index(startIndex, offsetBy: 3)]
            let lastFourDigit = self[index(endIndex, offsetBy: -4)...]
            return String(firstFourDigit) + "****" + String(lastFourDigit)
        }
        return self
    }

    /// Cast as Int and add the given value. No changes if casting fails.
    mutating func advanceNumberValue(step: Int = 1) {
        if let value = Int(self) {
            self = String(value.advanced(by: step))
        }
    }
    
    /// Comparing app versions. Returns `true` if self is `1.1.0` and the given value is `1.2.0`.
    /// - Parameter aVersion: Another version.
    /// - Returns: `true`  if the give version is newer than self.
    func isOldAppVersion(comparedWith aVersion: String) -> Bool {
        self.compare(aVersion, options: .numeric) == .orderedAscending
    }
    
    var uppercasingFirstLetter: String {
        prefix(1).uppercased() + dropFirst()
    }
    
    var lowercasingFirstLetter: String {
        prefix(1).lowercased() + dropFirst()
    }
    
    /// Return `true` if self is empty or only contains white spaces and/or new lines.
    var isBlank: Bool { isEmpty || trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    /// Return `false` if self is empty or only contains white spaces and/or new lines.
    var isVisible: Bool { !isBlank }
    /// Return `nil` if `self.isBlank` is `true`.
    var nilIfBlank: String? { isBlank ? nil : self }
    
    @available(*, deprecated, message: "Use `nilIfBlank` instead.")
    func treatsVisuallyEmptyAsNil() -> String? { nilIfBlank }

}

public extension Optional where Wrapped == String {
    /// Return `true` if self is empty or only contains white spaces and/or new lines.
    var isBlank: Bool {
        if case .some(let str) = self {
            return str.isBlank
        }
        return true
    }
    /// Return `false` if self is empty or only contains white spaces and/or new lines.
    var isVisible: Bool {
        !isBlank
    }
}

public extension Data {
    /// Returns a string of hex value.
    var hexString: String {
        return withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> String in
            let buffer = bytes.bindMemory(to: UInt8.self)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}

// ====================================================
//
// MARK: - Apple Foundation
//
// ====================================================

public extension NSObject {
    
    /// Exchange two implementations of the given selectors, aka method swizzling.
    ///
    /// - Parameters:
    ///   - originalSelector: The original selector.
    ///   - swizzledSelector: Another selector.
    class func exchangeImplementations(originalSelector: Selector, swizzledSelector: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        else {
            dprint("Error: Unable to exchange method implemenation!!")
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    /// Return class name.
    var className: String {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }
    
    /// Print the deinitialization message of self.
    final func printDeinitMessage() {
        dprint("Deinit Message: \(className): \(self)")
    }
}


public extension FileManager {
    
    /// 返回指定路径上的文件大小
    ///
    /// - Parameter path: 路径
    /// - Returns: 文件大小
    func fileSize(atPath path: String) -> Int {
        let attributes = try? attributesOfItem(atPath: path)
        return (attributes?[FileAttributeKey.size] as? Int) ?? 0
    }
    
    /// 返回指定路径上的目录大小
    ///
    /// - Parameter path: 路径
    /// - Returns: 目录大小
    func folderSize(atPath path: String) -> Int {
        let manager = FileManager.default
        if manager.fileExists(atPath: path) {
            do {
                let childFilesEnumerator = try (manager.subpathsOfDirectory(atPath: path) as NSArray).objectEnumerator()
                var folderSize = 0
                while childFilesEnumerator.nextObject() != nil {
                    if let fileName = childFilesEnumerator.nextObject() as? String,
                        let url = URL(string: path) {
                        let fileAbsolutePath = url.appendingPathComponent(fileName).absoluteString
                        folderSize += self.fileSize(atPath: fileAbsolutePath)
                    }
                }
                return folderSize
                
            } catch {
                dprint(error)
            }
        }
        return 0
    }
    
    
    /// 返回指定路径上的目录大小
    ///
    /// - Parameter URL: URL
    /// - Returns: 目录大小
    func directorySize(at URL: URL) -> Int {
        var result = 0
        let properties = [URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
        let manager = FileManager.default
        do {
            let urls = try manager.contentsOfDirectory(at: URL, includingPropertiesForKeys: properties, options: .skipsHiddenFiles)
            for fileSystemItem in urls {
                var directory: ObjCBool = false
                let path = fileSystemItem.path
                manager.fileExists(atPath: path, isDirectory: &directory)
                if directory.boolValue {
                    result += directorySize(at: fileSystemItem)
                } else {
                    result += try manager.attributesOfItem(atPath: path)[FileAttributeKey.size] as! Int
                }
            }
            
        } catch {
            dprint("无法计算目录大小：\(error)")
        }
        return result
    }
}

public extension Timer {
    
    /// 设定一个非重复延时timer（注意：这是一个CFRunLoopTimer对象，如果需要，请调用CFRunLoopTimer的`invalidate()`方法）
    ///
    /// - Parameters:
    ///   - delay: 延时时长
    ///   - handler: 回调
    /// - Returns: 一个CFRunLoopTimer对象
    @discardableResult
    class func schedule(delay: TimeInterval, handler: @escaping () -> Void) -> CFRunLoopTimer? {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0) { _ in
            handler()
        }
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer
    }
    
    
    /// 设定一个重复延时timer（注意：这是一个CFRunLoopTimer对象，如果需要，请调用CFRunLoopTimer的`invalidate()`）
    ///
    /// - Parameters:
    ///   - interval: 触发时长，从现在开始经过interval时长后触发第一次
    ///   - handler: 回调
    /// - Returns: 一个CFRunLoopTimer对象
    @discardableResult
    class func schedule(repeatInterval interval: TimeInterval, handler: @escaping () -> Void) -> CFRunLoopTimer? {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0) { _ in
            handler()
        }
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer
    }
    
}

public extension Date {
    private static let days = ["", "周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    /// 返回当天星期几，如：周一、周六
    var weekdayCN: String {
        let gregorian = Calendar(identifier: .gregorian)
        let weekday = gregorian.component(.weekday, from: self)
        return Date.days[weekday]
    }
}

public extension Locale {
    static var cn: Locale {
        return Locale(identifier: "zh_Hans")
    }
    static var en_hk: Locale {
        return Locale(identifier: "en_HK")
    }
    static var tc_hk: Locale {
        return Locale(identifier: "zh_Hant_HK")
    }
}

// ====================================================
//
// MARK: - Apple CoreFoundation
//
// ====================================================
public extension CFRunLoopTimer {
    /// 使一个CFRunLoopTimer失效
    func invalidate() {
        CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), self, .commonModes)
    }
}



// ====================================================
//
// MARK: - Apple UIKit
//
// ====================================================
public extension UIApplication {
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), canOpenURL(url) {
            if #available(iOS 10.0, *) {
                open(url, options: [:], completionHandler: nil)
            } else {
                openURL(url)
            }
        }
    }
    func openPhone(calling number: String) {
        if let url = URL(string: "tel://" + number) {
            if #available(iOS 10.0, *) {
                open(url, options: [:], completionHandler: nil)
            } else {
                openURL(url)
            }
        }
    }
    /// Find My Facebook ID: https://findmyfbid.com/
    func openFacebook(name: String?, id: String?) {
        if let facebookID = id,
            let facebookURL = URL(string: "fb://profile/\(facebookID)"),
            UIApplication.shared.canOpenURL(facebookURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(facebookURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(facebookURL)
            }
        }
        else if let name = name {
            UIViewController.getCurrentViewController()?.pushSafariViewController(urlString: "https://www.facebook.com/" + name)
        }
    }
    
    func openInstagram(name: String?) {
        if let ins = name {
            if let instagramURL = URL(string: "instagram://user?username=\(ins)"),
                UIApplication.shared.canOpenURL(instagramURL) {
                if #available(iOS 10.0, *) {
                    open(instagramURL, options: [:], completionHandler: nil)
                } else {
                    openURL(instagramURL)
                }
            } else {
                UIViewController.getCurrentViewController()?.pushSafariViewController(urlString: "https://www.instagram.com/" + ins)
            }
        }
    }
    
    /// Open a map app with the given query. Orders: Google Map -> Apple Map
    ///
    /// - Parameter query: The query to search on the map.
    func openExternalMapApp(query: String) {
        if let string = "comgooglemaps://?q=\(query)&zoom=13".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let googleMapURL = URL(string: string),
            UIApplication.shared.canOpenURL(googleMapURL) {
            UIApplication.shared.open(googleMapURL)
            return
        }
        if let string = "https://maps.apple.com/?address=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }
    }
}

public extension UIView {

    /// 便利属性，读写layer的anchorPoint
    var anchorPoint: CGPoint {
        get {
            return layer.anchorPoint
        }
        set {
            let oldOrigin = frame.origin
            layer.anchorPoint = newValue
            let newOrigin = frame.origin
            let transition = CGPoint(x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin .y)
            center = CGPoint(x: center.x - transition.x, y: center.y - transition.y)
        }
    }
    
    /// 便利属性，读写layer的cornerRadius
    @IBInspectable var layerCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// 便利属性，读写layer的borderWidth
    @IBInspectable var layerBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 便利属性，读写layer的borderColor
    @IBInspectable var layerBorderColor: UIColor? {
        get {
            return layer.borderColor == nil ? nil : UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    enum GradientLayerChangingDirection {
        case top, bottom, left, right
    }
    
    /// 添加一个透明渐变Layer
    ///
    /// - Parameters:
    ///   - frame: 渐变Layer的frame，如果不指定则为self的bounds
    ///   - toColor: 渐变成什么颜色
    ///   - minAlpha: 透明度最小值
    ///   - maxAlpha: 透明度最大值
    ///   - horizontally: 水平方向是否参与渐变
    ///   - vertically: 垂直方向是否参与渐变
    @discardableResult
    func addTransparentGradientLayer(frame: CGRect? = nil, toColor: UIColor, minAlpha: CGFloat, maxAlpha: CGFloat, from start: GradientLayerChangingDirection, to end: GradientLayerChangingDirection) -> CAGradientLayer {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        toColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame ?? self.bounds
        gradientLayer.colors = [minAlpha, maxAlpha].map { UIColor(red: r, green: g, blue: b, alpha: $0).cgColor }
        gradientLayer.locations = [0, 1]
        
        switch start {
        case .left:
            gradientLayer.startPoint.x = 0
        case .right:
            gradientLayer.startPoint.x = 1
        case .top:
            gradientLayer.startPoint.y = 0
        case .bottom:
            gradientLayer.startPoint.y = 1
        }
        
        switch end {
        case .left:
            gradientLayer.endPoint.x = 1
        case .right:
            gradientLayer.endPoint.x = 0
        case .top:
            gradientLayer.endPoint.y = 0
        case .bottom:
            gradientLayer.endPoint.y = 1
        }
        
        layer.addSublayer(gradientLayer)
        return gradientLayer
    }
    
    
    /// Resizes `self.frame` so as to fit the constraint-based layout.
    func sizeToFitConstraintedBasedLayout() {
        frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    
    /// Commit a shake animation and vibrate to indicate the occured error.
    func shakeToIndicateError() {
        commitShakeAnimation()
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    private func commitShakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }

}

// These methods are for fixing a bug that `layer.content` exceeds its border programmically set by those `layer.borderxxx`.
public extension UIView {
    
    func addCleanBorder(cornerRadius: CGFloat, color: UIColor, width: CGFloat, targetBounds: CGRect?) {
        let path = UIBezierPath(roundedRect: targetBounds ?? bounds, cornerRadius: cornerRadius)
        return addCleanBorder(using: path, color: color, width: width, targetBounds: targetBounds)
    }
    
    func addCleanBorder(roundingCorners: UIRectCorner, cornerRadii: CGSize, color: UIColor, width: CGFloat, targetBounds: CGRect?) {
        let path = UIBezierPath(roundedRect: targetBounds ?? bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadii)
        return addCleanBorder(using: path, color: color, width: width, targetBounds: targetBounds)
    }
    
    private func addCleanBorder(using path: UIBezierPath, color: UIColor, width: CGFloat, targetBounds: CGRect?) {
        // Setting up a mask that clips receiver's content
        if layer.mask?.name == "addCleanBorderMaskLayerName" {
            layer.mask = nil
        }
        let maskLayer = CAShapeLayer()
        maskLayer.name = "addCleanBorderMaskLayerName"
        maskLayer.frame = targetBounds ?? bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        
        // Setting up an additional layer that acts like a normal border.
        if let borderLayer = layer.sublayers?.first(where: { $0.name == "addCleanBorderBorderLayerName" }) {
            borderLayer.removeFromSuperlayer()
        }
        let borderLayer = CAShapeLayer()
        borderLayer.name = "addCleanBorderBorderLayerName"
        borderLayer.frame = targetBounds ?? bounds
        borderLayer.path = path.cgPath
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = width * 2
        borderLayer.fillColor = nil
        layer.addSublayer(borderLayer)
    }
}

public extension UIColor {
    
    convenience init(rgbValue: UInt, alpha: CGFloat) {
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    convenience init(rgbValue: UInt) {
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1)
    }
    
    convenience init(hexCode: String) {
        var cString:String = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            self.init()
        } else {
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: 1)
        }
    }
    
    /// Check whether self is a light/bright color.
    /// https://stackoverflow.com/questions/2509443/check-if-uicolor-is-dark-or-bright
    var isLight: Bool {
        guard let components = cgColor.components, components.count > 2 else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return brightness > 0.5
    }
    
    var isExtremelyLight: Bool {
        guard let components = cgColor.components, components.count > 2 else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return brightness > 0.9
    }

}


public extension UIImage {
    
    convenience init?(qrCodeFrom string: String) {
        if let data = string.data(using: .ascii), let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                self.init(ciImage: output)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func withStarShape(size: CGSize, strokeColor: UIColor = .clear, lineWidth: CGFloat = 2.0, fillColor: UIColor?) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let starPath = UIBezierPath()
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let numberOfPoints = CGFloat(5.0)
        let numberOfLineSegments = Int(numberOfPoints * 2.0)
        let theta = .pi / numberOfPoints
        
        let circumscribedRadius = center.x
        let outerRadius = circumscribedRadius * 1.039
        let excessRadius = outerRadius - circumscribedRadius
        let innerRadius = CGFloat(outerRadius * 0.382)
        
        let leftEdgePointX = (center.x + cos(4.0 * theta) * outerRadius) + excessRadius
        let horizontalOffset = leftEdgePointX / 2.0
        
        // Apply a slight horizontal offset so the star appears to be more
        // centered visually
        let offsetCenter = CGPoint(x: center.x - horizontalOffset, y: center.y)
        
        // Alternate between the outer and inner radii while moving evenly along the
        // circumference of the circle, connecting each point with a line segment
        for i in 0..<numberOfLineSegments {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            
            let pointX = offsetCenter.x + cos(CGFloat(i) * theta) * radius
            let pointY = offsetCenter.y + sin(CGFloat(i) * theta) * radius
            let point = CGPoint(x: pointX, y: pointY)
            
            if i == 0 {
                starPath.move(to: point)
            } else {
                starPath.addLine(to: point)
            }
        }
        
        starPath.close()
        
        // Rotate the path so the star points up as expected
        var pathTransform  = CGAffineTransform.identity
        pathTransform = pathTransform.translatedBy(x: center.x, y: center.y)
        pathTransform = pathTransform.rotated(by: CGFloat(-.pi / 2.0))
        pathTransform = pathTransform.translatedBy(x: -center.x, y: -center.y)
        
        starPath.apply(pathTransform)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.addPath(starPath.cgPath)
            context.setLineWidth(lineWidth)
            context.setStrokeColor(strokeColor.cgColor)
            if let fillColor = fillColor {
                context.setFillColor(fillColor.cgColor)
            }
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            
        } else {
            print("Error: UIGraphicsGetCurrentContext() returns nil when drawing star shape!")
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
    }
    
    
    /// Returns an identical image with specified tint color. Note that the returned image is with rendering mode `.alwaysOriginal`
    ///
    /// - Reference
    ///
    ///   https://stackoverflow.com/questions/31803157/how-can-i-color-a-uiimage-in-swift
    ///
    /// - Parameter color: The tint color
    /// - Returns: An identical image with specified tint color
    func withTintColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let maskImage = cgImage, let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        context.setBlendMode(.colorBurn)
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
    }
    
    
    
    /// 是否为正方形的图
    var isSquare: Bool {
        return size.height == size.width
    }
    
    /// 图像的二进制数据量大小
    var sizeOnDisk: String {
        var length = Double(self.jpegData(compressionQuality: 1.0)!.count) / 1024 / 1024
        if length < 1.0 {
            length *= 1024
            return "\(length)KB"
        } else {
            return "\(length)MB"
        }
    }
    
    
    /// 返回等比缩放后适应屏幕的高度
    var heightForScreenWidth: CGFloat {
        return aspectHeight(for: Screen.width)
    }
    
    /// 给定的宽度的等比缩放高度
    ///
    /// - parameter width: 目标宽度
    ///
    /// - returns: 等比缩放后的高度
    func aspectHeight(for width: CGFloat) -> CGFloat {
        return width / size.width * size.height
    }
    
    
    /// 给定的高度的等比缩放宽度
    ///
    /// - parameter height: 目标高度
    ///
    /// - returns: 等比缩放后的宽度
    func aspectWidth(for height: CGFloat) -> CGFloat {
        return height / size.height * size.width
    }
    
    
    /// 保持宽高比，返回给定的size的fitting size
    ///
    /// - Parameter binding: <#binding description#>
    /// - Returns: <#return value description#>
    func aspectFitSize(forBindingSize binding: CGSize) -> CGSize {
        let rw = size.width / binding.width
        let rh = size.height / binding.height
        if rw < rh {
            return CGSize(width: size.width / rh, height: binding.height)
        } else {
            return CGSize(width: binding.height, height: size.height / rw)
        }
    }
    
    /// Get an single-colored image
    ///
    /// - Parameters:
    ///   - color: The color
    ///   - rect: The rect to draw in a CGContext.
    /// - Returns: An single-colored image object, nil if any problems occur, such as CGRect.zero got passed.
    class func image(withPureColor color: UIColor, for rect: CGRect, rounded: Bool) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        if rounded {
            context?.fillEllipse(in: rect)
        } else {
            context?.fill(rect)
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 修正图片方向，使之正确地朝上
    ///
    /// - Returns: 修正后的UIImage对象
    var orientationFixed: UIImage {
        
        if imageOrientation == .up {
            return self
        }
        
        guard let cgImage = cgImage else {
            return self
        }
        
        let width = size.width
        let height = size.height
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: .pi)

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: .pi / 2)

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -(.pi / 2))

        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        guard let space = cgImage.colorSpace else { return self }
        let ctx = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        guard let cgimg = ctx.makeImage() else {
            return self
        }
        return UIImage(cgImage: cgimg)
    }
    
    
    /// 获取图像中的某个区域的子图像
    ///
    /// - Parameter rect: 子图像区域
    /// - Returns: 指定区域里的子图像
    func subImage(in rect: CGRect) -> UIImage? {
        if let cgimage = cgImage, let image = cgimage.cropping(to: rect) {
            return UIImage(cgImage: image, scale: 1.0, orientation: .up)
        }
        return nil
    }

    
    /// 将图像重新绘制成指定尺寸
    ///
    /// - Parameter size: 要绘制的尺寸
    /// - Returns: 指定尺寸的新图像
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resizedImageWithAspectFitSize(forBindingSize binding: CGSize) -> UIImage? {
        return resized(to: aspectFitSize(forBindingSize: binding))
    }
    
    
    /// Resize the image so that its width and height are equal.
    ///
    /// - Returns: A newly created image.
    func square() -> UIImage? {
        let edgeLength = max(size.width, size.height)
        let contextSize = CGSize(width: edgeLength, height: edgeLength)
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let origin = CGPoint(x: (contextSize.width - size.width) / 2, y: (contextSize.height - size.height) / 2)
        draw(in: CGRect(origin: origin, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Redraw a new image with the given requirements.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color of the image.
    ///   - cornerRadius: The corner radius of the image, pass 0.0 if you perfer a squared one.
    ///   - insets: The inset to apply to the image.
    /// - Returns: A newly created image.
    func with(backgroundColor: UIColor, cornerRadius: CGFloat, insets: UIEdgeInsets) -> UIImage? {
        let contextSize = CGSize(width: size.width + insets.left + insets.right,
                                 height: size.height + insets.top + insets.bottom)
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
       
        let context = UIGraphicsGetCurrentContext()
        let contextRect = CGRect(origin: .zero, size: contextSize)
        let backgroundPath = UIBezierPath(roundedRect: contextRect, cornerRadius: cornerRadius)
        context?.addPath(backgroundPath.cgPath)
        context?.setFillColor(backgroundColor.cgColor)
        context?.fillPath()
        draw(in: CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    enum ArrowDirection {
        case up, down, left, right
    }
    
    static func arrowHead(direction: ArrowDirection, color: UIColor, size: CGSize, lineWidth: CGFloat = 2.0) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        
        switch direction {
        case .up:
            context?.move(to: rect.bottomLeft)
            context?.addLine(to: rect.topMiddle)
            context?.addLine(to: rect.bottomRight)

        case .down:
            context?.move(to: rect.topLeft)
            context?.addLine(to: rect.bottomMiddle)
            context?.addLine(to: rect.topRight)

        case .left:
            context?.move(to: rect.topRight)
            context?.addLine(to: rect.leftMiddle)
            context?.addLine(to: rect.bottomRight)

        case .right:
            context?.move(to: rect.topLeft)
            context?.addLine(to: rect.rightMiddle)
            context?.addLine(to: rect.bottomLeft)
        }
        
        context?.setLineCap(.round)
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(color.cgColor)
        context?.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    class func borderImage(size: CGSize, backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(borderColor.cgColor)
        context?.setLineWidth(borderWidth)
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: cornerRadius)
        context?.addPath(path.cgPath)
        context?.strokePath()
        context?.setFillColor(backgroundColor.cgColor)
        context?.fillPath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    class func buttonBackgroundBorderImage(backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) -> UIImage? {
        let inset = borderWidth + cornerRadius + 2
        let width = inset * 2 + 1
        return borderImage(size: CGSize(width: width, height: width), backgroundColor: backgroundColor, borderColor: borderColor, borderWidth: borderWidth, cornerRadius: cornerRadius)?.resizableImage(withCapInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), resizingMode: .stretch)
    }
    
    
}

public extension UIViewController {
    
    /// Combine an array of models and an array of views.
    ///
    /// - Parameters:
    ///   - models: The models as data source.
    ///   - views: The views in need of loading data. Note that this is an inout parameters.
    ///   - newViewGeneration: The function to generate new views, which would immediately be appended into `views`.
    ///   - operation: The main operation that combine each model and view together.
    ///   - remainingViews: The handler responsible for dealing with the rest of unused views.
    class func combine<Model, View>(models: [Model], into views: inout [View], newViewGeneration: () -> View, using operation: (Model, View) -> Void, remainingViews: (ArraySlice<View>) -> Void) {
        
        // If the models outnumber the views, generate more views
        if models.count > views.count {
            for _ in 0 ..< models.count - views.count {
                views.append(newViewGeneration())
            }
        }
        
        // Combine each model into each view
        for i in 0 ..< models.count {
            operation(models[i], views[i])
        }
        
        // Handle the rest of unused views
        if views.count > models.count {
            remainingViews(views.suffix(from: models.count))
        }
    }
    
    /// 显示一个弹窗，系统样式。如果传入confirm的两个参数，就会多一个“确定”按键。
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - confirmTitle: 确定键标题
    ///   - confirmHandler: 确定后回调
    ///   - cancelTitle: 取消键标题，默认是“我知道了”
    ///   - cancelHandler: 取消后的回调
    func showSystemAlert(
        title: String?,
        message: String? = nil,
        confirmTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        cancelTitle: String = "Cancel",
        cancelHandler: (() -> Void)? = nil)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: { _ in cancelHandler?() }
        )
        alertController.addAction(cancelAction)
        
        if let confirmTitle = confirmTitle {
            let confirmAction = UIAlertAction(
                title: confirmTitle,
                style: .default,
                handler: { _ in confirmHandler?() }
            )
            alertController.addAction(confirmAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// 显示一个弹窗，带.destructive按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - destructiveTitle: 红色标题
    ///   - destructiveHandler: 红色回调
    ///   - cancelTitle: 取消标题
    ///   - cancelHandler: 取消回调
    func showSystemDistructiveAlert(
        title: String?,
        message: String? = nil,
        destructiveTitle: String?,
        destructiveHandler: (() -> Void)?,
        cancelTitle: String?,
        cancelHandler: (() -> Void)? = nil)
    {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: { _ in
                cancelHandler?()
        }))
        alertViewController.addAction(UIAlertAction(
            title: destructiveTitle,
            style: .destructive,
            handler: { _ in
                destructiveHandler?()
        }))
        present(alertViewController, animated: true, completion: nil)
    }

    
    /// 显示一个弹出菜单
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 描述
    ///   - actions: 各个action
    func showSystemActionSheet(title: String?, message: String?, validActions: (String?, (() -> Void)?)...) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        validActions.forEach { action in
            ac.addAction(UIAlertAction(
                title: action.0,
                style: .default,
                handler: { _ in
                    action.1?()
            }))
        }
        ac.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        present(ac, animated: true, completion: nil)
    }
    

    /// NavigationBar上主标题的颜色
    var titleColor: UIColor? {
        get {
            return navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor
        }
        set {
            if navigationController?.navigationBar.titleTextAttributes == nil {
                navigationController?.navigationBar.titleTextAttributes = [:]
            }
            navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = newValue
        }
    }
    
    
    /// NavigationBar上主标题的字体
    var titleFont: UIFont? {
        get {
            return navigationController?.navigationBar.titleTextAttributes?[.font] as? UIFont
        }
        set {
            if navigationController?.navigationBar.titleTextAttributes == nil {
                navigationController?.navigationBar.titleTextAttributes = [:]
            }
            navigationController?.navigationBar.titleTextAttributes?[.font] = newValue
        }
    }
    
    /// 判断当前View Controller是否正在显示
    var viewIsVisible: Bool {
        return (isViewLoaded && view.window != nil)
    }
    
    private struct AutoHideKeyboardTapKey {
        static var key = "autoHideKeyboardTap"
    }
    
    var automaticallyHideKeyboardWhenViewTapped: Bool {
        get {
            return objc_getAssociatedObject(self, &AutoHideKeyboardTapKey.key) != nil
        }
        set {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.resignTextFieldToHideKeyboard(_:)))
            view.addGestureRecognizer(tap)
            objc_setAssociatedObject(self, &AutoHideKeyboardTapKey.key, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
    }
    
    /// 为 `UITapGestureRecognizer` 所使用，隐藏键盘
    @IBAction func resignTextFieldToHideKeyboard(_ sender: AnyObject) {
        view.endEditing(false)
    }
    
    
    /// 返回当前的View Controller
    ///
    /// - Parameter base: 迭代起点
    /// - Returns: 当前的View Controller
    class func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getCurrentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        return base
    }
    
    /// 设置此属性以快速设置底栏于toolbarItems中
    var bottomToolBar: UIView? {
        get {
            if let toolbarItems = toolbarItems, toolbarItems.count == 3 {
                return toolbarItems[1].customView
            }
            return nil
        }
        set {
            if let bar = newValue {
                let toolbarItems = [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(customView: bar),
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                ]
                setToolbarItems(toolbarItems, animated: false)
            } else {
                setToolbarItems(nil, animated: false)
            }
        }
    }

    func popFromNavigationStack() {
        navigationController?.popViewController(animated: true)
    }
    
    func addDismissNavigationItem(localizedTitle: String = "Dismiss", image: UIImage? = nil) {
        if let image = image {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissSelf(_:)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localizedTitle, style: .plain, target: self, action: #selector(dismissSelf(_:)))
        }
    }
    
    @objc func dismissSelf(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private struct HidesNavigationBarBackgroundKey {
        static var whenVisible = "hidesNavigationBarBackgroundWhenVisible"
    }
    var hidesNavigationBarBackgroundWhenVisible: Bool {
        get {
            return (objc_getAssociatedObject(self, &HidesNavigationBarBackgroundKey.whenVisible) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &HidesNavigationBarBackgroundKey.whenVisible, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.bounds.height ?? 0
    }
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.bounds.height ?? 0
    }
}

public extension UIViewControllerPreviewingDelegate where Self: UIViewController {
    
    /// 注册 3D Touch（异步操作）
    ///
    /// - parameter sourceView: sourceView
    func asyncRegisterForPreviewing(with sourceView: UIView) {
        DispatchQueue.global().async {
            if #available(iOS 9.0, *), self.traitCollection.forceTouchCapability == .available {
                self.registerForPreviewing(with: self, sourceView: sourceView)
            }
        }
    }
    
}

public extension UITabBarController {
    func tabBarIconImageView(atIndex index: Int) -> UIView? {
        if let buttonClass = NSClassFromString("UITabBarButton"), let swappableImageViewClass = NSClassFromString("UITabBarSwappableImageView") {
            let buttons = tabBar.subviews.filter({ $0.isKind(of: buttonClass) })
            return buttons[index].subviews.first(where: { $0.isKind(of: swappableImageViewClass) })
        }
        return nil
    }
}

public extension UINavigationController {
    private var barHairline: UIImageView? {
        guard
            let cls = NSClassFromString("_UIBarBackground"),
            let background = navigationBar.subviews.filter({ type(of: $0) == cls }).first
        else {
            return nil
        }
        return background.subviews.filter({ $0.bounds.size.height < 1 }).first as? UIImageView
    }
    var isBarHairlineHidden: Bool {
        get {
            return barHairline?.isHidden ?? false
        }
        set {
            barHairline?.isHidden = newValue
        }
    }
    
    /// 隐藏背景(不包括left/right items)
    func viewWillAppearHideBackground() {
        navigationBar.animateBackground(show: false)
    }
    /// 显示背景(不包括left/right items)
    func viewWillDisappearShowBackground() {
        navigationBar.animateBackground(show: true)
    }

    /// 隐藏整个navigationBar(包括left/right items)
    @available(*, deprecated, message: "use the system method 'setNavigationBarHidden(_:animated:) instead'")
    func viewWillAppearHideNavBar(immediately: Bool = false) {
        navigationBar.animate(show: false, immediately: immediately)
    }

    /// 显示整个navigationBar(包括left/right items)
    @available(*, deprecated, message: "use the system method 'setNavigationBarHidden(_:animated:) instead'")
    func viewWillDisappearShowNavBar(immediately: Bool = false) {
        navigationBar.animate(show: true, immediately: immediately)
    }
    
    func setNavigationBarBackgroundHidden(_ hidden: Bool, animated: Bool) {
        // For iOS 11.0 and later, we use `loyalAlpha`, which requires swizzling;
        // For other versions, simply use `alpha`.
        if #available(iOS 11.0, *) {
            let animations: () -> () = {
                self.navigationBar.background?.loyalAlpha = hidden ? 0 : 1
            }
            let completion: (Bool) -> Void = { _ in
                self.navigationBar.background?.loyalAlpha = hidden ? 0 : 1
                if !hidden {
                    self.navigationBar.background?.loyalAlpha = nil
                }
            }
            if animated {
                UIView.animate(withDuration: 0.25, animations: animations, completion: completion)
            } else {
                animations()
            }
        } else {
            let animations: () -> () = {
                self.navigationBar.background?.alpha = hidden ? 0 : 1
            }
            let completion: (Bool) -> Void = { _ in
                self.navigationBar.background?.alpha = hidden ? 0 : 1
            }
            if animated {
                UIView.animate(withDuration: 0.25, animations: animations, completion: completion)
            } else {
                animations()
            }
        }
    }

}

public extension UINavigationBar {
    
    /// The first subview of the receiver, kind of class `_UIBarBackground`
    /// This view is responsible for rendering `navigationBar.barTintColor`
    var background: UIView? {
        return subviews.first
    }
    
    @available(iOS 11.0, *)
    var largeTitleBaseView: UIView? {
        let cls: AnyClass? = NSClassFromString("_UINavigationBarLargeTitleView")
        return subviews.filter({ type(of: $0) == cls }).first
    }
    
    var centralTitleBaseView: UIView? {
        let cls: AnyClass? = NSClassFromString("_UINavigationBarContentView")
        return subviews.filter({ type(of: $0) == cls }).first
    }
    
    var centralTitleLabel: UILabel? {
        return centralTitleBaseView?.subviews.filter({ type(of: $0) == UILabel.self }).first as? UILabel
    }
    
    var isBackgroundInvisible: Bool {
        get { return background?.alpha == .some(0) }
        set { background?.alpha = newValue ? 0 : 1 }
    }
    
    func animateBackground(show: Bool, immediately: Bool = false) {
        if #available(iOS 11.0, *) {
            // To achieve an animation for the navigation background in iOS 11
            let animations: () -> () = {
                self.background?.loyalAlpha = show ? 1 : 0
            }
            let completion: (Bool) -> Void = { _ in
                self.background?.loyalAlpha = show ? 1 : 0
                if show {
                    self.background?.loyalAlpha = nil
                }
            }
            if immediately {
                animations()
            } else {
                UIView.animate(withDuration: 0.25, animations: animations, completion: completion)
            }
            
        } else {
            guard let background = self.background else { return }
            animate(target: background, show: show, immediately: immediately)
        }
    }
    
    func animate(show: Bool, immediately: Bool = false) {
        animate(target: self, show: show, immediately: immediately)
    }
    
    private func animate(target: UIView, show: Bool, immediately: Bool) {
        let animations = {
            target.alpha = show ? 1 : 0
        }
        let completion: (Bool) -> Void = { _ in
            target.alpha = show ? 1 : 0
        }
        if immediately {
            animations()
        } else {
            UIView.animate(withDuration: 0.25, animations: animations, completion: completion)
        }
    }
    
}

public extension UIButton {
    
    @IBInspectable var normalStateBackgroundColor: UIColor? {
        // not gettable
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .normal)
            }
        }
    }
    @IBInspectable var disabledStateBackgroundColor: UIColor? {
        // not gettable
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .disabled)
            }
        }
    }
    @IBInspectable var highlightedStateBackgroundColor: UIColor? {
        // not gettable
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .highlighted)
            }
        }
    }
    @IBInspectable var selectedStateBackgroundColor: UIColor? {
        // not gettable
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .selected)
            }
        }
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        if let image = UIImage.image(withPureColor: color, for: rect, rounded: false) {
            setBackgroundImage(image, for: state)
        } else {
            dprint("UIButton.setBackgroundColor(_:for:) got called but returning a nil image!")
        }
    }
    
    @IBInspectable var titleImageSpacing: CGFloat {
        get { return -1 }
        set {
            self.centerTextAndImage(spacing: newValue, forceRightToLeft: false)
        }
    }
    
    /// Adjust `contentEdgeInsets`, `imageEdgeInsets` and `titleEdgeInsets` with appropriate value so as to make a specified spacing between the button's title and image.
    /// - Reference: https://stackoverflow.com/questions/4564621/aligning-text-and-image-on-uibutton-with-imageedgeinsets-and-titleedgeinsets
    ///
    /// - Parameters:
    ///   - spacing: The desired spacing to make.
    ///   - forceRightToLeft: Whether the content of the button is in `forceRightToLeft` semantic.
    func centerTextAndImage(spacing: CGFloat, forceRightToLeft: Bool) {
        let insetAmount = spacing / 2
        let factor: CGFloat = forceRightToLeft ? -1 : 1
        
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount*factor, bottom: 0, right: insetAmount*factor)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount*factor, bottom: 0, right: -insetAmount*factor)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
    
    var isTitleImagePositionReversed: Bool {
        get {
            return transform == .identity
        }
        set {
            let reversingTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = reversingTransform
            titleLabel?.transform = reversingTransform
            imageView?.transform = reversingTransform
        }
    }
    
    var backgroundImageView: UIImageView? {
        return subviews.first {
            if let backgroundImageView = $0 as? UIImageView, backgroundImageView != imageView {
                return true
            }
            return false
        } as? UIImageView
    }
    
    
    private class ButtonClosureWrapper {
        
        let closure: () -> Void
        
        init (_ closure: @escaping () -> Void) {
            self.closure = closure
        }
        
        @objc func invoke () {
            closure()
        }
    }

    func addAction(for controlEvent: UIControl.Event, closure: @escaping () -> Void) {
        let wrapper = ButtonClosureWrapper(closure)
        addTarget(wrapper, action: #selector(ButtonClosureWrapper.invoke), for: controlEvent)
        
        var possibleKey = "hessekit_ClosureWrapper_\(arc4random())"
        while objc_getAssociatedObject(self, &possibleKey) != nil {
            possibleKey = "hessekit_ClosureWrapper_\(arc4random())"
        }
        
        objc_setAssociatedObject(self, &possibleKey, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

}


public extension UILabel {
    func layoutHeightForNumberOfLines(_ numberOfLines: Int) -> CGFloat {
        let tempLb = UILabel()
        tempLb.text = text
        tempLb.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        tempLb.numberOfLines = numberOfLines
        return tempLb.intrinsicContentSize.height
    }
    func layoutHeightMoreThanNumberOfLines(_ numberOfLines: Int) -> Bool {
        let nowNumberOfLines = self.numberOfLines
        
        self.numberOfLines = 0
        let line0Height = intrinsicContentSize.height
        
        self.numberOfLines = numberOfLines
        let targetHeight = intrinsicContentSize.height
        
        self.numberOfLines = nowNumberOfLines
        
        return line0Height > targetHeight
    }
}

public extension UITextField {
    
    /// Return whether the text is a valid e-mail address
    var hasValidEmail: Bool {
        return text?.isEmail ?? false
    }
    
    /// Return whether the text is a valid password with more than 8 characters.
    var hasValidPassword: Bool {
        return (text?.count ?? 0) >= 8
    }
    
    /// Return whether the text is valid phone number (Chinese cellphone number, to be exact).
    var hasValidChinesePhoneNumber: Bool {
        return text?.isChinesePhoneNumber ?? false
    }
    
    /// Return whether the text is visible.
    var hasVisibleText: Bool {
        return text?.isVisible ?? false
    }
    
    /// Return whether the text is blank.
    var hasBlankText: Bool {
        return text?.isBlank ?? true
    }
    
}

public extension UITableView {
    var isEmpty: Bool {
        return numberOfSections.range.reduce(0, {
            $0 + numberOfRows(inSection: $1)
        }) == 0
    }
    func reloadCell(_ cell: UITableViewCell, with animation: UITableView.RowAnimation) {
        if let indexPath = indexPath(for: cell) {
            reloadRows(at: [indexPath], with: animation)
        }
    }
    func scrollToBottom(position: UITableView.ScrollPosition = .bottom, animated: Bool = true) {
        if let lastSection = (0 ..< numberOfSections).reversed().first(where: { numberOfRows(inSection: $0) > 0 }) {
            let lastRow = numberOfRows(inSection: lastSection) - 1
            let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
            scrollToRow(at: lastIndexPath, at: position, animated: animated)
        }
    }
}

public extension UITableViewCell {
    
    /// 上层的tableView
    var tableView: UITableView? {
        return superview?.superview as? UITableView
    }
    
    /// 当前cell是否可见
    var isVisible: Bool {
        return tableView?.visibleCells.contains(self) ?? false
    }

    /// 将cell的seperator线顶格
    func makeSeperatorReachMargin() {
        if #available(iOS 11.0, *) {
            
        } else {
            separatorInset = .zero
            layoutMargins = .zero
        }
    }
}

public extension UIPickerView {
    func title(forRow row: Int, forComponent component: Int) -> String? {
        let label = view(forRow: row, forComponent: component) as? UILabel
        return label?.text
    }
}

public extension UISearchBar {
    var textField: UITextField? {
        return subviews.first?.subviews.first(where: { $0 is UITextField }) as? UITextField
    }
}

// ====================================================
//
// MARK: - Apple CoreLocation
//
// ====================================================
import CoreLocation

public extension CLLocationManager {
    static var isLocationServiceEnabled: Bool {
        switch authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .notDetermined, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}


// ====================================================
//
// MARK: - Apple CoreGraphics
//
// ====================================================

public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
}

public extension CGRect {
    var topLeft: CGPoint {
        return origin
    }
    var topRight: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    var topMiddle: CGPoint {
        return CGPoint(x: midX, y: minY)
    }
    var bottomLeft: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }
    var bottomRight: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
    var bottomMiddle: CGPoint {
        return CGPoint(x: midX, y: maxY)
    }
    var leftMiddle: CGPoint {
        return CGPoint(x: minX, y: midY)
    }
    var rightMiddle: CGPoint {
        return CGPoint(x: maxX, y: midY)
    }
    var midX: CGFloat {
        return (maxX - minX) / 2
    }
    var midY: CGFloat {
        return (maxY - minY) / 2
    }
    var center: CGPoint {
        get {
            let x = origin.x + size.width / 2
            let y = origin.y + size.height / 2
            return CGPoint(x: x, y: y)
        }
        set {
            origin.x = newValue.x - size.width / 2
            origin.y = newValue.y - size.height / 2
        }
    }
    var sameCenterSquare: CGRect {
        let maxLength = max(size.width, size.height)
        var rect = CGRect(x: 0, y: 0, width: maxLength, height: maxLength)
        rect.center = center
        return rect
    }
}

public extension CGPoint {
    func offseted(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CGPoint {
        var point = self
        point.x += x
        point.y += y
        return point
    }
}

public extension CGSize {
    
    /// 返回基于self的宽高比、适应于屏幕的size
    var sizeThatFitScreen: CGSize {
        return fittingTargetSize(Screen.size)
    }
    
    /// 使self维持宽高比并适应于屏幕
    mutating func sizeToFitScreen() {
        self = sizeThatFitScreen
    }
    
    /// 返回基于self的宽高比、适应于targetSize的size
    ///
    /// - Parameter targetSize: targetSize
    /// - Returns: 基于self的宽高比、适应于targetSize的size
    func fittingTargetSize(_ targetSize: CGSize) -> CGSize {
        let ratioWidth = width / targetSize.width
        let ratioHeight = height / targetSize.height
        let m = max(ratioWidth, ratioHeight)
        return CGSize(width: width / m, height: height / m)
    }
    
    func addingHeight(_ h: CGFloat) -> CGSize {
        return CGSize(width: width, height: height + h)
    }
}

public extension CGAffineTransform {
    mutating func identify() {
        self = .identity
    }
    mutating func translateBy(x: CGFloat, y: CGFloat) {
        self = self.translatedBy(x: x, y: y)
    }
    mutating func rotate(by angle: CGFloat) {
        self = self.rotated(by: angle)
    }
    mutating func scaleBy(x: CGFloat, y: CGFloat) {
        self = self.scaledBy(x: x, y: y)
    }
}

public extension CALayer {
    
    // https://stackoverflow.com/questions/34269399/how-to-control-shadow-spread-and-blur
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}


// ====================================================
//
// MARK: - Apple SafariServices
//
// ====================================================
import SafariServices

public extension UIViewController {
    func pushSafariViewController(urlString: String, entersReaderIfAvailable: Bool = false) {
        if let url = URL(string: urlString) {
            let safariViewController: SFSafariViewController = {
                if #available(iOS 11.0, *) {
                    let configuration = SFSafariViewController.Configuration()
                    configuration.entersReaderIfAvailable = entersReaderIfAvailable
                    return SFSafariViewController(url: url, configuration: configuration)
                } else {
                    return SFSafariViewController(url: url)
                }
            }()
            if #available(iOS 11.0, *) {
                safariViewController.dismissButtonStyle = .close
                safariViewController.configuration.entersReaderIfAvailable = true
            }
            present(safariViewController, animated: true, completion: nil)
        }
    }
}


// ====================================================
//
// MARK: - Apple CoreNFC
//
// ====================================================
import CoreNFC

public extension NFCTypeNameFormat {
    var description: String {
        switch self {
        case .empty:        return "Empty"
        case .nfcWellKnown: return "NFCWellKnown"
        case .media:        return "Media"
        case .absoluteURI:  return "AbsoluteURI"
        case .nfcExternal:  return "NFCExternal"
        case .unknown:      return "Unknown"
        case .unchanged:    return "Unchanged"
        @unknown default:   return "Unexpected+Unknown"
        }
    }
}

public extension Data {
    
    //
    // The Well Known Type header is as follows:
    // |------------------------------|
    // | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0|
    // |------------------------------|
    // |UTF| 0 | Length of Lang Code  |  1 byte Text Record Status Byte
    // |------------------------------|
    // |          Lang Code           |  2 or 5 bytes, multi-byte language code
    // |------------------------------|
    // |             Text             |  Multiple Bytes encoded in UTF-8 or UTF-16
    // |------------------------------|
    //
    
    /// Treats the receiver as a payload from reading NFC tag, and returns a string value.
    /// This is a very simple implementation of a NFC payload parser and should be called very carefully!!
    ///
    /// Ref: https://github.com/vinceyuan/VYNFCKit/blob/master/VYNFCKit/VYNFCNDEFPayloadParser.m
    var nfcPayloadText: String? {
        
        var firstByte: UInt8 = 0
        copyBytes(to: &firstByte, count: 1)
        let isUTF16 = firstByte & 0x80 == 0x80
        let langCodeLength = Int(firstByte & 0x7F)
        
        
        var textData = [UInt8](repeating: 0, count: count - 1 - langCodeLength)
        copyBytes(to: &textData, from: 1 + langCodeLength ..< count)
        let text = String(data: Data(textData), encoding: isUTF16 ? .utf16 : .utf8)
        
        // Uncomment the following lines of code if you want to inspect the variables.
        
        // var langCodeData = [UInt8](repeating: 0, count: langCodeLength)
        // copyBytes(to: &langCodeData, from: 1 ..< 1 + langCodeLength)
        // let langCode = String(data: Data(bytes: langCodeData), encoding: .utf8)
        
        // print("isUTF16: \(isUTF16)")he
        // print("Lang code: \(langCode as Any)")
        // print("Text: \(text as Any)")
        
        return text
    }
    
    
}


// MARK: - Pending Merge
