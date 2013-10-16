//
//  SCLMantleResponseSerializer.h
//  Sculptor
//
//  Created by David Caunt on 13/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class SCLURLMatcher;

@interface SCLMantleResponseSerializer : AFJSONResponseSerializer
@property (nonatomic, strong, readonly) SCLURLMatcher *matcher;

+ (instancetype)serializerWithUriMatcher:(SCLURLMatcher *)matcher readingOptions:(NSJSONReadingOptions)readingOptions;

@end
