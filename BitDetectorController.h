// -*- Mode: ObjC -*-
//
// Copyright (C) 2011, Brad Howes. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DetectorController.h"

@class BitDetector;

@interface BitDetectorController : DetectorController {
@private
    BitDetector* bitDetector;
    CGFloat gestureStart;
    int gestureType;
}

+ (id)createWithBitDetector:(BitDetector*)bitDetector;

- (id)initWithBitDetector:(BitDetector*)bitDetector;

@end
