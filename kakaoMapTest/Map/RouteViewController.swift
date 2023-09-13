//
//  A.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/12.
//

import Foundation
import UIKit
import KakaoMapsSDK

final class RouteViewController: KakaoMapViewController {
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.7335293, latitude: 37.3401906)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        
        if mapController?.addView(mapviewInfo) == Result.OK {
            print("OK")
            createRouteStyleSet()
            createRouteline()
        }
    }
    
    // MARK: - Route
    
    // RouteStyleSet을 생성한다.
    // 전체 구성은 PolylineStyleSet과 같다.
    // RouteSegment마다 RouteStyleSet에 있는 다른 RouteStyle을 적용할 수 있다.
    func createRouteStyleSet() {

        let mapView = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getRouteManager()
        let _ = manager?.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        let patternImages = [UIImage(named: "route_pattern_arrow.png"), UIImage(named: "route_pattern_walk.png"), UIImage(named: "route_pattern_long_dot.png")]
        
        // pattern
        let styleSet = RouteStyleSet(styleID: "routeStyleSet1")
        styleSet.addPattern(RoutePattern(pattern: patternImages[0]!, distance: 60, symbol: nil, pinStart: false, pinEnd: false))
        styleSet.addPattern(RoutePattern(pattern: patternImages[1]!, distance: 6, symbol: nil, pinStart: true, pinEnd: true))
        styleSet.addPattern(RoutePattern(pattern: patternImages[2]!, distance: 6, symbol: UIImage(named: "route_pattern_long_airplane.png")!, pinStart: true, pinEnd: true))
        
        let colors = [
            UIColor(hexCode: "ff0000"),
            UIColor(hexCode: "00ff00"),
            UIColor(hexCode: "0000ff"),
            UIColor(hexCode: "ffff00") ]

        let strokeColors = [
            UIColor(hexCode: "ffffff"),
            UIColor(hexCode: "ddffdd"),
            UIColor(hexCode: "00ddff"),
            UIColor(hexCode: "ffffdd") ]
            
        let patternIndex = [-1, 0, 1, 2]
        
        for index in 0 ..< colors.count {
            let routeStyle = RouteStyle(styles: [
                PerLevelRouteStyle(width: 18, color: colors[index], strokeWidth: 4, strokeColor: strokeColors[index], level: 0, patternIndex: patternIndex[index])
            ])
 
            styleSet.addStyle(routeStyle)
        }

        manager?.addRouteStyleSet(styleSet)
    }
    
    func createRouteline() {
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getRouteManager()
        let layer = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        
        let segmentPoints = routeSegmentPoints()
        var segments: [RouteSegment] = [RouteSegment]()
        var styleIndex: UInt = 0
        for points in segmentPoints {
            // 경로 포인트로 RouteSegment 생성. 사용할 스타일 인덱스도 지정한다.
            let seg = RouteSegment(points: points, styleIndex: styleIndex)
            segments.append(seg)
            styleIndex = (styleIndex + 1) % 4
        }
        
        let options = RouteOptions(routeID: "routes", styleID: "routeStyleSet1", zOrder: 0)
        options.segments = segments
        let route = layer?.addRoute(option: options)
        route?.show()
        
        let pnt = segments[0].points[0]
        mapView.moveCamera(CameraUpdate.make(target: pnt, zoomLevel: 15, mapView: mapView))
    }
    
    /// 위도 경도를 이용하여 point를 찍음
    func routeSegmentPoints() -> [[MapPoint]] {
        var segments = [[MapPoint]]()
        
        var points = [MapPoint]()
        points.append(MapPoint(longitude: 126.7335293,
                               latitude: 37.3401906))
        points.append(MapPoint(longitude: 126.7323429,
                               latitude: 37.3416939))
        
        segments.append(points)
        
//        points = [MapPoint]()   // 따로 표시가 됨
//        points.append(MapPoint(longitude: 129.0759853,
//                               latitude: 35.1794697))
//        points.append(MapPoint(longitude: 129.0764276,
//                               latitude: 35.1795108))
//        points.append(MapPoint(longitude: 129.0762855,
//                               latitude: 35.1793188))
//        segments.append(points)
        return segments
    }
    
}
