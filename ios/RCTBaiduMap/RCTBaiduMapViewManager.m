//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapViewManager.h"
#import "UIImage+Rotate.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

RCTBaiduMapView* _smapView;
BMKRouteSearch* _srouteSearch;
BMKLocationService* _slocService;

BMKDrivingRouteLine* _drivingLine;
BMKWalkingRouteLine* _walkingLine;
BMKMassTransitRouteLine* _transiteLine;

BMKAnnotationView* selectedView;

@implementation RCTBaiduMapViewManager {
    RCTBaiduMapView* _mapView;
    BMKRouteSearch* _routeSearch;
    BMKLocationService* _locService;
    
};

RCT_EXPORT_MODULE(RCTBaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(selectedMarker, NSDictionary*)
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
//    if(_mapView != nil) {
//        [_mapView removeFromSuperview];
//    }
    _mapView = [[RCTBaiduMapView alloc] init];
    _mapView.delegate = self;
    NSLog(@"RCTBaiduMapView======= %@", _mapView);
    
    _routeSearch = [[BMKRouteSearch alloc]init];
    _routeSearch.delegate = self;
    
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    
    _smapView = _mapView;
    _smapView.delegate = self;
    _srouteSearch = _routeSearch;
    _slocService = _locService;
    return _smapView;
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
    //NSLog(@"annotationViewForBubble======");
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
    if(selectedView != nil) {
        selectedView.image = [UIImage imageNamed:@"baidu_one"];
    }
    view.image = [UIImage imageNamed:@"baidu_selected"];
    selectedView = view;
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
    NSLog(@"viewForAnnotation====== %@", annotation);
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        //newAnnotationView.pinColor = BMKPinAnnotationColorGreen;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_my"];
        return newAnnotationView;
    } else if([annotation isKindOfClass:[SomeOneAnnotation class]]){
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"someoneAnnotation"];
        //newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_one"];
        return newAnnotationView;
    } else if([annotation isKindOfClass:[RouteAnnotation class]]) {
        BMKAnnotationView* view = [(RouteAnnotation*)annotation getRouteAnnotationView:mapView];
        NSLog(@"BMKAnnotationView====== %@", view);
        return view;
    } else if([annotation isKindOfClass:[SelectedAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"selectedAnnotation"];
        //newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_selected"];
        selectedView = newAnnotationView;
        newAnnotationView.selected = YES;
        //[_smapView mapForceRefresh];
        return newAnnotationView;
    }else {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"nooneAnnotation"];
        //newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.image = [UIImage imageNamed:@"baidu_one"];
        return newAnnotationView;
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:248/255.0 green:70/255.0 blue:191/255.0 alpha:0.7];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:248/255.0 green:70/255.0 blue:191/255.0 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
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
//    NSLog(@"sendEvent");

    if (!mapView.onChange) {
        return;
    }
    NSLog(@"sendEvent");
    mapView.onChange(params);
}

#pragma mark - BMKRouteSearchDelegate
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetDrivingRouteResult  =====oc %d", error);
    
    int minitus = 0;
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        BMKTime *duration = plan.duration;
        minitus = duration.dates * 24 * 60 + duration.hours * 60 + duration.minutes;
        _drivingLine = plan;
        
        NSDictionary* event = @{
                                @"type": @"onDrivingRouteResult",
                                @"params": @{
                                        @"time": [NSString stringWithFormat:@"%d", minitus],
                                        }
                                };
        [self mapView:_mapView sendEvent:event];
    }
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetWalkingRouteResult  =====oc %d", error);
    
    int minitus = 0;
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        BMKTime *duration = plan.duration;
        minitus = duration.dates * 24 * 60 + duration.hours * 60 + duration.minutes;
        _walkingLine = plan;
        
        NSDictionary* event = @{
                                @"type": @"onWalkingRouteResult",
                                @"params": @{
                                        @"time": [NSString stringWithFormat:@"%d", minitus],
                                        }
                                };
        [self mapView:_mapView sendEvent:event];
    }
}

