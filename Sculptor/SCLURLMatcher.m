//
//  SCLURLMatcher.m
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

#import "SCLURLMatcher.h"

#import <Mantle/Mantle.h>

typedef NS_ENUM(NSInteger, SCLURLMatcherType) {
    SCLURLMatcherTypeNone   = -1,
    SCLURLMatcherTypeExact  = 0,
    SCLURLMatcherTypeNumber = 1,
    SCLURLMatcherTypeText   = 2,
};

@interface SCLURLMatcher ()
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, assign) SCLURLMatcherType matcherType;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, unsafe_unretained) Class matchClass;
@end

static BOOL SCLTextOnlyContainsDigits(NSString *text) {
	static NSCharacterSet *notDigits;
	if (!notDigits) {
		notDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
	}
	return [text rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

@implementation SCLURLMatcher

+ (instancetype)matcher
{
	return [[self alloc] initWithPathPrefix:nil];
}

+ (instancetype)matcherWithPathPrefix:(NSString *)pathPrefix
{
	return [[self alloc] initWithPathPrefix:pathPrefix];
}

- (id)init
{
    self = [super init];
    if (self) {
        _matcherType = SCLURLMatcherTypeNone;
		_children = [NSMutableArray array];
    }
    return self;
}

- (id)initWithPathPrefix:(NSString *)pathPrefix
{
    self = [self init];
    if (self) {
        _prefix = [pathPrefix copy];
    }
    return self;
}

- (void)addPath:(NSString *)path forClass:(Class)class
{
	NSParameterAssert(path);
	NSParameterAssert(class && [class isSubclassOfClass:MTLModel.class]);
	
	NSArray *tokens = nil;
	if ([path length] > 0) {
		NSString *newPath = path;
		if ([path hasPrefix:@"/"]) {
			newPath = [path substringFromIndex:1];
		}
		
		tokens = [newPath componentsSeparatedByString:@"/"];
	}
	
	SCLURLMatcher *node = self;
	for (NSString *token in tokens) {
		NSMutableArray *children = node.children;
		
		SCLURLMatcher *existingChild = nil;
		for (SCLURLMatcher *child in children) {
			if ([token isEqualToString:child.text]) {
				node = child;
				existingChild = node;
				break;
			}
		}
		
		if (!existingChild) {
			existingChild = [[SCLURLMatcher alloc] init];
			if ([token isEqualToString:@"#"]) {
				existingChild.matcherType = SCLURLMatcherTypeNumber;
			} else if ([token isEqualToString:@"*"]) {
				existingChild.matcherType = SCLURLMatcherTypeText;
			} else {
				existingChild.matcherType = SCLURLMatcherTypeExact;
			}
			existingChild.text = token;
			[node.children addObject:existingChild];
			node = existingChild;
		}
	}
	node.matchClass = class;
}

- (Class)match:(NSURL *)URL
{
	NSParameterAssert(URL);
	
	NSString *path = URL.path;
	if (self.prefix && [path hasPrefix:self.prefix]) {
		path = [path substringFromIndex:self.prefix.length];
	}
	
	path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
	
	NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
	if ([pathComponents count] == 0) {
		return self.matchClass;
	}
	
	SCLURLMatcher *node = self;
	for (NSString *u in pathComponents) {
		NSArray *list = node.children;
		if (!list) {
			break;
		}
		node = nil;
		
		for (SCLURLMatcher *n in list) {
			switch (n.matcherType) {
				case SCLURLMatcherTypeExact:
	
					if ([n.text isEqualToString:u]) {
						node = n;
					}
					break;
					
				case SCLURLMatcherTypeNumber:
					
					if (SCLTextOnlyContainsDigits(u)) {
						node = n;
					}

					break;
					
				case SCLURLMatcherTypeText:
					node = n;
					break;
				case SCLURLMatcherTypeNone:
					// Do nothing
					break;
			}
			
			if (node) {
				break;
			}
		}
		if (!node) {
			return nil;
		}
	}
	
	return node.matchClass;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p, type:%ld, text:%@, matchClass:%@, children:%@>", self.class, self, (long)self.matcherType, self.text, NSStringFromClass(self.matchClass), self.children];
}

@end
