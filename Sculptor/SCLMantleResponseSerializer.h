//
//  SCLMantleResponseSerializer.h
//  Sculptor
//
//  Created by David Caunt on 13/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@protocol SCLModelMatcher <NSObject>
@required
- (Class)modelClassForResponse:(NSURLResponse *)response data:(NSData *)data;
@end

@interface SCLMantleResponseSerializer : AFJSONResponseSerializer
@property (nonatomic, strong, readonly) id<SCLModelMatcher> modelMatcher;

+ (instancetype)serializerWithModelMatcher:(id<SCLModelMatcher>)modelMatcher readingOptions:(NSJSONReadingOptions)readingOptions;

@end
