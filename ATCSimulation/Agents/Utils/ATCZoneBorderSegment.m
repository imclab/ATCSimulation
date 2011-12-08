//
//  ATCZoneBorder.m
//  ATCSimulation
//
//  Created by Ludovic Delaveau on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATCZoneBorderSegment.h"

@interface ATCZoneBorderSegment ()

@property (nonatomic, retain) ATCPoint *extremity1;
@property (nonatomic, retain) ATCPoint *extremity2;
@property (nonatomic, assign) float a;
@property (nonatomic, assign) float b;
@property (nonatomic, assign) float c;
@property (nonatomic, assign) BOOL directionPositive;
@property (nonatomic, assign) float orthA;
@property (nonatomic, assign) float orthB;
@property (nonatomic, assign) float orth1C;
@property (nonatomic, assign) float orth2C;

- (BOOL)testPoint:(ATCPoint *)testedPoint IsInHalfSpaceOfLineWithCoefficientsA:(float )a B:(float )b C:(float )c andInequalityPositive:(BOOL)positive;

@end

@implementation ATCZoneBorderSegment

- (id)initWithExtremity1:(ATCPoint *)extremity1 andExtremity2:(ATCPoint *)extremity2 withDirectionPositive:(BOOL)positive {
    self = [super init];
    
    if (self) {
        self.directionPositive = positive;
        
        self.extremity1 = extremity1;
        self.extremity2 = extremity2;
        
        self.a = self.extremity2.Y - self.extremity1.Y;
        self.b = self.extremity1.X - self.extremity2.X;
        self.c = - self.b * self.extremity1.Y - self.a * self.extremity1.X;
        
        self.orthA = self.b;
        self.orthB = - self.a;
        self.orth1C = - self.orthB * self.extremity1.Y - self.orthA * self.extremity1.X;
        self.orth2C = - self.orthB * self.extremity2.Y - self.orthA * self.extremity2.X;
    }
    
    return self;
}

@synthesize extremity1 = _extremity1;
@synthesize extremity2 = _extremity2;

@synthesize a = _a;
@synthesize b = _b;
@synthesize c = _c;
@synthesize directionPositive = _directionPositive;

@synthesize orthA = _orthA;
@synthesize orthB = _orthB;
@synthesize orth1C = _orth1C;
@synthesize orth2C = _orth2C;

# pragma mark - Segment and point methods

- (float)calculateDistanceToSegment:(ATCAirplaneInformation *)testedPosition {
    float distance = MAXFLOAT;
    
    // first verifies if the point is inside the space generated by the segment in the direction
    BOOL line = [self testPoint:testedPosition.coordinates IsInHalfSpaceOfLineWithCoefficientsA:self.a B:self.b C:self.c andInequalityPositive:self.directionPositive];
    
    if (line) {
        // ok the point belongs to our zone segment, let's calculate the distance
        float cosCourse = cosf(testedPosition.course * 2 * M_PI / 360.0);
        float sinCourse = sinf(testedPosition.course * 2 * M_PI / 360.0);
        
        float generatedLineYIntersect = sinCourse * testedPosition.coordinates.Y + cosCourse * testedPosition.coordinates.X;
        
        float intersectionY = (generatedLineYIntersect + cosCourse) / (self.a * sinCourse - self.b * cosCourse);
        float intersectionX = - (sinCourse * intersectionY - generatedLineYIntersect) / cosCourse;
        
        if (intersectionX >= self.extremity1.X && intersectionX <= self.extremity2.X && intersectionY >= self.extremity1.Y  && intersectionY <= self.extremity2.Y) {
            // intersection is inside the segment, ok
            return sqrtf(powf(testedPosition.coordinates.X - intersectionX, 2) + powf(testedPosition.coordinates.Y - intersectionY, 2));
        }
    }
    
    return distance;
}

# pragma mark Point inside segment half-space related methods

