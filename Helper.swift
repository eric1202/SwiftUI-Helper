//
//  Helper.swift
//  HdsContract
//
//  Created by LZJ on 2021/12/3.
//

import Foundation
import UIKit
import SwiftUI

enum Device {
    // MARK: 当前设备类型 iphone ipad mac
    enum Devicetype {
        case iphone, ipad, mac
    }

    static var deviceType: Devicetype {
        #if os(macOS)
        return .mac
        #else
        if  UIDevice.current.userInterfaceIdiom == .pad {
            return .ipad
        } else {
            return .iphone
        }
        #endif
 }
}

extension View {
    @ViewBuilder func ifIs<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func ifElse<T: View, V: View>( _ condition: Bool, isTransform: (Self) -> T, elseTransform: (Self) -> V) -> some View {
        if condition {
            isTransform(self)
        } else {
            elseTransform(self)
        }
    }

    @ViewBuilder func lightBlueShadow() -> some View {
        self.shadow(color: Color(hex: "0081FF11"), radius: 4)
    }
}
struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }

}
struct KeyboardManagment: ViewModifier {
    @State private var offset: CGFloat = 0
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            offset = keyboardFrame.height - geo.safeAreaInsets.bottom
                        }
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (_) in
                        withAnimation(Animation.easeOut(duration: 0.1)) {
                            offset = 0
                        }
                    }
                }
                .padding(.bottom, offset)
        }
    }
}
extension View {

    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

    @ViewBuilder
    func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }

    func hideBottomBarWhenOnPush() -> some View {
        return self
//        self.introspectTabBarController(customize: { t in
//            t.tabBar.isHidden = true
//        })
    }
    func keyboardManagment() -> some View {
        self.modifier(KeyboardManagment())
    }
    func bgGrayColor() -> some View {
        self.background(ColorBackground)
    }
    func blackColor() -> some View {
        self.foregroundColor(ColorTitleBlack)
    }
    func textWhiteColor() -> some View {
        self.foregroundColor(Color(hex: "ffffff"))
    }
    func textGray666Color() -> some View {
        self.foregroundColor(Color(hex: "666666"))
    }
    func textGray999Color() -> some View {
        self.foregroundColor(Color(hex: "999999"))
    }
    func redColor() -> some View {
        self.foregroundColor(ColorRed)
    }

    func blueColor() -> some View {
        self.foregroundColor(ColorBlue)
    }

    func font34() -> some View {
        self.font(.largeTitle)
    }

    func font28() -> some View {
        self.font(.title)
    }

    func font22() -> some View {
        self.font(.title2)
    }

    func font20() -> some View {
        self.font(.title3)
    }

    func font18() -> some View {
        self.font(.body)
    }

    func font17() -> some View {
        self.font(.headline)
    }

    func font16() -> some View {
        self.font(.callout)
    }

    func font15() -> some View {
        self.font(.subheadline)
    }

    func font14() -> some View {
        self.font(.subheadline)
    }

    func font13() -> some View {
        self.font(.footnote)
    }

    func font12() -> some View {
        self.font(.caption)
    }

    func font11() -> some View {
        self.font(.caption2)
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class NavBarPreferences: ObservableObject {
    @Published var navBarIsHidden = true
}
extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}

extension String {
    func firstPinYin() -> String {
        guard let c = self.transformToPinYin().first else { return "#" }
        return c.uppercased()

    }

    func transformToPinYin() -> String {

        let mutableString = NSMutableString(string: self)
        // 把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        // 去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)

        let string = String(mutableString)
        // 去掉空格
        return string
    }
}

// extension Codable {
//  var encodeDictionary: [String: Any]? {
//    guard let data = try? JSONEncoder().encode(self) else { return nil }
//    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
//  }
// }

/// 直接将Struct或Class转成Dictionary
protocol Convertable: Codable {

}

extension Convertable {

    /// 直接将Struct或Class转成Dictionary
    func convertToDict() -> [String: Any]? {

        var dict: [String: Any]?

        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(self)

            dict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]

        } catch {
            print(error)
        }

        return dict
    }
}

extension Date {
 var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
        // RESOLVED CRASH HERE
    }

//    init(milliseconds:Int) {
//        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
//    }
}

extension Decimal {
    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}

struct NavigationUtil {
  static func popToRootView() {
      if let nav = findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController) {
          print(nav.debugDescription)
          nav.popToRootViewController(animated: true)
      } else {
          print("popToRootView not call")
      }
  }

  static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
    guard let viewController = viewController else {
      return nil
    }

    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }

    for childViewController in viewController.children {
      return findNavigationController(viewController: childViewController)
    }

    return nil
  }
}

extension UIImage {
    class func base64PNGImage(_ string: String) -> UIImage {

        guard let imageData = Data(base64Encoded: string.replacingOccurrences(of: "data:image/png;base64,", with: ""), options: .ignoreUnknownCharacters) else {
                   return UIImage()
               }
        return UIImage(data: imageData)!
    }
}

extension Double {
    func numberRMM() -> String {
        return String(self).numberRMM()
    }
}
extension String {
    /// 人名币大写
    func numberRMM() -> String {
        guard let num = Double(self) else {
            return ""
        }
        let format = NumberFormatter()
        format.locale = Locale(identifier: "zh_CN")
        format.numberStyle = .spellOut
        format.minimumIntegerDigits = 1
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 2
        let text = format.string(from: NSNumber(value: num)) ?? ""
        let sept = self.components(separatedBy: ".")
        let decimals: Double? = sept.count == 2 ? Double("0." + sept.last!) : nil
        return self.formatRMM(text: text, isInt: decimals == nil || decimals! < 0.01)
    }

    private func formatRMM(text: String, isInt: Bool) -> String {
        let formattedString = text.replacingOccurrences(of: "一", with: "壹")
                                  .replacingOccurrences(of: "二", with: "贰")
                                  .replacingOccurrences(of: "三", with: "叁")
                                  .replacingOccurrences(of: "四", with: "肆")
                                  .replacingOccurrences(of: "五", with: "伍")
                                  .replacingOccurrences(of: "六", with: "陆")
                                  .replacingOccurrences(of: "七", with: "柒")
                                  .replacingOccurrences(of: "八", with: "捌")
                                  .replacingOccurrences(of: "九", with: "玖")
                                  .replacingOccurrences(of: "十", with: "拾")
                                  .replacingOccurrences(of: "百", with: "佰")
                                  .replacingOccurrences(of: "千", with: "仟")
                                  .replacingOccurrences(of: "〇", with: "零")
        let sept = formattedString.components(separatedBy: "点")
        var intStr = sept[0]
        if sept.count > 0 && isInt {
            // 整数处理
            return intStr.appending("元整")
        } else {
            // 小数处理
            let decStr = sept[1]
            intStr = intStr.appending("元").appending("\(decStr.first!)角")
            if decStr.count > 1 {
                intStr = intStr.appending("\(decStr[decStr.index(decStr.startIndex, offsetBy: 1)])分")
            } else {
                intStr = intStr.appending("零分")
            }
            return intStr
        }
    }
}
