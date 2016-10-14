//
// Created by Mats Melke on 2014-02-20.
//

#import "LogglyFields.h"

@import UIKit;

@implementation LogglyFields {
    dispatch_queue_t _queue;
    NSDictionary *_fieldsDictionary;
}

- (id)init {
    if((self = [super init])) {
        _queue = dispatch_queue_create("se.baresi.logglylogger.logglyfields.queue", NULL);
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"lang"];
        id bundleDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        if (bundleDisplayName != nil) {
            [dict setObject:bundleDisplayName forKey:@"appName"];
        } else {
            NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
            if(bundleName != nil) {
                [dict setObject:bundleName forKey:@"appName"];
            }
        }
        NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        if(bundleVersion != nil) {
            [dict setObject:bundleVersion forKey:@"appVersionCode"];
        }
        NSString *bundleShortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if(bundleShortVersion != nil) {
            [dict setObject:bundleShortVersion forKey:@"appVersionName"];
        }
        [dict setObject:[UIDevice currentDevice].name forKey:@"deviceName"];
        [dict setObject:[UIDevice currentDevice].model forKey:@"deviceModel"];
        [dict setObject:[UIDevice currentDevice].systemVersion forKey:@"osVersion"];
        [dict setObject:[self generateRandomStringWithSize:10] forKey:@"sessionId"];
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    }
    return self;
}

#pragma mark implementation of LogglyFieldsDelegate protocol

- (NSDictionary *)logglyFieldsToIncludeInEveryLogStatement {
    // The dict may be altered by one of the setters, so lets use a queue for thread safety
    __block NSDictionary *dict;
    dispatch_sync(_queue, ^{
        dict = [_fieldsDictionary copy];
    });
    return dict;
}

#pragma mark Property setters

- (void)setAppversion:(NSString *)appversion {
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *dict = [_fieldsDictionary mutableCopy];
        if (appversion != nil) {
            [dict setObject:appversion forKey:@"appVersionCode"];
        } else {
            [dict removeObjectForKey:@"appVersionCode"];
        }
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    });
}

- (void)setAppShortVersion:(NSString *)appShortVersion {
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *dict = [_fieldsDictionary mutableCopy];
        if (appShortVersion != nil) {
            [dict setObject:appShortVersion forKey:@"appVersionName"];
        } else {
            [dict removeObjectForKey:@"appVersionName"];
        }
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    });
}

- (void)setSessionid:(NSString *)sessionid {
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *dict = [_fieldsDictionary mutableCopy];
        if (sessionid != nil) {
            [dict setObject:sessionid forKey:@"sessionId"];
        } else {
            [dict removeObjectForKey:@"sessionId"];
        }
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    });
}

- (void)setUserid:(NSString *)userid {
    dispatch_barrier_async(_queue, ^{
        NSMutableDictionary *dict = [_fieldsDictionary mutableCopy];
        if (userId != nil) {
             [dict setObject:userid forKey:@"userId"];
        } else {
            [dict removeObjectForKey:@"userId"];
        }
        _fieldsDictionary = [NSDictionary dictionaryWithDictionary:dict];
    });
}

#pragma mark Private methods

- (NSString*)generateRandomStringWithSize:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

@end
