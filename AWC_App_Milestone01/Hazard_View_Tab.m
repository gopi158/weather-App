//location ka problem aara merku!

//  Hazard_View_Tab.m
//  AWC_App_Milestone01
//
//  Created by SATISH KUMAR BASWAPURAM on 12/2/13.
//  Edited by Syed Mazhar Hussani
//  Copyright (c) 2013 Satish Kumar Baswapuram. All rights reserved.
//

#import "Hazard_View_Tab.h"
#import "ControlPanelManager.h"

@interface Hazard_View_Tab ()

@property HazardsParser * myHazardsParser;
@property UIBarButtonItem * mtnObsn;
@property UIBarButtonItem * icing;
@property UIBarButtonItem * turbulence;
@property UIBarButtonItem * generic;
@property UIBarButtonItem * ifr;
@property UIBarButtonItem * ash;
@property UIBarButtonItem * convective;
@property BOOL mtnValidate;
@property BOOL turbValidate;
@property BOOL icingValidate;
@property BOOL ashValidate;
@property BOOL ifrValidate;
@property BOOL convectiveValidate;
@property BOOL genericValidate;
@property NSMutableArray * hazardOverlays;


@property BOOL mapLoaded;
@property BOOL annotationsAdded;
@property BOOL overlaysAdded;

@property int selectedIndex;
@property int selectedFore;

//Zoom in properties
@property MKCoordinateRegion beforeZoom;//edit2014
@property int check;
@property ControlPanelManager *cp;
@property AppDelegate* appDelegate;
@property int trigger;

@end

@implementation Hazard_View_Tab

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Initialize the map and the loading activity indicator.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    
    self.activityStatus.transform = CGAffineTransformMakeScale(2, 2);
    
    //edit2015
    self.forecastVC = [[Forecast alloc]initWithStyle:UITableViewStylePlain];
    self.forecastVC.delegate = self;
    
    self.popOverController = [[UIPopoverController alloc]initWithContentViewController:self.forecastVC];
    //Assigning targets and action
    [self.forecastsBTN setTarget:self];
    [self.forecastsBTN setAction:@selector(selectForecasts:)];
    
    //Zooming in
    self.button = [UIImage imageNamed:@"zoomingin.png"];
    [self.zoom setBackgroundImage:self.button forState:UIControlStateNormal];
    [self.zoom addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
    self.check = 0;
    
    //Control Panel Transperancy
    self.cp = [ControlPanelManager sharedManager];
    self.panel.alpha = 0.6;

}

//Set the view background color and header color to reflect the theme of the app.
-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    //  Loading control Panel
    [self controlPanelLoad];
    
    self.view.backgroundColor = appDelegate.awcColor;
    [self.header setBarTintColor:appDelegate.awcColor];
    [self.header setBackgroundImage:appDelegate.header forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [self.header setTintColor:[UIColor whiteColor]];
    self.header.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    //self.navigationItem.leftBarButtonItem
    [self updateTimeLabel];
}

//Save the state of the segmented control when the view is loaded for the first time and initialize the data.
-(void)viewDidAppear:(BOOL)animated
{
    self.mapLoaded = NO;
    self.annotationsAdded = NO;
    self.overlaysAdded = NO;
    
    static BOOL viewLoadedFirstTime = YES;
    
    if(viewLoadedFirstTime)
    {
        self.selectedIndex = (int)self.hazardsSegmentedControl.selectedSegmentIndex;
        viewLoadedFirstTime = NO;
    }
    else
    {
        [self.hazardsSegmentedControl setSelectedSegmentIndex:self.selectedIndex];
    }
    
    [self initializeData:self.selectedFore];
}

//This will start the loading activity indicator when the map loads.
-(void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    self.mapLoaded = NO;
    [self.activityStatus startAnimating];
    self.activityStatus.hidden = NO;
    self.loadingImage.hidden = NO;
}

//If the map is completely loaded, then set mapLoaded to yes and check if the loading activity indicator needs to be stopped.
-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    self.mapLoaded = YES;
    [self stopStatusIndicator];
    //Zoom level
    if(self.check==0){
        self.beforeZoom = self.mapView.region;// Setting the region for Map
        self.check++;
    }
}

//If the annotations are completely loaded, then set annotationsAdded to yes and check if the loading activity indicator needs to be stopped.
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    self.annotationsAdded = YES;
    [self stopStatusIndicator];
}

//If the overlays are completely loaded, then set overlaysAdded to yes and check if the loading activity indicator needs to be stopped.
-(void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    self.overlaysAdded = YES;
    [self stopStatusIndicator];
}

//If the map is loaded and all the Hazards are added, then stop and hide the loading activity indicator.
-(void)stopStatusIndicator
{
    if(self.mapLoaded && self.annotationsAdded && self.overlaysAdded)
    {
        [self.activityStatus stopAnimating];
        self.activityStatus.hidden = YES;
        self.loadingImage.hidden = YES;
    }
}

