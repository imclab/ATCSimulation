//
//  Airplane.m
//  ATCSimulation
//
//  Created by Ludovic Delaveau on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Airplane.h"

@interface Airplane ()

@property (nonatomic, retain) ATCPosition *currentPosition;
@property (nonatomic, assign) NSInteger speed;
@property (nonatomic, assign) NSInteger course;
@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSString *currentController;
@property (nonatomic, retain) NSDate *lastPositionCheck;

- (void)updatePosition;

- (void)sendCurrentPosition;
- (void)changeZoneWithNewController:(NSString *)controllerName;

@end

@implementation Airplane

- (id)initWithTailNumber:(NSString *)tailNumber initialPosition:(ATCPosition *)airplanePosition andDestination:(NSString *)destinationName {
    self = [super initWithAgentName:tailNumber];
    
    if (self) {
        self.currentPosition = airplanePosition;
        
        // registers for the broadcast messages in the zone
    }
    
    return self;
}

@synthesize currentPosition = _currentPosition;
@synthesize course = _course;

- (void)setCourse:(NSInteger)course {
    // updates the current position each time a change is made in the route
    [self updatePosition];
    
    _course = course;
}

@synthesize speed = _speed;

- (void)setSpeed:(NSInteger)speed {
    // updates the current position each time a change is made in the route
    [self updatePosition];
    
    _speed = speed;
}

@synthesize destination = _destination;
@synthesize currentController = _currentController;
@synthesize lastPositionCheck = _lastPositionCheck;

- (void)dealloc {
    self.currentPosition = nil;
    self.destination = nil;
    
    [super dealloc];
}

- (void)updatePosition {
    // calculates current position since last check, and updates the attribute
    NSTimeInterval lastCheckInterval = [self.lastPositionCheck timeIntervalSinceNow];
    float distance = lastCheckInterval * self.speed / 3600;
    
    self.currentPosition.positionX = [NSNumber numberWithFloat:(distance * cos(self.course * M_2_PI / 360))];
    self.currentPosition.positionY = [NSNumber numberWithFloat:(distance * sin(self.course * M_2_PI / 360))];
    
    // updates the timestamp since last check
    self.lastPositionCheck = [NSDate date];
    
    // verifies if we changed zone
    NSInteger newZone = [Artifacts calculateCurrentZonefromX:self.currentPosition.positionX andY:self.currentPosition.positionY];
    
    if (newZone != self.currentPosition.zone) {
        // aha, we are leaving a zone
        
        // unregisters from the previous' zone messages, and registers for the new zone
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"Zone %d", self.currentPosition.zone] object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:[NSString stringWithFormat:@"Zone %d", newZone] object:nil];
        
        // calls the current zone controller to inform we are leaving his control, and would like the
        // new controller's name for the next zone
    }
    
    // sets a timer calling back this method to verify if we changed zone, based on the current
    // route and speed
}

# pragma mark - Messages

- (void)analyzeMessage:(NSDictionary *)messageContent {
    // depending on the type of the message, activates the corresponding method
}

- (void)changeZoneWithNewController:(NSString *)controllerName {
    // updates the controller we have to contact
    self.currentController = controllerName;
    
    // calls new controller, to transmit destination, position, course, and speed
    NSString *message = [NSString stringWithFormat:@"%@;%f;%f;%d;%d", self.destination, self.currentPosition.positionX, self.currentPosition.positionY, self.course, self.speed];
    
    [self sendMessage:message fromType:NVMessageEnteringNewZone toAgent:self.currentController];
}

- (void)sendCurrentPosition {
    // checks where the airplane is, to send actual value
    [self updatePosition];
    
    // creates the message as a string
    NSString *message = [NSString stringWithFormat:@"%f;%f", self.currentPosition.positionX, self.currentPosition.positionY];
    
    [self sendMessage:message fromType:NVMessageCurrentPosition toAgent:self.currentController];
}

@end
