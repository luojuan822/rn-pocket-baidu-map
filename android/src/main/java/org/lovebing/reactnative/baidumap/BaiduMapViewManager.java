package org.lovebing.reactnative.baidumap;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.baidu.mapapi.SDKInitializer;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.map.MapPoi;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.MapViewLayoutParams;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.Text;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.overlayutil.DrivingRouteOverlay;
import com.baidu.mapapi.overlayutil.MassTransitRouteOverlay;
import com.baidu.mapapi.overlayutil.OverlayManager;
import com.baidu.mapapi.overlayutil.WalkingRouteOverlay;
import com.baidu.mapapi.search.core.SearchResult;
import com.baidu.mapapi.search.route.BikingRouteResult;
import com.baidu.mapapi.search.route.DrivingRouteLine;
import com.baidu.mapapi.search.route.DrivingRouteResult;
import com.baidu.mapapi.search.route.IndoorRouteResult;
import com.baidu.mapapi.search.route.MassTransitRouteLine;
import com.baidu.mapapi.search.route.MassTransitRouteResult;
import com.baidu.mapapi.search.route.OnGetRoutePlanResultListener;
import com.baidu.mapapi.search.route.RoutePlanSearch;
import com.baidu.mapapi.search.route.TransitRouteResult;
import com.baidu.mapapi.search.route.WalkingRouteLine;
import com.baidu.mapapi.search.route.WalkingRouteResult;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by lovebing on 12/20/2015.
 */
public class BaiduMapViewManager extends ViewGroupManager<MapView> implements OnGetRoutePlanResultListener {

    private static final String REACT_CLASS = "RCTBaiduMapView";

    private ThemedReactContext mReactContext;

    private ReadableArray childrenPoints;

    private WalkingRouteLine walkingRouteLine;
    private DrivingRouteLine drivingRouteLine;
    private MassTransitRouteLine busRouteLine;

    private MapView _mapView;
    private RoutePlanSearch _search;
    private OverlayManager routeOverlay;

    public String getName() {
        return REACT_CLASS;
    }

//    public static  BaiduMapViewManager getInstance() {
//        if(instance == null) {
//            synchronized (BaiduMapViewManager.class) {
//                if(instance == null)
//                    instance = new BaiduMapViewManager();
//            }
//        }
//        return instance;
//    }

    public void initSDK(Context context) {
        SDKInitializer.initialize(context);
    }

    public MapView createViewInstance(ThemedReactContext context) {
        mReactContext = context;
//        if(mMapView != null) {
//            mMapView.onDestroy();
//        }

        MapView mapView = new MapView(context);
        setListeners(mapView);
        mapView.getMap().showMapPoi(true);
        _mapView = mapView;
        System.out.println("createViewInstance=====" + mapView);
        return mapView;
    }

    @Override
    public void addView(MapView parent, View child, int index) {
        if(childrenPoints != null) {
            Point point = new Point();
            ReadableArray item = childrenPoints.getArray(index);
            if(item != null) {
                point.set(item.getInt(0), item.getInt(1));
                MapViewLayoutParams mapViewLayoutParams = new MapViewLayoutParams
                        .Builder()
                        .layoutMode(MapViewLayoutParams.ELayoutMode.absoluteMode)
                        .point(point)
                        .build();
                parent.addView(child, mapViewLayoutParams);
            }
        }

    }

    @ReactProp(name = "zoomControlsVisible")
    public void setZoomControlsVisible(MapView mapView, boolean zoomControlsVisible) {
        mapView.showZoomControls(zoomControlsVisible);
    }

    @ReactProp(name="trafficEnabled")
    public void setTrafficEnabled(MapView mapView, boolean trafficEnabled) {
        mapView.getMap().setTrafficEnabled(trafficEnabled);
    }

