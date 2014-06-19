//
//  CommonData.m
//  Watsons
//
//  Created by Fish on 11-4-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonData.h"

#import "SBJSON.h"
#import "User.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "AppDelegate.h"
//#import "StartViewController.h"
//#import "NSScanner.h"


@implementation CBLDatabase (FISH_HELPER)

- (NSString *) saveNewDocument:(NSDictionary *)dic
{
    CBLDocument * d = [self createDocument];
    NSError * e;
    [d putProperties:dic error:&e];
    if (e) {
        return nil;
    }
    return d.documentID;
}

- (NSError* ) saveDic:(NSDictionary *)dic toDoc:(CBLDocument*)doc
{
    NSError * e;
    [doc putProperties:dic error:&e];
    if (e) {
        return e;
    }
    return nil;
}

- (NSError* ) saveDic:(NSDictionary *)dic toDocID:(NSString*)docID
{
    NSError * e;
    CBLDocument * doc = [self documentWithID:docID];
    if (doc.properties) {
        NSMutableDictionary * md = [doc.properties mutableCopy];
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isEqualToString:@"_id"] || [key isEqualToString:@"_rev"] ) {
                
            }
            else{
                md[key] = obj;
            }
        }];
        
        [doc putProperties:md error:&e];
    }
    else [doc putProperties:dic error:&e];
    if (e) {
        return e;
    }
    return nil;
}
@end

 

@implementation NSNull (FishTest)

- (BOOL)isEqualToString:(NSString *)aString
{
    return NO;
}

@end


NSString * StringForSignature(NSDictionary * dic)
{
    NSMutableString * ms= [[NSMutableString alloc] init];
    NSArray * allKeys = [dic allKeys];
    NSArray * sortedKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString * key in sortedKeys ) {
        if ([ms length]>0) {
            [ms appendString:@"&"];
        }
        NSString * value= [dic valueForKey:key];
        NSString * skey = (NSString*)key;
        [ms appendString:[skey lowercaseString]];
        [ms appendString:@":"];
        [ms appendString:[value lowercaseString]];
    }


    return ms;
}

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (NSStringAdditions)

+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;

    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;

    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }

        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];

        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];

        ixtext += 3;
        charsonline += 4;

        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}
-(NSString*) sha1//:(NSString*)input
{
    // const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:input.length];
    NSData * data= [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;

}
@end


static inline char hexChar(unsigned char c) {
    return c < 10 ? '0' + c : 'a' + c - 10;
}

static inline void hexString(unsigned char *from, char *to, NSUInteger length) {
    for (NSUInteger i = 0; i < length; ++i) {
        unsigned char c = from[i];
        unsigned char cHigh = c >> 4;
        unsigned char cLow = c & 0xf;
        to[2 * i] = hexChar(cHigh);
        to[2 * i + 1] = hexChar(cLow);
    }
    to[2 * length] = '\0';
}

NSString * sha1(const char *string) {
    static const NSUInteger LENGTH = 20;
    unsigned char result[LENGTH];
    CC_SHA1(string, (CC_LONG)strlen(string), result);

    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);

    return @(hexResult);
}


@implementation SinaFace
@synthesize  facename;
@synthesize imgName;
@end

@implementation URLCache

@synthesize cachedResponses, responsesInfo;

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    [cachedResponses removeObjectForKey:request.URL.absoluteString];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
    NSLog(@"removeAllObjects");
    [cachedResponses removeAllObjects];
    [super removeAllCachedResponses];
}


- (void)saveInfo {
    if ([responsesInfo count]) {
        User * theUser = [User userManager];
        NSString *path = [theUser.user_doc_path stringByAppendingPathComponent:@"responsesInfo.plist"];
        [responsesInfo writeToFile:path atomically: YES];
    }
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        User * theUser = [User userManager];
        cachedResponses = [[NSMutableDictionary alloc] init];
        NSString *path = [theUser.user_doc_path stringByAppendingPathComponent:@"responsesInfo.plist"];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            responsesInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        } else {
            responsesInfo = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

+(BOOL) checkIfBufferd:(NSString*) urlString
{
    User * theUser = [User userManager];
    NSString *path = [theUser.user_doc_path stringByAppendingPathComponent:@"responsesInfo.plist"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:path]) {
        NSMutableDictionary *responsesInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        NSDictionary *responseInfo = responsesInfo[urlString];
        if (responseInfo) {
            NSString *path = [theUser.user_doc_path stringByAppendingPathComponent:responseInfo[@"filename"]];
            if ([fileManager fileExistsAtPath:path]) {
                return YES;
            }

        }

    }
    return NO;

}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }

    NSSet *supportSchemes = [NSSet setWithObjects:@"http", @"https", @"ftp", nil];
    NSURL *url = request.URL;
    if (![supportSchemes containsObject:url.scheme]) {
        return [super cachedResponseForRequest:request];
    }


    NSString *absoluteString = url.absoluteString;
    NSLog(@"%@", absoluteString);
    NSCachedURLResponse *cachedResponse = cachedResponses[absoluteString];
    if (cachedResponse) {
        NSLog(@"cached: %@", absoluteString);
        return cachedResponse;
    }

    NSDictionary *responseInfo = responsesInfo[absoluteString];
    if (responseInfo) {
        User * theUser = [User userManager];
        NSString *path = [theUser.user_doc_path stringByAppendingPathComponent:responseInfo[@"filename"]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {

            NSData *data = [NSData dataWithContentsOfFile:path];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:responseInfo[@"MIMEType"] expectedContentLength:data.length textEncodingName:@"UTF-8"];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];

            cachedResponses[absoluteString] = cachedResponse;
            NSLog(@"cached: %@", absoluteString);
            return cachedResponse;
        }
    }

    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&error];
    if (error) {
        NSLog(@"%@", error);
        NSLog(@"not cached: %@", absoluteString);
        return nil;
    }

    NSString *filename = sha1([absoluteString UTF8String]);
    User * theUser = [User userManager];
    NSString *path = [theUser.user_doc_path stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createFileAtPath:path contents:data attributes:nil];

    NSURLResponse *newResponse = [[NSURLResponse alloc] initWithURL:response.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:@"UTF-8"];
    responseInfo = @{@"filename": filename, @"MIMEType": newResponse.MIMEType};
    responsesInfo[absoluteString] = responseInfo;
    NSLog(@"saved: %@", absoluteString);

    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse data:data];
    cachedResponses[absoluteString] = cachedResponse;
    return cachedResponse;
}

@end






@implementation TempData

@synthesize  boolValue;
@synthesize  intValue;
@synthesize  floadValue;
@synthesize s1;
@synthesize s2;
@synthesize s3;
@synthesize deadLine;
@synthesize remainTimes;
@synthesize dic;
@end


@implementation ApplicationData
@synthesize applicationName;
@synthesize textColor;
@synthesize iconBackImage;
@synthesize iconHotImage;
@synthesize bigBackgroundImage;
@synthesize applicationID;
@synthesize	textPng;

@end



@implementation ButtonURL
@synthesize pb;
@synthesize ps;
-(id) initWithButton:(UIButton*)b andString:(NSString*)s
{
	if (!(self = [super init])) return nil;
	self.pb = b;
	self.ps = s;
	return self;
}
@end

static CommonData *sharedInstance = nil;





