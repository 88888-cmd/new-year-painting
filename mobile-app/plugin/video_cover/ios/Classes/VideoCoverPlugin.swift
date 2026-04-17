import Flutter
import AVFoundation

enum ImageFormat: Int {
    case JPEG
    case PNG
}

public class VideoCoverPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_cover", binaryMessenger: registrar.messenger())
    let instance = VideoCoverPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
           guard let args = call.arguments as? [String: Any] else {
               result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments provided", details: nil))
               return
           }

           let video = args["video"] as? String ?? ""
           let headers = args["headers"] as? [String: String]
           let path = args["path"] as? String
           let format = args["format"] as? Int ?? 0
           let maxh = args["maxh"] as? Int ?? 0
           let maxw = args["maxw"] as? Int ?? 0
           let timeMs = args["timeMs"] as? Int ?? 0
           let quality = args["quality"] as? Int ?? 10

           let isLocalFile = video.hasPrefix("file://") || video.hasPrefix("/")
           let url: URL
           if video.hasPrefix("file://") {
               url = URL(fileURLWithPath: String(video.dropFirst(7)))
           } else if video.hasPrefix("/") {
               url = URL(fileURLWithPath: video)
           } else {
               url = URL(string: video)!
           }

           switch call.method {
           case "data":
               DispatchQueue.global().async { [weak self] in
                    guard let self = self else { return result(nil) }
                   let thumbnailData = self.generateThumbnail(url: url, headers: headers, format: ImageFormat(rawValue: format)!, maxHeight: maxh, maxWidth: maxw, timeMs: timeMs, quality: quality)
                   result(thumbnailData)
               }
           case "file":
               var finalPath = path
               if finalPath == nil && !isLocalFile {
                   finalPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
               }

               DispatchQueue.global().async { [weak self] in
                    guard let self = self else { return result(nil) }
                   if let data = self.generateThumbnail(url: url, headers: headers, format: ImageFormat(rawValue: format)!, maxHeight: maxh, maxWidth: maxw, timeMs: timeMs, quality: quality) {
                       let ext: String
                       switch ImageFormat(rawValue: format)! {
                       case .JPEG:
                           ext = "jpg"
                       case .PNG:
                           ext = "png"
                       }

                       var thumbnail = url.deletingPathExtension().appendingPathExtension(ext)

                       if let finalPath = finalPath, !finalPath.isEmpty {
                           let lastPart = thumbnail.lastPathComponent
                           thumbnail = URL(fileURLWithPath: finalPath)
                           if thumbnail.pathExtension != ext {
                               thumbnail = thumbnail.appendingPathComponent(lastPart)
                           }
                       }

                       do {
                           try data.write(to: thumbnail)
                           var fullpath = thumbnail.absoluteString
                           if fullpath.hasPrefix("file://") {
                               fullpath = String(fullpath.dropFirst(7))
                           }
                           result(fullpath)
                       } catch {
                           result(FlutterError(code: "IO_ERROR", message: "Failed to write data to file", details: error.localizedDescription))
                       }
                   } else {
                       result(FlutterError(code: "THUMBNAIL_ERROR", message: "Failed to generate thumbnail", details: nil))
                   }
               }
           default:
               result(FlutterMethodNotImplemented)
           }
       }

       private func generateThumbnail(url: URL, headers: [String: String]?, format: ImageFormat, maxHeight: Int, maxWidth: Int, timeMs: Int, quality: Int) -> Data? {
           let asset = AVURLAsset(url: url, options: headers != nil ? ["AVURLAssetHTTPHeaderFieldsKey": headers!] : nil)
           let imgGenerator = AVAssetImageGenerator(asset: asset)
           imgGenerator.appliesPreferredTrackTransform = true
           imgGenerator.maximumSize = CGSize(width: CGFloat(maxWidth), height: CGFloat(maxHeight))
           imgGenerator.requestedTimeToleranceBefore = .zero
           imgGenerator.requestedTimeToleranceAfter = CMTime(value: 100, timescale: 1000)

           var error: NSError?
           let cgImage = try? imgGenerator.copyCGImage(at: CMTime(value: Int64(timeMs), timescale: 1000), actualTime: nil)

           if let cgImage = cgImage {
               let thumbnail = UIImage(cgImage: cgImage)

               switch format {
               case .JPEG:
                   let fQuality = CGFloat(quality) * 0.01
                   return thumbnail.jpegData(compressionQuality: fQuality)
               case .PNG:
                   return thumbnail.pngData()
               }
           } else if let error = error {
               print("couldn't generate thumbnail, error: \(error)")
           }
            // imgGenerator = nil
            // asset = nil
           return nil
       }
}

