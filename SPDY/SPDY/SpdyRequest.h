#import <Foundation/Foundation.h>

#import "SPDY.h"

@class SpdyRequest;

typedef void (^LLSpdySuccessCallback)(NSHTTPURLResponse*,NSData*);
typedef void (^LLSpdyPushSuccessCallback)(NSHTTPURLResponse*,NSData*,int32_t);
typedef void (^LLSpdyErrorCallback)(NSError*);
typedef void (^LLSpdyVoidCallback)();

@interface SpdyRequest : NSObject

/* this initializer is for HTTP GET */
- (id)initWithGETString:(NSString *)url;

/* this initializer can do GET or POST */
- (id)initWithRequest:(NSURLRequest *)request;

/* causes the request to be loaded */
- (void)send;

/* causes spdy to send a ping over the associated session, if connected */
- (void)sendPing;

/* closes all streams and sends a GOAWAY on the associated session */
- (void)teardown;

/* the url being loaded, as a string */
@property (nonatomic, strong, readonly) NSString* urlString;

/* the url being loaded as an NSURL */
@property (nonatomic, strong) NSURL* URL;

/* the body of the response, as NSData */
@property (nonatomic, strong) NSData* body;

/* if set to YES, causes kCFStreamNetworkServiceType to be set to
   kCFStreamNetworkServiceTypeVoIP (for voip background mode) 
   This needs to be set before the message fetch is sent. */
@property (nonatomic, assign) BOOL voip;

/* returns the current network status (3g, wifi, etc) of the underlying session.
   This enum is defined in SPDY.h */
@property (nonatomic, assign, readonly) SpdyNetworkStatus networkStatus;

/* returns the current connection state (connected, connecting, etc) of the underlying
   session.  This enum is defined in SPDY.h */
@property (nonatomic, assign, readonly) SpdyConnectState connectState; 

/* Block Callbacks */

/* called on success of the original request */
@property (nonatomic, copy) LLSpdySuccessCallback successCallback;

/* called on failure of the original request */
@property (nonatomic, copy) LLSpdyErrorCallback errorCallback;

/* called in the event that a valid push is received */
@property (nonatomic, copy) LLSpdyPushSuccessCallback pushSuccessCallback;

/* called in the event that a push error is received */
@property (nonatomic, copy) LLSpdyErrorCallback pushErrorCallback;

/* called when a ping response is received */
@property (nonatomic, copy) LLSpdyVoidCallback pingCallback;

/* called when the stream is closed */
@property (nonatomic, copy) LLSpdyVoidCallback streamCloseCallback;

/* called after the stream is first connected */
@property (nonatomic, copy) LLSpdyVoidCallback connectCallback;

@end
