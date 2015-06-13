//
//  GroupCodeHelper.m
//  Handshake
//
//  Created by Sam Ober on 6/12/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "GroupCodeHelper.h"

@implementation GroupCodeHelper

+ (NSString *)code {
    // check for any string of length 6 in the clipboard
    NSMutableCharacterSet *set = [[[NSCharacterSet alphanumericCharacterSet] invertedSet] mutableCopy];
    NSString *code = [[[UIPasteboard generalPasteboard].string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    
    if ([code length] != 6) {
        code = nil;
        
        [set removeCharactersInString:@"- "];
        
        // try to detect code in text
        for (NSString *text in [[[[UIPasteboard generalPasteboard].string componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""] componentsSeparatedByString:@" "]) {
            // if 3 components separated by '-' of length 2 consider it a valid code
            NSArray *comps = [text componentsSeparatedByString:@"-"];
            if ([comps count] == 3 && [comps[0] length] == 2 && [comps[1] length] == 2 && [comps[2] length] == 2) {
                code = [comps componentsJoinedByString:@""];
                break;
            }
        }
    }
    
    return [code lowercaseString];
}

@end