@implementation CommonData
@synthesize iSyncCount;
@synthesize preButton;
@synthesize nextButton;

@synthesize profileButton;
@synthesize typesCollection;
@synthesize savedImages;
@synthesize belowBackButton;
@synthesize belowShareButton;
@synthesize mainPageChangeableImages;
@synthesize shareString;
@synthesize shareSubject;
@synthesize sinafaceArray;
@synthesize pushOption;
@synthesize curentSubjectColor;
@synthesize currentSubjectIndex;
@synthesize isTrueDevice;
@synthesize isAppActive;
@synthesize userDefaults;
@synthesize systemDefaults;
@synthesize recentShops;
@synthesize searchkeys;
@synthesize iosVersion;
@synthesize activityIndicatorView_EmptyView;
@synthesize shareImageView;
@synthesize shareImageUrl;
@synthesize downloadedMagazings;
@synthesize bookMarkes;
@synthesize magaInfor;
@synthesize readedMagazines;
@synthesize iosVersionString;

@synthesize bundle_version;
@synthesize localeCode;
@synthesize currentPage;
@synthesize offline_label;
@synthesize theMainPageViewController;
//@synthesize sqlietedb;
@synthesize theWebView;
@synthesize token;
@synthesize token_timestamp;
@synthesize  macAddress;
@synthesize menuViewArray;
@synthesize userFolder;
@synthesize userTaskFolder;
@synthesize doNotReleaseViewControllers;
@synthesize pendingTasks;
@synthesize bHadLogin;
@synthesize bGetNewToken;
@synthesize delegateTo;
@synthesize managedObjectContext;
@synthesize imPort;
@synthesize imServer;
@synthesize challengeReservedArray;
@synthesize roleReservedArray;
@synthesize subReservedArray;
@synthesize challengeForSupportArray;
@synthesize templete_path  ;
@synthesize templeteDic  ;
@synthesize imageNode    ;
@synthesize imageTempNode;
@synthesize localeFileSchemaNode;
@synthesize emotionHtmlBaseURL;
@synthesize emojiDic;
@synthesize emojiArray;
@synthesize baiduBindData;
+(NSString*)MacAddress
{
    int                    mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;

	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;

	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}

	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}

	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}

	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		return NULL;
	}

	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	// NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

+(BOOL) isPdfZipFileExit: (NSString *)Document_ID TrueFileSizeKB:(NSString*) sizeKB
{
    NSString * strpath =[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"PDF"] stringByAppendingPathComponent:Document_ID]stringByAppendingPathComponent:@"PDF"];
    NSString * zippath=[[strpath stringByAppendingPathComponent:@"/"] stringByAppendingPathComponent:@"PDF.zip"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSDictionary * dic = [fileManager attributesOfItemAtPath:zippath error:nil];
    if (dic)
    {
        NSInteger zipsize = [dic fileSize];
        NSString * szipsize = [[NSString  stringWithFormat:@"%d", zipsize/1024] stringByAppendingString:@"K"];
        if ([szipsize isEqualToString:sizeKB]) {
            return TRUE;
        }
    }
    return FALSE;

}

+ (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);

    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));

    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);

    CFRelease(uuidObject);

    return uuidStr;
}

-(void)retainIsSync
{
    @synchronized(self){
        iSyncCount++;
    }
}

-(void)releaseIsSync
{
    @synchronized(self){
        iSyncCount--;
        if (iSyncCount<0) {
            iSyncCount=0;
        }
    }
}

