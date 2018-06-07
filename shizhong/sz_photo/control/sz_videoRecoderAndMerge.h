//
//  sz_videoRecoderAndMerge.h
//  shizhong
//
//  Created by sundaoran on 15/11/25.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "videoProgressBar.h"

@class sz_videoRecoderAndMerge;
@protocol sz_videoRecoderAndMergeDelegate <NSObject>

@optional
//recorder开始录制一段视频时
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

//recorder完成一段视频的录制时
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder正在录制的过程中
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur;

//recorder删除了某一段视频
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder完成视频的合成
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL ;

//recorder结束录制
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorderdidFinishRecord;


//录制达到最大长度自动结束
- (void)sz_videoRecorderMoreThanLength;

@end

@interface sz_videoRecoderAndMerge : NSObject<AVCaptureFileOutputRecordingDelegate>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

@property (strong,nonatomic)  UIView *viewContainer;//视频容器
@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标

@property(nonatomic,strong)NSMutableArray   *videoDataArray;

@property(nonatomic)CGFloat      progressSecond;

@property(nonatomic,weak)__weak id<sz_videoRecoderAndMergeDelegate>delegate;

@property (assign, nonatomic) BOOL isFrontCameraSupported;
@property (assign, nonatomic) BOOL isCameraSupported;
@property (assign, nonatomic) BOOL isTorchSupported;
@property (assign, nonatomic) BOOL isTorchOn;
@property (assign, nonatomic) BOOL isUsingFrontCamera;
@property (assign, nonatomic) BOOL isRecording;


-(void)startRecording;
-(void)stopRecoding;
-(void)stopRecoding:(NSString *)audioPath;
-(void)pauseRecording;


- (BOOL)deleteLastVideo;//调用delegate
- (void)deleteAllVideo;//不调用delegate

- (NSUInteger)getVideoCount;

- (BOOL)isCameraSupported;
- (BOOL)isFrontCameraSupported;
- (BOOL)isTorchSupported;

- (void)switchCamera;
- (void)openTorch:(BOOL)open;


-(void)videoOrPicRecordStop;

-(void)videoOrPicRecordRestart;

-(void)mergeVideo:(NSString *)audioPath;

@end
