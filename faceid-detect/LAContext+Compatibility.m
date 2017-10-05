//
//  LAContext+Compatibility.m
//  faceid-detect
//
//  Created by David Wagner on 05/10/2017.
//  Copyright © 2017 David Wagner. All rights reserved.
//

#import "LAContext+Compatibility.h"

@implementation LAContext (Compatibility)

- (BOOL)nah_biometryTypeIsEqualTo:(LAContextCompatibilityBiometryType)biometryType
{
    const SEL BiometryTypeSelector = NSSelectorFromString(@"biometryType");
    
    if ([self respondsToSelector:BiometryTypeSelector]) {
        NSInteger selfBiometryType = (NSInteger)[self performSelector:BiometryTypeSelector];
        return selfBiometryType == biometryType;
    }
    
    return NO;
}

@end