    @ReactProp(name="baiduHeatMapEnabled")
    public void setBaiduHeatMapEnabled(MapView mapView, boolean baiduHeatMapEnabled) {
        mapView.getMap().setBaiduHeatMapEnabled(baiduHeatMapEnabled);
    }

    @ReactProp(name = "mapType")
    public void setMapType(MapView mapView, int mapType) {
        mapView.getMap().setMapType(mapType);
    }

    @ReactProp(name="zoom")
    public void setZoom(MapView mapView, float zoom) {
        MapStatus mapStatus = new MapStatus.Builder().zoom(zoom).build();
        MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
        mapView.getMap().setMapStatus(mapStatusUpdate);
    }
    @ReactProp(name="center")
    public void setCenter(MapView mapView, ReadableMap position) {
        if(position != null) {
            double latitude = position.getDouble("latitude");
            double longitude = position.getDouble("longitude");
            LatLng point = new LatLng(latitude, longitude);
            MapStatus mapStatus = new MapStatus.Builder()
                    .target(point)
                    .build();
            MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
            mapView.getMap().setMapStatus(mapStatusUpdate);
        }
    }

    @ReactProp(name="marker")
    public void setMarker(MapView mapView, ReadableMap option) {
        System.out.println("marker===========");
//        System.out.println(mMarker);
        if(option != null) {
//            if(mMarker != null) {
//                mMarker.remove();
//            }
//            mMarker = MarkerUtil.addMarker(mapView, option, MarkerUtil.MarkerType.current);
            MarkerUtil.addMarker(mapView, option, MarkerUtil.MarkerType.current);
        }
    }

    @ReactProp(name="someoneMarkers")
    public void setSomeoneMarkers(MapView mapView, ReadableArray options) {
        System.out.println("someoneMarkers===========" + mapView);
//        System.out.println(someoneMarkers.size());
//
//        for (int i=0; i < someoneMarkers.size(); i++) {
//            someoneMarkers.get(i).remove();
//        }
//        someoneMarkers.clear();
        if(options == null)
            return;
        for (int i = 0; i < options.size(); i++) {
            ReadableMap option = options.getMap(i);
//            if(mMarkers.size() > i + 1 && mMarkers.get(i) != null) {
//                MarkerUtil.updateMaker(mMarkers.get(i), option, false);
//            }
//            else {
            MarkerUtil.addMarker(mapView, option, MarkerUtil.MarkerType.someone);
//            someoneMarkers.add(i, MarkerUtil.addMarker(mapView, option, MarkerUtil.MarkerType.someone));
//            }
        }
//        if(options.size() < mMarkers.size()) {
//            int start = mMarkers.size() - 1;
//            int end = options.size();
//            for (int i = start; i >= end; i--) {
//                mMarkers.get(i).remove();
//                mMarkers.remove(i);
//            }
//        }
    }

    @ReactProp(name="nooneMarkers")
    public void setNooneMarkers(MapView mapView, ReadableArray options) {
        System.out.println("someoneMarkers===========" + mapView);
//        System.out.println(nooneMarkers.size());
//
//        for (int i=0; i < nooneMarkers.size(); i++) {
//            nooneMarkers.get(i).remove();
//        }
//        nooneMarkers.clear();
        if(options == null)
            return;

        for (int i = 0; i < options.size(); i++) {
            ReadableMap option = options.getMap(i);
            MarkerUtil.addMarker(mapView, option, MarkerUtil.MarkerType.noone);
//            nooneMarkers.add(i, MarkerUtil.addMarker(mapView, option, MarkerUtil.MarkerType.noone));
        }
    }

    @ReactProp(name = "childrenPoints")
    public void setChildrenPoints(MapView mapView, ReadableArray childrenPoints) {
        this.childrenPoints = childrenPoints;
    }

