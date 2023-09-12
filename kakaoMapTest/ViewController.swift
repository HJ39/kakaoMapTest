//
//  A.swift
//  kakaoMapTest
//
//  Created by 정호진 on 2023/09/11.
//

import Foundation
import UIKit
import KakaoMapsSDK

final class ViewController: UIViewController{
    var _observerAdded: Bool?
    var _auth: Bool?
    var _appear: Bool?
    var mapController: KMController?
    
    /// MARK:
    private lazy var mapView: KMViewContainer = {
        let view = KMViewContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    
    deinit {
        mapController?.stopRendering()
        mapController?.stopEngine()
        
        print("deinit")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _observerAdded = false
        _auth = false
        _appear = false
        
        view.backgroundColor = .white
        set()
        //KMController 생성
        mapController = KMController(viewContainer: mapView)!
        mapController!.delegate = self
        mapController?.initEngine() //엔진 초기화. 엔진 내부 객체 생성 및 초기화가 진행된다.
    }
    
    /// MARK:
    private func set(){
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
        if mapController?.engineStarted == false {
            mapController?.startEngine()
        }
        
        if mapController?.rendering == false {
            mapController?.startRendering()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.stopRendering()  //렌더링 중지.
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.stopEngine()     //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        _observerAdded = true
    }
     
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

        _observerAdded = false
    }

    @objc func willResignActive(){
        mapController?.stopRendering()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
    }

    @objc func didBecomeActive(){
        mapController?.startRendering() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                                        toastLabel.alpha = 0.0
                                    },
                       completion: { (finished) in
                                        toastLabel.removeFromSuperview()
                                    })
    }
    
    func createRouteStyleSet() {
        let mapView = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getRouteManager()
        let _ = manager?.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        let patternImages = [UIImage(named: "route_pattern_arrow.png"), UIImage(named: "route_pattern_walk.png"), UIImage(named: "route_pattern_long_dot.png")]
        
        // pattern
        let styleSet = RouteStyleSet(styleID: "routeStyleSet4")
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
                PerLevelRouteStyle(width: 30, color: colors[index], strokeWidth: 4, strokeColor: strokeColors[index], level: 0, patternIndex: patternIndex[index])
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
        
        let options = RouteOptions(routeID: "routes", styleID: "routeStyleSet4", zOrder: 0)
        options.segments = segments
        let route = layer?.addRoute(option: options)
        route?.show()
        
        let pnt = segments[0].points[0]
        mapView.moveCamera(CameraUpdate.make(target: pnt, zoomLevel: 8, mapView: mapView))
    }
    
    /// 위도 경도를 이용하여 point를 찍음
    func routeSegmentPoints() -> [[MapPoint]] {
        var segments = [[MapPoint]]()
        
        var points = [MapPoint]()
        points.append(MapPoint(longitude: 127.1059968,
                               latitude: 37.3597093))
        points.append(MapPoint(longitude: 127.1058342,
                               latitude: 37.3597078))
        
        segments.append(points)
        
        points = [MapPoint]()   // 따로 표시가 됨
        points.append(MapPoint(longitude: 129.0759853,
                               latitude: 35.1794697))
        points.append(MapPoint(longitude: 129.0764276,
                               latitude: 35.1795108))
        points.append(MapPoint(longitude: 129.0762855,
                               latitude: 35.1793188))
        segments.append(points)
        return segments
    }
    
}

extension ViewController: MapControllerDelegate{
    // 인증 성공시 delegate 호출.
    func authenticationSucceeded() {
        // 일반적으로 내부적으로 인증과정 진행하여 성공한 경우 별도의 작업은 필요하지 않으나,
        // 네트워크 실패와 같은 이슈로 인증실패하여 인증을 재시도한 경우, 성공한 후 정지된 엔진을 다시 시작할 수 있다.
        if _auth == false {
            _auth = true
        }
        
        if mapController?.engineStarted == false {
            mapController?.startEngine()    //엔진 시작 및 렌더링 준비. 준비가 끝나면 MapControllerDelegate의 addViews 가 호출된다.
            mapController?.startRendering() //렌더링 시작.
        }
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break;
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break;
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.authenticate()
            }
            break;
        default:
            break;
        }
    }
    
    func addViews() {
        //여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        //지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
        
        //KakaoMap 추가.
        if mapController?.addView(mapviewInfo) == Result.OK {
            createRouteStyleSet()
            createRouteline()
            print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
        }
    }
    
    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
    }
    
    func viewWillDestroyed(_ view: ViewBase) {
        
    }

}
