//
//  BaiduMapModule.m
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//


#import "BaiduMapModule.h"

@implementation BaiduMapModule {
    BMKPointAnnotation* _annotation;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setMarker:(double)lat lng:(double)lng) {
    if(_annotation == nil) {
      _annotation = [[BMKPointAnnotation alloc]init];
    }
    else {
        [[self getBaiduMapView] removeAnnotation:_annotation];
    }

    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    _annotation.coordinate = coor;
    [[self getBaiduMapView] addAnnotation:_annotation];
}

RCT_EXPORT_METHOD(setMapType:(int)type) {
    [[self getBaiduMapView] setMapType:type];
}

RCT_EXPORT_METHOD(setZoom:(float)zoom) {
    [[self getBaiduMapView] setZoomLevel:zoom];
}

RCT_EXPORT_METHOD(moveToCenter:(double)lat lng:(double)lng zoom:(float)zoom) {
    NSDictionary* center = @{
                             @"lat": @(lat),
                             @"lng": @(lng)
                             };
    [[self getBaiduMapView] setCenterLatLng:center];
    [[self getBaiduMapView] setZoomLevel:zoom];
}

RCT_EXPORT_METHOD(walkSearch:(NSString*)startName lat:(double)lat lng:(double)lng endName:(NSString*)endName endlat:(double)endlat endlng:(double)endlng ) {
    BMKPlanNode* start = [[BMKPlanNode alloc] init];
    start.name = startName;
    start.pt = CLLocationCoordinate2DMake(lat, lng);
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    end.name = endName;
    end.pt = CLLocationCoordinate2DMake(endlat, endlng);
    
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc] init];
    walkingRouteSearchOption.from = start;
    walkingRouteSearchOption.to = end;
    BOOL flag = [[self getBMKRouteSearch] walkingSearch:walkingRouteSearchOption];
    if(flag)
    {
        NSLog(@"walk检索发送成功");
    }
    else
    {
        NSLog(@"walk检索发送失败");
    }
}

RCT_EXPORT_METHOD(driveSearch:(NSString*)startName lat:(double)lat lng:(double)lng endName:(NSString*)endName endlat:(double)endlat endlng:(double)endlng ) {
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = startName;
    start.pt = CLLocationCoordinate2DMake(lat, lng);
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = endName;
    end.pt = CLLocationCoordinate2DMake(endlat, endlng);
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
    BOOL flag = [[self getBMKRouteSearch] drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }}


RCT_EXPORT_METHOD(busSearch:(NSString*)startName lat:(double)lat lng:(double)lng endName:(NSString*)endName endlat:(double)endlat endlng:(double)endlng ) {
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = startName;
    start.pt = CLLocationCoordinate2DMake(lat, lng);
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = endName;
    end.pt = CLLocationCoordinate2DMake(endlat, endlng);
    
    BMKMassTransitRoutePlanOption *option = [[BMKMassTransitRoutePlanOption alloc]init];
    option.from = start;
    option.to = end;
    BOOL flag = [[self getBMKRouteSearch] massTransitSearch:option];
    
    if(flag) {
        NSLog(@"公交交通检索（支持垮城）发送成功");
    } else {
        NSLog(@"公交交通检索（支持垮城）发送失败");
    }
}


RCT_EXPORT_METHOD(allSearch:(NSString*)startName lat:(double)lat lng:(double)lng endName:(NSString*)endName endlat:(double)endlat endlng:(double)endlng ) {
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = startName;
    start.pt = CLLocationCoordinate2DMake(lat, lng);
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = endName;
    end.pt = CLLocationCoordinate2DMake(endlat, endlng);
    
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc] init];
    walkingRouteSearchOption.from = start;
    walkingRouteSearchOption.to = end;
    BOOL flag = [[self getBMKRouteSearch] walkingSearch:walkingRouteSearchOption];
    if(flag)
    {
        NSLog(@"walk检索发送成功");
    }
    else
    {
        NSLog(@"walk检索发送失败");
    }
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
    flag = [[self getBMKRouteSearch] drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }
    
    BMKMassTransitRoutePlanOption *option = [[BMKMassTransitRoutePlanOption alloc]init];
    option.from = start;
    option.to = end;
    flag = [[self getBMKRouteSearch] massTransitSearch:option];
    
    if(flag) {
        NSLog(@"公交交通检索（支持垮城）发送成功");
    } else {
        NSLog(@"公交交通检索（支持垮城）发送失败");
    }
}

RCT_EXPORT_METHOD(drawDriving) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCTBaiduMapViewManager drawDriving];
    });
}

RCT_EXPORT_METHOD(drawBus) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCTBaiduMapViewManager drawBus];
    });
}

RCT_EXPORT_METHOD(drawWalking) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCTBaiduMapViewManager drawWalking];
    });
}

RCT_EXPORT_METHOD(setEnableLoc:(BOOL)enable) {
    [[RCTBaiduMapViewManager getBMKLocationService] startUserLocationService];
    
    [self getBaiduMapView].showsUserLocation = NO;
    [self getBaiduMapView].userTrackingMode = BMKUserTrackingModeFollow;
    [self getBaiduMapView].showsUserLocation = YES;
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine _mapView:(RCTBaiduMapView*)_mapView {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}


-(RCTBaiduMapView *) getBaiduMapView {
    return [RCTBaiduMapViewManager getBaiduMapView];
}

-(BMKRouteSearch*) getBMKRouteSearch {
    return [RCTBaiduMapViewManager getBMKRouteSearch];
}

@end
