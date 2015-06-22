//
//  WXCTileServer.swift
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

import Foundation

protocol WXCTileServerDelegate {
    func tilesUpdated() -> Void
}

class WXCTileServer
{
    let seriesUrl:String = "http://hackathon.weather.com/Maps/jsonserieslist.do"
    var timer:NSTimer?
    var seriesInfo:NSDictionary?
    var lastTimestamp:String?
    var delegate:WXCTileServerDelegate? = nil
    
    init() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60 * 2.5, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        
        let url: NSURL = NSURL(string: self.seriesUrl)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
            
            self.seriesInfo = json["seriesInfo"] as? NSDictionary
            
            let timeStamp:String? = json["timestamp"] as? String
            
            if (timeStamp != self.lastTimestamp) {
                self.lastTimestamp = timeStamp
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.delegate!.tilesUpdated()
                })
            }
        })
    }
    
    func maxZoom(series:String) -> Int {
        
        if (self.seriesInfo == nil) {
            return 10
        }
        
        let seriesData:NSDictionary = self.seriesInfo![series] as! NSDictionary
        let maxZoom:Int = seriesData["maxZoom"] as! Int
        
        return maxZoom
    }
    
    func latestTimeForSeries(series:String) -> String? {
        
        if (self.seriesInfo == nil) {
            return nil
        }
        
        let seriesData:NSDictionary = self.seriesInfo![series] as! NSDictionary
        let seriesList:NSArray = seriesData["series"] as! NSArray
        let latestSeries:NSDictionary = seriesList[0] as! NSDictionary
        return latestSeries["date"] as? String
    }
    
    func urlForTile(x: UInt, y: UInt, zoom: UInt, series:String?)-> NSURL? {
        
        if (series == nil) {
            return nil
        }
        
        let time:NSString? = latestTimeForSeries(series!)
        if (time == nil) {
            return nil
        }
        
        let quadKey:String = quadkeyForTile(x, y:y, zoom:zoom)
        let url:String = NSString(format:"http://hackathon.weather.com/Maps/imgs/%@/%@/%@.png",
            series!, time!, quadKey) as String
        return NSURL(string: url)
    }

    func quadkeyForTile(x: UInt, y: UInt, zoom: UInt) -> String {
        
        var quadKey = String()
        for ( var i = zoom; i > 0; i-- )
        {
            let mask:UInt = 1 << ( i - 1 )
            
            var cell:Int = 0
            
            if ( ( x & mask ) != 0 )
            {
                cell = cell + 1
            }
            
            if ( ( y & mask ) != 0 )
            {
                cell = cell + 2
            }
            
            var character:Character = Character(UnicodeScalar(48 + cell))
            quadKey.append(character)
        }
        
        return quadKey
    }
}
