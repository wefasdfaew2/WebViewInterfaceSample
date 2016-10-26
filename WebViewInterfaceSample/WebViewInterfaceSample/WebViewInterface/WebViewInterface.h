//
//  WebViewInterface.h
//
//  Copyright (c) 2014 Ram Kulkarni (ramkulkarni.com). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebViewInterface <NSObject>
- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error;
@end
