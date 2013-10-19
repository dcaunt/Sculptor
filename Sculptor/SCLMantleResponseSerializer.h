//
//  SCLMantleResponseSerializer.h
//  Sculptor
//
//  Created by David Caunt on 13/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class SCLURLMatcher;

@protocol SCLURLResponseMatcher <NSObject>
- (Class)classForURLResponse:(NSURLResponse *)URLResponse;
@end

@interface SCLMantleResponseSerializer : AFJSONResponseSerializer
@property (nonatomic, strong, readonly) id<SCLURLResponseMatcher> matcher;

+ (instancetype)serializerWithUriMatcher:(id<SCLURLResponseMatcher>)matcher readingOptions:(NSJSONReadingOptions)readingOptions;

@end