-(CommonData*) init
{
	NSString *az_info_plistfilePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType: @"plist"];
    NSDictionary * az_info_plist = [NSDictionary dictionaryWithContentsOfFile:az_info_plistfilePath];
    self.bundle_version =[az_info_plist valueForKey:@"CFBundleShortVersionString"] ;

	UIDevice * device = [UIDevice currentDevice];
    [[NSUserDefaults standardUserDefaults] setObject: @[@"zh-Hans"] forKey:@"AppleLanguages"];
 //   NSArray * aaaaa = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	localeCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];

	typesCollection = [[NSMutableArray alloc] init];

    iSyncCount = 0;
    isAppActive= YES;
    self.macAddress = [CommonData MacAddress ];
    iosVersion= [@([device.systemVersion doubleValue]) intValue];
	iosVersionString = device.systemVersion;
 



    menuViewArray = [[NSMutableArray alloc] init];
    doNotReleaseViewControllers = [[NSMutableArray alloc] init];

    delegateTo = [[NSMutableArray alloc] init];
    roleReservedArray = [[NSMutableArray alloc] init];
    challengeReservedArray = [[NSMutableArray alloc] init];
    subReservedArray = [[NSMutableArray alloc] init];
    challengeForSupportArray = [[NSMutableArray alloc] init];

	//////////////////////////////////////////////////////////////////
	savedImagesDictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:SAVEDIMAGESDICTIONARYPATH  ];
	savedImages = [NSMutableDictionary dictionaryWithContentsOfFile:savedImagesDictionaryPath];

	if (savedImages == nil) {
		savedImages =[[ NSMutableDictionary alloc] init];
	}
	else {
	}


	NSFileManager * fileManager = [NSFileManager defaultManager];
	BOOL ISD= YES;
	if (![fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images"] isDirectory:&ISD]) {
		[fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images"] withIntermediateDirectories:NO  attributes:nil error:NULL];
	}



	timer2 = [NSTimer scheduledTimerWithTimeInterval:60 target:self	selector:@selector(saveSavedDatas) userInfo:nil repeats:YES];
	/////////////////////////////////////////////////////////////////////

    ///////////////////



	dbPath=[NSHomeDirectory()  stringByAppendingPathComponent:@"Documents/azcoaching.db"];


    if (![fileManager fileExistsAtPath:dbPath isDirectory:&ISD]) {
		NSString *tempdbpath = [[NSBundle mainBundle] pathForResource:@"azcoaching" ofType: @"db"];
        if (tempdbpath)
        {
            [fileManager copyItemAtPath:tempdbpath toPath:dbPath error:0];
        }
	}



  //  sqlietedb = [FMDatabase databaseWithPath:dbPath];
   /* if (![sqlietedb open]) {
        NSLog(@"Could not open db.");

    }
    [sqlietedb setShouldCacheStatements:YES];
    [sqlietedb executeUpdate:@"insert into testtable (name, age) values ('mike',24)"];
    FMResultSet * fmset = [sqlietedb executeQuery:@"select * from testtable"];
    while ([fmset next]) {
        NSString * name = [fmset stringForColumn:@"name"];
        long  age  = [fmset longForColumn:@"age"];
        int a =0;
    }
    [sqlietedb close];*/
	///////////////////////////////////
    recentShops = [NSMutableDictionary dictionaryWithContentsOfFile:[NSHomeDirectory()  stringByAppendingPathComponent:RECENTSHOPSPATH]];
	if (!recentShops) {
		recentShops = [[NSMutableDictionary alloc] init];
	}
	else {
	}
    ///////////////////////////////////
    searchkeys = [NSMutableDictionary dictionaryWithContentsOfFile:[NSHomeDirectory()  stringByAppendingPathComponent:SEARCHKEYSPATH]];
	if (!searchkeys) {
		searchkeys = [[NSMutableDictionary alloc] init];
	}
	else {
	}
    /////////////////////////////////////////////////////////////////////
	systemDefaults = [NSMutableDictionary dictionaryWithContentsOfFile:[NSHomeDirectory()  stringByAppendingPathComponent:SYSTEMDEFAULTSPATH]];
	if (!systemDefaults) {
		systemDefaults = [[NSMutableDictionary alloc] init];
	}
	else {
	}
	/////////////////////////////////
    bHadLogin = NO;
    bGetNewToken = NO;
    /////////////////
    templete_path = [[NSBundle mainBundle] pathForResource:@"templetes" ofType: @"plist"];
    templeteDic = [NSDictionary dictionaryWithContentsOfFile:templete_path];
    imageNode = [templeteDic valueForKey:@"imageNode"];
    imageTempNode = [templeteDic valueForKey:@"imageTempNode"];
    localeFileSchemaNode = [templeteDic valueForKey:@"localeFileSchemaNode"];
    /////////////////////////////////
    
    NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
    NSString *emojilistFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotion.plist"];
    self.emojiDic = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
    self.emojiArray = [[NSArray alloc ] initWithContentsOfFile:emojilistFilePath];
    
	//sinafaces
	sinafaceArray = [[NSMutableArray alloc] init];
	SinaFace * sf = [SinaFace alloc];
	sf.facename = @"/呵呵/";
	sf.imgName = @"smile.gif";
	[sinafaceArray addObject:sf];
	   
    
	sf = [SinaFace alloc];
	sf.facename = @"/嘻嘻/";
	sf.imgName = @"tooth.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/哈哈/";
	sf.imgName = @"laugh.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/爱你/";
	sf.imgName = @"love.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/晕/";
	sf.imgName = @"dizzy.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/泪/";
	sf.imgName = @"sad.gif";
	[sinafaceArray addObject:sf];
	   
    sf = [SinaFace alloc];
	sf.facename = @"/馋嘴/";
	sf.imgName = @"cz_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/抓狂/";
	sf.imgName = @"crazy.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/哼/";
	sf.imgName = @"hate.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/抱抱/";
	sf.imgName = @"bb_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/可爱/";
	sf.imgName = @"tz_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/怒/";
	sf.imgName = @"angry.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/汗/";
	sf.imgName = @"sweat.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/困/";
	sf.imgName = @"sleep_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/害羞/";
	sf.imgName = @"shame_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/睡觉/";
	sf.imgName = @"sleep_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/钱/";
	sf.imgName = @"money_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/偷笑/";
	sf.imgName = @"hei_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/酷/";
	sf.imgName = @"cool_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/衰/";
	sf.imgName = @"cry.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/吃惊/";
	sf.imgName = @"cj_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/闭嘴/";
	sf.imgName = @"bz_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/鄙视/";
	sf.imgName = @"bs2_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/挖鼻屎/";
	sf.imgName = @"kbs_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/花心/";
	sf.imgName = @"hs_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/鼓掌/";
	sf.imgName = @"gz_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/失望/";
	sf.imgName = @"sw_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/思考/";
	sf.imgName = @"sk_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/生病/";
	sf.imgName = @"sb_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/亲亲/";
	sf.imgName = @"qq_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/怒骂/";
	sf.imgName = @"nm_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/太开心/";
	sf.imgName = @"mb_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/懒得理你/";
	sf.imgName = @"ldln_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/右哼哼/";
	sf.imgName = @"yhh_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/左哼哼/";
	sf.imgName = @"zhh_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/嘘/";
	sf.imgName = @"x_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/委屈/";
	sf.imgName = @"wq_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/吐/";
	sf.imgName = @"t_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/可怜/";
	sf.imgName = @"kl_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/打哈气/";
	sf.imgName = @"k_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/顶/";
	sf.imgName = @"d_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/疑问/";
	sf.imgName = @"yw_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/做鬼脸/";
	sf.imgName = @"zgl_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/握手/";
	sf.imgName = @"ws_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/耶/";
	sf.imgName = @"ye_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/good/";
	sf.imgName = @"good_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/弱/";
	sf.imgName = @"sad_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/不要/";
	sf.imgName = @"no_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/ok/";
	sf.imgName = @"ok_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/赞/";
	sf.imgName = @"z2_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/来/";
	sf.imgName = @"come_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/蛋糕/";
	sf.imgName = @"cake.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/心/";
	sf.imgName = @"heart.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/伤心/";
	sf.imgName = @"unheart.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/钟/";
	sf.imgName = @"clock_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/猪头/";
	sf.imgName = @"pig.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/咖啡/";
	sf.imgName = @"cafe_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/话筒/";
	sf.imgName = @"m_thumb.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/月亮/";
	sf.imgName = @"moon.gif";
	[sinafaceArray addObject:sf];
	   
	sf = [SinaFace alloc];
	sf.facename = @"/太阳/";
	sf.imgName = @"sun.gif";
	[sinafaceArray addObject:sf];
	   
    /*
    NSMutableDictionary * aaaaa = [NSMutableDictionary new];
    NSMutableArray   * bbbb = [NSMutableArray new];
    for (SinaFace * ss in sinafaceArray) {
        [aaaaa setObject:ss.imgName forKey:ss.facename];
        [bbbb addObject:ss.facename];
    }
    
    [aaaaa writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"]  stringByAppendingPathComponent:@"aaaaa.plist"] atomically:YES ];
    [bbbb writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"]  stringByAppendingPathComponent:@"bbbb.plist"] atomically:YES ];
    */
	////////////////
  /*  sf = [self.sinafaceArray objectAtIndex:0];
    NSString * img_name = sf.imgName;
    NSString * ext = [img_name pathExtension];
    NSString * pure_name = [img_name substringToIndex:img_name.length- ext.length-1];
    NSString * img_Path =[[NSBundle mainBundle] pathForResource:pure_name ofType: ext];
    emotionHtmlBaseURL = [NSURL fileURLWithPath:img_Path isDirectory:NO ];
*/
    /////////////////
	return self;
}
-(void) initUserFolder
{
    User * theUser = [User userManager];
    self.userFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] stringByAppendingPathComponent:[[theUser userAccount] lowercaseString]];
    self.userTaskFolder = [userFolder stringByAppendingPathComponent:@"Tasks"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL fileDirectoryExists=[fm fileExistsAtPath:userFolder];
    if (!fileDirectoryExists) {
        [fm createDirectoryAtPath:userFolder withIntermediateDirectories:YES  attributes:nil error:NULL];
    }


	NSString * fileDirectory= [userFolder stringByAppendingPathComponent:@"maga_files/"];

    fileDirectoryExists=[fm fileExistsAtPath:fileDirectory];
    if (!fileDirectoryExists) {
        [fm createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES  attributes:nil error:NULL];
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
	BOOL ISD= YES;
    if (![fileManager fileExistsAtPath:[userFolder stringByAppendingPathComponent:@"Files/"] isDirectory:&ISD]) {
		[fileManager createDirectoryAtPath:[userFolder stringByAppendingPathComponent:@"Files/"] withIntermediateDirectories:NO  attributes:nil error:NULL];
	}
    //////////////////////////

    /////////////////////////////////////////////////////////////////////
     ISD= YES;
    if (![fileManager fileExistsAtPath:[userFolder stringByAppendingPathComponent:@"Tasks/"] isDirectory:&ISD]) {
		[fileManager createDirectoryAtPath:[userFolder stringByAppendingPathComponent:@"Tasks/"] withIntermediateDirectories:NO  attributes:nil error:NULL];
	}
    ///////////////////////
    userDefaults = [NSMutableDictionary dictionaryWithContentsOfFile:[userFolder stringByAppendingPathComponent:USERDEFAULTSPATH]];
	if (!userDefaults) {
		userDefaults = [[NSMutableDictionary alloc] init];
	}
    /////////
    if ([userDefaults valueForKey:@"forceversion"]) {
        NSNumber * n = [userDefaults valueForKey:@"forceversion"];
        NSNumber * l= @([ bundle_version doubleValue]);
        if ([l compare:n] == NSOrderedDescending) {
            [userDefaults setValue: l forKey:@"forceversion"];
        }
    }
    else{
        [userDefaults setValue:@1.0 forKey:@"forceversion"];
    }
    ///////////
    if (![userDefaults valueForKey:@"last_excute_time_master"]) {//上一次同步主数据的服务器时间

        [userDefaults setValue:@1.0 forKey:@"last_excute_time_master"];
    }
    if (![userDefaults valueForKey:@"last_excute_time_template"]) {//上一次同步主数据的服务器时间

        [userDefaults setValue:@1.0 forKey:@"last_excute_time_template"];
    }
    if (![userDefaults valueForKey:@"last_excute_time_formdata"]) {//上一次同步主数据的服务器时间

        [userDefaults setValue:@1.0 forKey:@"last_excute_time_formdata"];
    }
    if (![userDefaults valueForKey:@"last_excute_time_activity"]) {//上一次同步主数据的服务器时间

        [userDefaults setValue:@1.0 forKey:@"last_excute_time_activity"];
    }
    ////////////////////
    downloadedMagazings = [NSMutableDictionary dictionaryWithContentsOfFile:[userFolder stringByAppendingPathComponent:DOWNLOADEDMAGAZINGSPATH]];
	if (!downloadedMagazings) {
		downloadedMagazings = [[NSMutableDictionary alloc] init];
	}
	else {
	}
    //////////////////////////
    pendingTasks = [NSMutableDictionary dictionaryWithContentsOfFile:[userFolder stringByAppendingPathComponent:PENDINGTASKSPATH]];
	if (!pendingTasks) {
		pendingTasks = [[NSMutableDictionary alloc] init];
	}
	else {
	}
    /////////////////////////////////////////////////////////////////////

    bookMarkes = [NSMutableDictionary dictionaryWithContentsOfFile:[userFolder stringByAppendingPathComponent:BOOKMARKSSPATH]];
	if (!bookMarkes) {
		bookMarkes = [[NSMutableDictionary alloc] init];
	}
	else {
	}

    /////////////////////////////////////////////////////////////////////

    magaInfor = [NSMutableDictionary dictionaryWithContentsOfFile:[userFolder stringByAppendingPathComponent:MAGAINFORPATH]];
	if (!magaInfor) {
		magaInfor = [[NSMutableDictionary alloc] init];
	}
	else {
	}

    /////////////////////////////////////////////////////////////////////

    readedMagazines = [NSMutableDictionary dictionaryWithContentsOfFile:[userFolder stringByAppendingPathComponent:READEDMAGAZINESPATH]];
	if (!readedMagazines) {
		readedMagazines = [[NSMutableDictionary alloc] init];
	}
	else {
	}

	/////////////////////////////////////////////////////////////////////



	//////////////////
    dbPath = [userFolder stringByAppendingPathComponent:@"unileveremagazing.db"];
    if (![fileManager fileExistsAtPath:dbPath isDirectory:&ISD]) {
        NSString * tempdbpath =  [[NSBundle mainBundle] pathForResource:@"unileveremagazing" ofType:@"db"];
        if(tempdbpath)
        {
            NSError * e=0;
            [fileManager copyItemAtPath:tempdbpath toPath:dbPath error:&e];
            if (!e) {

            }
        }
    }
}
+ (id)sharedCommonData
{
    if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];

    return sharedInstance;
}
-(NSString *) querySavedImage: (NSString *) imageURL
{
	NSURL * imageurl = [NSURL URLWithString:imageURL];

	NSString * fileName = [imageurl lastPathComponent];
	id value =	savedImages[fileName];
	if (value ==nil) {
		return nil;
	}
	else {
		return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images/"  ] stringByAppendingPathComponent:fileName];
	}

}

