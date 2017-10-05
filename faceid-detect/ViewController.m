//
//  ViewController.m
//  faceid-detect
//
//  Created by David Wagner on 05/10/2017.
//  Copyright © 2017 David Wagner. All rights reserved.
//

#import "ViewController.h"
#import "LAContext+Compatibility.h"

#define STR_BOOL(b) ((b) ? @"YES" : @"NO")

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *hasBiometricsLabel;
@property (weak, nonatomic) IBOutlet UILabel *touchIDSupportedLabel;
@property (weak, nonatomic) IBOutlet UILabel *faceIDSupportedLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateStatus];
}

- (IBAction)onRefresh:(UIButton *)sender
{
    [self updateStatus];
}

- (void)updateStatus
{
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    const BOOL biometryAvailable = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (error != nil) {
        NSLog(@"Could not evaluate policy: %@", [error debugDescription]);
    }

    self.hasBiometricsLabel.text = [NSString stringWithFormat:@"Can auth with biometrics: %@", STR_BOOL(biometryAvailable)];
    self.touchIDSupportedLabel.text = [NSString stringWithFormat:@"Has TouchID: %@", STR_BOOL([context nah_biometryTypeIsEqualTo:LAContextCompatibilityBiometryTypeTouchID])];
    self.faceIDSupportedLabel.text = [NSString stringWithFormat:@"Has FaceID: %@", STR_BOOL([context nah_biometryTypeIsEqualTo:LAContextCompatibilityBiometryTypeFaceID])];
}

@end
