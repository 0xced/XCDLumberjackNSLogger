//
//  Created by Cédric Luthi on 25/04/16.
//  Copyright © 2016 Cédric Luthi. All rights reserved.
//

#import "AppDelegate.h"

#import <XCDLumberjackNSLogger/XCDLumberjackNSLogger.h>

@implementation AppDelegate

@synthesize window = _window;

static NSString * const NSLoggerBonjourServiceNameKey = @"NSLoggerBonjourServiceName";

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSString *bonjourServiceName = [[NSUserDefaults standardUserDefaults] stringForKey:NSLoggerBonjourServiceNameKey];
	XCDLumberjackNSLogger *nsLogger = [[XCDLumberjackNSLogger alloc] initWithBonjourServiceName:bonjourServiceName];
	[DDLog addLogger:nsLogger withLevel:DDLogLevelAll];
	
	DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
	ttyLogger.colorsEnabled = YES;
	[DDLog addLogger:ttyLogger withLevel:DDLogLevelWarning];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
	
	return YES;
}

- (void) userDefaultsDidChange:(NSNotification *)notification
{
	XCDLumberjackNSLogger *nsLogger = [[DDLog allLoggers] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		return [evaluatedObject isKindOfClass:XCDLumberjackNSLogger.class];
	}]].firstObject;
	
	NSString *bonjourServiceName = [notification.object stringForKey:NSLoggerBonjourServiceNameKey];
	if (![bonjourServiceName isEqualToString:(__bridge NSString *)nsLogger.logger->bonjourServiceName])
	{
		[DDLog removeLogger:nsLogger];
		[DDLog addLogger:[[XCDLumberjackNSLogger alloc] initWithBonjourServiceName:bonjourServiceName] withLevel:DDLogLevelAll];
	}
}

@end