    /**
     *
     */
    private void setListeners(final MapView _mapView) {
        BaiduMap map = _mapView.getMap();
        map.setOnMapStatusChangeListener(new BaiduMap.OnMapStatusChangeListener() {

            private WritableMap getEventParams(MapStatus mapStatus) {
                WritableMap writableMap = Arguments.createMap();
                WritableMap target = Arguments.createMap();
                target.putDouble("latitude", mapStatus.target.latitude);
                target.putDouble("longitude", mapStatus.target.longitude);
                writableMap.putMap("target", target);
                writableMap.putDouble("zoom", mapStatus.zoom);
                writableMap.putDouble("overlook", mapStatus.overlook);
                return writableMap;
            }

            @Override
            public void onMapStatusChangeStart(MapStatus mapStatus) {
                System.out.println("onMapStatusChangeStart=============");
                sendEvent(_mapView, "onMapStatusChangeStart", getEventParams(mapStatus));
            }

            @Override
            public void onMapStatusChange(MapStatus mapStatus) {
                System.out.println("onMapStatusChange=============");
                sendEvent(_mapView, "onMapStatusChange", getEventParams(mapStatus));
            }

            @Override
            public void onMapStatusChangeFinish(MapStatus mapStatus) {
                System.out.println("onMapStatusChangeFinish=============");
                sendEvent(_mapView, "onMapStatusChangeFinish", getEventParams(mapStatus));
            }
        });

//        map.setOnMapLoadedCallback(new BaiduMap.OnMapLoadedCallback() {
//            @Override
//            public void onMapLoaded() {
//                sendEvent("onMapLoaded", null);
//            }
//        });

        map.setOnMapClickListener(new BaiduMap.OnMapClickListener() {
            @Override
            public void onMapClick(LatLng latLng) {
                System.out.println("onMapClick=============");
                _mapView.getMap().hideInfoWindow();
                WritableMap writableMap = Arguments.createMap();
                writableMap.putDouble("latitude", latLng.latitude);
                writableMap.putDouble("longitude", latLng.longitude);
                sendEvent(_mapView, "onMapClick", writableMap);
            }

            @Override
            public boolean onMapPoiClick(MapPoi mapPoi) {
                System.out.println("onMapPoiClick=============");
                return false;
            }
        });
        map.setOnMapDoubleClickListener(new BaiduMap.OnMapDoubleClickListener() {
            @Override
            public void onMapDoubleClick(LatLng latLng) {
                System.out.println("onMapDoubleClick=============");
                WritableMap writableMap = Arguments.createMap();
                writableMap.putDouble("latitude", latLng.latitude);
                writableMap.putDouble("longitude", latLng.longitude);
                sendEvent(_mapView, "onMapDoubleClick", writableMap);
            }
        });

        map.setOnMarkerDragListener(new BaiduMap.OnMarkerDragListener() {
            @Override
            public void onMarkerDrag(Marker marker) {
                System.out.println("onMarkerDrag=============");
            }

            @Override
            public void onMarkerDragEnd(Marker marker) {
                System.out.println("onMarkerDragEnd=============");
            }

            @Override
            public void onMarkerDragStart(Marker marker) {
                System.out.println("onMarkerDragStart=============");
            }
        });

        map.setOnMarkerClickListener(new BaiduMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(final Marker marker) {
                System.out.println("onMarkerClick=============");
                if(marker != null && marker.getTitle() != null && marker.getTitle().length() > 0) {
                    TextView mMarkerText = new TextView(_mapView.getContext());
                    mMarkerText.setBackgroundResource(R.drawable.popup);
                    mMarkerText.setPadding(32, 32, 32, 32);
                    mMarkerText.setText(marker.getTitle());

                    InfoWindow.OnInfoWindowClickListener listener = new InfoWindow.OnInfoWindowClickListener() {
                        @Override
                        public void onInfoWindowClick() {
                            //隐藏infowindow
                            System.out.println("onAnnotationClick=============");
                            WritableMap writableMap = Arguments.createMap();
                            WritableMap position = Arguments.createMap();
                            position.putDouble("latitude", marker.getPosition().latitude);
                            position.putDouble("longitude", marker.getPosition().longitude);
                            writableMap.putMap("position", position);
                            writableMap.putString("title", marker.getTitle());
                            sendEvent(_mapView, "onAnnotationClick", writableMap);
                        }
                    };
                    InfoWindow infoWindow = new InfoWindow(BitmapDescriptorFactory.fromView(mMarkerText),
                            marker.getPosition(), -80, listener);
                    _mapView.getMap().showInfoWindow(infoWindow);
                } else {
                    _mapView.getMap().hideInfoWindow();
                }
//                WritableMap writableMap = Arguments.createMap();
//                WritableMap position = Arguments.createMap();
//                position.putDouble("latitude", marker.getPosition().latitude);
//                position.putDouble("longitude", marker.getPosition().longitude);
//                writableMap.putMap("position", position);
//                writableMap.putString("title", marker.getTitle());
//                sendEvent("onMarkerClick", writableMap);
                return true;
            }
        });
    }

    /**
     *
     * @param eventName
     * @param params
     */
    private void sendEvent(MapView mMapView, String eventName, @Nullable WritableMap params) {
        System.out.println("sendEvent==========" + mMapView);
        System.out.println("sendEvent==========" + mReactContext);
        WritableMap event = Arguments.createMap();
        event.putMap("params", params);
        event.putString("type", eventName);
        mReactContext
                .getJSModule(RCTEventEmitter.class)
                .receiveEvent(mMapView.getId(),
                        "topChange",
                        event);
    }

    @Override
    public void onGetWalkingRouteResult(WalkingRouteResult result) {
        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
            return;
        }
        if (result.error == SearchResult.ERRORNO.AMBIGUOUS_ROURE_ADDR) {
            // 起终点或途经点地址有岐义，通过以下接口获取建议查询信息
            // result.getSuggestAddrInfo()
            return;
        }
        if (result.error == SearchResult.ERRORNO.NO_ERROR && result.getRouteLines().size() > 0) {
            walkingRouteLine = result.getRouteLines().get(0);
            WritableMap writableMap = Arguments.createMap();
            writableMap.putInt("time", walkingRouteLine.getDuration()/60);
            sendEvent(_mapView, "onWalkingRouteResult", writableMap);
        }

    }

    @Override
    public void onGetTransitRouteResult(TransitRouteResult transitRouteResult) {
    }

    @Override
    public void onGetMassTransitRouteResult(MassTransitRouteResult result) {
        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
            return;
        }
        if (result.error == SearchResult.ERRORNO.AMBIGUOUS_ROURE_ADDR) {
            // 起终点模糊，获取建议列表
            //result.getSuggestAddrInfo();
            return;
        }
        if (result.error == SearchResult.ERRORNO.NO_ERROR && result.getRouteLines().size() > 0) {
            busRouteLine = result.getRouteLines().get(0);

            WritableMap writableMap = Arguments.createMap();
            writableMap.putInt("time", busRouteLine.getDuration()/60);
            sendEvent(_mapView, "onMassTransitRouteResult", writableMap);
        }
    }

    @Override
    public void onGetDrivingRouteResult(DrivingRouteResult result) {
        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
            return;
        }
        if (result.error == SearchResult.ERRORNO.AMBIGUOUS_ROURE_ADDR) {
            // 起终点或途经点地址有岐义，通过以下接口获取建议查询信息
            // result.getSuggestAddrInfo()
            return;
        }
        if (result.error == SearchResult.ERRORNO.NO_ERROR && result.getRouteLines().size() > 0) {
            drivingRouteLine = result.getRouteLines().get(0);

            WritableMap writableMap = Arguments.createMap();
            writableMap.putInt("time", drivingRouteLine.getDuration()/60);
            sendEvent(_mapView, "onDrivingRouteResult", writableMap);
        }
    }

    @Override
    public void onGetIndoorRouteResult(IndoorRouteResult indoorRouteResult) {
    }

    @Override
    public void onGetBikingRouteResult(BikingRouteResult bikingRouteResult) {
    }

    public RoutePlanSearch getRoutePlanSearch() {
        if(_search == null) {
            synchronized (BaiduMapViewManager.class) {
                if(_search == null) {
                    _search = RoutePlanSearch.newInstance();
                    _search.setOnGetRoutePlanResultListener(this);
                }
            }
        }
        return _search;
    }

    public void drawWalking() {
        if(routeOverlay != null) {
            routeOverlay.removeFromMap();
        }
        BaiduMap baiduMap = _mapView.getMap();
        WalkingRouteOverlay overlay = new MyWalkingRouteOverlay(baiduMap);
        baiduMap.setOnMarkerClickListener(overlay);
        routeOverlay = overlay;
        overlay.setData(walkingRouteLine);
        overlay.addToMap();
        overlay.zoomToSpan();
    }

    public void drawBus() {
        if(routeOverlay != null) {
            routeOverlay.removeFromMap();
        }
        BaiduMap baiduMap = _mapView.getMap();
        MyMassTransitRouteOverlay overlay = new MyMassTransitRouteOverlay(baiduMap);
        baiduMap.setOnMarkerClickListener(overlay);
        routeOverlay = overlay;

        overlay.setData( busRouteLine );
        // 同城
        overlay.setSameCity(true);

        overlay.addToMap();
        overlay.zoomToSpan();
    }

    public void drawDriving() {
        if(routeOverlay != null) {
            routeOverlay.removeFromMap();
        }
        BaiduMap baiduMap = _mapView.getMap();
        DrivingRouteOverlay overlay = new MyDrivingRouteOverlay(baiduMap);
        routeOverlay = overlay;

        baiduMap.setOnMarkerClickListener(overlay);
        overlay.setData(drivingRouteLine);

        overlay.addToMap();
        overlay.zoomToSpan();
    }


    /**
     *
     * @return
     */
