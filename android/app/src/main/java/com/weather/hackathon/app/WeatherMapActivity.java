/*
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The Weather Company's API for obtaining radar tile images is provided only for the purposes of the hackathon hosted by
 * The Weather Company in June, 2015.
 *
 * The software is provided "as is", without warranty of any kind, express or implied, including but not limited to the
 * warranties of merchantability, fitness for a particular purpose or noninfringement.  In no event shall the authors or
 * copyright holders be liable for any claim, damages or other liability, whether in action of contract, tort or
 * otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
 */
package com.weather.hackathon.app;

import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.*;
import com.squareup.okhttp.OkHttpClient;
import com.weather.hackathon.model.LayersFetcher;

import java.util.concurrent.TimeUnit;

/**
 * Activity for displaying the map with a weather overlay.
 *
 * @author michael.krussel
 */
public class WeatherMapActivity extends FragmentActivity {
    private static final String LAYER_TO_DISPLAY = "radar";
    private GoogleMap map; // Might be null if Google Play services APK is not available.
    private Handler handler;
    private LayersFetcher layersFetcher;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_weather_map);
        setUpMapIfNeeded();
        handler = new Handler();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
        if (layersFetcher != null) {
            layersFetcher.fetchAsync();
            setupLayerCallback();
        }
    }

    @Override
    protected void onPause() {
        handler.removeCallbacksAndMessages(null);
        super.onPause();
    }

    private void setupLayerCallback() {
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                layersFetcher.fetchAsync();
                setupLayerCallback();
            }
        }, TimeUnit.MINUTES.toMillis(5));
    }

    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only ever
     * call {@link #setUpMap()} once when {@link #map} is not null.
     * <p/>
     * If it isn't installed {@link SupportMapFragment} (and
     * {@link com.google.android.gms.maps.MapView MapView}) will show a prompt for the user to
     * install/update the Google Play services APK on their device.
     * <p/>
     * A user can return to this FragmentActivity after following the prompt and correctly
     * installing/updating/enabling the Google Play services. Since the FragmentActivity may not
     * have been completely destroyed during this process (it is likely that it would only be
     * stopped or paused), {@link #onCreate(Bundle)} may not be called again so we should call this
     * method in {@link #onResume()} to guarantee that it will be called.
     */
    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (map == null) {
            // Try to obtain the map from the SupportMapFragment.
            map = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map))
                    .getMap();
            // Check if we were successful in obtaining the map.
            if (map != null) {
                setUpMap();
            }
        }
    }

    /**
     * This is where we can add markers or lines, add listeners or move the camera. In this case, we centered the map
     * on the US and initialized classes for loading the tiles.
     * <p/>
     * This should only be called once and when we are sure that {@link #map} is not null.
     */
    private void setUpMap() {
        map.getUiSettings().setTiltGesturesEnabled(false);
        map.getUiSettings().setRotateGesturesEnabled(false);
        map.getUiSettings().setMyLocationButtonEnabled(true);

        CameraPosition position = CameraPosition.builder()
                .target(new LatLng(39.8282, -98.5795))
                .zoom(3.5f).build();
        map.moveCamera(CameraUpdateFactory.newCameraPosition(position));

        layersFetcher = new LayersFetcher(new OkHttpClient());
        layersFetcher.setLayersResultListener(new WeatherOverlayCreator(map, LAYER_TO_DISPLAY));
    }
}