-(void) saveSavedDatas
	 {

		 if ( savedImages  ) {
			 [savedImages writeToFile:savedImagesDictionaryPath atomically:YES ];
		 }
         if ( systemDefaults  ) {
			 [systemDefaults writeToFile:[NSHomeDirectory()  stringByAppendingPathComponent:SYSTEMDEFAULTSPATH] atomically:YES ];
		 }
         if ( recentShops  ) {
			 [recentShops writeToFile:[NSHomeDirectory()  stringByAppendingPathComponent:RECENTSHOPSPATH] atomically:YES ];
		 }
         if ( searchkeys  ) {
			 [searchkeys writeToFile:[NSHomeDirectory()  stringByAppendingPathComponent:SEARCHKEYSPATH] atomically:YES ];
		 }
		 if ( userDefaults  ) {
			 [userDefaults writeToFile:[userFolder  stringByAppendingPathComponent:USERDEFAULTSPATH] atomically:YES ];
		 }
         if (downloadedMagazings  ) {
			 [downloadedMagazings writeToFile:[userFolder stringByAppendingPathComponent:DOWNLOADEDMAGAZINGSPATH] atomically:YES ];
		 }
         if (bookMarkes  ) {
			 BOOL b = [bookMarkes writeToFile:[userFolder stringByAppendingPathComponent:BOOKMARKSSPATH] atomically:YES ];
             int a=0;
		 }

         if (magaInfor  ) {
			 [magaInfor writeToFile:[userFolder stringByAppendingPathComponent:MAGAINFORPATH] atomically:YES ];
		 }

         if (readedMagazines  ) {
			 [readedMagazines writeToFile:[userFolder stringByAppendingPathComponent:READEDMAGAZINESPATH] atomically:YES ];
		 }

         if (pendingTasks) {
             [pendingTasks writeToFile:[userFolder stringByAppendingPathComponent:PENDINGTASKSPATH] atomically:YES ];
         }

	 }

+ (void) checkNetworkStatus: (id) value {
/*    User * gUser = [User userManager];
    if([value isKindOfClass:[NSError class]]) {
        gUser.isOffLine = TRUE;

    }

    else if([value isKindOfClass:[SoapFault class]]) {
        gUser.isOffLine = TRUE;

    }

    if (gUser.isOffLine  ) {
        CommonData * gData = [CommonData sharedCommonData];
        gData.offline_label.hidden = NO;

        if (gUser.fish_flag) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"error", @"platform",nil) message:NSLocalizedStringFromTable(@"access_webservice_failed", @"platform",nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"confirm", @"platform",nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }



        [[NSNotificationCenter defaultCenter] postNotificationName:@"begin_offline_mode" object:nil  ];
    }*/
}


