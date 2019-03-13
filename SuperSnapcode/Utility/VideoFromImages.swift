import AVKit

class VideoFromImages {
    
    let images: [UIImage]
    let framesPerSecond: Int
    
    init(images: [UIImage], framesPerSecond: Int){
        self.images = images
        self.framesPerSecond = framesPerSecond
    }
    
    func writeMovieToURL(url: URL, completion: @escaping (Bool) -> ()) {

        if images.count < 1 { completion(false); return }
        
        guard let assetWriter = try? AVAssetWriter(url: url, fileType: .mov) else { completion(false); return }
        
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: ["AVVideoCodecKey": AVVideoCodecType.h264,
                                                                                "AVVideoWidthKey": Int(images[0].size.width),
                                                                                "AVVideoHeightKey": Int(images[0].size.height)])
        
        
        // Create metadata item
        let metadataItem = AVMutableMetadataItem()
        metadataItem.key = "com.apple.quicktime.content.identifier" as (NSCopying & NSObjectProtocol)?
        metadataItem.keySpace = .quickTimeMetadata
        metadataItem.value = UUID().uuidString as (NSCopying & NSObjectProtocol)?
        metadataItem.dataType = "com.apple.metadata.datatype.UTF-8"
        assetWriter.metadata = [metadataItem]
        
        guard assetWriter.canAdd(writerInput) else { completion(false); return }
        assetWriter.add(writerInput)
        
        let bufferAttributes = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
        let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: bufferAttributes)
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        let mediaInputQueue = DispatchQueue(label: "MediaInputQueue")
        
        writerInput.requestMediaDataWhenReady(on: mediaInputQueue) {
            
            for i in 0 ..< self.images.count {
                if writerInput.isReadyForMoreMediaData {
                    
                    var sampleBuffer: CVPixelBuffer?
                    
                    // Create autorelease pool to drain sample buffer after each run
                    autoreleasepool(invoking: {
                        sampleBuffer = self.images[i].pixelBuffer()
                    })
                    
                    if let sampleBuffer = sampleBuffer {
                        
                        // Write the current sample buffer as a frame in the video
                        if i == 0 {
                            bufferAdapter.append(sampleBuffer, withPresentationTime: CMTime.zero)
                        }
                        else {
                            let frameTime = CMTimeMake(value: 1, timescale: Int32(self.framesPerSecond))
                            let lastTime = CMTimeMake(value: Int64(i - 1), timescale: frameTime.timescale)
                            let presentTime = CMTimeAdd(lastTime, frameTime)
                            
                            bufferAdapter.append(sampleBuffer, withPresentationTime: presentTime)
                        }
                    }
                }
            }
            
            writerInput.markAsFinished()
            assetWriter.finishWriting {
                DispatchQueue.main.async {
                    
                    if let error = assetWriter.error {
                        print(error.localizedDescription)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
}



