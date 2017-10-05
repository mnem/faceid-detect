//
//  LAContext+Compatibility.h
//  faceid-detect
//
//  Created by David Wagner on 05/10/2017.
//  Copyright © 2017 David Wagner. All rights reserved.
//

@import Foundation;
@import LocalAuthentication;

typedef NS_ENUM(NSInteger, LAContextCompatibilityBiometryType) {
    LAContextCompatibilityBiometryNone,
    LAContextCompatibilityBiometryTypeTouchID,
    LAContextCompatibilityBiometryTypeFaceID,
};

@interface LAContext (Compatibility)

- (BOOL)nah_biometryTypeIsEqualTo:(LAContextCompatibilityBiometryType)biometryType;

@end