- (BOOL)pointBelongsToGeneratedHalfSpace:(ATCPoint *)testedPoint {
    BOOL insideSegment = [self checkIfProjectionIsInsideSegmentWithPoint:testedPoint];
    if (insideSegment) {
        // tests if on the right side
        return [self testPoint:testedPoint IsInHalfSpaceOfLineWithCoefficientsA:self.a B:self.b C:self.c andInequalityPositive:self.directionPositive];
    }
    return NO;
}

- (BOOL)testPoint:(ATCPoint *)testedPoint IsInHalfSpaceOfLineWithCoefficientsA:(float )a B:(float )b C:(float )c andInequalityPositive:(BOOL)positive {
    float inequationResult = a * testedPoint.X + b * testedPoint.Y + c;
    
    if (positive) {
        if (b > 0) {
            return inequationResult >= 0;
        } else if (b < 0) {
            return inequationResult <= 0;
        } else {
            if (a > 0) {
                return inequationResult >= 0;
            } else {
                return inequationResult <= 0;
            }
        }
    } else {
        if (b > 0) {
            return inequationResult <= 0;
        } else if (b < 0) {
            return inequationResult >= 0;
        } else {
            if (a > 0) {
                return inequationResult <= 0;
            } else {
                return inequationResult >= 0;
            }
        }

        
    }
}

- (BOOL)checkIfProjectionIsInsideSegmentWithPoint:(ATCPoint *)testedPoint {
    ATCPoint *intersectionPoint = [self calculateLinesIntersectionWithPoint:testedPoint];
    float deltaSegmentX = self.extremity2.X - self.extremity1.X;
    float deltaX = self.extremity2.X - intersectionPoint.X;
    
    if (!(deltaSegmentX >= 0 && deltaX >= 0) && !(deltaSegmentX <= 0 && deltaX <= 0)) {
        // if the two vectors are not in the same direction
        return FALSE;
    }
    
    float deltaSegmentY = self.extremity2.Y - self.extremity1.Y;
    float deltaY = self.extremity2.Y - intersectionPoint.Y;

    if (!(deltaSegmentY >= 0 && deltaY >= 0) && !(deltaSegmentY <= 0 && deltaY <= 0)) {
        // if the two vectors are not in the same direction
        return FALSE;
    }
    
    deltaSegmentX = deltaSegmentX > 0 ? deltaSegmentX : - deltaSegmentX;
    deltaX = deltaX >= 0 ? deltaX : - deltaX;
    
    deltaSegmentY = deltaSegmentY > 0 ? deltaSegmentY : - deltaSegmentY;
    deltaY = deltaY >= 0 ? deltaY : - deltaY;
    
    return deltaX <= deltaSegmentX && deltaY <= deltaSegmentY;
}

- (ATCPoint *)calculateLinesIntersectionWithPoint:(ATCPoint *)testedPoint {
    // finishes the calculation of the line orthogonal to the segment and going through testedPoint
    float cOrthogonalLine = - self.orthB * testedPoint.Y - self.orthA * testedPoint.X;
    
    float x, y;
    
    // calculates the point of intersection between the line and the segment
    if (self.a == 0) {
        x = - cOrthogonalLine / self.b;
        y = - self.c / self.b;
    } else if (self.b == 0) {
        x = - self.c / self.a;
        y = cOrthogonalLine / self.a;
    } else {
        x = (- self.a * self.c - self.b * cOrthogonalLine) / ((self.a * self.a + self.b * self.b));
        y = (self.a * (self.a * self.c + self.b * cOrthogonalLine) - self.c * (self.b * self.b + self.a * self.a)) / ((self.b * self.b + self.a * self.a) * self.b);
    }
    
    return [[[ATCPoint alloc] initWithCoordinateX:x andCoordinateY:y] autorelease];
}

- (void)dealloc {
    self.extremity1 = nil;
    self.extremity2 = nil;
    
    [super dealloc];
}

@end