/**
 *返回公共交通路线检索结果（new）
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKMassTransitRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetMassTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKMassTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetMassTransitRouteResult  =====oc %d", error);

    int minitus = 0;
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKMassTransitRouteLine* routeLine = (BMKMassTransitRouteLine*)[result.routes objectAtIndex:0];
        BMKTime *duration = routeLine.duration;
        minitus = duration.dates * 24 * 60 + duration.hours * 60 + duration.minutes;
        _transiteLine = routeLine;
        
        NSDictionary* event = @{
                                @"type": @"onMassTransitRouteResult",
                                @"params": @{
                                        @"time": [NSString stringWithFormat:@"%d", minitus],
                                        }
                                };
        [self mapView:_mapView sendEvent:event];
    }
}



/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    //NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
}

#pragma mark - 私有

//根据polyline设置地图范围
+ (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
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
    [_smapView setVisibleMapRect:rect];
    _smapView.zoomLevel = _smapView.zoomLevel - 0.3;
}

+(RCTBaiduMapView *) getBaiduMapView {
    return _smapView;
}
+(BMKRouteSearch*) getBMKRouteSearch {
    return _srouteSearch;
}
+(BMKLocationService*) getBMKLocationService {
    return _slocService;
}

+(BMKWalkingRouteLine*) getWalkingLine {
    return _walkingLine;
}
+(BMKDrivingRouteLine*) getDrivingLine {
    return _drivingLine;
}
+(BMKMassTransitRouteLine*) getTransiteLine {
    return _transiteLine;
}

+(void) drawWalking {
    NSLog(@"drawWalking======= %@", _smapView);
    NSArray* array = [NSArray arrayWithArray:_smapView.annotations];
    [_smapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_smapView.overlays];
    [_smapView removeOverlays:array];
    
    BMKWalkingRouteLine* plan = [RCTBaiduMapViewManager getWalkingLine];
    
    NSInteger size = [plan.steps count];
    int planPointCounts = 0;
    for (int i = 0; i < size; i++) {
        BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
        if(i==0){
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = plan.starting.location;
            item.title = @"起点";
            item.type = 0;
            [_smapView addAnnotation:item]; // 添加起点标注
            
        }else if(i==size-1){
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = plan.terminal.location;
            item.title = @"终点";
            item.type = 1;
            [_smapView addAnnotation:item]; // 添加起点标注
        }
        //添加annotation节点
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        item.coordinate = transitStep.entrace.location;
        item.title = transitStep.entraceInstruction;
        item.degree = transitStep.direction * 30;
        item.type = 4;
        [_smapView addAnnotation:item];
        
        //轨迹点总数累计
        planPointCounts += transitStep.pointsCount;
    }
    
    //轨迹点
    BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
    int i = 0;
    for (int j = 0; j < size; j++) {
        BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
        int k=0;
        for(k=0;k<transitStep.pointsCount;k++) {
            temppoints[i].x = transitStep.points[k].x;
            temppoints[i].y = transitStep.points[k].y;
            i++;
        }
        
    }
    // 通过points构建BMKPolyline
    BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
    [_smapView addOverlay:polyLine]; // 添加路线overlay
    delete []temppoints;
    [RCTBaiduMapViewManager mapViewFitPolyLine:polyLine];
    
    //    [[RCTBaiduMapViewManager getBMKLocationService] startUserLocationService];
    //    _mapView.showsUserLocation = NO;
    //    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    //    _mapView.showsUserLocation = YES;

}

+(void) drawBus {
    NSLog(@"drawBus======= %@", _smapView);
    NSArray* array = [NSArray arrayWithArray:_smapView.annotations];
    [_smapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_smapView.overlays];
    [_smapView removeOverlays:array];
    
    BMKMassTransitRouteLine* routeLine = [RCTBaiduMapViewManager getTransiteLine];
    BOOL startCoorIsNull = YES;
    CLLocationCoordinate2D startCoor;//起点经纬度
    CLLocationCoordinate2D endCoor;//终点经纬度
    
    NSInteger size = [routeLine.steps count];
    NSInteger planPointCounts = 0;
    for (NSInteger i = 0; i < size; i++) {
        BMKMassTransitStep* transitStep = [routeLine.steps objectAtIndex:i];
        for (BMKMassTransitSubStep *subStep in transitStep.steps) {
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = subStep.entraceCoor;
            item.title = subStep.instructions;
            item.type = 2;
            [_smapView addAnnotation:item];
            
            if (startCoorIsNull) {
                startCoor = subStep.entraceCoor;
                startCoorIsNull = NO;
            }
            endCoor = subStep.exitCoor;
            
            //轨迹点总数累计
            planPointCounts += subStep.pointsCount;
            
            //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
            if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                break;
            }
            else {
                //是子路段，需要完整遍历transitStep.steps
            }
        }
    }
    
    //添加起点标注
    RouteAnnotation* startAnnotation = [[RouteAnnotation alloc]init];
    startAnnotation.coordinate = startCoor;
    startAnnotation.title = @"起点";
    startAnnotation.type = 0;
    [_smapView addAnnotation:startAnnotation]; // 添加起点标注
    //添加终点标注
    RouteAnnotation* endAnnotation = [[RouteAnnotation alloc]init];
    endAnnotation.coordinate = endCoor;
    endAnnotation.title = @"终点";
    endAnnotation.type = 1;
    [_smapView addAnnotation:endAnnotation]; // 添加起点标注
    
    //轨迹点
    BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
    NSInteger index = 0;
    for (BMKMassTransitStep* transitStep in routeLine.steps) {
        for (BMKMassTransitSubStep *subStep in transitStep.steps) {
            for (NSInteger i = 0; i < subStep.pointsCount; i++) {
                temppoints[index].x = subStep.points[i].x;
                temppoints[index].y = subStep.points[i].y;
                index++;
            }
            
            //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
            if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                break;
            }
            else {
                //是子路段，需要完整遍历transitStep.steps
            }
        }
    }
    
    // 通过points构建BMKPolyline
    BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
    [_smapView addOverlay:polyLine]; // 添加路线overlay
    delete []temppoints;
    [RCTBaiduMapViewManager mapViewFitPolyLine:polyLine];
    
    //    [[RCTBaiduMapViewManager getBMKLocationService] startUserLocationService];
    //    _mapView.showsUserLocation = NO;
    //    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    //    _mapView.showsUserLocation = YES;
}

+ (void) drawDriving {
    NSLog(@"drawDriving======= %@", _smapView);
    NSArray* array = [NSArray arrayWithArray:_smapView.annotations];
    [_smapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_smapView.overlays];
    [_smapView removeOverlays:array];
    
    BMKDrivingRouteLine* plan = _drivingLine;
    // 计算路线方案中的路段数目
    NSInteger size = [plan.steps count];
    int planPointCounts = 0;
    for (int i = 0; i < size; i++) {
        BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
        if(i==0){
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = plan.starting.location;
            item.title = @"起点";
            item.type = 0;
            [_smapView addAnnotation:item]; // 添加起点标注
            
        }else if(i==size-1){
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = plan.terminal.location;
            item.title = @"终点";
            item.type = 1;
            [_smapView addAnnotation:item]; // 添加起点标注
        }
        //添加annotation节点
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        item.coordinate = transitStep.entrace.location;
        item.title = transitStep.entraceInstruction;
        item.degree = transitStep.direction * 30;
        item.type = 4;
        [_smapView addAnnotation:item];
        
        NSLog(@"%@   %@    %@", transitStep.entraceInstruction, transitStep.exitInstruction, transitStep.instruction);
        
        //轨迹点总数累计
        planPointCounts += transitStep.pointsCount;
    }
    // 添加途经点
    if (plan.wayPoints) {
        for (BMKPlanNode* tempNode in plan.wayPoints) {
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item = [[RouteAnnotation alloc]init];
            item.coordinate = tempNode.pt;
            item.type = 5;
            item.title = tempNode.name;
            [_smapView addAnnotation:item];
        }
    }
    //轨迹点
    BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
    int i = 0;
    for (int j = 0; j < size; j++) {
        BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
        int k=0;
        for(k=0;k<transitStep.pointsCount;k++) {
            temppoints[i].x = transitStep.points[k].x;
            temppoints[i].y = transitStep.points[k].y;
            i++;
        }
        
    }
    // 通过points构建BMKPolyline
    BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
    [_smapView addOverlay:polyLine]; // 添加路线overlay
    delete []temppoints;
    [RCTBaiduMapViewManager mapViewFitPolyLine:polyLine];
    
    
    //    [[RCTBaiduMapViewManager getBMKLocationService] startUserLocationService];
    //    _mapView.showsUserLocation = NO;
    //    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    //    _mapView.showsUserLocation = YES;
}
@end
