//
//  SCLStaticModelMatcher.h
//  Sculptor
//
//  Created by David Caunt on 23/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCLMantleResponseSerializer.h"

@interface SCLStaticModelMatcher : NSObject <SCLModelMatcher, NSCoding>
@property (nonatomic, copy, readonly) Class modelClass;

+ (instancetype)staticModelMatcher:(Class)modelClass;

@end