//If the user has no internet connection, display an alert. Else, parse the json from database and add Hazards on the map.
-(void)initializeData:(int)fore
{

    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    if([appDelegate isConnectedToInternet])
    
    {
        
        [self updateTimeLabel];
    
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        _myHazardsParser = [[HazardsParser alloc]init];
        
        self.hazardOverlays = [_myHazardsParser GetHazards:fore];
        [self.hazardsSegmentedControl setSelectedSegmentIndex:self.selectedIndex];
        
        [self.hazardsSegmentedControl addTarget:self action:@selector(segmentActions:) forControlEvents:UIControlEventValueChanged];
        [self.hazardsSegmentedControl setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.72]];
        
        [self segmentActions:nil];
    
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"No internet!!" message:@"Make sure you have a working internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
	// Do any additional setup after loading the view.
}

//Updates the time label by getting the user's local time.
-(void)updateTimeLabel
{
    NSDate * now = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString * updateTime = [dateFormatter stringFromDate:now];
    self.lastUpdateLabel.text = [@"Last updated at: " stringByAppendingString:updateTime];
}

//Handle action when a segment button is clicked.
-(IBAction)segmentActions:(id)sender
{
    //NSLog(@"Previous Index: %d",self.selectedIndex);
    self.selectedIndex = (int)self.hazardsSegmentedControl.selectedSegmentIndex;
    //NSLog(@"Selected: %d",self.selectedIndex);
    switch (self.selectedIndex) {
        case 0: [self genericButton:nil];
                break;
            
        case 1: [self mtnObsnButton:nil];
                break;
            
        case 2: [self turbulenceButton:nil];
                break;
            
        case 3: [self icingButton:nil];
                break;
            
        case 4: [self convectiveButton:nil];
                break;
            
        case 5: [self ashButton:nil];
                break;
            
        case 6: [self ifrButton:nil];
                break;
            
        default:
                break;
    }
    
}

//Previous method used to display a toolbar of buttons that contained all the different hazards.
-(void)showHazards
{
    _mtnObsn.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    _icing.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    _turbulence.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    _ifr.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    _convective.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    _generic.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    _ash.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.7 alpha:1.0];
    
    self.genericValidate = NO;
    self.turbValidate = NO;
    self.mtnValidate = NO;
    self.ifrValidate = NO;
    self.ashValidate = NO;
    self.convectiveValidate = NO;
    
    self.icingValidate = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [self.mapView addAnnotations:self.hazardOverlays];
//    [self.mapView addOverlays:self.hazardOverlays];
    [self genericButton:self];
}

//Remove all hazards from the screen except mtnObsn.
-(void)mtnObsnButton:(id)sender
{
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            if([myHazard.type isEqualToString:@"MTN OBSCN"] || [myHazard.type isEqualToString:@"MT_OBSC"])
            {
                [self.mapView addAnnotation:myHazard];
                [self.mapView addOverlay:myHazard];
            }
            
        }
        
}

//Remove all hazards from the screen except turbulence.
-(void)turbulenceButton:(id)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
        for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            if([myHazard.type isEqualToString:@"TURB"] || [myHazard.type isEqualToString:@"TURB-HI"] || [myHazard.type isEqualToString:@"TURB-LO"])
            {
                [self.mapView addAnnotation:myHazard];
                [self.mapView addOverlay:myHazard];
            }
        }
    
}

//Remove all hazards from the screen except icing.
-(void)icingButton:(id)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
        for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            if([myHazard.type isEqualToString:@"ICE"])
            {
                [self.mapView addAnnotation:myHazard];
                [self.mapView addOverlay:myHazard];
            }
            
        }
}

//Remove all hazards from the screen except convective.
-(void)convectiveButton:(id)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
        for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            if([myHazard.type isEqualToString:@"CONVECTIVE"])
            {
                [self.mapView addAnnotation:myHazard];
                [self.mapView addOverlay:myHazard];
            }
            
        }
}

//Remove all hazards from the screen except ash.
-(void)ashButton:(id)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
        for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            if([myHazard.type isEqualToString:@"ASH"])
            {
                [self.mapView addAnnotation:myHazard];
                [self.mapView addOverlay:myHazard];
            }
            
        }
}

//Remove all hazards from the screen except ifr.
-(void)ifrButton:(id)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
        for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            if([myHazard.type isEqualToString:@"IFR"])
            {
                [self.mapView addAnnotation:myHazard];
                [self.mapView addOverlay:myHazard];
            }
            
        }
}


//Display all hazards on the screen.
-(void)genericButton:(id)sender
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
        for( int i=0;i< [self.hazardOverlays count];i++)
        {
            Hazards * myHazard = [self.hazardOverlays objectAtIndex:i];
            
            
            [self.mapView addAnnotation:myHazard];
            [self.mapView addOverlay:myHazard];
            
            
        }
    
}

