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

#import "DeviceListViewController.h"

#import "AppDelegate.h"
#import "TicTacToeViewController.h"

#import <GCKFramework/GCKFramework.h>

@interface DeviceListViewController () <GCKDeviceManagerListener> {
  NSMutableArray *_devices;
  GCKDevice *_selectedDevice;
}

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
  if (!_devices) {
    _devices = [[NSMutableArray alloc] init];
  }
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _devices = [appDelegate.deviceManager.devices mutableCopy];
  [appDelegate.deviceManager addListener:self];
  [appDelegate.deviceManager startScan];
  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  NSString *userName = [appDelegate userName];
  if (!userName || [userName length] == 0) {
    [self performSegueWithIdentifier:@"Settings" sender:self];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [appDelegate.deviceManager stopScan];
  [appDelegate.deviceManager removeListener:self];

  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)refresh:(id)sender {
  [appDelegate.deviceManager startScan];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return (NSInteger)[_devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"DeviceCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  // Configure the cell.
  const GCKDevice *device = [_devices objectAtIndex:(NSUInteger)indexPath.row];
  cell.textLabel.text = device.friendlyName;
  cell.detailTextLabel.text = device.ipAddress;

  return cell;
}

#pragma mark - GCKDeviceManagerListener

- (void)scanStarted {
}

- (void)scanStopped {
  // No-op
}

- (void)deviceDidComeOnline:(GCKDevice *)device {
  if (![_devices containsObject:device]) {
    [_devices addObject:device];
    [self.tableView reloadData];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  [_devices removeObject:device];
  [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"DeviceSelected"]) {
    TicTacToeViewController *viewController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    viewController.device = [_devices objectAtIndex:indexPath.row];
  }
}

@end
