package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new plugins.cachet.audio_streamer.AudioStreamerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin audio_streamer, plugins.cachet.audio_streamer.AudioStreamerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new id.flutter.flutter_background_service.FlutterBackgroundServicePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_background_service_android, id.flutter.flutter_background_service.FlutterBackgroundServicePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.lib.flutter_blue_plus.FlutterBluePlusPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_blue_plus, com.lib.flutter_blue_plus.FlutterBluePlusPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_local_notifications, com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new xyz.canardoux.fluttersound.FlutterSound());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_sound, xyz.canardoux.fluttersound.FlutterSound", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin", e);
    }
  }
}
