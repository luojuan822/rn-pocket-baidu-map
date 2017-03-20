//
//  RCTBaiduMapViewManager.h
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#ifndef RCTBaiduMapViewManager_h
#define RCTBaiduMapViewManager_h

#import "RCTBaiduMapView.h"
#import "RouteAnnotation.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Search/BMKRouteSearchType.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface RCTBaiduMapViewManager : RCTViewManager<BMKMapViewDelegate, BMKRouteSearchDelegate, BMKLocationServiceDelegate>

+(void)initSDK:(NSString *)key;

-(void)sendEvent:(NSDictionary *) params;

+(RCTBaiduMapView*) getBaiduMapView;
+(BMKRouteSearch*) getBMKRouteSearch;
+(BMKLocationService*) getBMKLocationService;

+(BMKWalkingRouteLine*) getWalkingLine;
+(BMKDrivingRouteLine*) getDrivingLine;
+(BMKMassTransitRouteLine*) getTransiteLine;

+(void) drawDriving;
+(void) drawBus;
+(void) drawWalking;
@end

#endif /* RCTBaiduMapViewManager_h */
