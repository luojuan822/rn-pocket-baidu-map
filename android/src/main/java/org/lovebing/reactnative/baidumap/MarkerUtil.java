package org.lovebing.reactnative.baidumap;

import android.util.Log;
import android.widget.Button;

import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by lovebing on Sept 28, 2016.
 */
public class MarkerUtil {

    public enum MarkerType {
        current,
        someone,
        noone
    }


    public static int getResource(MarkerType markerType) {
        switch (markerType) {
            case current:
                return R.mipmap.baidu_my;
            case someone:
                return R.mipmap.baidu_someone;
            case noone:
                return R.mipmap.baidu_noone;
            default:
                return 0;
        }
    }

    public static void updateMaker(Marker maker, ReadableMap option, boolean isCurrent) {
        System.out.println("updateMaker===========");
        LatLng position = getLatLngFromOption(option);
        maker.setPosition(position);
        maker.setTitle(option.getString("title"));
//        maker.setIcon(BitmapDescriptorFactory.fromResource(isCurrent ? R.mipmap.icon_center_point : R.mipmap.icon_gcoding));
//        System.out.println(maker.getIcon().getBitmap());
    }

    public static Marker addMarker(MapView mapView, ReadableMap option, MarkerType markerType) {
        System.out.println("addMarker===========");
        BitmapDescriptor bitmap = BitmapDescriptorFactory.fromResource(getResource(markerType));
        LatLng position = getLatLngFromOption(option);
        OverlayOptions overlayOptions = new MarkerOptions()
                .icon(bitmap)
                .position(position)
                .title(option.hasKey("title") ? option.getString("title") : "");

        Marker marker = (Marker)mapView.getMap().addOverlay(overlayOptions);
        return marker;
    }


    private static LatLng getLatLngFromOption(ReadableMap option) {
        double latitude = option.getDouble("latitude");
        double longitude = option.getDouble("longitude");
        return new LatLng(latitude, longitude);

    }
}
