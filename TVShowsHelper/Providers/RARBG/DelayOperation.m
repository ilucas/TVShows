/*
 *  This file is part of the TVShows source code.
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */


#import "DelayOperation.h"

@import libextobjc;

@interface DelayOperation ()
@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite) NSTimeInterval delay;
@end

@implementation DelayOperation
@synthesize executing, finished;

- (void)main {
    NSOperationQueue *operationQueue = [NSOperationQueue currentQueue];
    dispatch_queue_t queue = operationQueue.underlyingQueue;
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delay * NSEC_PER_SEC));
    
    @weakify(self);
    dispatch_after(delayTime, queue, ^{
        @strongify(self);
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = NO;
        self.finished  = YES;
        
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    });
}

#pragma mark - Init

- (instancetype)initWithDelay:(NSTimeInterval)delay {
    self = [super init];
    
    if (self) {
        self.delay = delay;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.delay = 1.5;
    }
    
    return self;
}

@end
