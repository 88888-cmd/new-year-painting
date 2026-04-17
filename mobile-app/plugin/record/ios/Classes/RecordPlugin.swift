import Flutter
import UIKit
import AVFoundation

public class RecordPlugin: NSObject, FlutterPlugin {

    private var audioRecorder: AVAudioRecorder?
    private var currentFilePath: String?
    private var isRecording: Bool = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "voice_record_plugin", binaryMessenger: registrar.messenger())
    let instance = RecordPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startRecord":
            startRecord(result: result)
        case "stopRecord":
            stopRecord(result: result)
        case "isRecording":
            result(isRecording)
        default:
            result(FlutterMethodNotImplemented)
        }
  }

    private func startRecord(result: @escaping FlutterResult) {
        if isRecording {
            result(false)
            return
        }

        
        do {
            // 设置音频会话
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 生成文件路径
            currentFilePath = generateFilePath()
            guard let filePath = currentFilePath else {
                result(FlutterError(code: "FILE_PATH_ERROR", message: "无法生成文件路径", details: nil))
                return
            }
            
            let url = URL(fileURLWithPath: filePath)
            
            // 配置录音设置
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 64000
            ]
            
            // 创建录音器
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            // 开始录音
            if audioRecorder?.record() == true {
                isRecording = true
                result(true)
            } else {
                result(FlutterError(code: "RECORDING_ERROR", message: "录音启动失败", details: nil))
            }
            
        } catch {
            result(FlutterError(code: "RECORDING_ERROR", message: "录音启动失败: \(error.localizedDescription)", details: nil))
        }
    }

    private func stopRecord(result: @escaping FlutterResult) {
        if !isRecording {
            result(nil)
            return
        }
        
        audioRecorder?.stop()
        isRecording = false
        
        // 停用音频会话
        try? AVAudioSession.sharedInstance().setActive(false)
        
        result(currentFilePath)
    }
    
    private func generateFilePath() -> String? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "recording_\(timestamp).aac"
        return (documentsPath as NSString).appendingPathComponent(fileName)
    }
}

extension RecordPlugin: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("录音完成，但可能存在问题")
        }
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("录音编码错误: \(error?.localizedDescription ?? "未知错误")")
        isRecording = false
    }
}