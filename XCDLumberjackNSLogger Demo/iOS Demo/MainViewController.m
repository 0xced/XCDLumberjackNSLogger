//
//  Created by Cédric Luthi on 25/04/16.
//  Copyright © 2016 Cédric Luthi. All rights reserved.
//

#import "MainViewController.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation MainViewController

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationItem.prompt = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSLoggerBonjourServiceName"];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row)
	{
		case 0: DDLogError(@"Error log sample"); break;
		case 1: DDLogWarn(@"Warning log sample"); break;
		case 2: DDLogInfo(@"Info log sample"); break;
		case 3: DDLogDebug(@"Debug log sample"); break;
		case 4: DDLogVerbose(@"Verbose log sample"); break;
		default: break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
