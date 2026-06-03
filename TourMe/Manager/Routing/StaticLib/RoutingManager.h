//
//  RoutingManager.h
//  Routing
//
//  Created by Savet on 22/5/25.
//

#import <Foundation/Foundation.h>

@interface RoutingManager : NSObject

- (instancetype)initWithPathOrder:(NSString *)pathOrder pathTail:(NSString*)pathTail pathHead:(NSString*)pathHead pathTT:(NSString*)pathTT pathLat:(NSString *)pathLat pathLng:(NSString *)pathLng;
- (void)setup;
- (NSArray<NSDictionary *> *)coordinatesFromLat:(double)fromLat fromLng:(double)fromLng toLat:(double)toLat toLng:(double)toLng;
- (NSInteger)travelDurationFromLat:(double)fromLat fromLng:(double)fromLng toLat:(double)toLat toLng:(double)toLng;

@end
