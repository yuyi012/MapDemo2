//
//  CustomAnnotation.m
//  MapDemo2
//
//  Created by 俞 億 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize addressDic;
@synthesize image;
@synthesize title;
@synthesize subtitle;
@synthesize coordinate;
- (void)dealloc
{
    [addressDic release];
    [super dealloc];
}

-(void)setAddressDic:(NSDictionary *)theDic{
    [addressDic release];
    addressDic = [theDic retain];
    self.title = [addressDic objectForKey:@"title"];
    self.subtitle = [addressDic objectForKey:@"subTitle"];
    self.image = [UIImage imageNamed:[addressDic objectForKey:@"image"]];
    self.coordinate = CLLocationCoordinate2DMake([[addressDic objectForKey:@"latitude"]doubleValue], [[addressDic objectForKey:@"longitude"]doubleValue]);
}
@end
