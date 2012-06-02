//
//  MapRootController.m
//  MapDemo2
//
//  Created by 俞 億 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MapRootController.h"
#import "CustomAnnotation.h"
#include <stdlib.h>
#import "CustomPolyline.h"

@interface MapRootController ()
-(void)zoomToShowAllAnotations;
@end

@implementation MapRootController

-(void)loadView{
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    self.view = container;
    [container release];
    descLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    descLabel.numberOfLines = NSIntegerMax;
    [self.view addSubview:descLabel];
    
    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 60, 320, 416-60)];
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    stepControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"后退",@"前进", nil]];
    stepControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [stepControl addTarget:self
                    action:@selector(stepChange)
          forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:stepControl]autorelease];
}

- (void)dealloc
{
    [mapView release];
    [descLabel release];
    [stepControl release];
    [circle release];
    [lineArray release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CustomAnnotation *startPoint = [[CustomAnnotation alloc]init];
    NSDictionary *startDic = [NSDictionary dictionaryWithObjectsAndKeys:@"31.995447",@"latitude",@"118.763527",@"longitude",@"中华职业教育中心",@"title",@"雨花西路260号",@"subTitle",@"SFIcon.png",@"image", nil];
    startPoint.addressDic = startDic;
    [mapView addAnnotation:startPoint];
    [startPoint release];
    
    CustomAnnotation *endPoint = [[CustomAnnotation alloc]init];
    NSDictionary *endDic = [NSDictionary dictionaryWithObjectsAndKeys:@"32.205829",@"latitude",@"118.725257",@"longitude",@"南京信息工程大学",@"title",@"盘新路5号",@"subTitle",@"SFIcon.png",@"image", nil];
    endPoint.addressDic = endDic;
    [mapView addAnnotation:endPoint];
    [endPoint release];
    
    NSString *linePath = [[NSBundle mainBundle]pathForResource:@"lineArray" ofType:@"plist"];
    lineArray = [[NSMutableArray alloc]initWithContentsOfFile:linePath];
    currentStep = 0;
    [self adjustViewForStep];
    for (NSDictionary *lineDic in lineArray) {
        NSArray *pointArray = [lineDic objectForKey:@"pointArray"];
        CLLocationCoordinate2D *points = malloc([pointArray count] * sizeof(CLLocationCoordinate2D));
        for(int i = 0; i < [pointArray count]; i++) {
            NSString *pointStr = [pointArray objectAtIndex:i];
            NSString *latitude = [pointStr substringToIndex:[pointStr rangeOfString:@","].location];
            NSString *longitude = [pointStr substringFromIndex:[pointStr rangeOfString:@","].location+1];
            NSLog(@"latitude:%@,longitude:%@",latitude,longitude);
            points[i] = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        }
        
        CustomPolyline *myPolyline = [CustomPolyline polylineWithCoordinates:points count:[pointArray count]];
        myPolyline.step = [lineArray indexOfObject:lineDic];
        [mapView addOverlay:myPolyline];
        free(points);
    }
    [self zoomToShowAllAnotations];
    [self addCurrentLocationCircle];
}

-(void)addCurrentLocationCircle{
    NSDictionary *currentLineDic = [lineArray objectAtIndex:currentStep];
    NSArray *pointArray = [currentLineDic objectForKey:@"pointArray"];
    NSString *pointStr = [pointArray objectAtIndex:0];
    NSString *latitude = [pointStr substringToIndex:[pointStr rangeOfString:@","].location];
    NSString *longitude = [pointStr substringFromIndex:[pointStr rangeOfString:@","].location+1];
    //NSLog(@"latitude:%@,longitude:%@",latitude,longitude);
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    if (circle) {
        [mapView removeOverlay:circle];
    }
    [circle release];
    
    circle = [[MKCircle circleWithCenterCoordinate:coordinate radius:mapView.visibleMapRect.size.width/50]retain];
    [mapView addOverlay:circle];
}

-(void)stepChange{
    if (stepControl.selectedSegmentIndex==0) {
        currentStep--;
    }else if (stepControl.selectedSegmentIndex==1) {
        currentStep++;
    }
    NSArray *overlayArray = mapView.overlays;
    [mapView removeOverlays:overlayArray];
    [mapView addOverlays:overlayArray];
    [self zoomToShowAllAnotations];
    [self adjustViewForStep];
    [self addCurrentLocationCircle];
    stepControl.selectedSegmentIndex=-1;
}

-(void)adjustViewForStep{
    NSDictionary *currentLineDic = [lineArray objectAtIndex:currentStep];
    descLabel.text = [currentLineDic objectForKey:@"desc"];
    if (currentStep==0) {
        [stepControl setEnabled:NO forSegmentAtIndex:0];
        [stepControl setEnabled:YES forSegmentAtIndex:1];
    }else if (currentStep==lineArray.count-1) {
        [stepControl setEnabled:YES forSegmentAtIndex:0];
        [stepControl setEnabled:NO forSegmentAtIndex:1];
    }else {
        [stepControl setEnabled:YES forSegmentAtIndex:0];
        [stepControl setEnabled:YES forSegmentAtIndex:1];
    }
}

-(void)zoomToShowAllAnotations{
    //缩放地图显示地图上所有的annotation
    MKMapRect zoomRect = MKMapRectNull;
    //循环所有的annotation
    for (id <MKOverlay> overlay in mapView.overlays)
    {
        if ([overlay isKindOfClass:[CustomPolyline class]]) {
            CustomPolyline *customPolyLine = (CustomPolyline*)overlay;
            if (customPolyLine.step==currentStep) {
                for (NSInteger i=0; i<customPolyLine.pointCount; i++) {
                    MKMapPoint annotationPoint = customPolyLine.points[i];
                    //计算出这个的区域
                    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                    if (MKMapRectIsNull(zoomRect)) {
                        zoomRect = pointRect;
                    } else {
                        //每个点的区域合并，变成要显示的区域
                        zoomRect = MKMapRectUnion(zoomRect, pointRect);
                    }
                }
            }
        }
    }
    //移动和缩放地图来显示所有的标记
    [mapView setVisibleMapRect:zoomRect animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMap viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (pin==nil) {
            pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
            pin.canShowCallout = YES;
            pin.animatesDrop = YES;
        }
        pin.pinColor = MKPinAnnotationColorGreen;
        CustomAnnotation *customAnnotation = (CustomAnnotation*)annotation;
        pin.annotation = annotation;
        UIImageView *sfIconView = [[UIImageView alloc] initWithImage:customAnnotation.image];
        pin.leftCalloutAccessoryView = sfIconView;
        [sfIconView release];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.rightCalloutAccessoryView = button;
        annotationView = pin;
    }
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)theMap viewForOverlay:(id <MKOverlay>)overlay{
    MKOverlayView *overlayView = nil;
    if ([overlay isKindOfClass:[CustomPolyline class]]) {
        MKPolylineView *lineView = [[MKPolylineView alloc]initWithPolyline:overlay];
        CustomPolyline *customPolyLine = (CustomPolyline*)overlay;
        lineView.fillColor = [UIColor redColor];
        if (customPolyLine.step==currentStep) {
            lineView.strokeColor = [UIColor blackColor];
        }else {
            lineView.strokeColor = [UIColor blueColor];
        }
        overlayView = lineView;
    }else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc]initWithOverlay:overlay];
        circleView.fillColor = [[UIColor blueColor]colorWithAlphaComponent:0.6];
        overlayView = circleView;
    }
    return overlayView;
}
@end
