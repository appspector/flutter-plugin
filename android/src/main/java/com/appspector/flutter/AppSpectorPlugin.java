package com.appspector.flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.appspector.flutter.MainAppSpectorHandler.internalRegister;

/**
 * AppSpectorPlugin
 */
public class AppSpectorPlugin implements FlutterPlugin {

    @Nullable
    private MainAppSpectorHandler mainAppSpectorHandler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        mainAppSpectorHandler = internalRegister(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (mainAppSpectorHandler != null) {
            mainAppSpectorHandler.release();
            mainAppSpectorHandler = null;
        }
    }

    /**
     * Plugin registration.
     * Deprecated: it's old plugin registration which is needed for Flutter v1
     */
    @SuppressWarnings("deprecation")
    @Deprecated
    public static void registerWith(Registrar registrar) {
        internalRegister(registrar.context().getApplicationContext(), registrar.messenger());
    }
}
