package com.example.record;

import android.content.Context;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Environment;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;


/** RecordPlugin */
public class RecordPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private Context context;

    private MediaRecorder mediaRecorder;
    private String currentFilePath;
    private boolean isRecording = false;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "voice_record_plugin");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "startRecord":
                startRecord(result);
                break;
            case "stopRecord":
                stopRecord(result);
                break;
            case "isRecording":
                result.success(isRecording);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void startRecord(Result result) {
        if (isRecording) {
            result.success(false);
            return;
        }

        try {
            currentFilePath = generateFilePath();
            mediaRecorder = new MediaRecorder();

            mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS);
            mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
            

            mediaRecorder.setOutputFile(currentFilePath);

            mediaRecorder.setAudioSamplingRate(16000);
            mediaRecorder.setAudioEncodingBitRate(64000);
            mediaRecorder.setAudioChannels(1);

            mediaRecorder.prepare();
            mediaRecorder.start();
            isRecording = true;

            result.success(true);
        } catch (IOException e) {
            result.error("RECORDING_ERROR", "录音启动失败: " + e.getMessage(), null);
        }
    }

    private void stopRecord(Result result) {
        if (!isRecording) {
            result.success(null);
            return;
        }

        try {
            stopRecordInternal();
            result.success(currentFilePath);
        } catch (Exception e) {
            result.error("STOP_ERROR", "停止录音失败: " + e.getMessage(), null);
        }
    }

    private void stopRecordInternal() {
        if (mediaRecorder != null) {
            try {
                mediaRecorder.stop();
                mediaRecorder.release();
            } catch (Exception e) {
            }
            mediaRecorder = null;
        }
        isRecording = false;
    }

    private String generateFilePath() {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String fileName = "recording_" + timeStamp + ".aac";

        File externalDir = context.getExternalFilesDir(Environment.DIRECTORY_MUSIC);
        if (externalDir == null) {
            externalDir = context.getFilesDir();
        }

        return new File(externalDir, fileName).getAbsolutePath();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        if (mediaRecorder != null) {
            stopRecordInternal();
        }
    }
}