//Action for Forecast bar button
-(IBAction)selectForecasts:(id)sender{
    [self.popOverController presentPopoverFromBarButtonItem:self.forecastsBTN permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)selectedForecast:(NSString *)fore{
    //[self.forecasts addObject:fore];
    //NSLog(@"After Selection: %d",self.forecasts.count);
    self.selectedFore =[fore intValue];
    [self initializeData:self.selectedFore];
    
}

//Color the overlays with respect to the hazard.
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
    if([overlay isKindOfClass:[Hazards class]]){
        MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:((Hazards *)overlay).polygon] ;
        view.lineWidth=3;
        view.strokeColor = ((Hazards *)overlay).color;
        view.fillColor = [((Hazards *)overlay).color colorWithAlphaComponent:0.25];
        return view;
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setHazardsBar:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}

//Display appropriate pins on the map for each annotation based on the value of fltcat property.
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString * identifier = @"Annotation";
    MKPinAnnotationView * annotView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(annotView == nil)
        {
            annotView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
            annotView.image = [UIImage imageNamed:@"RedPin.png"];
            //annotView.pinColor = ];
            //annotView.canShowCallout = YES;
            
        }
    annotView.annotation = annotation;
    return annotView;
}

// Zoom in Functionality Code
- (void)zoomIn{
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.appDelegate.userLocTAF.latitude,self.appDelegate.userLocTAF.longitude), MKCoordinateSpanMake(4.347, 4.347));
    self.button = [UIImage imageNamed:@"zoomingout.png"];
    [self.zoom setBackgroundImage:self.button forState:UIControlStateNormal];
    [self.zoom addTarget:self action:@selector(zoomOut) forControlEvents:UIControlEventTouchUpInside];
}
-(void)zoomOut{
    self.mapView.region = MKCoordinateRegionMake(self.beforeZoom.center, self.beforeZoom.span);
    [self.zoom addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
    self.button = [UIImage imageNamed:@"zoomingin.png"];
    [self.zoom setBackgroundImage:self.button forState:UIControlStateNormal];
}
//Display a popover when a Metar is clicked. The popover contains the details of the Metar listed in a table format.
//-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    
//}
//  Setting Control Panel Properties
- (void)controlPanelLoad{
    self.panel.hidden = YES;
    self.controlUp.hidden = NO;
    if(self.cp.isFlightOn == NO){
        self.flightOn.hidden = NO;
        self.flightOff.hidden = YES;
    }
    else {
        self.flightOn.hidden = YES;
        self.flightOff.hidden = NO;
    }
    
    if (self.cp.isTurbOn) {
        self.turbOff.hidden = NO;
        self.turbOn.hidden = YES;
    }
    else{
        self.turbOff.hidden = YES;
        self.turbOn.hidden = NO;
    }
}
- (IBAction)controlPanel:(id)sender {
    self.panel.hidden = NO;
    self.controlUp.hidden = YES;
    [self updateTimerLabel];
    
}
- (IBAction)flightOnAction:(id)sender {
   
    if(self.flightOn.hidden){
        self.cp.isFlightOn = NO;
        self.flightOff.hidden = YES;
        self.flightOn.hidden = NO;
        
        if (self.turbOn.hidden) {
            self.turbOff.hidden = YES;
            self.turbOn.hidden = NO;
            self.cp.isTurbOn = NO;
        }
        [self.cp.stopWatchTimer invalidate];
        self.cp.stopWatchTimer = nil;
        [self updateTimerLabel];
        self.cp.stoppingRec = NO;

        
    }
    else{
        self.cp.isFlightOn = YES;
        self.flightOff.hidden = NO;
        self.flightOn.hidden = YES;
        self.cp.startDate = [NSDate date];
        [self.cp startTimer];
        [self updateTimerLabel];
        [self.cp startRec];

    }
}

- (IBAction)turbAction:(id)sender {
    
    if (self.cp.isFlightOn) {
        if(self.turbOn.hidden){
            self.cp.isTurbOn = NO;
            self.turbOff.hidden = YES;
            self.turbOn.hidden = NO;
            self.cp.TurbFlag = YES;
        }
        else {
            self.cp.isTurbOn = YES;
            self.turbOn.hidden = YES;
            self.turbOff.hidden = NO;
            self.cp.TurbFlag = YES;
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Turbulence can be only activated if the flight data is being recorded, So switch on Flight Recorder first." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)updateTimerLabel{
    self.stopWatchLBL.text = self.cp.stopwatch;//self.appDelegate.stopWatchCall;//self.appDelegate.stopwatchLabel;
    [self performSelector:@selector(updateTimerLabel) withObject:self afterDelay:0.1];
}

- (IBAction)controlPanelDown:(id)sender {
    self.controlUp.hidden = NO;
    self.panel.hidden = YES;
}

@end
