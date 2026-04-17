import AVFoundation
import Flutter

public class AudioPlayerPlugin: NSObject, FlutterPlugin {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var channel: FlutterMethodChannel
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_player", binaryMessenger: registrar.messenger())
        let instance = AudioPlayerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            initPlayer()
            result(nil)
        case "play":
            guard let args = call.arguments as? [String: Any],
                  let urlString = args["url"] as? String,
                  let url = URL(string: urlString) else {
                result(FlutterError(code: "INVALID_URL", message: "无效的URL", details: nil))
                return
            }
            play(url: url, result: result)
        case "pause":
            pause(result: result)
        case "resume":
            resume(result: result)
        case "stop":
            stop(result: result)
        case "seekTo":
            guard let args = call.arguments as? [String: Any],
                  let position = args["position"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "缺少position参数", details: nil))
                return
            }
            seekTo(position: position, result: result)
        case "getDuration":
            getDuration(result: result)
        case "getCurrentPosition":
            getCurrentPosition(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initPlayer() {
        player = nil
        playerItem = nil
    }
    
    private func play(url: URL, result: @escaping FlutterResult) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        let statusObservation = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard let self = self else { return }
            switch item.status {
            case .readyToPlay:
                self.player?.play()
                result(nil)
            case .failed:
                result(FlutterError(code: "PLAYBACK_ERROR", message: "播放失败", details: item.error?.localizedDescription))
            case .unknown:
                result(FlutterError(code: "PLAYBACK_ERROR", message: "播放未知错误", details: nil))
            @unknown default:
                result(FlutterError(code: "PLAYBACK_ERROR", message: "播放错误", details: nil))
            }
        }
        
        objc_setAssociatedObject(self, "statusObservation", statusObservation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func pause(result: @escaping FlutterResult) {
        player?.pause()
        result(nil)
    }
    
    private func resume(result: @escaping FlutterResult) {
        player?.play()
        result(nil)
    }
    
    private func stop(result: @escaping FlutterResult) {
        player?.pause()
        player = nil
        playerItem = nil
        result(nil)
    }
    
    private func seekTo(position: Int, result: @escaping FlutterResult) {
        let time = CMTime(seconds: Double(position) / 1000, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time) { [weak self] completed in
            if completed {
                result(nil)
            } else {
                result(FlutterError(code: "SEEK_ERROR", message: "定位失败", details: nil))
            }
        }
    }
    
    private func getDuration(result: @escaping FlutterResult) {
        guard let playerItem = playerItem,
              let duration = playerItem.duration.seconds,
              !duration.isNaN, !duration.isInfinite else {
            result(0)
            return
        }
        result(Int(duration * 1000))
    }
    
    private func getCurrentPosition(result: @escaping FlutterResult) {
        guard let player = player,
              let currentTime = player.currentItem?.currentTime().seconds,
              !currentTime.isNaN, !currentTime.isInfinite else {
            result(0)
            return
        }
        result(Int(currentTime * 1000))
    }
}