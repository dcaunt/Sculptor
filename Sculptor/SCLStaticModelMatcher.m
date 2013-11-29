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
	NSParameterAssert(modelClass != nil);
	NSParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);
    self = [super init];
    if (self) {
        _modelClass = modelClass;
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p, modelClass:%@>", self.class, self, NSStringFromClass(self.modelClass)];
}

#pragma mark - SCLModelMatcher

- (Class)modelClassForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	return self.modelClass;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *modelClassName = [aDecoder decodeObjectForKey:@"modelClass"];
    Class modelClass = NSClassFromString(modelClassName);
    self = [self initWithModelClass:modelClass];
    if (!self) {
        return nil;
    }
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	NSString *modelClassName = NSStringFromClass(self.modelClass);
    [aCoder encodeObject:modelClassName forKey:@"modelClass"];
}

@end
