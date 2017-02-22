//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapViewManager.h"

//RCTBaiduMapView* _mapView;

@implementation RCTBaiduMapViewManager;

RCT_EXPORT_MODULE(RCTBaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(someoneMarkers, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(nooneMarkers, NSArray*)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, RCTBaiduMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}


+(void)initSDK:(NSString*)key {
    
    BMKMapManager* _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:key  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

- (UIView *)view {
    NSLog(@"RCTBaiduMapView");
//    if(_mapView != nil) {
//        [_mapView removeFromSuperview];
//    }
    RCTBaiduMapView* _mapView = [[RCTBaiduMapView alloc] init];
    _mapView.delegate = self;
    return _mapView;
}

-(void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self mapView:mapView sendEvent:event];
}

-(void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self mapView:mapView sendEvent:event];
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    [self mapView:mapView sendEvent:event];
}

-(void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    NSLog(@"annotationViewForBubble======");
    NSDictionary* event = @{
                            @"type": @"onAnnotationClick",
                            @"params": @{
                                    @"title": [[view annotation] title],
                                    @"position": @{
                                            @"latitude": @([[view annotation] coordinate].latitude),
                                            @"longitude": @([[view annotation] coordinate].longitude)
                                            }
                                    }
                            };
    [self mapView:mapView sendEvent:event];
}

-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    NSLog(@"didSelectAnnotationView");
    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": @{
                                    @"title": [[view annotation] title],
                                    @"position": @{
                                            @"latitude": @([[view annotation] coordinate].latitude),
                                            @"longitude": @([[view annotation] coordinate].longitude)
                                            }
                                    }
                            };
    [self mapView:mapView sendEvent:event];
}

- (void) mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi");
    NSDictionary* event = @{
                            @"type": @"onClickedMapPoi",
                            @"params": @{
                                    @"title": mapPoi.text,
                                    @"position": @{
                                            @"latitude": @(mapPoi.pt.latitude),
                                            @"longitude": @(mapPoi.pt.longitude)
                                            }
                                    }
                            };
    [self mapView:mapView sendEvent:event];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorGreen;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_my"];
        return newAnnotationView;
    } else if([annotation isKindOfClass:[SomeOneAnnotation class]]){
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"someoneAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_someone"];
        return newAnnotationView;
    } else {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"nooneAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_noone"];
        return newAnnotationView;
    }
    return nil;
}

-(void)mapStatusDidChanged: (BMKMapView *)mapView	 {
    NSLog(@"mapStatusDidChanged");
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @"",
                                    @"overlook": @""
                                    }
                            };
    [self mapView:mapView sendEvent:event];
    
}

-(void)mapView:(RCTBaiduMapView *)mapView sendEvent:(NSDictionary *) params {
    NSLog(@"sendEvent");

    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}

//+(RCTBaiduMapView *) getBaiduMapView {
//    return _mapView;
//}

@end
