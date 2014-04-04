//
//  AppDelegate.m
//  Blimps
//
//  Created by Raymond on 3/26/14.
//  Copyright (c) 2014 Raymond. All rights reserved.
//

#import "AppDelegate.h"
#define NULL_PLAYER @"No Player Selected"

@implementation AppDelegate

NSString *current_player = NULL_PLAYER;
NSArray *supported_players;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	/* Indicate which players currently supported */
	supported_players = @[@"Spotify", @"ITunes"];
	/* Get the menu bar */
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	/* Attach it to the status menu */
	[self.statusItem setMenu:self.statusMenu];
	[self.statusItem setTitle:nil];
	/* Give it an icon */
	[self.statusItem setImage:[NSImage imageNamed:@"spot"]];
	[self.statusItem setHighlightMode:YES];
	/* Add items */
	[self.statusMenu insertItemWithTitle:@"Play" action:@selector(terminate) keyEquivalent:@"" atIndex:1];
	[self.statusMenu insertItemWithTitle:@"Next" action:@selector(terminate) keyEquivalent:@"" atIndex:2];
	[self.statusMenu insertItemWithTitle:@"Previous" action:@selector(terminate) keyEquivalent:@"" atIndex:3];
	[self.statusMenu insertItem: [NSMenuItem separatorItem] atIndex:4];
	NSString *title = [self getSongName];
	title = [NSString stringWithFormat:@"  %@", title];
	NSString *album = [self getAlbumName];
	album = [NSString stringWithFormat:@"  %@", album];
	NSString *artist = [self getArtistName];
	artist = [NSString stringWithFormat:@"  %@", artist];
	NSString *popularity = [NSString stringWithFormat:@"  Popularity %@", [self getPopularity]];
	NSString *position = [NSString stringWithFormat:@"  %@", [self playerPosition]];
	[self.statusMenu insertItemWithTitle:@"Now Playing" action:@selector(terminate) keyEquivalent:@"" atIndex:5];
	[self.statusMenu insertItemWithTitle:title action: @selector(terminate) keyEquivalent:@"" atIndex:6];
	[self.statusMenu insertItemWithTitle:album action: @selector(terminate) keyEquivalent:@"" atIndex:7];
	[self.statusMenu insertItemWithTitle:artist action: @selector(terminate) keyEquivalent:@"" atIndex:8];
	[self.statusMenu insertItem: [NSMenuItem separatorItem] atIndex:9];
	[self.statusMenu insertItem: [NSMenuItem separatorItem] atIndex:1];
	/* Timer for updating */
	NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                           target:self
                                         selector:@selector(updateTheMenu)
                                         userInfo:nil
                                          repeats:YES];
	
	/* Initialize the submenu */
	NSMenuItem *item0 = [self.statusMenu itemAtIndex:0];
	[item0 setTitle:current_player];
	NSMenu *player_menu = [item0 submenu];
	[player_menu removeItemAtIndex:0];
	for(int i = 0; i < [supported_players count]; i++)
	{
		NSString *player_title = [supported_players objectAtIndex:i];
		[player_menu insertItemWithTitle: player_title action: @selector(switchPlayer:) keyEquivalent:@"" atIndex:i];
	}
	//[self.statusMenu insertItem: [NSMenuItem separatorItem] atIndex:10];
	[self.statusMenu insertItemWithTitle: position action: @selector(terminate) keyEquivalent:@"" atIndex:10];
	[self.statusMenu insertItemWithTitle: popularity action: @selector(terminate) keyEquivalent:@"" atIndex:11];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (IBAction)checkPlayerActive:(id)sender{
	NSString *script = @"tell application \"System Events\"\n\
	set check to (name of processes) contains \"current_player\"\n\
	return check\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:[sender title]];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	NSString *res = [theResult stringValue];
	if([res isEqualToString:@"false"])
	{
		if([current_player isEqualToString:[sender title]])
		{
			current_player = NULL_PLAYER;
		}
		[sender setAction:@selector(terminate)];
	}
	else
		[sender setAction:@selector(switchPlayer:)];
	return;
}

- (IBAction) switchPlayer:(id)sender {
	NSString *new_player = [sender title];
	if([supported_players containsObject:new_player])
	{
		current_player = new_player;		
	}
	return;
}

