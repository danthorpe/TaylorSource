//
//  FKFlickrContactsGetList.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrContactsGetList.h" 

@implementation FKFlickrContactsGetList



- (BOOL) needsLogin {
    return YES;
}

- (BOOL) needsSigning {
    return YES;
}

- (FKPermission) requiredPerms {
    return 0;
}

- (NSString *) name {
    return @"flickr.contacts.getList";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.filter) {
		[args setValue:self.filter forKey:@"filter"];
	}
	if(self.page) {
		[args setValue:self.page forKey:@"page"];
	}
	if(self.per_page) {
		[args setValue:self.per_page forKey:@"per_page"];
	}
	if(self.sort) {
		[args setValue:self.sort forKey:@"sort"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrContactsGetListError_InvalidSortParameter:
			return @"Invalid sort parameter.";
		case FKFlickrContactsGetListError_SSLIsRequired:
			return @"SSL is required";
		case FKFlickrContactsGetListError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrContactsGetListError_MissingSignature:
			return @"Missing signature";
		case FKFlickrContactsGetListError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrContactsGetListError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrContactsGetListError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrContactsGetListError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrContactsGetListError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrContactsGetListError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrContactsGetListError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrContactsGetListError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrContactsGetListError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrContactsGetListError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end