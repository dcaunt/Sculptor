//
//  SCLURLModelMatcher.h
//  Sculptor
//
//  Created by David Caunt on 13/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

// This source a port based on the UriMatcher class from the Android Open Source Project and licensed as below
// https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/content/UriMatcher.java
// Many thanks to AOSP.

/*
 * Copyright (C) 2006 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "SCLMantleResponseSerializer.h"

@interface SCLURLModelMatcher : NSObject <SCLModelMatcher, NSCoding>

+ (instancetype)matcher;
+ (instancetype)matcherWithPathPrefix:(NSString *)pathPrefix;

- (id)initWithPathPrefix:(NSString *)pathPrefix;
- (void)addPath:(NSString *)path forClass:(Class)class;
- (Class)match:(NSURL *)URL;

@end
