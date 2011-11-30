//
//  AirplanePosition.m
//  ATCSimulation
//
//  Created by Ludovic Delaveau on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATCPosition.h"

@implementation ATCPosition

- (id)initWithZone:(NSInteger)currentZone andPoint:(ATCPoint *)airplaneCoordinates {
    
    self = [super init];
    
    if (self) {
        self.zone = currentZone;
        self.coordinates = airplaneCoordinates;
    }
    
    return self;
}

@synthesize zone = _zone;
@synthesize coordinates = _coordinates;
@synthesize speed = _speed;
@synthesize course = _course;

- (void)dealloc {
    self.coordinates = nil;
    
    [super dealloc];
}

# pragma mark - Class methods

+ (ATCPosition *)positionFromExisting:(ATCPosition *)position {
    ATCPoint *newPoint = [ATCPoint pointFromExisting:position.coordinates];
    
    ATCPosition *newPosition = [[ATCPosition alloc] initWithZone:position.zone
                                                        andPoint:newPoint];
    newPosition.course = position.course;
    newPosition.speed = position.speed;
    
    return [newPosition autorelease];
}

@end