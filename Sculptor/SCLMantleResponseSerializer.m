//
//  SCLMantleResponseSerializer.m
//  Sculptor
//
//  Created by David Caunt on 13/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import "SCLMantleResponseSerializer.h"
#import <Mantle/Mantle.h>
#import "SCLStaticModelMatcher.h"

NSString * const SCLErrorDomain = @"SCLErrorDomain";

@interface SCLMantleResponseSerializer ()
@property (nonatomic, strong, readwrite) id<SCLModelMatcher> modelMatcher;
@end

@implementation SCLMantleResponseSerializer

+ (instancetype)serializerForModelClass:(Class)modelClass
{
	SCLMantleResponseSerializer *responseSerializer = [self serializer];
	responseSerializer.modelMatcher = [SCLStaticModelMatcher staticModelMatcher:modelClass];
	return responseSerializer;
}

+ (instancetype)serializerWithModelMatcher:(id<SCLModelMatcher>)modelMatcher
{
	NSParameterAssert(modelMatcher != nil);
	SCLMantleResponseSerializer *responseSerializer = [self serializerWithReadingOptions:0];
	responseSerializer.modelMatcher = modelMatcher;
	return responseSerializer;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	NSError *parentError = nil;
	id responseObject = [super responseObjectForResponse:response data:data error:&parentError];

	if (parentError != nil) {
		*error = parentError;
		return nil;
	}
	
	NSError *matcherError = nil;
	Class modelClass = [self.modelMatcher modelClassForResponse:response data:data error:&matcherError];
	if (!modelClass) {
		if (error) {
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
			[userInfo setValue:NSLocalizedStringFromTable(@"Unable to create model from response data", nil, @"SCL") forKey:NSLocalizedDescriptionKey];
			[userInfo setValue:NSLocalizedStringFromTable(@"Model matcher failed to match the response to a model class", nil, @"SCL") forKey:NSLocalizedFailureReasonErrorKey];
			[userInfo setValue:matcherError forKey:NSUnderlyingErrorKey];
			*error = [[NSError alloc] initWithDomain:SCLErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
		}
		return nil;
	}

	NSValueTransformer *JSONTransformer = nil;
	if ([responseObject isKindOfClass:[NSDictionary class]]) {
		JSONTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass];
	} else if ([responseObject isKindOfClass:[NSArray class]]) {
		JSONTransformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:modelClass];
	} else {
		if (error) {
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
			[userInfo setValue:NSLocalizedStringFromTable(@"Unable to create model from response data", nil, @"SCL") forKey:NSLocalizedDescriptionKey];
			[userInfo setValue:NSLocalizedStringFromTable(@"Response data is not a dictionary or array of dictionaries", nil, @"SCL") forKey:NSLocalizedFailureReasonErrorKey];
			*error = [[NSError alloc] initWithDomain:SCLErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
		}
		return nil;
	}
	
	return [JSONTransformer transformedValue:responseObject];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
	
	self.modelMatcher = [aDecoder decodeObjectForKey:@"modelMatcher"];
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:self.modelMatcher forKey:@"modelMatcher"];
}

@end
