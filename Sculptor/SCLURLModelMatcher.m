//
//  SCLURLModelMatcher.m
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

#import "SCLURLModelMatcher.h"

#import <Mantle/Mantle.h>

typedef NS_ENUM(NSInteger, SCLURLModelMatcherType) {
    SCLURLModelMatcherTypeNone   = -1,
    SCLURLModelMatcherTypeExact  = 0,
    SCLURLModelMatcherTypeNumber = 1,
    SCLURLModelMatcherTypeText   = 2,
};

@interface SCLURLModelMatcher ()
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, assign) SCLURLModelMatcherType matcherType;
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

@implementation SCLURLModelMatcher

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
        _matcherType = SCLURLModelMatcherTypeNone;
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
	NSParameterAssert(path != nil);
	NSParameterAssert(class != nil);
	NSParameterAssert([class isSubclassOfClass:MTLModel.class]);
	
	NSArray *tokens = nil;
	if ([path length] > 0) {
		NSString *newPath = path;
		if ([path hasPrefix:@"/"]) {
			newPath = [path substringFromIndex:1];
		}
		
		tokens = [newPath componentsSeparatedByString:@"/"];
	}
	
	SCLURLModelMatcher *node = self;
	for (NSString *token in tokens) {
		NSMutableArray *children = node.children;
		
		SCLURLModelMatcher *existingChild = nil;
		for (SCLURLModelMatcher *child in children) {
			if ([token isEqualToString:child.text]) {
				node = child;
				existingChild = node;
				break;
			}
		}
		
		if (!existingChild) {
			existingChild = [[SCLURLModelMatcher alloc] init];
			if ([token isEqualToString:@"#"]) {
				existingChild.matcherType = SCLURLModelMatcherTypeNumber;
			} else if ([token isEqualToString:@"*"]) {
				existingChild.matcherType = SCLURLModelMatcherTypeText;
			} else {
				existingChild.matcherType = SCLURLModelMatcherTypeExact;
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
	NSParameterAssert(URL != nil);
	
	NSString *path = URL.path;
	if (self.prefix && [path hasPrefix:self.prefix]) {
		path = [path substringFromIndex:self.prefix.length];
	}
	
	path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
	
	NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
	if ([pathComponents count] == 0) {
		return self.matchClass;
	}
	
	SCLURLModelMatcher *node = self;
	for (NSString *u in pathComponents) {
		NSArray *list = node.children;
		if (!list) {
			break;
		}
		node = nil;
		
		for (SCLURLModelMatcher *n in list) {
			switch (n.matcherType) {
				case SCLURLModelMatcherTypeExact:
	
					if ([n.text isEqualToString:u]) {
						node = n;
					}
					break;
					
				case SCLURLModelMatcherTypeNumber:
					
					if (SCLTextOnlyContainsDigits(u)) {
						node = n;
					}

					break;
					
				case SCLURLModelMatcherTypeText:
					node = n;
					break;
				case SCLURLModelMatcherTypeNone:
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

#pragma mark - SCLModelMatcher

- (Class)modelClassForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	Class class = [self match:response.URL];
	if (!class && error) {
		NSDictionary *userInfo = @{
								   NSLocalizedDescriptionKey : @"Failed to match the response URL to a class",
								   NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"No path spec matches for URL: %@", response.URL]
								   };
		*error = [[NSError alloc] initWithDomain:SCLErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
	}
	return class;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *pathPrefix = [aDecoder decodeObjectForKey:@"pathPrefix"];
    self = [self initWithPathPrefix:pathPrefix];
    if (!self) {
        return nil;
    }
	
	self.matchClass = NSClassFromString([aDecoder decodeObjectForKey:@"modelClass"]);
	self.matcherType = (SCLURLModelMatcherType)[aDecoder decodeIntegerForKey:@"matcherType"];
	self.text = [aDecoder decodeObjectForKey:@"text"];
	self.children = [aDecoder decodeObjectForKey:@"children"];
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.prefix forKey:@"pathPrefix"];
	NSString *modelClassName = NSStringFromClass(self.matchClass);
    [aCoder encodeObject:modelClassName forKey:@"modelClass"];
	
	[aCoder encodeInteger:self.matcherType forKey:@"matcherType"];
	[aCoder encodeObject:self.text forKey:@"text"];
	[aCoder encodeObject:self.children forKey:@"children"];
}

@end
