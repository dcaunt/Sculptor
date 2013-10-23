//
//  SCLURLModelMatcherSpec.m
//  Sculptor
//
//  Created by David Caunt on 20/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import "SCLTestModel.h"

SpecBegin(SCLURLModelMatcher)

it(@"should return nil when no match is found", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	Class cls = [matcher match:[NSURL URLWithString:@"/test"]];
	expect(cls).to.beNil();
});

it(@"should return the correct class when a match is found", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"test" forClass:SCLTestModel.class];
	[matcher addPath:@"alt" forClass:SCLAlternativeTestModel.class];
	
	Class cls = [matcher match:[NSURL URLWithString:@"test"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
	
	Class altCls = [matcher match:[NSURL URLWithString:@"alt"]];
	expect(altCls).notTo.beNil();
	expect(altCls).to.beSubclassOf(MTLModel.class);
	expect(altCls).to.equal(SCLAlternativeTestModel.class);
});

it(@"should match regardless of the presence of preceeding slashes in paths and URLs", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"/test" forClass:SCLTestModel.class];
	Class cls;
	
	cls = [matcher match:[NSURL URLWithString:@"test"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
	
	cls = [matcher match:[NSURL URLWithString:@"/test"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
	
	cls = [matcher match:[NSURL URLWithString:@"test/"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
});

it(@"should ignore the path prefix if present in a URL", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] initWithPathPrefix:@"v1"];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"test" forClass:SCLTestModel.class];
	
	Class cls = [matcher match:[NSURL URLWithString:@"v1/test"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
});

it(@"should only match if the number of path components is equal", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"test/foos" forClass:SCLTestModel.class];
	
	Class cls;
	
	cls = [matcher match:[NSURL URLWithString:@"test"]];
	expect(cls).to.beNil();
	cls = [matcher match:[NSURL URLWithString:@"foos"]];
	expect(cls).to.beNil();
	cls = [matcher match:[NSURL URLWithString:@"test/foos/bars"]];
	expect(cls).to.beNil();
	
	cls = [matcher match:[NSURL URLWithString:@"test/foos"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
});

it(@"should match digits if a # is used", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"test/#" forClass:SCLTestModel.class];
	
	Class cls = [matcher match:[NSURL URLWithString:@"test/42"]];
	
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
});

it(@"should not match non-digits if a # is used", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"test/#" forClass:SCLTestModel.class];
	
	Class cls = [matcher match:[NSURL URLWithString:@"test/foo"]];
	
	expect(cls).to.beNil();
});

it(@"should match everything if a * is used", ^{
	SCLURLModelMatcher *matcher = [[SCLURLModelMatcher alloc] init];
	expect(matcher).notTo.beNil();
	
	[matcher addPath:@"test/*" forClass:SCLTestModel.class];
	
	Class cls = [matcher match:[NSURL URLWithString:@"test/foo42"]];
	expect(cls).notTo.beNil();
	expect(cls).to.beSubclassOf(MTLModel.class);
	expect(cls).to.equal(SCLTestModel.class);
});

SpecEnd
