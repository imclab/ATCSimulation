//
//  Zone.m
//  ATCSimulation
//
//  Created by Ludovic Delaveau on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATCZone.h"

@interface ATCZone ()

@property (nonatomic, retain) NSMutableSet *adjacentZones;
@property (nonatomic, retain) NSArray *corners;
@property (nonatomic, retain) NSMutableArray *borders;

@end

@implementation ATCZone

- (id)initWithCorners:(NSArray *)cornersArray withControllerName:(NSString *)controllerName andIsAirport:(BOOL)airport {
    self = [super init];
    
    if (self) {
        _controllerName = controllerName;
        _airport = airport;
        
        _corners = cornersArray;
        // process the corners to add the necessary border segments
        
        int numberOfCorners = [cornersArray count];
        _borders = [NSMutableArray arrayWithCapacity:numberOfCorners];
        int i, deltaX, deltaY;
        BOOL positive = YES;
        
        for (i = 0; i < numberOfCorners - 1; i++) {
            ATCPoint *extremity1 = [cornersArray objectAtIndex:i];
            ATCPoint *extremity2 = [cornersArray objectAtIndex:(i + 1)];
            
            // calculates the deltas of x and y
            deltaX = extremity2.X - extremity1.X;
            deltaY = extremity2.Y - extremity1.Y;
            
            if (deltaX > 0) {
                if (deltaY >= 0) {
                    positive = YES;
                } else {
                    positive = NO;
                }
            } else if (deltaX < 0) {
                if (deltaY >= 0) {
                    positive = NO;
                } else {
                    positive = YES;
                }
            } else if (deltaX == 0) {
                if (deltaY > 0) {
                    positive = NO;
                } else if (deltaY < 0) {
                    positive = YES;
                } else {
                    // shouldn't happen, it means the two extremities are the same point
                    continue;
                }
            }
            
            [self.borders addObject:[[ATCZoneBorderSegment alloc] initWithExtremity1:extremity1 andExtremity2:extremity2 withDirectionPositive:positive]];
        }
        // adds the last line to close the path
        ATCPoint *extremity1 = [cornersArray objectAtIndex:i];
        ATCPoint *extremity2 = [cornersArray objectAtIndex:(i + 1)];
        
        // calculates the deltas of x and y
        deltaX = extremity2.X - extremity1.X;
        deltaY = extremity2.Y - extremity1.Y;
        
        if (deltaX > 0) {
            if (deltaY >= 0) {
                positive = YES;
            } else {
                positive = NO;
            }
        } else if (deltaX < 0) {
            if (deltaY >= 0) {
                positive = NO;
            } else {
                positive = YES;
            }
        } else if (deltaX == 0) {
            if (deltaY > 0) {
                positive = NO;
            } else if (deltaY < 0) {
                positive = YES;
            } else {
                // shouldn't happen, it means the two extremities are the same point
                return self;
            }
        }
        
        [self.borders addObject:[[ATCZoneBorderSegment alloc] initWithExtremity1:extremity1 andExtremity2:extremity2 withDirectionPositive:positive]];
    }

    return self;
}

@synthesize adjacentZones = _adjacentZones;
@synthesize corners = _corners;
@synthesize borders = _borders;
@synthesize airport = _airport;
@synthesize controllerName = _controllerName;

- (void)addAdjacentZone:(ATCZone *)zone {
    [self.adjacentZones addObject:zone];
}

- (float)calculateDistanceToZoneBorderWithPosition:(ATCAirplaneInformation *)position {
    
    float distance = MAXFLOAT;
    
    // tests all segments composing the borders to have the nearest intersection
    for (ATCZoneBorderSegment *segment in self.borders) {
        float currentDistance = [segment calculateDistanceToSegment:position];
        if (currentDistance < distance) {
            // new minimum
            distance = currentDistance;
        }
    }
    
    return distance;
}

- (BOOL)pointBelongsToZone:(ATCPoint *)point {
    for (ATCZoneBorderSegment *segment in self.borders) {
        // the point has to belong to every half-space generated by the borders
        if (![segment pointBelongsToGeneratedHalfSpace:point]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)dealloc {
    self.borders = nil;
    self.adjacentZones = nil;

    [super dealloc];
}

@end
