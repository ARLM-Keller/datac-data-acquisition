// -*- Mode: ObjC -*-
//
// Copyright (C) 2011, Brad Howes. All rights reserved.
//

#import <iterator>
#import <sstream>

#import "LowPassFilter.h"

@interface LowPassFilter (Private)

- (void)loadFile:(NSString *)path;

@end

@implementation LowPassFilter

@synthesize fileName;

- (void)setFileName:(NSString *)theFileName
{
    B.clear();
    Z.clear();
	
    fileName = [theFileName retain];

    //
    // Locate the file to read. First, look in the user directory.
    //
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"Filters",
                                                                                          @"Filters directory")];
    NSFileManager* fileManager = [[[NSFileManager alloc] init] autorelease];
    if ([fileManager fileExistsAtPath:path] == NO) {
        NSError* err = nil;
        if ([fileManager createDirectoryAtPath:path 
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&err] == NO) {
            NSLog(@"LowPassFilter.setFileName: failed to create Filters directory - %@", err);
            path = [path stringByDeletingLastPathComponent];
        }
    }

    path = [path stringByAppendingPathComponent:fileName];
    path = [path stringByAppendingPathExtension:@"txt"];
    if ([fileManager fileExistsAtPath:path] == YES) {
        [self loadFile:path];
        return;
    }

    //
    // Attempt to locate the file in the application bundle.
    //
    NSBundle* bundle = [NSBundle mainBundle];
    path = [bundle pathForResource:fileName ofType:@"txt"];
    if (path != nil) {
        [self loadFile:path];
        return;
    }
    
    NSLog(@"did not find resource file '%@.txt'", fileName);
    return;
}

+ (id)createFromFile:(NSString *)fileName
{
    return [[[LowPassFilter alloc] initFromFile: fileName] autorelease];
}

+ (id)createFromArray:(NSArray *)array
{
    return [[[LowPassFilter alloc] initFromArray:array] autorelease];
}

- (id)initFromFile:(NSString*)theFileName
{
    self = [super init];
    if (self == nil) return self;
    self.fileName = theFileName;
    return self;
}

- (id)initFromArray:(NSArray*)taps
{
    self = [super init];
    if (self == nil) return self;
    if (taps == nil) {
        @throw [NSException exceptionWithName:@"NullTaps" reason:@"" userInfo:nil];
    }
    
    for (NSNumber* obj in taps) {
        B.push_back([obj floatValue]);
	Z.push_back(0.0);
    }

    return self;
}

- (void)dealloc
{
    B.clear();
    Z.clear();
    [super dealloc];
}

- (void)reset
{
    for (UInt32 index = 0; index < Z.size(); ++index)
	Z[index] = 0.0;
}

- (Float32)filter:(Float32)x
{
    if (Z.size() == 0) return x;

    Float32 y = B[0] * x + Z[0];

    //
    // Update difference equation weights.
    //
    UInt32 tapIndex = 1;
    for (; tapIndex < Z.size(); ++tapIndex) {
	Z[tapIndex - 1] = B[tapIndex] * x + Z[tapIndex];
    }

    return y;
}

- (NSUInteger)size
{
    return Z.size();
}

- (NSString*)description
{
    std::ostringstream os;
    std::copy(Z.begin(), Z.end(), std::ostream_iterator<Float32>(os, ", "));
    std::string s(os.str());
    return [NSString stringWithCString:s.c_str() encoding:[NSString defaultCStringEncoding]];
}

@end

@implementation LowPassFilter (Private)

- (void)loadFile:(NSString*)path
{
    NSLog(@"LowPassFilter.loadFile: loading file '%@'", path);

    //
    // Read the contents of the file. The format should be one tap weight per line.
    //
    NSError* error;
    NSString* contents = [NSString stringWithContentsOfFile:path encoding:NSUnicodeStringEncoding error: &error];
    if (contents == nil) {
	NSLog(@"failed to read contents of file '%@'", path);
	return;
    }
    
    //
    // Create a scanner to convert the text values into floating-point numbers.
    //
    NSScanner* scanner = [NSScanner scannerWithString:contents];
    NSDecimal tap;
    NSMutableArray* taps = [NSMutableArray arrayWithCapacity:32];
    while ([scanner scanDecimal:&tap]) {
	[taps addObject:[NSDecimalNumber decimalNumberWithDecimal:tap]];
    }
    
    NSLog(@"num taps: %d", [taps count]);
    
    for (NSDecimalNumber* obj in taps) {
	B.push_back([obj floatValue]);
	NSLog(@"B[%d]: %f", B.size()-1, B.back());
	Z.push_back(0.0);
    }
}

@end