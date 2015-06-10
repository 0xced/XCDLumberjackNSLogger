//
//  Copyright (c) 2015 Cédric Luthi. All rights reserved.
//

#import "XCDLumberjackNSLogger.h"

@implementation XCDLumberjackNSLogger

- (instancetype) init
{
	return [self initWithBonjourServiceName:nil];
}

- (instancetype) initWithBonjourServiceName:(NSString *)bonjourServiceName
{
	if (!(self = [super init]))
		return nil;
	
	_logger = LoggerInit();
	LoggerSetupBonjour(_logger, NULL, (__bridge CFStringRef)bonjourServiceName);
	LoggerSetOptions(_logger, _logger->options & ~kLoggerOption_CaptureSystemConsole);
	
	return self;
}

- (void) dealloc
{
	LoggerStop(self.logger);
}

#pragma mark - DDLogger

static NSData * MessageAsData(NSString *message);

@synthesize logFormatter = _logFormatter;

- (NSString *) loggerName
{
	return @"cocoa.lumberjack.NSLogger";
}

- (void) didAddLogger
{
	LoggerStart(self.logger);
}

- (void) flush
{
	LoggerFlush(self.logger, NO);
}

- (void) logMessage:(DDLogMessage *)logMessage
{
	int level = log2f(logMessage.flag);
	NSString *tag = self.tags[@(logMessage.context)];
	NSData *data = MessageAsData(logMessage.message);
	if (data)
		LogDataToF(self.logger, logMessage.fileName.UTF8String, (int)logMessage.line, logMessage.function.UTF8String, tag, level, data);
	else
		LogMessageRawToF(self.logger, logMessage.fileName.UTF8String, (int)logMessage.line, logMessage.function.UTF8String, tag, level, logMessage.message);
}

@end

static NSData * MessageAsData(NSString *message)
{
	if ([message hasPrefix:@"<"] && [message hasSuffix:@">"])
	{
		message = [message substringWithRange:NSMakeRange(1, message.length - 2)];
		message = [message stringByReplacingOccurrencesOfString:@" " withString:@""];
		NSCharacterSet *hexadecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];
		if (message.length % 2 == 0 && [message rangeOfCharacterFromSet:hexadecimalCharacterSet.invertedSet].location == NSNotFound)
		{
			NSMutableData *data = [NSMutableData new];
			char chars[3] = {'\0','\0','\0'};
			for (NSUInteger i = 0; i < message.length / 2; i++)
			{
				chars[0] = [message characterAtIndex:i*2];
				chars[1] = [message characterAtIndex:i*2 + 1];
				uint8_t byte = strtol(chars, NULL, 16);
				[data appendBytes:&byte length:sizeof(byte)];
			}
			return data;
		}
	}
	return nil;
}
