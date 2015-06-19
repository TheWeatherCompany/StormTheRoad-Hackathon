//
//  ViewController.swift
//  Hackathon
//
//  Created by Patrick Childers on 6/5/15.
//  Copyright (c) 2015 The Weather Company.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The Weather Company's API for obtaining radar tile images is provided only
//  for the purposes of the hackathon hosted by The Weather Company in June, 2015.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, WXCTileServerDelegate {
    
    var selectedSeries: String!

    var tileServer: WXCTileServer = WXCTileServer()
    var tileLayer: GMSURLTileLayer!
    var mapView:GMSMapView!

    override func viewDidLoad() {
        var camera = GMSCameraPosition.cameraWithLatitude(33.8936574, longitude:-84.4602094, zoom:10)
        
        tileServer.delegate = self
        
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera:camera)
        mapView.buildingsEnabled = false
        mapView.indoorEnabled = false
        mapView.setMinZoom(1, maxZoom:10)

        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)

        unowned var unownedSelf:MapViewController = self
        let urls:GMSTileURLConstructor = { (x: UInt, y: UInt, zoom: UInt)-> NSURL in
            
            let url:NSURL? = unownedSelf.tileServer.urlForTile(x, y:y, zoom:zoom, series:unownedSelf.selectedSeries)
            if (url == nil) {
                return NSURL()
            }
           
            return url!
        }
        
        tileLayer = GMSURLTileLayer(URLConstructor:urls)
        tileLayer.map = mapView
        tileLayer.opacity = 0.70
        
        selectedSeries = "radar"
        tileServer.update();
    }
    
    func tilesUpdated() {
        
        tileLayer?.clearTileCache()
    }
    
    @IBAction func switchSeries(sender:UISegmentedControl) {

        let series: [String] = ["radar", "satrad", "clouds", "temp"]
        selectedSeries = series[ sender.selectedSegmentIndex ]
        
        let maxZoom:Float = Float(tileServer.maxZoom(selectedSeries))
        mapView!.setMinZoom(1, maxZoom:maxZoom)

        tileLayer!.clearTileCache()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

