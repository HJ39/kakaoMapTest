//
//  PolygonViewController.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/13.
//

import Foundation
import UIKit
import KakaoMapsSDK

final class PolyGonViewController: KakaoMapViewController {
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.7335293, latitude: 37.3401906)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        
        if mapController?.addView(mapviewInfo) == Result.OK {
            print("OK")
            createPolygonStyleSet()
            createShape()
        }
    }
    
    func createPolygonStyleSet() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getShapeManager()

        // 레벨별 스타일을 생성.
        let perLevelStyle1 = PerLevelPolygonStyle(color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3),
                                                  strokeWidth: 1,
                                                  strokeColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                                                  level: 0)
        let perLevelStyle2 = PerLevelPolygonStyle(color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3),
                                                  strokeWidth: 1,
                                                  strokeColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                                                  level: 15)
        
        // 각 레벨별 스타일로 구성된 2개의 Polygon Style
        let shapeStyle1 = PolygonStyle(styles: [perLevelStyle1, perLevelStyle2])
        
        // PolygonStyle을 PolygonStyleSet에 추가.
        let shapeStyleSet = PolygonStyleSet(styleSetID: "aroundMyPoistion", styles: [shapeStyle1])
        manager.addPolygonStyleSet(shapeStyleSet)
    }
    
    func createShape() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getShapeManager()
        let layer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001)
        
        // 두 개의 원으로 구성된 PolygonShape을 생성.
        
        // 첫번째 폴리곤 -> styleSet의 0번째 index의 style을 사용한다.
        let points = Primitives.getCirclePoints(radius: 500, numPoints: 90, cw: true)
        let polygon = Polygon(exteriorRing: points, hole: nil, styleIndex: 0)
        
        // 두개의 폴리곤( polygon, polygon2 )로 구성된 PolygonShape를 생성한다.
        let options = PolygonShapeOptions(shapeID: "CircleShape", styleID: "aroundMyPoistion", zOrder: 1)
        options.basePosition = MapPoint(longitude: 126.7335293, latitude: 37.3401906)
        options.polygons.append(polygon)
        
        let shape = layer?.addPolygonShape(options)
        shape?.show()
    }
}