-(NSString*) getBackUpButtonSelector:(UIControl*)control
{
	NSSet * set = [control allTargets];
	id oldTarget = [ set anyObject];

	NSArray* array = [control actionsForTarget:oldTarget forControlEvent:UIControlEventTouchUpInside] ;

	return  array[0];
}
-(NSString*) getBackUpButtonSelector
{
	NSSet * set = [belowBackButton allTargets];
	id oldTarget = [ set anyObject];

	NSArray* array = [belowBackButton actionsForTarget:oldTarget forControlEvent:UIControlEventTouchUpInside] ;

	return  array[0];
}
-(id)getBackUpButtonTarget:(UIControl*) control
{
    NSSet * set = [control allTargets];
	return [ set anyObject];
}
-(id)getBackUpButtonTarget
{
	NSSet * set = [belowBackButton allTargets];
	return [ set anyObject];
}
-(void) saveBackUpButtonStateWithNewTarget:(id)newT andAction:(SEL) act
{
	[belowBackButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
	[belowBackButton addTarget:newT action:act forControlEvents:UIControlEventTouchUpInside];

}
-(void) setNavigateButtonTarget:(id)preTarget preAction:(SEL) preAct nextTarget:(id)nextTarget nextAction:(SEL) nextact
{
	[preButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];


	[nextButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];


	[preButton addTarget:preTarget action:preAct forControlEvents:UIControlEventTouchUpInside];
    [nextButton addTarget:nextTarget action:nextact forControlEvents:UIControlEventTouchUpInside];
}
-(void) restoreBackUpButtonState:(UIControl*) control WithOldTarget:(id) oldTarget andoldSelectorString:(NSString*) oldSelectorString
{
    [control removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
	[control addTarget:oldTarget action:NSSelectorFromString(oldSelectorString) forControlEvents:UIControlEventTouchUpInside];
}
-(void) restoreBackUpButtonStateWithOldTarget:(id) oldTarget andoldSelectorString:(NSString*) oldSelectorString
{
	[belowBackButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
	[belowBackButton addTarget:oldTarget action:NSSelectorFromString(oldSelectorString) forControlEvents:UIControlEventTouchUpInside];

}
-(bool) getShareButtonState:(NSString*) willShareString andShareSubject:(NSString*) subject andShareImageView:(UIImageView*) imageView  andShareImageURL:(NSString*) imageUrl
{



	shareString = [willShareString copy];
	shareSubject = [subject copy];
	shareImageView = imageView;
	shareImageUrl = [imageUrl copy];
	return belowShareButton.hidden;

}
//bill.ma add functino control tab double click
+(void) setViewControllerTopInNavigation:(UIViewController *)viewControl NavigationCtrl:(UINavigationController*) aNavi animated:(BOOL)animated
{
	[aNavi popToRootViewControllerAnimated:NO];

	if([aNavi.viewControllers indexOfObject:viewControl] == NSNotFound)
	{
		[aNavi pushViewController:viewControl animated:animated];
	}
	[aNavi popToViewController:viewControl animated:animated];
}
-(void)ShowWaitView:(UIView*) parentView  WithMsg:(NSString *)msg
{
    if (!theWaitViewController) {
        theWaitViewController = [[WaitViewController alloc] initWithNibName:@"WaitViewController_ipad" bundle:nil];
        //[self presentModalViewController:w animated:NO];
        theWaitViewController.msg = msg;
        [parentView addSubview:theWaitViewController.view];
        [self.doNotReleaseViewControllers addObject:theWaitViewController];
    }


}
-(void)HideWaitView
{
    if (theWaitViewController) {
        [theWaitViewController.view removeFromSuperview];
        [self.doNotReleaseViewControllers removeObject:theWaitViewController];
        theWaitViewController = nil;

    }
}

-(void)RefreshWaitView
{
    if (theWaitViewController) {
        [theMainPageViewController.view bringSubviewToFront:theWaitViewController.view];

    }
}
+(void) hideBelowView:(BOOL)bHide
{

}
+(void) hideShareView:(BOOL)bHide
{
	TempData  * dd = [TempData alloc];   dd.boolValue = bHide;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOWSHAREBUTTON" object:dd];
}



+(void) addArrowForUITableViewCell:(UITableViewCell *) cell withImageFileName:(NSString*) imageName
{
	cell.accessoryView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]  ];
	UIView * v =  cell.accessoryView;
	CGPoint  center = v.center;
	CGRect  rc = v.frame;
	float width = rc.size.width;
	float height = rc.size.height;
	rc.origin.x += width/4;
	rc.origin.y+= height/4;
	rc.size.height = height/2;
	rc.size.width = width/2;
	v.frame = rc;
	v.center = center;
}

-(void) dealloc
{
	//app will close, needn't to release the resource.

	[self saveSavedDatas];
//	[savedImagesDictionaryPath release];
//	[savedImagesDictionaryPath release];
	[timer1 invalidate];
	[timer2 invalidate];
}
+ (void)showAlertView:(NSString*)title message:(NSString*)msg{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title  message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)postStringAsynchronously:(NSString*)str connectionDelegate:(id) delegate
{
    NSURL *url = [NSURL URLWithString:BASEURL];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSString *msgLength = [NSString stringWithFormat:@"%d", [str length]];

    [req addValue:@"application/x-www-form-urlencoded"    forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody: [str dataUsingEncoding:NSUTF8StringEncoding]];



    [NSURLConnection connectionWithRequest:req delegate:delegate];

}


+(NSString*)PostString:(NSString*)str    UsingSpecialURL:(NSString*) baseurl2
{
    NSURL *url;
    if (baseurl2) {
        url = [NSURL URLWithString:BASEURL2];
    }
    else
    {
        url = [NSURL URLWithString:BASEURL];
    }
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSString *msgLength = [NSString stringWithFormat:@"%d", [str length]];

    [req addValue:@"application/x-www-form-urlencoded"    forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody: [str dataUsingEncoding:NSUTF8StringEncoding]];
   // [req setTimeoutInterval:3];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSError * e=0;
//    NSString *begint = [@"post string begin at :" stringByAppendingString:[[NSDate date] description]];
 //   NSLog( begint);
    NSData * d = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error: &e];
 //   NSString *endt = [@"post string end at :" stringByAppendingString:[[NSDate date] description]];
  //  NSLog( endt);
    NSString *responseDataStrFish = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    User * theUser =[User userManager];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;



    NSDictionary * resdic = [responseDataStrFish JSONValue];
    if (e && e.domain == NSURLErrorDomain && e.code == NSURLErrorCannotConnectToHost) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message: @"无法连接到服务器, 进入离线模式。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        theUser.isOffLine = TRUE;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BEGINOFFLINE" object:self userInfo:nil];
        return 0;
    }
    else if (resdic && [resdic valueForKey:@"response_id"]) {

        NSNumber * nid = [resdic valueForKey:@"response_id"];
        if ([nid intValue] == 0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message: [resdic valueForKey:@"response_msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return 0;
        }
    }
    if (!resdic  ) {

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message: @"连接服务器出错，请再试一次。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return 0;
    }

    return  responseDataStrFish;
}


