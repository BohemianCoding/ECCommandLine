// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 09/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <ECUnitTests/ECUnitTests.h>


@interface ExampleToolTests : ECTestCase

@end


@implementation ExampleToolTests

- (NSString*)runToolWithArguments:(NSArray*)arguments {
	NSTask *task = [[NSTask alloc] init];
	NSString* path = [[NSBundle bundleForClass:[self class]].bundlePath stringByDeletingLastPathComponent];
	task.launchPath = [path stringByAppendingPathComponent:@"ECCommandLineExample"];
	
	if (arguments)
	[task setArguments:arguments];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	
	NSData *data = [file readDataToEndOfFile];
	NSString* output = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
	
	return output;
}


- (void)testHelp {
	NSURL* expectedURL = [self URLForTestResource:@"Help" withExtension:@"txt"];
	NSString* output = [self runToolWithArguments:nil];
	[self assertString:output matchesContentsOfURL:expectedURL mode:ECTestComparisonDiff];
}

- (void)testExample {
	NSString* output = [self runToolWithArguments:@[@"example"]];
	[self assertString:output matchesString:@"This is an example command. It's not very useful. The blah parameter was “waffle”" mode:ECTestComparisonDiff];
}

- (void)testExampleWithOption {
	NSString* output = [self runToolWithArguments:@[@"example", @"--blah=doodah"]];
	[self assertString:output matchesString:@"This is an example command. It's not very useful. The blah parameter was “doodah”" mode:ECTestComparisonDiff];
}

- (void)testUnknown {
	NSString* output = [self runToolWithArguments:@[@"zoinks"]];
	NSString* line1 = [output componentsSeparatedByString:@"\n"][0];
	[self assertString:line1 matchesString:@"Unknown command ‘zoinks’" mode:ECTestComparisonDiff];
}

@end