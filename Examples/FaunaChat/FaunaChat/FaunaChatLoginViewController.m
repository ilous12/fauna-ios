//
// FaunaChatLoginViewController.m
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

#import <Fauna/Fauna.h>
#import "FaunaChatUser.h"
#import "FaunaChatLoginViewController.h"

@implementation FaunaChatLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Sign In";
  self.emailField.text = @"test@example.com";
  self.passwordField.text = @"my_pass";
}

- (IBAction)loginAction:(id)sender {
  NSString* email = self.emailField.text;
  NSString* password = self.passwordField.text;

  [[FaunaChatUser signInWithEmail:email password:password] onSuccess:^(id __unused _) {
    FNContext.currentContext.logHTTPTraffic = YES;

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                     message:[NSString stringWithFormat:@"Welcome to FaunaChat!"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];

  } onError:^(NSError *error) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {

}


@end
