# Sculptor

[![Build Status](https://travis-ci.org/dcaunt/Sculptor.png?branch=master)](https://travis-ci.org/dcaunt/Sculptor)

A simple yet powerful [AFNetworking](https://github.com/AFNetworking/AFNetworking) serializer for [Mantle](https://github.com/github/Mantle/).

Sculptor's implementation of `AFHTTPResponseSerializer` makes it easy to create Mantle models without changing your existing AFNetworking or Mantle code. You can use Sculptor's serializers whether working with `AFHTTPRequestOperationManager`, `AFURLSessionManager` or `AFHTTPRequestOperation` directly.

Sculptor is pre-[1.0](http://semver.org/) software but the API is already well-defined. Both iOS and Mac are supported.

## Installation

Install via CocoaPods:

```ruby
pod 'Sculptor', '~> 0.2'
```

Or clone this repo and drag Sculptor's project file into your project file or workspace.

## Simple Serialization

Serializing response data to a single model type is super-simple.

```objective-c
AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
manager.responseSerializer = [SCLMantleResponseSerializer serializerForModelClass:GHUser.class];

[manager GET:@"https://api.github.com/users/dcaunt" parameters:nil success:^(AFHTTPRequestOperation *operation, GHUser *user) {
	// GHUser is an MTLModel subclass
	NSLog(@"User model is %@", user);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	NSLog(@"Error fetching user: %@", error);
}];
```

## Model Matchers

For `AFHTTPRequestOperationManager` and `AFURLSessionManager` instances which require responses to be serialized to different Mantle model types, `SCLMantleResponseSerializer` allows you to specify a matcher, for matching the `NSURLResponse` and response data to a model class.

A model matcher implements the `SCLModelMatcher` protocol which defines a single method:

```objective-c
@protocol SCLModelMatcher <NSObject>
@required
- (Class)modelClassForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error;
@end
```

Sculptor provides two built-in matchers, `SCLStaticModelMatcher` and `SCLURLModelMatcher`. A `SCLStaticModelMatcher` is actually configured in the Simple Serialization example above, when using `+[SCLMantleResponseSerializer serializerForModelClass:]`. This matcher always returns the same Mantle model class regardless of the response.

`SCLURLModelMatcher` is a URL-based matcher, heavily inspired by Android's [`UriMatcher`](http://developer.android.com/reference/android/content/UriMatcher.html). To use it, you specify how paths map to `MTLModel` classes. 

Continuing our GitHub API example:

```objective-c
SCLURLModelMatcher *matcher = [SCLURLModelMatcher matcher];
[matcher addPath:@"/users/*" 			 forClass:GHUser.class];
[matcher addPath:@"/orgs/*"  			 forClass:GHOrganization.class];
[matcher addPath:@"/repos/*/*/issues/#"  forClass:GHIssue.class];
```

The token `*` matches any text and the token `#` matches only digits.

Make requests with AFNetworking:

```objective-c
NSURL *baseURL = [NSURL URLWithString:@"https://api.github.com/"];
self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
self.manager.responseSerializer = [SCLMantleResponseSerializer serializerWithModelMatcher:matcher readingOptions:0];

[self.manager GET:@"/users/dcaunt" parameters:nil success:^(AFHTTPRequestOperation *operation, GHUser *user) {
	NSLog(@"User model is %@", user);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	NSLog(@"Error fetching user: %@", error);
}];
```

### Matching Paths with SCLURLModelMatcher

Path matching is strict and the number of path components must be equal. Take the following matcher, for example:

```objective-c
SCLURLModelMatcher *matcher = [SCLURLModelMatcher matcher];
[matcher addPath:@"/users/*" forClass:GHUser.class];
```

This matcher would return the model class `GHUser` for the URLs `/users/dcaunt` and `/users/github` but no match would occur for `/users/dcaunt/repos`.

To match this URL, add another path to the matcher:
```objective-c
[matcher addPath:@"/users/*/repos" forClass:GHRepository.class];
```

If your baseURL contains a path prefix, e.g. `https://api.example.com/v3/` you can tell the matcher to ignore this prefix:

```objective-c
SCLURLModelMatcher *matcher = [SCLURLModelMatcher matcherWithPathPrefix:@"v3"];
```

Finally, the matcher uses the NSURL in the NSURLResponse provided by AFNetworking. If your web service issues redirects, be sure to add these paths to the matcher.

### Writing your own matcher

Implementations of `SCLModelMatcher` receive the full response object and the associated NSURLResponse when asked which Mantle model class to return. For example, the [Stack Exchange API](http://api.stackexchange.com/docs/questions#pagesize=1&order=desc&sort=activity&tagged=objective-c&filter=!9f8L7Erbc&site=stackoverflow&run=true) returns a `type` field in each JSON response wrapper. You could use this to choose the Mantle model subclass for serialization. 

## Unit Tests

Before running the tests, be sure to initialize the project by running the bootstrap script:

```bash
script/bootstrap
```

Run the tests with xctool. You'll need xctool version 0.1.14 or newer.

```bash
xctool -project Sculptor.xcodeproj -scheme 'Sculptor iOS' -sdk iphonesimulator -configuration Release test -test-sdk iphonesimulator
xctool -project Sculptor.xcodeproj -scheme 'Sculptor Mac' -sdk macosx -configuration Release test -test-sdk macosx
```

## TODO
* Request serialization (pending [AFNetworking 2.1](https://github.com/AFNetworking/AFNetworking/issues/1627))
* Full Unit Test Coverage (and Xcode support)
* Documentation

Sculptor intends to be compatible with Mantle 2.0, when that release is available.
