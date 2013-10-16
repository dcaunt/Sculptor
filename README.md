# Sculptor

Sculptor is a simple AFNetworking response serializer for Mantle.

`SCLMantleResponseSerializer` is an `AFJSONResponseSerializer` subclass which creates models from JSON responses based on the URL-Model mapping you provide. The URL matching component, `SCLURLMatcher` is heavily inspired by Android's [UriMatcher](http://developer.android.com/reference/android/content/UriMatcher.html).

## Getting Started

Tell Sculptor which paths correspond to which `MTLModel` classes.

```objective-c
SCLURLMatcher *matcher = [SCLURLMatcher matcher];
[matcher addPath:@"/users/*" 			 forClass:GHUser.class];
[matcher addPath:@"/orgs/*"  			 forClass:GHOrganization.class];
[matcher addPath:@"/repos/*/*/issues/#"  forClass:GHIssue.class];
```

The token `*` matches any text and the token `#` matches only digits.

Define your Mantle model:

```objective-c
@interface GHUser : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *avatarURL;
@end
```
```objective-c
@implementation GHUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	return @{
			 @"avatarURL": @"avatar_url",
	};
}

+ (NSValueTransformer *)avatarURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
```

Make a request with AFNetworking:

```objective-c
NSURL *baseURL = [NSURL URLWithString:@"https://api.github.com/"];
self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
self.manager.responseSerializer = [SCLMantleResponseSerializer serializerWithUriMatcher:matcher readingOptions:0];

[self.manager GET:@"/users/dcaunt" parameters:nil success:^(AFHTTPRequestOperation *operation, GHUser *user) {
	NSLog(@"User model is %@", user);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	NSLog(@"Error fetching user: %@", error);
}];
```

You can use the same response serializer with `AFURLSessionManager` too.

## Matching Paths

Path matching is strict and the number of path components must be equal. Take the following matcher, for example:

```objective-c
SCLURLMatcher *matcher = [SCLURLMatcher matcher];
[matcher addPath:@"/users/*" forClass:GHUser.class];
```

This matcher would return the model class `GHUser` for the URLs `/users/dcaunt` and `/users/github` but no match would occur for `/users/dcaunt/repos`.

To match this URL, add another path to the matcher:
```objective-c
[matcher addPath:@"/users/*/repos" forClass:GHRepository.class];
```

If your baseURL contains a path prefix, e.g. `https://api.example.com/v3/` you can tell the matcher to ignore this prefix:

```objective-c
SCLURLMatcher *matcher = [SCLURLMatcher matcherWithPathPrefix:@"v3"];
```

Finally, the matcher uses the NSURL in the NSURLResponse provided by AFNetworking. If your web service issues redirects, be sure to add these paths to the matcher.

## Installation

Sculptor supports both iOS and Mac.

Install via CocoaPods:

```
pod 'Sculptor', '~> 0.1'
```

Or clone the repo and drag Sculptor's project file into your project file or workspace.

Then import the header:
```objective-c
#import <Sculptor/Sculptor.h>
```

## TODO
* Unit Tests
