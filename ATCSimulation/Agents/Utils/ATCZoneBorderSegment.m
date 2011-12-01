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
@property (nonatomic, assign) float aLine;
@property (nonatomic, assign) float bLine;
@property (nonatomic, assign) float cLine;
@property (nonatomic, assign) BOOL directionPositive;
@property (nonatomic, assign) float aOrthogonalLine1;
@property (nonatomic, assign) float bOrthogonalLine1;
@property (nonatomic, assign) float cOrthogonalLine1;
@property (nonatomic, assign) float aOrthogonalLine2;
@property (nonatomic, assign) float bOrthogonalLine2;
@property (nonatomic, assign) float cOrthogonalLine2;

- (BOOL)testHalfSpaceWithInequationCoefficientsA:(float)a andB:(float)b andC:(float)c andInequalityPositive:(BOOL)positive atPoint:(ATCPoint *)testedPoint;

@end

@implementation ATCZoneBorderSegment

- (id)initWithExtremity1:(ATCPoint *)extremity1 andExtremity2:(ATCPoint *)extremity2 withDirectionPositive:(BOOL)positive {
    self = [super init];
    
    if (self) {
        self.directionPositive = positive;
        
        self.extremity1 = extremity1;
        self.extremity2 = extremity2;
        
        self.aLine = self.extremity2.coordinateY - self.extremity1.coordinateY;
        self.bLine = self.extremity1.coordinateX - self.extremity2.coordinateX;
        self.cLine = - self.bLine * self.extremity1.coordinateY - self.aLine * self.extremity1.coordinateX;
        
        self.aOrthogonalLine1 = - self.bLine;
        self.bOrthogonalLine1 = self.aLine;
        self.cOrthogonalLine1 = - self.bOrthogonalLine1 * self.extremity1.coordinateY - self.aOrthogonalLine1 * self.extremity1.coordinateX;
        
        self.aOrthogonalLine2 = - self.bLine;
        self.bOrthogonalLine2 = self.aLine;
        self.cOrthogonalLine2 = - self.bOrthogonalLine2 * self.extremity2.coordinateY - self.aOrthogonalLine2 * self.extremity2.coordinateX;
    }
    
    return self;
}

@synthesize extremity1 = _extremity1;
@synthesize extremity2 = _extremity2;

@synthesize aLine = _aLine;
@synthesize bLine = _bLine;
@synthesize cLine = _cLine;
@synthesize directionPositive = _directionPositive;

@synthesize aOrthogonalLine1 = _aOrthogonalLine1;
@synthesize bOrthogonalLine1 = _bOrthogonalLine1;
@synthesize cOrthogonalLine1 = _cOrthogonalLine1;

@synthesize aOrthogonalLine2 = _aOrthogonalLine2;
@synthesize bOrthogonalLine2 = _bOrthogonalLine2;
@synthesize cOrthogonalLine2 = _cOrthogonalLine2;

- (BOOL)pointBelongsToGeneratedHalfSpace:(ATCPoint *)testedPoint {
    return [self testHalfSpaceWithInequationCoefficientsA:self.aLine andB:self.bLine andC:self.cLine andInequalityPositive:self.directionPositive atPoint:testedPoint];
}

- (float)calculateDistanceToSegment:(ATCAirplaneInformation *)testedPosition {
    float distance = MAXFLOAT;
    
    // first verifies if the point is inside the space generated by the segment in the direction
    BOOL line = [self testHalfSpaceWithInequationCoefficientsA:self.aLine andB:self.bLine andC:self.cLine andInequalityPositive:!self.directionPositive atPoint:testedPosition.coordinates];
    
    if (line) {
        // ok the point belongs to our zone segment, let's calculate the distance
        float cosCourse = cosf(testedPosition.course * 2 * M_PI / 360.0);
        float sinCourse = sinf(testedPosition.course * 2 * M_PI / 360.0);
        
        float generatedLineYIntersect = sinCourse * testedPosition.coordinates.coordinateY + cosCourse * testedPosition.coordinates.coordinateX;
        
        float intersectionY = (generatedLineYIntersect + cosCourse) / (self.aLine * sinCourse - self.bLine * cosCourse);
        float intersectionX = - (sinCourse * intersectionY - generatedLineYIntersect) / cosCourse;
        
        if (intersectionX >= self.extremity1.coordinateX && intersectionX <= self.extremity2.coordinateX && intersectionY >= self.extremity1.coordinateY  && intersectionY <= self.extremity2.coordinateY) {
            // intersection is inside the segment, ok
            return sqrtf(powf(testedPosition.coordinates.coordinateX - intersectionX, 2) + powf(testedPosition.coordinates.coordinateY - intersectionY, 2));
        }
    }
    
    return distance;
}

- (BOOL)testHalfSpaceWithInequationCoefficientsA:(float )a andB:(float )b andC:(float )c andInequalityPositive:(BOOL)positive atPoint:(ATCPoint *)testedPoint {
    float inequationResult = a * testedPoint.coordinateX + b * testedPoint.coordinateY + c;
    
    if (positive) {
        return inequationResult >= 0;
    } else {
        return inequationResult <= 0;
    }
}

- (void)dealloc {
    self.extremity1 = nil;
    self.extremity2 = nil;
    
    [super dealloc];
}

@end
