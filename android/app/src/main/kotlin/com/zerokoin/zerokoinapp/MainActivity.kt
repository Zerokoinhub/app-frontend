package com.zerokoin.zerokoinapp

import androidx.annotation.NonNull
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.zerokoin.zerokoinapp/biometric"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "authenticate" -> {
                    val reason = call.argument<String>("reason") ?: "Authenticate"
                    authenticate(reason, result)
                }
                "checkBiometricSupport" -> {
                    checkSupport(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkSupport(result: MethodChannel.Result) {
        val manager = BiometricManager.from(this)
        val canAuth = manager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        )
        result.success(canAuth == BiometricManager.BIOMETRIC_SUCCESS)
    }

    private fun authenticate(reason: String, result: MethodChannel.Result) {
        val executor: Executor = ContextCompat.getMainExecutor(this)

        val prompt = BiometricPrompt(
            this,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {

                override fun onAuthenticationSucceeded(
                    authResult: BiometricPrompt.AuthenticationResult
                ) {
                    result.success(true)
                }

                override fun onAuthenticationError(
                    errorCode: Int,
                    errString: CharSequence
                ) {
                    result.error("AUTH_ERROR", errString.toString(), null)
                }

                override fun onAuthenticationFailed() {
                    // ignore
                }
            }
        )

        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric Authentication")
            .setSubtitle(reason)
            .setAllowedAuthenticators(
                BiometricManager.Authenticators.BIOMETRIC_STRONG or
                    BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
            .build()

        prompt.authenticate(info)
    }
}