//    public static MapView getMapView() {
//        return mMapView;
//    }

    // 定制RouteOverly
    private class MyDrivingRouteOverlay extends DrivingRouteOverlay {

        public MyDrivingRouteOverlay(BaiduMap baiduMap) {
            super(baiduMap);
        }

        @Override
        public BitmapDescriptor getStartMarker() {
            return BitmapDescriptorFactory.fromResource(R.mipmap.icon_st);
        }

        @Override
        public BitmapDescriptor getTerminalMarker() {
            return BitmapDescriptorFactory.fromResource(R.mipmap.icon_en);
        }

        @Override
        public int getLineColor() {
            return Color.argb(200, 248, 70, 191);
        }
    }

    private class MyWalkingRouteOverlay extends WalkingRouteOverlay {

        public MyWalkingRouteOverlay(BaiduMap baiduMap) {
            super(baiduMap);
        }

        @Override
        public BitmapDescriptor getStartMarker() {
            return BitmapDescriptorFactory.fromResource(R.mipmap.icon_st);
        }

        @Override
        public BitmapDescriptor getTerminalMarker() {
            return BitmapDescriptorFactory.fromResource(R.mipmap.icon_en);
        }
        @Override
        public int getLineColor() {
            return Color.argb(200, 248, 70, 191);
        }
    }

    private class MyMassTransitRouteOverlay extends MassTransitRouteOverlay {
        public  MyMassTransitRouteOverlay(BaiduMap baiduMap) {
            super(baiduMap);
        }

        @Override
        public BitmapDescriptor getStartMarker() {
            return BitmapDescriptorFactory.fromResource(R.mipmap.icon_st);
        }

        @Override
        public BitmapDescriptor getTerminalMarker() {
            return BitmapDescriptorFactory.fromResource(R.mipmap.icon_en);
        }
        @Override
        public int getLineColor() {
            return Color.argb(200, 248, 70, 191);
        }

    }
}


