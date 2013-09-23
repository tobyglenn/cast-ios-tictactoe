// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "SettingsViewController.h"

#import "AppDelegate.h"

@interface SettingsViewController () <UITextFieldDelegate>

@end

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.nameTextField.returnKeyType = UIReturnKeyDone;
  self.nameTextField.text = [appDelegate userName];
  self.nameTextField.delegate = self;
  [self.nameTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if ([self.nameTextField.text length] == 0) {
    NSString *message = NSLocalizedString(@"Set your player name to play Tic-Tac-Toe.", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
  }
}

- (IBAction)save:(id)sender {
  [self save];
}

- (BOOL)save {
  NSString *userName = self.nameTextField.text;
  if ([userName length] == 0) {
    NSString *message = NSLocalizedString(@"You must enter a username.", nil);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"OK",
                                                                                   nil), nil];
    [errorAlert show];
    return NO;
  } else {
    [appDelegate setUserName:userName];
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  return [textField.text length] > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  return [self save];
}

@end
