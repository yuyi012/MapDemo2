//
//  CustomAnnotation.h
//  MapDemo2
//
//  Created by 俞 億 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property(nonatomic, retain) UIImage *image;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic,retain)NSDictionary *addressDic;
@end
