//
//  SCLStaticModelMatcher.m
//  Sculptor
//
//  Created by David Caunt on 23/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import "SCLStaticModelMatcher.h"
#import <Mantle/Mantle.h>

@implementation SCLStaticModelMatcher

+ (instancetype)staticModelMatcher:(Class)modelClass
{
	return [[self alloc] initWithModelClass:modelClass];
}

- (id)initWithModelClass:(Class)modelClass
{
	NSParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);
    self = [super init];
    if (self) {
        _modelClass = modelClass;
    }
    return self;
}

#pragma mark - SCLModelMatcher

- (Class)modelClassForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	return self.modelClass;
}

@end