+(BOOL) forceCheckToken:(NSString *)specialURL
{
    CommonData * gcd = [CommonData sharedCommonData];
    User * theUser = [User userManager];
    NSDate * date = [NSDate  date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    NSNumber * num = @(interval);
    interval = [num longLongValue] - gcd.token_timestamp;


        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue: @"get_token" forKey:@"request_id"];
        [dic setValue:theUser.userAccount forKey:@"user_account_id"];
        [dic setValue:theUser.password forKey:@"pass_word"];
        [dic setValue:CLIENT_TYPE forKey:@"app_type"];
        [dic setValue:gcd.macAddress forKey:@"device_id"];
        NSString *postString =[dic JSONRepresentation];

        UIApplication * app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible= YES;

        NSString * result= [CommonData PostString:postString UsingSpecialURL:specialURL ];
        if (!result) {
            return FALSE;
        }
        NSDictionary * resdic = [result JSONValue];
        gcd.token = resdic[@"token"];
        date = [NSDate  date];
        interval = [date timeIntervalSince1970];
        num = @(interval);
        gcd.token_timestamp = [num longLongValue];

        return  TRUE;

}

//fish: original method, the token is managed by ourself.
+(BOOL) checkToken
{
    CommonData * gcd = [CommonData sharedCommonData];
    User * theUser = [User userManager];
    NSDate * date = [NSDate  date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    NSNumber * num = @(interval);
    interval = [num longLongValue] - gcd.token_timestamp;
    if (interval/60>9) {

        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue: @"get_token" forKey:@"request_id"];
        [dic setValue:theUser.userAccount forKey:@"user_account_id"];
        [dic setValue:theUser.password forKey:@"pass_word"];
        [dic setValue:CLIENT_TYPE forKey:@"app_type"];
        [dic setValue:gcd.macAddress forKey:@"device_id"];
        NSString *postString =[dic JSONRepresentation];

        UIApplication * app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible= YES;

        NSString * result= [CommonData PostString:postString UsingSpecialURL:0  ];
        if (!result) {
            return FALSE;
        }
        NSDictionary * resdic = [result JSONValue];
        gcd.token = resdic[@"token"];
        date = [NSDate  date];
        interval = [date timeIntervalSince1970];
        num = @(interval);
        gcd.token_timestamp = [num longLongValue];

        return  TRUE;

    }
    return TRUE;
}

//fish: new method, even the token is managed by ourself, but this will be constrained by the oauth access token.
+(BOOL) checkTokenForOAuth
{
    CommonData * gcd = [CommonData sharedCommonData];
    NSNumber * zzz = [gcd.systemDefaults valueForKey:@"token_dead_line"];

    NSDate * date = [NSDate  date];
    NSTimeInterval interval = [date timeIntervalSince1970];

    if (interval>= zzz.intValue-1800) {//tolerance is half hour.
   // if (interval>= zzz.intValue ) {
        return  FALSE;

    }
    //NSLog(@"目前check token已经被禁用。");
    return TRUE;
}


+(NSString*) MakeCategoryString:(NSArray *) ctids baseDB:(NSArray *)categorys
{
    NSString * str = @"";
    for (NSString * cid in ctids ) {
        for (NSDictionary * dic in categorys) {
            if ([[dic valueForKey:@"category_id"] isEqualToString:  cid]) {
                str = [str stringByAppendingString:   [dic valueForKey:@"category_name"]];
                str = [str stringByAppendingString:   @"  "];
            }
        }
    }


    return str;
}
+(NSString *) FindChannelNameWithID:(NSString *) channelsID channels:(NSArray *)channels
{
        for (NSDictionary * dic in channels ) {
            if ([[dic valueForKey:@"channel_id"] isEqualToString:  channelsID]) {
                return  [dic valueForKey:@"channel_name"];
            }
        }
    return 0;

}
+(int ) FindTagIndexWithID:(NSNumber *) tagid tags:(NSArray *)tags
{
    NSDictionary * dic ;
    for (int i=0 ; i< [tags count]; i++) {
        dic = tags[i];
        if ([[dic valueForKey:@"tagid"] isEqualToNumber:tagid]) {
            return i;
        }
    }
    return -1;
}

+(int ) FindTagIndexWithSTRID:(NSString *) tagid tags:(NSArray *)tags
{
    NSDictionary * dic ;
    for (int i=0 ; i< [tags count]; i++) {
        dic = tags[i];
        if ([[dic valueForKey:@"tagid"] isEqualToString:tagid]) {
            return i;
        }
    }
    return -1;
}

+(int ) FindChannelIndexWithID:(NSString *) channelsID channels:(NSArray *)channels
{
    NSDictionary * dic ;
    for (int i=0 ; i< [channels count]; i++) {
        dic = channels[i];
        if ([[dic valueForKey:@"channel_id"] isEqualToString:channelsID]) {
            return i;
        }
    }
    return -1;
}
+(int) FindCatagaryIndexWithID:(NSString *) catid catagary:(NSArray *)catagarys
{
    NSDictionary * dic ;
    for (int i=0 ; i< [catagarys count]; i++) {
        dic = catagarys[i];
        if ([[dic valueForKey:@"category_id"] isEqualToString:catid]) {
            return i;
        }
    }
    return -1;
}

+(NSDictionary *) FindZoneWithID:(NSString *) tagid zones:(NSArray *)zones
{
    for (NSDictionary * dic in zones ) {
        if ([[dic valueForKey:@"zone_id"] isEqualToString:tagid]) {
            return dic;
        }
    }
    return 0;
}

+(NSDictionary *) FindProvinceWithID:(NSString *) tagid provinces:(NSArray *)provinces
{
    for (NSDictionary * dic in provinces ) {
        if ([[dic valueForKey:@"province_id"] isEqualToString:tagid]) {
            return dic;
        }
    }
    return 0;
}

+(NSDictionary *) FindMagaWithID:(NSString *) tagid allMagaInfo:(NSDictionary*) allMagaInfo
{
    NSArray * allvalues = [allMagaInfo allValues];
    for (NSArray * array in allvalues) {
        for (NSDictionary * dic in array ) {
            if ([[[dic valueForKey:@"periodical_id"] stringValue] isEqualToString:tagid]) {
                return  dic;
            }
        }
    }
    return 0;
}

+(void)hideMenu
{
    CommonData * gcd = [CommonData sharedCommonData];
    [UIView beginAnimations:@"MOVE" context:nil];
	[UIView setAnimationDuration:0.5];
    for (UIView * v in gcd.menuViewArray ) {
        CGRect   frame = v.frame;
        if (frame.origin.y<440) {
            frame.origin.y  += 50;
        }

        v.frame = frame;
    }
    [UIView commitAnimations];


}
+(void)showMenu
{
    CommonData * gcd = [CommonData sharedCommonData];
    [UIView beginAnimations:@"MOVE" context:nil];
	[UIView setAnimationDuration:0.5];
    for (UIView * v in gcd.menuViewArray ) {
        CGRect   frame = v.frame;
        if (frame.origin.y>440) {
            frame.origin.y -= 50;
        }
        v.frame = frame;
    }
    [UIView commitAnimations];
}




-(BOOL)checkDownloadedMagazing:(NSNumber*)magid
{
    NSArray * allKeys = [downloadedMagazings allKeys];
    for (NSNumber * mid in allKeys ) {
        if ([mid intValue]== [magid intValue]) {
            return YES;
        }
    }
    return NO;
}

