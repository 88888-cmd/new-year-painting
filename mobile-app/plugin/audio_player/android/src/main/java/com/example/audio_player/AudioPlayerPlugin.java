package com.example.audio_player;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.io.IOException;

public class AudioPlayerPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private Context context;
    private MediaPlayer mediaPlayer;
    private Handler handler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "audio_player");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "init":
                initPlayer();
                result.success(null);
                break;
            case "play":
                String url = call.argument("url");
                play(url, result);
                break;
            case "pause":
                pause(result);
                break;
            case "resume":
                resume(result);
                break;
            case "stop":
                stop(result);
                break;
            case "seekTo":
                int position = call.argument("position");
                seekTo(position, result);
                break;
            case "getDuration":
                getDuration(result);
                break;
            case "getCurrentPosition":
                getCurrentPosition(result);
                break;
            default:
                result.notImplemented();
        }
    }

    private void initPlayer() {
        if (mediaPlayer != null) {
            mediaPlayer.release();
        }
        mediaPlayer = new MediaPlayer();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mediaPlayer.setAudioAttributes(
                    new AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .build()
            );
        }
    }

    private void play(String url, final Result result) {
        try {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.stop();
            }
            mediaPlayer.reset();
            mediaPlayer.setDataSource(url);
            mediaPlayer.prepareAsync();
            mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    mp.start();
                    result.success(null);
                }
            });
            mediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
                @Override
                public boolean onError(MediaPlayer mp, int what, int extra) {
                    result.error("MEDIA_ERROR", "播放错误: " + what, null);
                    return true;
                }
            });
        } catch (IOException e) {
            result.error("IO_ERROR", "网络错误: " + e.getMessage(), null);
        } catch (Exception e) {
            result.error("UNKNOWN_ERROR", "未知错误: " + e.getMessage(), null);
        }
    }

    private void pause(final Result result) {
        try {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.pause();
            }
            result.success(null);
        } catch (Exception e) {
            result.error("PAUSE_ERROR", "暂停错误: " + e.getMessage(), null);
        }
    }

    private void resume(final Result result) {
        try {
            if (!mediaPlayer.isPlaying()) {
                mediaPlayer.start();
            }
            result.success(null);
        } catch (Exception e) {
            result.error("RESUME_ERROR", "继续错误: " + e.getMessage(), null);
        }
    }

    private void stop(final Result result) {
        try {
            if (mediaPlayer != null) {
                mediaPlayer.stop();
            }
            result.success(null);
        } catch (Exception e) {
            result.error("STOP_ERROR", "停止错误: " + e.getMessage(), null);
        }
    }

    private void seekTo(int position, final Result result) {
        try {
            mediaPlayer.seekTo(position);
            result.success(null);
        } catch (Exception e) {
            result.error("SEEK_ERROR", "定位错误: " + e.getMessage(), null);
        }
    }

    private void getDuration(final Result result) {
        try {
            result.success(mediaPlayer.getDuration());
        } catch (Exception e) {
            result.error("DURATION_ERROR", "获取时长错误: " + e.getMessage(), null);
        }
    }

    private void getCurrentPosition(final Result result) {
        try {
            result.success(mediaPlayer.getCurrentPosition());
        } catch (Exception e) {
            result.error("POSITION_ERROR", "获取位置错误: " + e.getMessage(), null);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        if (mediaPlayer != null) {
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }
}