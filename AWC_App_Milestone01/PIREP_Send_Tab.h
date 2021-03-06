//
//  AWCSecondViewController.h
//  AWC_App_Milestone01
//
//  Created by SATISH KUMAR BASWAPURAM on 9/29/13.
//  Edited by Syed Mazhar Hussani
//  Copyright (c) 2013 Satish Kumar Baswapuram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "FlightInfo.h"
#import "AppDelegate.h"
#import "PIREP_View_Tab.h"//edit2014

@interface PIREP_Send_Tab : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, UIAlertViewDelegate>

// Display the title for Pirep Send
@property (weak, nonatomic) IBOutlet UIButton *titleInfo;

// Buttons for CHOP
//@property (strong, nonatomic) IBOutlet UIButton *chop;
@property (strong, nonatomic) IBOutlet UIButton *lightChop;
@property (strong, nonatomic) IBOutlet UIButton *modChop;
@property (strong, nonatomic) IBOutlet UIButton *greaterChop;
@property (weak, nonatomic) IBOutlet UIButton *noChop;

//edit2014
// Buttons for Dual Levels
@property (strong, nonatomic) IBOutlet UIButton *chopLM;//edit2014
@property (strong, nonatomic) IBOutlet UIButton *chopMS;
@property (strong, nonatomic) IBOutlet UIButton *turbLM;
@property (strong, nonatomic) IBOutlet UIButton *turbMS;
@property (strong, nonatomic) IBOutlet UIButton *mtnLM;
@property (strong, nonatomic) IBOutlet UIButton *mtnMS;
@property (strong, nonatomic) IBOutlet UIButton *iceTL;
@property (strong, nonatomic) IBOutlet UIButton *iceLM;
@property (strong, nonatomic) IBOutlet UIButton *iceMS;


// Buttons for TURB
//@property (strong, nonatomic) IBOutlet UIButton *turb;
@property (strong, nonatomic) IBOutlet UIButton *lightTurb;
@property (strong, nonatomic) IBOutlet UIButton *modTurb;
@property (strong, nonatomic) IBOutlet UIButton *greaterTurb;
@property (weak, nonatomic) IBOutlet UIButton *noTurb;

// Buttons for MTN WAVE
//@property (strong, nonatomic) IBOutlet UIButton *mtn;
@property (strong, nonatomic) IBOutlet UIButton *lightMtn;
@property (strong, nonatomic) IBOutlet UIButton *modMtn;
@property (strong, nonatomic) IBOutlet UIButton *greaterMtn;
@property (weak, nonatomic) IBOutlet UIButton *noMtn;


// Buttons for ICE
//@property (strong, nonatomic) IBOutlet UIButton *ice;
@property (strong, nonatomic) IBOutlet UIButton *clear;
@property (strong, nonatomic) IBOutlet UIButton *rime;
@property (strong, nonatomic) IBOutlet UIButton *mixed;
@property (strong, nonatomic) IBOutlet UIButton *trace;
@property (strong, nonatomic) IBOutlet UIButton *lightIce;
@property (strong, nonatomic) IBOutlet UIButton *modIce;
@property (strong, nonatomic) IBOutlet UIButton *greaterIce;
@property (weak, nonatomic) IBOutlet UIButton *noIce;

// Properties to send data to the ground station
@property (strong, nonatomic) IBOutlet UILabel *pirepSelected;
@property NSMutableArray * pirepData;
//- (IBAction)sendPirep:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendPirep;
-(void)saveToFile;
- (IBAction)cancelPirep:(id)sender;


// Property to get the location
@property (nonatomic,strong) CLLocationManager * myLoc;
@property AppDelegate * appDelegate;


@property (weak, nonatomic) IBOutlet UINavigationBar *header;

//  Properties for the control panel
@property (weak, nonatomic) IBOutlet UIVisualEffectView *panel;
- (IBAction)controlPanel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *controlUp;

//  Properties/Action Events for FlightOn/Off switch
@property (weak, nonatomic) IBOutlet UIButton *flightOn;
- (IBAction)flightOnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *flightOff;

//  Properties/Action Events for Turb Flag
- (IBAction)turbAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *turbOff;
@property (weak, nonatomic) IBOutlet UIButton *turbOn;

@property (weak, nonatomic) IBOutlet UILabel *stopWatchLBL;

- (IBAction)controlPanelDown:(id)sender;

//  Properties Control panel

@end
