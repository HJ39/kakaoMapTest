//
//  PoiViewController.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/13.
//

import Foundation
import UIKit
import KakaoMapsSDK

final class PoiViewController: KakaoMapViewController {
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.7335293, latitude: 37.3401906)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        
        if mapController?.addView(mapviewInfo) == Result.OK {
            print("OK")
            createLabelLayer()
            createPoiStyle()
            createPois()
        }
    }
    
    
    // MARK: - Poi
    
    // POI가 속할 LabelLayer를 생성한다.
    func createLabelLayer() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()    //LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.
        
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()

        let iconStyle = PoiIconStyle(symbol: UIImage(named: "route_pattern_long_dot.png"), anchorPoint: CGPoint(x: 0.0, y: 0.0))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
    }
    
    // POI를 생성한다.
    func createPois() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let poiOption = PoiOptions(styleID: "customStyle1") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
        poiOption.rank = 0
        
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.7335293, latitude: 37.3401906), callback: nil)
        poi1?.show()
    }
    
    
}

