//
//  List.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/13.
//

import Foundation
import UIKit

struct List {
    static let viewControllersName: [String] = ["Route","Poi","PolyGon"]
    static let viewControllers: [UIViewController] = [RouteViewController(), PoiViewController(),PolyGonViewController()]
}
