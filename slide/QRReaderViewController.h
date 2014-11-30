//
//  RootViewController.h
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRReaderViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate> {
    AVMetadataMachineReadableCodeObject *metadataObj;
}

@property (weak, nonatomic) IBOutlet UIView *scanPreview;
@property (nonatomic, strong) NSDictionary *form;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property BOOL stoppedCapture;

- (void)startReading;
- (void)stopReading;
- (IBAction)dismiss;

@end
