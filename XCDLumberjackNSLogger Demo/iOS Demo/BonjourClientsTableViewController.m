//
//  Created by Cédric Luthi on 26/04/16.
//  Copyright © 2016 Cédric Luthi. All rights reserved.
//

#import "BonjourClientsTableViewController.h"

@interface BonjourClientsTableViewController () <NSNetServiceBrowserDelegate>
@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, strong) NSMutableArray<NSNetService *> *services;
@end

@implementation BonjourClientsTableViewController

- (NSMutableArray *) services
{
	if (!_services)
		_services = [NSMutableArray new];
	return _services;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.netServiceBrowser = [NSNetServiceBrowser new];
	self.netServiceBrowser.delegate = self;
	[self.netServiceBrowser searchForServicesOfType:@"_nslogger-ssl._tcp." inDomain:@""];
}

- (IBAction) cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSNetServiceBrowserDelegate

static NSString * NSNetServicesErrorDescription(NSNetServicesError error)
{
	switch (error)
	{
		case NSNetServicesUnknownError:       return @"An unknown error occured during resolution or publication.";
		case NSNetServicesCollisionError:     return @"An NSNetService with the same domain, type and name was already present when the publication request was made.";
		case NSNetServicesNotFoundError:      return @"The NSNetService was not found when a resolution request was made.";
		case NSNetServicesActivityInProgress: return @"A publication or resolution request was sent to an NSNetService instance which was already published or a search request was made of an NSNetServiceBrowser instance which was already searching.";
		case NSNetServicesBadArgumentError:   return @"An required argument was not provided when initializing the NSNetService instance.";
		case NSNetServicesCancelledError:     return @"The operation being performed by the NSNetService or NSNetServiceBrowser instance was cancelled.";
		case NSNetServicesInvalidError:       return @"An invalid argument was provided when initializing the NSNetService instance or starting a search with an NSNetServiceBrowser instance.";
		case NSNetServicesTimeoutError:       return @"Resolution of an NSNetService instance failed because the timeout was reached.";
	}
	return [NSString stringWithFormat:@"NSNetServicesError %@", @(error)];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
	NSString *message = NSNetServicesErrorDescription(errorDict[NSNetServicesErrorCode].integerValue);
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Bonjour Error" message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	[self.services addObject:service];
	[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:self.services.count - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	NSUInteger serviceIndex = [self.services indexOfObject:service];
	if (serviceIndex != NSNotFound)
	{
		[self.services removeObjectAtIndex:serviceIndex];
		[self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:serviceIndex inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.services.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BonjourClientCell" forIndexPath:indexPath];
	NSString *serviceName = self.services[indexPath.row].name;
	cell.textLabel.text = serviceName;
	cell.accessoryType = [serviceName isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"NSLoggerBonjourServiceName"]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[NSUserDefaults standardUserDefaults] setObject:self.services[indexPath.row].name forKey:@"NSLoggerBonjourServiceName"];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