-(NSArray*) mergeMagaInfor:(NSArray*)newMagalist forMagaID:(NSNumber*) magid
{
    NSString * smagid = [magid stringValue];

    if ([magaInfor valueForKey:smagid]) {
        NSArray * arr = [magaInfor valueForKey:smagid];
        NSMutableArray * marr = [NSMutableArray arrayWithArray:newMagalist];
        for (NSDictionary * dic in arr) {
            NSNumber * pid = [dic valueForKey:@"periodical_id"];
            if ([self checkDownloadedMagazing:pid]) {
                BOOL bin = NO;
                for (NSDictionary *nd in marr ) {
                    NSNumber * npid = [nd valueForKey:@"periodical_id"];
                    if ([npid integerValue] == [pid integerValue ]) {
                        bin = YES;
                        break;
                    }
                }

                if (!bin) {
                    [marr addObject:dic];
                }

            }
        }
        [magaInfor setValue:marr forKey:[magid stringValue]];
        [self saveSavedDatas];
        return marr;

    }
    else{
        [magaInfor setValue:newMagalist forKey:[magid stringValue]];
         [self saveSavedDatas];
        return newMagalist;
    }

    return 0;

}

-(NSString*) invokeJSFunction:(NSString*)function withParam:(NSString*) params
{
    NSString * fun =[function stringByAppendingString:   @"('"];
    fun = [fun stringByAppendingString:params];
    fun = [fun stringByAppendingString:@"');"];
    return  [ theWebView   stringByEvaluatingJavaScriptFromString:fun];
}

+ (NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [kvPair[0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [kvPair[1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            pairs[key] = value;
        }
    }

    return [NSDictionary dictionaryWithDictionary:pairs];
}

+(NSString*)formatDate:(NSDate*) date
{
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents *componts = [[NSCalendar currentCalendar] components:flags fromDate:date];


    NSString * fs  ;

    if ([componts month]<10 && [componts day]<10)
    {
        fs = @"%d/0%d/0%d";
    }
    else if ([componts month]<10 && [componts day]>9)
    {
        fs = @"%d/0%d/%d";
    }
    else if ([componts month]>9 && [componts day]<10)
    {
        fs = @"%d/%d/0%d";
    }
    else if ([componts month]>9 && [componts day]>9)
    {
        fs = @"%d/%d/%d";
    }
    NSString * ddd = [NSString stringWithFormat:fs, [componts year], [componts month], [componts day]];
    return ddd;
}

+(NSString*)formatSpecialDate:(NSDate*) date
{
    NSDate * today = [NSDate date];
    if ( [[CommonData formatDate:today] isEqualToString:[CommonData formatDate:date]])
    {
        NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *componts = [[NSCalendar currentCalendar] components:flags fromDate:date];


        NSDateFormatter*formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"a HH:mm"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *locationString=[formatter stringFromDate: date];

        return locationString;


    }
    else{
        return [CommonData formatDate:date];
    }


}

+(NSString*)formatTime:(NSDate*) date
{
        NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *componts = [[NSCalendar currentCalendar] components:flags fromDate:date];


        NSDateFormatter*formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"a HH:mm"];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *locationString=[formatter stringFromDate: date];

        return locationString;





}



+(NSInteger) heightOfLabel:(NSString *)text forLabel:(UILabel*)label
{
    
    
    
    UIFont* keyValueFont = label.font;
    CGSize keyValueSize = label.frame.size;
    if (!text || [text isKindOfClass:[NSNull class]]) {
        return keyValueSize.height;
        
    }
    if ( keyValueFont ) {
        CGSize constraintSize = CGSizeMake(keyValueSize.width, MAXFLOAT);
        CGSize labelSize = [text sizeWithFont:keyValueFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];

        return  labelSize.height> keyValueSize.height ? labelSize.height : keyValueSize.height;

    }
    return 44;
}

- (NSManagedObjectContext *) managedObjectContext{
    if(managedObjectContext == nil){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask] lastObject];
        NSURL *storeDatabaseURL = [url URLByAppendingPathComponent:@"im.sqlite"];
        // 设置SQLite 数据库存储路径 /ShoppingCart.sqlite
        NSError *error = nil;

        //根据被管理对象模型创建NSPersistentStoreCoordinator 对象实例

        NSPersistentStoreCoordinator *persistentStoreCoordinator =   [[NSPersistentStoreCoordinator alloc]  initWithManagedObjectModel: [NSManagedObjectModel mergedModelFromBundles:nil]];

        //根据指定的存储类型和路径，创建一个新的持久化存储（Persistent Store）
        if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:storeDatabaseURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error])
        {
            NSLog(@"Error while loading persistent store ...%@", error);
        }

        managedObjectContext = [[NSManagedObjectContext alloc] init];

        //设置当前被管理对象上下文的持久化存储协调器
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator]; }

    // 返回初始化的被管理对象上下文实例
    return managedObjectContext;
}

+(void) forceMicrosoftYaHei  :(UILabel*)label
{/*
    UIFont * oldFont = label.font;
    label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:oldFont.pointSize];
  */
}



+(void) forceMicrosoftYaHei_Bold  :(UILabel*)label
{/*
    UIFont * oldFont = label.font;
    label.font = [UIFont fontWithName:@"MicrosoftYaHei-Bold" size:oldFont.pointSize];
  */
}

+(void)forceAllControlsToMicrosoftYaHei:(UIView *)rootview indent:(NSInteger)indent
{
    if ([rootview isKindOfClass: [UILabel class]])
    {
        UILabel * c = (UILabel*) rootview;
        [CommonData forceMicrosoftYaHei:c];
    }
    else if ([rootview isKindOfClass: [UITextField class]])
    {
        UITextField * c = (UITextField*) rootview;
        [CommonData forceMicrosoftYaHei:c];
    }
    else if ([rootview isKindOfClass: [UITextView class]])
    {
        UITextView * c = (UITextView*) rootview;
        [CommonData forceMicrosoftYaHei:c];
    }
    else if ([rootview isKindOfClass: [UIButton class]])
    {
        UIButton * c = (UIButton*) rootview;
        [CommonData forceMicrosoftYaHei:c];
    }

    indent++;
    for (UIView *aview in [rootview subviews])
    {
        [ CommonData forceAllControlsToMicrosoftYaHei:aview indent:indent];
    }

}

//模拟翻滚提示 mzm add
static BOOL dealwithing = NO;
-(void) presentHitViewWithMsg:(NSString *)msg
{

    if(!self.hintMsgArray)
    {
        self.hintMsgArray = [[NSMutableArray alloc] init];
    }
     
    {
        [self.hintMsgArray addObject:msg];
    }
    
    if(!dealwithing)
    {
        [self dealwithHitMsg];
    }
}

