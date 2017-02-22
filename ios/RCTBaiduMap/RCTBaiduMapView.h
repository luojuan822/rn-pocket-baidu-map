//
//  RCTBaiduMap.h
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#ifndef RCTBaiduMapView_h
#define RCTBaiduMapView_h


#import "RCTViewManager.h"
#import "RCTConvert+CoreLocation.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <UIKit/UIKit.h>

@interface RCTBaiduMapView : BMKMapView <BMKMapViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

-(void)setZoom:(float)zoom;
-(void)setCenterLatLng:(NSDictionary *)LatLngObj;
-(void)setMarker:(NSDictionary *)Options;

@end

///表示一个点的annotation
@interface SomeOneAnnotation : BMKPointAnnotation
@end

@interface NoOneAnnotation : BMKPointAnnotation
@end

@interface MyAnnotation : BMKPointAnnotation
@end

#endif
