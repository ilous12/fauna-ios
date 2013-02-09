//
//  FaunaExampleRoomViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleRoomViewController.h"
#import "FaunaExampleMessageComposerViewController.h"
#import "FaunaExampleReplyViewController.h"

#define kEventsPageSize 30

@implementation FaunaExampleRoomViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.timelineResource = @"classes/message/timelines/chat";
  self.title = @"Room";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarStyleBlackTranslucent target:self action:@selector(postAction:)];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self reloadTimeline];
}

- (void)reloadTimeline {
  [FaunaCache ignoreCache:^{
    [FaunaContext background:^id{
      NSError *error;
      FaunaTimelinePage *page = [FaunaTimeline pageFromTimeline:self.timelineResource withCount:kEventsPageSize error:&error];
      // if there is an error in my background block
      if(error) {
        // ... then return error, failure callback will be executed.
        return error;
      }
      NSArray * incomingEvents = page.events;
      _messages = [[NSMutableArray alloc] initWithCapacity:incomingEvents.count];
      
      // filter for "create" event only.
      for (NSArray * event in incomingEvents) {
        if([@"create" isEqualToString:event[1]]) {
          NSString* instanceRef = (NSString*)event[2];
          NSError* error;
          FaunaResource *resource = [FaunaResource get:instanceRef error:&error];
          if(error) {
            return error;
          }
          if(resource) {
            [_messages addObject:resource];
          }
        }
      }
      return nil;
    } success:^(FaunaResponse * response) {
      /*
       SUCCESS
       */
      [self.tableView reloadData];

    } failure:^(NSError *error) {
      /*
       FAILURE
       */
      NSLog(@"Error retrieving timeline: %@", error);
    }];
  }];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  FaunaInstance* messageInstance = self.messages[indexPath.row];
  NSDictionary* messageData = messageInstance.data;
  NSString* messageBody = messageData[@"body"];
  cell.textLabel.text = messageBody;
  
  return cell;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return YES;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
   FaunaResource *resource = self.messages[indexPath.row];
   NSString* instanceRef = resource.reference;
   [self.messages removeObject:resource];
   
   // Remove instance from Timeline.
   [Fauna.client removeInstance:instanceRef fromTimeline:self.timelineResource callback:^(FaunaResponse *response, NSError *error) {
     if(error) {
       NSLog(@"Message Remove from Timeline error: %@", error);
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
       [alert show];
     } else {
       NSLog(@"Message Removed from timeline successfully: %@", response.resource);
       
       // Destroy the instance of 'message'.
       [Fauna.client destroyInstance:instanceRef callback:^(NSError *error) {
         if(error) {
           NSLog(@"Message Instance destroy error: %@", error);
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
           [alert show];
         } else {
           NSLog(@"Message Instance destroyed successfully");
         }
       }];
     }
   }];
   [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
}
 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary* messageInstance = self.messages[indexPath.row];
  
  FaunaExampleReplyViewController *detailViewController = [[FaunaExampleReplyViewController alloc] initWithNibName:@"FaunaExampleReplyViewController" bundle:nil];
  detailViewController.timelineResource = self.timelineResource;
  detailViewController.message = messageInstance;
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
  [self presentModalViewController:navController animated:YES];
}

#pragma mark - Post

- (void)postAction:(id)sender {
  FaunaExampleMessageComposerViewController * controller = [[FaunaExampleMessageComposerViewController alloc] initWithNibName:@"FaunaExampleMessageComposerViewController" bundle:nil];
  controller.timelineResource = self.timelineResource;
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
  [self presentModalViewController:navController animated:YES];
}

@end
