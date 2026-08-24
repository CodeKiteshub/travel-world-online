package com.travel.travelworldonline

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterShellArgs

class MainActivity : FlutterActivity() {
    override fun getRenderMode(): RenderMode {
        // SurfaceView + BLAST/SurfaceControl is black on many x86 emulators
        // (especially 16KB-page API 35+ images). TextureView composites via HWUI.
        return if (isEmulator) RenderMode.texture else RenderMode.surface
    }

    override fun getFlutterShellArgs(): FlutterShellArgs {
        val args = super.getFlutterShellArgs()
        if (isEmulator) {
            args.add(FlutterShellArgs.ARG_ENABLE_SOFTWARE_RENDERING)
        }
        return args
    }

    private val isEmulator: Boolean
        get() {
            val fingerprint = Build.FINGERPRINT
            val model = Build.MODEL
            val product = Build.PRODUCT
            val hardware = Build.HARDWARE
            val manufacturer = Build.MANUFACTURER
            return fingerprint.startsWith("generic") ||
                fingerprint.startsWith("unknown") ||
                model.contains("google_sdk") ||
                model.contains("Emulator") ||
                model.contains("Android SDK built for") ||
                manufacturer.contains("Genymotion") ||
                hardware.contains("goldfish") ||
                hardware.contains("ranchu") ||
                product.contains("sdk_gphone") ||
                product.contains("emulator")
        }
}
