//
//  RCTBaiduMap.h
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#ifndef RCTBaiduMapView_h
#define RCTBaiduMapView_h


#import <React/RCTViewManager.h>
#import <React/RCTConvert+CoreLocation.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface RCTBaiduMapView : BMKMapView

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

-(void)setZoom:(float)zoom;
-(void)setCenterLatLng:(NSDictionary *)LatLngObj;
-(void)setMarker:(NSDictionary *)Options;
-(void)setSelectedMarker:(NSDictionary *)option;

@end

///表示一个点的annotation
@interface SomeOneAnnotation : BMKPointAnnotation
@end

@interface NoOneAnnotation : BMKPointAnnotation
@end

@interface MyAnnotation : BMKPointAnnotation
@end

@interface SelectedAnnotation : BMKPointAnnotation
@end
#endif
