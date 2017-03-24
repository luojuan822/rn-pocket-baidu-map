//
//  RCTBaiduMap.m
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapView.h"

@implementation RCTBaiduMapView {
    MyAnnotation* _annotation;
    SelectedAnnotation* _selectedAnnotation;
    NSMutableArray* _someoneAnnotations;
    NSMutableArray* _nooneAnnotations;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

-(void)setZoom:(float)zoom {
    self.zoomLevel = zoom;
}

-(void)setCenterLatLng:(NSDictionary *)LatLngObj {
    double lat = [RCTConvert double:LatLngObj[@"lat"]];
    double lng = [RCTConvert double:LatLngObj[@"lng"]];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);
    self.centerCoordinate = point;
}

-(void)setMarker:(NSDictionary *)option {
    NSLog(@"setMarker");
    if(option != nil) {
        if(_annotation == nil) {
            _annotation = [[MyAnnotation alloc]init];
            [self addMarker:_annotation option:option];
        }
        else {
            [self updateMarker:_annotation option:option];
        }
    }
}

-(void)setSelectedMarker:(NSDictionary *)option {
    NSLog(@"setSelectedMarker");
    if(option != nil) {
        if(_selectedAnnotation == nil) {
            _selectedAnnotation = [[SelectedAnnotation alloc]init];
            [self addMarker:_selectedAnnotation option:option];
        }
        else {
            [self updateMarker:_selectedAnnotation option:option];
        }
    }
}

-(void) setSomeoneMarkers:(NSArray *) markers {
    NSLog(@"setSomeoneMarkers");
    int markersCount = [markers count];
    if(_someoneAnnotations == nil) {
        _someoneAnnotations = [[NSMutableArray alloc] init];
    }
    if(markers != nil) {
        for (int i = 0; i < markersCount; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            
            SomeOneAnnotation *annotation = nil;
            if(i < [_someoneAnnotations count]) {
                annotation = [_someoneAnnotations objectAtIndex:i];
            }
            if(annotation == nil) {
                annotation = [[SomeOneAnnotation alloc]init];
                [self addMarker:annotation option:option];
                [_someoneAnnotations addObject:annotation];
            }
            else {
                [self updateMarker:annotation option:option];
            }
        }
        
        int _annotationsCount = [_someoneAnnotations count];
        
        NSString *smarkersCount = [NSString stringWithFormat:@"%d", markersCount];
        NSString *sannotationsCount = [NSString stringWithFormat:@"%d", _annotationsCount];
        NSLog(smarkersCount);
        NSLog(sannotationsCount);
        
        if(markersCount < _annotationsCount) {
            int start = _annotationsCount - 1;
            for(int i = start; i >= markersCount; i--) {
                BMKPointAnnotation *annotation = [_someoneAnnotations objectAtIndex:i];
                [self removeAnnotation:annotation];
                [_someoneAnnotations removeObject:annotation];
            }
        }
        
        
    }
}

-(void) setNooneMarkers:(NSArray *) markers {
    NSLog(@"setNooneMarkers");
    int markersCount = [markers count];
    if(_nooneAnnotations == nil) {
        _nooneAnnotations = [[NSMutableArray alloc] init];
    }
    if(markers != nil) {
        for (int i = 0; i < markersCount; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            
            NoOneAnnotation *annotation = nil;
            if(i < [_nooneAnnotations count]) {
                annotation = [_nooneAnnotations objectAtIndex:i];
            }
            if(annotation == nil) {
                annotation = [[NoOneAnnotation alloc]init];
                [self addMarker:annotation option:option];
                [_nooneAnnotations addObject:annotation];
            }
            else {
                [self updateMarker:annotation option:option];
            }
        }
        
        int _annotationsCount = [_nooneAnnotations count];
        
        NSString *smarkersCount = [NSString stringWithFormat:@"%d", markersCount];
        NSString *sannotationsCount = [NSString stringWithFormat:@"%d", _annotationsCount];
        NSLog(smarkersCount);
        NSLog(sannotationsCount);
        
        if(markersCount < _annotationsCount) {
            int start = _annotationsCount - 1;
            for(int i = start; i >= markersCount; i--) {
                BMKPointAnnotation *annotation = [_nooneAnnotations objectAtIndex:i];
                [self removeAnnotation:annotation];
                [_nooneAnnotations removeObject:annotation];
            }
        }
        
        
    }
}

//-(void)setMarkers:(NSArray *)markers {
//    
//}

-(CLLocationCoordinate2D)getCoorFromMarkerOption:(NSDictionary *)option {
    double lat = [RCTConvert double:option[@"latitude"]];
    double lng = [RCTConvert double:option[@"longitude"]];
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    return coor;
}

-(void)addMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    [self updateMarker:annotation option:option];
    [self addAnnotation:annotation];
}

-(void)updateMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
    NSString *title = [RCTConvert NSString:option[@"title"]];
    if(title.length == 0) {
        title = nil;
    }
    annotation.coordinate = coor;
    annotation.title = title;
}

@end

@implementation SomeOneAnnotation
@end
@implementation NoOneAnnotation
@end
@implementation MyAnnotation
@end
@implementation SelectedAnnotation
@end