/* Update the status menu to show current information */
- (void)updateTheMenu{
		NSMenuItem *item0 = [self.statusMenu itemAtIndex:0];
		NSMenu *player_menu = [item0 submenu];
		[item0 setTitle:current_player];
		NSMenuItem *item2 = [self.statusMenu itemAtIndex:2];
		NSMenuItem *item3 = [self.statusMenu itemAtIndex:3];
		NSMenuItem *item4 = [self.statusMenu itemAtIndex:4];
		NSMenuItem *item7 = [self.statusMenu itemAtIndex:7];
		NSMenuItem *item8 = [self.statusMenu itemAtIndex:8];
		NSMenuItem *item9 = [self.statusMenu itemAtIndex:9];
		NSMenuItem *item10 = [self.statusMenu itemAtIndex:10];
		NSMenuItem *item11 = [self.statusMenu itemAtIndex:11];
		int count = 0;
		for(int i = 0; i < [supported_players count]; i++)
		{
			NSMenuItem *tmp_item = [player_menu itemAtIndex:i];
			[self checkPlayerActive:tmp_item];
			if([tmp_item action] != @selector(terminate))
				count += 1;
		}
		if(count == 0)
		{
			current_player = NULL_PLAYER;
		}
		if([current_player isEqualToString:NULL_PLAYER])
		{
			[item2 setAction:@selector(terminate)];
			[item3 setAction:@selector(terminate)];
			[item4 setAction:@selector(terminate)];
		}
		else
		{
			[item2 setAction:@selector(pause)];
			[item3 setAction:@selector(next)];
			[item4 setAction:@selector(previous)];

		}
		NSString *status = [self getStatus];
		NSString *play = @"playing";
		if([status isEqualToString:play])
		{
			status = @"Pause";
		}
		else
		{
			status = @"Play";
		}
		NSString *title = [NSString stringWithFormat:@"  %@", [self getSongName]];
		NSString *album = [NSString stringWithFormat:@"  %@", [self getAlbumName]];
		NSString *artist = [NSString stringWithFormat:@"  %@", [self getArtistName]];
		NSString *position = [NSString stringWithFormat:@"  %@", [self playerPosition]];
		NSString *popularity = [NSString stringWithFormat:@"  Popularity %@", [self getPopularity]];
		[item2 setTitle:status];
		[item7 setTitle:title];
		[item8 setTitle:album];
		[item9 setTitle:artist];
		[item10 setTitle:position];
		[item11 setTitle:popularity];

}

/* Toggle play/pause for the player */
- (IBAction)pause{
	if(![supported_players containsObject:current_player])
		return;
	NSDictionary *error = [NSDictionary new]; 
	NSString *script = @"tell application \"current_player\" to playpause";
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	if ([appleScript executeAndReturnError:&error]) {
		NSLog(@"success!");
	}
	else {
		NSLog(@"failure!");
	}
}

/* Move to the nex track */
- (IBAction)next{
	if(![supported_players containsObject:current_player])
		return;
	NSDictionary *error = [NSDictionary new]; 
	NSString *script = @"tell application \"current_player\" to next track";
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	if ([appleScript executeAndReturnError:&error]) {
		NSLog(@"success!");
	}
	else {
		NSLog(@"failure!");
	}
}

/* Move to the previous track */
- (IBAction)previous{
	if(![supported_players containsObject:current_player])
		return;
	NSDictionary *error = [NSDictionary new]; 
	NSString *script = @"tell application \"current_player\" to previous track";
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	if ([appleScript executeAndReturnError:&error]) {
		NSLog(@"success!");
	}
	else {
		NSLog(@"failure!");
	}
}

/* Get the position in the current track */
- (NSString *)playerPosition{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set pos to player position\n\
	set dur to duration of the current track\n\
	set dur_min to (round(dur div 60) * 100 / 100)\n\
	set dur_sec to (round(dur mod 60) * 100 / 100)\n\
	set pos_min to (round(pos div 60) * 100 / 100)\n\
	set pos_sec to (round(pos mod 60) * 100 / 100)\n\
	set dur_min to text -2 thru -1 of (\"00\" & dur_min)\n\
	set dur_sec to text -2 thru -1 of (\"00\" & dur_sec)\n\
	set pos_min to text -2 thru -1 of (\"00\" & pos_min)\n\
	set pos_sec to text -2 thru -1 of (\"00\" & pos_sec)\n\
	set tim to pos_min & \":\" & pos_sec & \"/\" & dur_min & \":\" & dur_sec as text\n\
	return tim\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	//NSLog(@"%@", [theResult stringValue]);
	return [theResult stringValue];
}

/* Get the volume of the current player */
- (NSString *)getVolume{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set theVolume to sound volume\n\
	return theVolume\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	return [theResult stringValue];
}

/* Get the popularity of the curent track */
- (NSString *)getPopularity{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set thePopularity to popularity of the current track\n\
	return thePopularity\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	return [theResult stringValue];
}

/* Get the song name of the current song */
- (NSString *)getSongName{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set theTrack to current track\n\
	set theName to name of theTrack\n\
	return theName\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	return [theResult stringValue];
}

/* Get the artist name of the current song */
- (NSString *)getArtistName{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set theTrack to current track\n\
	set theName to artist of theTrack\n\
	return theName\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	return [theResult stringValue];

}

/* Get the album name of the current song */
- (NSString *)getAlbumName{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set theTrack to current track\n\
	set theName to album of theTrack\n\
	return theName\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	return [theResult stringValue];
}

/* Get the state of the player */
- (NSString *)getStatus{
	if(![supported_players containsObject:current_player])
		return nil;
	NSString *script = @"tell application \"current_player\"\n\
	set theState to player state as string\n\
	return theState\n\
	end tell"
	;
	script = [script stringByReplacingOccurrencesOfString:@"current_player" withString:current_player];
	NSAppleScript *appleScript = [[NSAppleScript new]initWithSource:script];
	NSAppleEventDescriptor *theResult =[appleScript executeAndReturnError:nil];
	return [theResult stringValue];
}


@end
