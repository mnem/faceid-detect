//
//  ViewController.m
//  faceid-detect
//
//  Created by David Wagner on 05/10/2017.
//  Copyright © 2017 David Wagner. All rights reserved.
//

@import Security;

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
    [self storeItemInKeychain];
}

- (IBAction)onRefresh:(UIButton *)sender
{
    [self updateStatus];
}

- (IBAction)onFetchItem:(UIButton *)sender
{
    [self retrieveItemInKeychain];
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

- (void)deleteAnyExistingItem {
    // Try deleting it in case it already exists
    NSDictionary *deleteQuery = @{(id)kSecClass: (id)kSecClassGenericPassword,
                                  (id)kSecAttrService: @"myservice",
                                  (id)kSecAttrAccount: @"myaccount",
                                  (id)kSecReturnData: @NO,
                                  };
    
    OSStatus deleteResult = SecItemDelete((__bridge CFDictionaryRef)deleteQuery);
    NSLog(@"Delete item: %d", deleteResult);
}

- (void)addProtectedItem {
    CFErrorRef acError = nil;
    SecAccessControlRef ac = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                             kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                             kSecAccessControlTouchIDCurrentSet,
                                                             &acError);
    NSAssert(acError == nil, @"Could not create access control object: %@", acError);

    NSData *data = [@"It's oh so quiet, shhh, shhh" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *insertQuery = @{(id)kSecClass: (id)kSecClassGenericPassword,
                                  (id)kSecAttrAccessControl: (__bridge_transfer id)ac,
                                  (id)kSecValueData: data,
                                  (id)kSecAttrService: @"myservice",
                                  (id)kSecAttrAccount: @"myaccount",
                                  };
    OSStatus addResult = SecItemAdd((__bridge CFDictionaryRef)insertQuery, nil);
    NSLog(@"Add item: %d", addResult);
}

- (void)storeItemInKeychain
{
    [self deleteAnyExistingItem];
    [self addProtectedItem];
}

- (void)retrieveItemInKeychain
{
    NSDictionary *query = @{(id)kSecClass: (id)kSecClassGenericPassword,
                            (id)kSecAttrService: @"myservice",
                            (id)kSecAttrAccount: @"myaccount",
                            (id)kSecReturnData: @YES,
                            (id)kSecUseOperationPrompt: @"Authenticate to access keychain item",
                            };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFTypeRef dataTypeRef = NULL;
        NSString *message;
        
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef);
        if (status == errSecSuccess) {
            NSData *resultData = (__bridge_transfer NSData *)dataTypeRef;
            NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
            message = [NSString stringWithFormat:@"Result: %@\n", result];
        } else {
            message = [NSString stringWithFormat:@"SecItemCopyMatching status: %d", status];
        }
        
        NSLog(@"%@", message);
    });
}

@end
