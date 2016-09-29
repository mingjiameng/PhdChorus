//
//  zkeySandboxHelper.h
//  ShengCiBen_Alpha
//
//  Created by Zkey on 15-4-7.
//  Copyright (c) 2015年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zkeySandboxHelper : NSObject

+ (NSString *)pathOfSandbox;
+ (NSString *)pathOfMainBundle;
+ (NSString *)pathOfDocuments;
//+ (NSString *)pathOfDocuments_Inbox;
+ (NSString *)pathOfLibrary;
+ (NSString *)pathOfLibrary_Caches;
//+ (NSString *)pathOfLibrary_Preferences;
+ (NSString *)pathOfTmp;
+ (void)deleteFileAtPath:(NSString *)filePath;
+ (BOOL)fileExitAtPath:(NSString *)filePath;
+ (NSString *)getDeviceString;

@end
