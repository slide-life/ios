//
//  RootViewController.m
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "QRReaderViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "FormTableViewController.h"
#import "API.h"
#import "RequestsViewController.h"

@implementation QRReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startReading];
}

#pragma mark - QRCode reader

- (void)startReading {
    NSError *error;
    _stoppedCapture = NO;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:input];
        
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:captureMetadataOutput];
        
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:_scanPreview.layer.bounds];
        [_scanPreview.layer addSublayer:_videoPreviewLayer];
        
        [_captureSession startRunning];
    }
}

- (void)showForm {
    NSLog(@"form: %@", _form);
    RequestsViewController *rvc = (RequestsViewController *)self.delegate;
    [rvc addRequest:@{@"data": _form[@"blocks"], @"bucket": _form[@"id"], @"key": _form[@"key"]}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)queryBackend {
     [[API sharedInstance] getChannel:[metadataObj stringValue] onSuccess:^(id responseObject) {
        _form = (NSDictionary *)responseObject;
        [self showForm];
     } onFailure:^(NSError *error) {
         NSLog(@"Error: %@", error.description);
     }];
}

- (void)stopReading  {
    [_captureSession stopRunning];
    self.navigationController.navigationBar.hidden = NO;
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
    
    [self queryBackend];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] && !_stoppedCapture) {
            [self performSelectorOnMainThread:@selector(stopReading) withObject:metadataObj waitUntilDone:NO];
            _stoppedCapture = YES;
            
            return;
        }
    }
}

@end
