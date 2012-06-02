//
//  MapRootController.h
//  MapDemo2
//
//  Created by 俞 億 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapRootController : UIViewController<MKMapViewDelegate>{
    MKMapView *mapView;
    UILabel *descLabel;
    NSMutableArray *lineArray;
    NSInteger currentStep;
    UISegmentedControl *stepControl;
    MKCircle *circle;
}
@end
