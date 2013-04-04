//
// FaunaChatViewController.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

#import "FaunaChatClientKey.h"
#import "FaunaChatViewController.h"
#import "FaunaChatSignupViewController.h"
#import "FaunaChatLoginViewController.h"
#import "FaunaChatRoomViewController.h"
#import "FaunaChatChangePasswordViewController.h"

@interface FaunaChatViewController ()

- (void)refreshUI;

@end

@implementation FaunaChatViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"FaunaChat";
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self refreshUI];
}

- (IBAction)signupAction:(id)sender {
  FaunaChatSignupViewController *controller = [[FaunaChatSignupViewController alloc] initWithNibName:@"FaunaChatSignupViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)loginAction:(id)sender {
  FaunaChatLoginViewController *controller = [[FaunaChatLoginViewController alloc] initWithNibName:@"FaunaChatLoginViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)chatRoomAction:(id)sender {
  FaunaChatRoomViewController *controller = [[FaunaChatRoomViewController alloc] initWithNibName:@"FaunaChatRoomViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)changePasswordAction:(id)sender {
  FaunaChatChangePasswordViewController *controller = [[FaunaChatChangePasswordViewController alloc] initWithNibName:@"FaunaChatChangePasswordViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)logoutAction:(id)sender {
  [FNUser signOut];
  [self refreshUI];
}

- (void)refreshUI {
  for (UIButton *view in @[self.btnChatRoom, self.btnChangePassword, self.btnLogout]) {
    view.enabled = FNUser.isSignedIn;
  }
}

@end
