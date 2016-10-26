//
//  WebViewDelegate.m
//
//  Copyright (c) 2014 Ram Kulkarni (ramkulkarni.com). All rights reserved.
//
//

#import "WebViewDelegate.h"

@interface WebViewDelegate ()
	@property id<WebViewInterface> webInterface;
@end

@implementation WebViewDelegate 

- (id)initWithWebView:(UIWebView*) webView withWebViewInterface:(id<WebViewInterface>) webViewInterface
{
	self.webView = webView;
	
	self.webView.delegate = self;
	
	self.webInterface = webViewInterface;
	
	return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
    
}

//Loads page from a given folder. Supports only simple file and folder names. Does not support name with folder path. Valid usage - loadPage:@"index.html" fromFolder:@"www"
- (void) loadPage:(NSString*) pageName fromFolder:(NSString*) folderName
{
	NSRange range = [pageName rangeOfString:@"."];
    if (range.length > 0)
    {
        //調用loadPage時沒給資料夾名稱預設為index
		if (folderName == nil)
			folderName = @"index";
		
    	NSString *fileExt = [pageName substringFromIndex:range.location+1];
        NSString *fileName = [pageName substringToIndex:range.location];
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt inDirectory:folderName]];
				
		if (url != nil)
		{
       		NSURLRequest *req = [NSURLRequest requestWithURL:url];
            
       		[self.webView loadRequest:req];
		}
    }
}


- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        
        if (jsonError != nil)
        {
            //call error callback function here
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        return NO;
        
    }
    
    return YES;
}

- (void) callFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    NSError *error;
    
    id retVal = [self.webInterface processFunctionFromJS:name withArgs:args error:&error];
    
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    [self callSuccessCallback:successCallback withRetValue:retVal forFunction:name];
    
}

-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,msg]];
        
    }
    else
    {
        NSLog(@"%@",msg);
    }
    
}

-(void) callSuccessCallback:(NSString *) name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    if (name != nil)
    {
        //call succes handler
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %d", [args count]);
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,jsonStr]];
}

- (void) createError:(NSError**) error withMessage:(NSString *) msg
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:msg forKey:NSLocalizedDescriptionKey];
    
    *error = [NSError errorWithDomain:@"JSiOSBridgeError" code:-1 userInfo:dict];
    
}

-(void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg
{
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setValue:[NSNumber numberWithInt:code] forKey:@"code"];
    [msgDict setValue:msg forKey:@"message"];
    
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msgDict options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from error message  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [self createError:error withMessage:jsonStr];
}

@end


