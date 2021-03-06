// -*- Mode: ObjC -*-
//
// Copyright (C) 2011, Brad Howes. All rights reserved.
//

#import "BitDetector.h"
#import "BitFrameDecoder.h"
#import "BitStreamFrameDetector.h"
#import "HiLowSignalProcessor.h"
#import "HiLowSignalProcessorController.h"
#import "UserSettings.h"

@implementation HiLowSignalProcessor

@synthesize bitDetector, bitFrameDecoder, bitStreamFrameDetector, maxLowLevel, minHighLevel;

+ (HiLowSignalProcessor*)create
{
    return [[[HiLowSignalProcessor alloc] init] autorelease];
}

- (id)init
{
    if (self = [super init]) {
        bitDetector = [[BitDetector create] retain];
        bitFrameDecoder = [[BitFrameDecoder create] retain];
        bitStreamFrameDetector = [[BitStreamFrameDetector create] retain];
        bitDetector.observer = bitStreamFrameDetector;
        bitStreamFrameDetector.observer = bitFrameDecoder;
        bitFrameDecoder.observer = self;
        controller = nil;
        frequency = 0.0;
    }
    
    return self;
}

- (void)dealloc
{
    [controller release];
    [super dealloc];
}

- (void)setMaxLowLevel:(Float32)value
{
    bitDetector.maxLowLevel = value;
}

- (Float32)maxLowLevel
{
    return bitDetector.maxLowLevel;
}

- (void)setMinHighLevel:(Float32)value
{
    bitDetector.minHighLevel = value;
}

- (Float32)minHighLevel
{
    return bitDetector.minHighLevel;
}

- (void)reset
{
    [bitDetector reset];
    [bitStreamFrameDetector reset];
    frequency = 0.0;
}

- (void)updateFromSettings
{
    [bitDetector updateFromSettings];
    [bitStreamFrameDetector updateFromSettings];
}

- (SignalProcessorController*)controller
{
    if (controller == nil) {
        controller = [[HiLowSignalProcessorController createWithDetector:self] retain];
    }
    
    return controller;
}

- (NSObject<SampleProcessorProtocol>*)sampleProcessor
{
    return bitDetector;
}

- (void)frameButtonState:(NSInteger)buttonState frequency:(NSInteger)theFrequency
{
    frequency = theFrequency;
}

- (Float32)lastDetectionValue
{
    return frequency;
}

@end
