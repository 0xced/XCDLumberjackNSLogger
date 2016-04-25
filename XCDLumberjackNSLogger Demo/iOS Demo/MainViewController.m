//
//  Created by Cédric Luthi on 25/04/16.
//  Copyright © 2016 Cédric Luthi. All rights reserved.
//

#import "MainViewController.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation MainViewController

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *message = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	switch (indexPath.row)
	{
		case 0:   DDLogError(@"%@ log sample", message); break;
		case 1:    DDLogWarn(@"%@ log sample", message); break;
		case 2:    DDLogInfo(@"%@ log sample", message); break;
		case 3:   DDLogDebug(@"%@ log sample", message); break;
		case 4: DDLogVerbose(@"%@ log sample", message); break;
		default: break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
