NSString *videoOutputPath = [[self.videoUrl absoluteString] stringByDeletingLastPathComponent];
videoOutputPath = [videoOutputPath stringByAppendingPathComponent:@"testCompressVideo.mp4"];
AVAsset *video = [AVAsset assetWithURL:self.videoUrl];
AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPresetMediumQuality];
exportSession.shouldOptimizeForNetworkUse = YES;
exportSession.outputFileType = AVFileTypeMPEG4;
exportSession.outputURL = [NSURL URLWithString:videoOutputPath];

//trim video
CMTime start = CMTimeMakeWithSeconds(5, video.duration.timescale);
CMTime duration = CMTimeMakeWithSeconds(10, video.duration.timescale);
exportSession.timeRange = CMTimeRangeMake(start, duration);

[exportSession exportAsynchronouslyWithCompletionHandler:^{
    NSLog(@"done processing video!");
}];
