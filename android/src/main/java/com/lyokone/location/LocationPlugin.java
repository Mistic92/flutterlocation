package com.lyokone.location;

import android.Manifest;
import android.app.Activity;
import android.content.IntentSender;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.util.Log;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.*;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;


import java.util.HashMap;

/**
 * LocationPlugin
 */
public class LocationPlugin implements  MethodCallHandler, StreamHandler, ActivityResultListener  {
    private static final String STREAM_CHANNEL_NAME = "lyokone/locationstream";
    private static final String METHOD_CHANNEL_NAME = "lyokone/location";
    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;
    private EventSink events;
    private final Activity activity;
    private Result result;
    private static LocationPlugin locationPlugin;
    LocationPlugin(Activity activity) {
        this.activity = activity;
    }


    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL_NAME);
        locationPlugin = new LocationPlugin(registrar.activity());
        registrar.addActivityResultListener(locationPlugin);
        channel.setMethodCallHandler(locationPlugin);

        final EventChannel eventChannel = new EventChannel(registrar.messenger(), STREAM_CHANNEL_NAME);
        eventChannel.setStreamHandler(locationPlugin);
    }


    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        this.result = result;
        if (call.method.equals("getLocation")) {
            Intent locationActivity = new Intent(activity, LocationPluginActivity.class);
            activity.startActivityForResult(locationActivity, REQUEST_PERMISSIONS_REQUEST_CODE);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onListen(Object arguments, final EventSink eventsSink) {
        events = eventsSink;
        //call eventOnListen
        // TODO: IMPLEMENT LISTEN LOGIC
    }

    @Override
    public void onCancel(Object arguments) {
        System.out.println("###### GOT A CANCEL");
        //TODO: call eventCancel
        events = null;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                HashMap<String, Double> location = (HashMap<String, Double>) data.getSerializableExtra("location");
                result.success(location);
            }
            if (resultCode == Activity.RESULT_CANCELED) {
                System.out.println("RESULT_CANCELED: Error getting location");
                result.error(data.getStringExtra("errorCode"), data.getStringExtra("errorMsg"), null);
            }
        }
        return true;
    }
}