-(void)dealwithHitMsg
{
  /*  NSLog(@"self.hintMsgArray.count=%d",self.hintMsgArray.count);
    dealwithing = YES;
    if(self.hintMsgArray.count == 0)
    {
        dealwithing = NO;
        return;
    }
    
    //播放声音
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1109);
    
    
    AppDelegate* appdelete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIButton *hintBtn = (UIButton *) [appdelete.startViewController.view viewWithTag:976];
    if(!hintBtn)
    {
        hintBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [appdelete.startViewController.view addSubview:hintBtn];
    }
    hintBtn.alpha = 0.0;

    [hintBtn setBackgroundImage:[UIImage imageNamed:@"im_timebg"] forState:UIControlStateNormal];
    hintBtn.frame = CGRectMake(0, 0, 320, 40);
    [hintBtn setTitle:self.hintMsgArray[0] forState:UIControlStateNormal];
    [hintBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        hintBtn.alpha = 0.7;
    } completion:^(BOOL finished) {
        
        CATransition *animation = [CATransition animation];
        [animation setValue:self.hintMsgArray[0] forKey:@"hintMMM"];
        [animation setValue:hintBtn forKey:@"hintBtn"];
        animation.delegate = self;
        animation.duration = 2.0f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeBackwards;
        animation.removedOnCompletion = YES;
        animation.type = @"cube";
        [hintBtn.layer addAnimation:animation forKey:@"animation"];
    }];
   */
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    //AppDelegate* appdelete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    //UIButton *hintBtn = (UIButton *) [appdelete.startViewController.view viewWithTag:976];
     UIButton*hintBtn = [theAnimation valueForKey:@"hintBtn"];
    if(hintBtn)
    {
        [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            hintBtn.alpha = 0.0f;
        
        } completion:^(BOOL finished) {
            
             [hintBtn removeFromSuperview];
            
            NSString*vaue = [theAnimation valueForKey:@"hintMMM"];
            [self.hintMsgArray removeObject:vaue];
            [self dealwithHitMsg];
        }];
    }

}

static NSTimeInterval lastShowTime = 0;

+ (void)showNetworkErrorAlertView
{
    
    NSTimeInterval newTime= [[NSDate date] timeIntervalSince1970];
    NSLog(@"endTime = %f",newTime);
    NSLog(@"startTime = %f",lastShowTime);
      
    NSTimeInterval    interval = newTime-lastShowTime;
        if (interval>5) {
          //  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""  message:@"网络无法连接！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""  message:@"系统故障，请稍后再试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
     
    lastShowTime= [[NSDate date] timeIntervalSince1970];
}

-(NSString*) replaceEmotionIcon:(NSString * ) string
{
    
    
    for (SinaFace * sf in self.sinafaceArray ) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:sf.facename options:0 error:NULL];
        if (regex != nil) {
            
            NSArray *array =    nil;
            
            array = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
            NSString *str1 = nil;
            for (int i = array.count-1; i>=0; i--)
            {
                NSTextCheckingResult* tcr =   array[i];
                str1 = [string substringWithRange:tcr.range];
                NSString * img_name = sf.imgName;
                NSString * ext = [img_name pathExtension];
                NSString * pure_name = [img_name substringToIndex:img_name.length- ext.length-1];
                NSString * img_Path =[[NSBundle mainBundle] pathForResource:pure_name ofType: ext];
                NSString * localeFileSchemaNode = self.localeFileSchemaNode;
                //img_Path = [gcd.localeFileSchemaNode stringByAppendingString:img_Path];
                //  img_Path = [@"/sinaface/" stringByAppendingString:img_name];
                //   img_Path = img_name;
                NSString * imageTempNode = [self.imageTempNode stringByReplacingOccurrencesOfString:@"&path&" withString:img_name];
                string =[string stringByReplacingOccurrencesOfString: sf.facename   withString : imageTempNode];
            }
        }
        
    }
    return string;
}

-(NSString*) transformToHtml:(NSString*) source
{
    NSString *htmlBody = [self replaceEmotionIcon:source];
    
    NSString * htmlNode = [self.templeteDic valueForKey:@"htmlNode"];
    
    htmlBody = [htmlNode stringByReplacingOccurrencesOfString:@"&body&" withString:htmlBody];
    
    return htmlBody;
}
/*
#pragma mark - 正则匹配电话号码，网址链接，Email地址
- (NSMutableArray *)addHttpArr:(NSString *)text
{
    //匹配网址链接
    NSString *regex_http = @"(https?|ftp|file)+://[^\\s]*";
    NSArray *array_http = [text componentsMatchedByRegex:regex_http];
    NSMutableArray *httpArr = [NSMutableArray arrayWithArray:array_http];
    return httpArr;
}

- (NSMutableArray *)addPhoneNumArr:(NSString *)text
{
    //匹配电话号码
    NSString *regex_phonenum = @"\\d{3}-\\d{7}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{8}|1+[358]+\\d{9}|\\d{8}|\\d{7}";
    NSArray *array_phonenum = [text componentsMatchedByRegex:regex_phonenum];
    NSMutableArray *phoneNumArr = [NSMutableArray arrayWithArray:array_phonenum];
    return phoneNumArr;
}

- (NSMutableArray *)addEmailArr:(NSString *)text
{
    //匹配Email地址
    NSString *regex_email = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*.\\w+([-.]\\w+)*";
    NSArray *array_email = [text componentsMatchedByRegex:regex_email];
    NSMutableArray *emailArr = [NSMutableArray arrayWithArray:array_email];
    return emailArr;
}

- (NSString *)transformString:(NSString *)originalStr
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalStr;
  //  NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
     NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    if ([array_emoji count]) {
        for (NSString *str in array_emoji) {
            NSRange range = [text rangeOfString:str];
            NSString *i_transCharacter = (self.emojiDic)[str];
            if (i_transCharacter) {
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='16' height='16'>",i_transCharacter];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
            }
        }
    }
    //返回转义后的字符串
    return text;
}

- (BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    NSString *requestString = [linkInfo.URL absoluteString];
    NSLog(@"%@",requestString);
    if ([[UIApplication sharedApplication]canOpenURL:linkInfo.URL]) {
        [[UIApplication sharedApplication]openURL:linkInfo.URL];
    }
    return NO;
}

- (void)creatAttributedLabel:(NSString *)o_text Label:(OHAttributedLabel *)label
{
    [label setNeedsDisplay];
    NSMutableArray *httpArr = [self addHttpArr:o_text];
    NSMutableArray *phoneNumArr = [self addPhoneNumArr:o_text];
    
    NSString *text = [self transformString:o_text];
    text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",text];
    
    MarkupParser* p = [[MarkupParser alloc] init]  ;
    NSMutableAttributedString* attString = [p attrStringFromMarkup: text];
    //    attString = [NSMutableAttributedString attributedStringWithAttributedString:attString];
    [attString setFont:[UIFont systemFontOfSize:16]];
    label.backgroundColor = [UIColor clearColor];
    [label setAttString:attString withImages:p.images];
    
    NSString *string = attString.string;
    
    if ([phoneNumArr count]) {
        for (NSString *phoneNum in phoneNumArr) {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    
    if ([httpArr count]) {
        for (NSString *httpStr in httpArr) {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }
    
    label.delegate = self;
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].height;
    label.frame = labelRect;
    //    label.onlyCatchTouchesOnLinks = NO;
    label.underlineLinks = YES;//链接是否带下划线
    [label.layer display];
    // 调用这个方法立即触发label的|drawTextInRect:|方法，
    // |setNeedsDisplay|方法有滞后，因为这个需要画面稳定后才调用|drawTextInRect:|方法
    // 这里我们创建的时候就需要调用|drawTextInRect:|方法，所以用|display|方法，这个我找了很久才发现的
}
*/

+(UIImage*)findImageForAICO:(NSString*)imageName  defaultImage:(NSString*) dImageName{
    UIImage * image = [UIImage imageNamed:imageName];
    if (!image) {
        NSString * path    = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images/"] stringByAppendingPathComponent: imageName]  ;
        image = [UIImage imageWithContentsOfFile:path];
        
    }
    if (!image) {
        image = [UIImage imageNamed:dImageName];
    }
    return  image;
}


@end


