//
//  Extensions.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/12.
//

import Foundation
import UIKit

extension UIColor {
    public convenience init(hex: UInt32) {
        let r, g, b, a: CGFloat
        r = CGFloat((hex & 0xff000000) >> 24) / 255.0
        g = CGFloat((hex & 0x00ff0000) >> 16) / 255.0
        b = CGFloat((hex & 0x0000ff00) >> 8) / 255.0
        a = CGFloat((hex & 0x000000ff)) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
