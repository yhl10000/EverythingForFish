//
//  CommonData.h
//  Watsons
//
//  Created by Fish on 11-4-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyBoardTopBar.h"
#import "Security/SecBase.h"
#import "WaitViewController.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "OHAttributedLabel.h"
//#import "RegexKitLite.h"
#import "MarkupParser.h"
#import "NSAttributedString+Attributes.h"
#import <CouchbaseLite/CouchbaseLite.h>


#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define APP_ITUNES_URL @"https://==== d715405170?ls=1&mt=8"
//#define CLIENT_TYPE @"ipad"
#define CLIENT_TYPE @"iphone"
//fish: 用于判断程序启动时候是否显示帮助提示的界面。
#define BUILDNUMBER 1       

//#define SIT
//#define UAT
#define PRD



#ifdef SIT
//FISH SIT SERVER
#define BASEURL			  @"http://172.18.50.154:10001/MobileInterface/Interface.aspx"
#define PINGURL             @"www.baidu.com"

#endif

#ifdef  UAT
//FISH UAT SERVER
#define BASEURL			  @"http://218.4.117.12:50001/MobileInterface/Interface.aspx"
#define PINGURL             @"www.baidu.com"
#endif


#ifdef PRD
//FISH PRD SERVER    .
#define BASEURL			  @"http://172.18.50.154:9999/MobileInterface/Interface.aspx"
#define PINGURL             @"www.baidu.com"
#endif

  
 
 #define BASEURL2             @"http://ww com/api/"          //正式环境第二个地址，


#define SAVEDIMAGESDICTIONARYPATH @"Documents/savedImagesDictionary.plist"
#define SYSTEMDEFAULTSPATH			@"Documents/systemDefaults.plist"
#define RECENTSHOPSPATH			@"Documents/recentshops.plist"
#define SEARCHKEYSPATH			@"Documents/searchkeys.plist"
#define USERDEFAULTSPATH			@"userDefaultPath.plist"
#define DOWNLOADEDMAGAZINGSPATH			@"downloadedMagazings.plist"
#define BOOKMARKSSPATH			@"bookMarks.plist"
#define MAGAINFORPATH			@"magainfor.plist"
#define READEDMAGAZINESPATH @"readedmagazines.plist"
#define PENDINGTASKSPATH @"pendingtasks.plist"


@class UserController;


@interface CBLDatabase (FISH_HELPER)

- (NSString *) saveNewDocument:(NSDictionary *)dic  ;
- (NSError* ) saveDic:(NSDictionary *)dic toDoc:(CBLDocument*)doc;
- (NSError* ) saveDic:(NSDictionary *)dic toDocID:(NSString*)docID;
@end



NSString * StringForSignature(NSDictionary * dic);
@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;
-(NSString*) sha1;
@end


NSString * sha1(const char *string);

@interface URLCache : NSURLCache {
    NSMutableDictionary *cachedResponses;
    NSMutableDictionary *responsesInfo;

}

@property (nonatomic, strong) NSMutableDictionary *cachedResponses;
@property (nonatomic, strong) NSMutableDictionary *responsesInfo;

- (void)saveInfo;
+(BOOL) checkIfBufferd:(NSString*) urlString;
@end 

@protocol SubNavigationViewBackUpWithNoAnimation<NSObject>
-(IBAction) backUpWithNoAnimation: (id) sender;

@end

@interface NSNull (FishTest)

- (BOOL)isEqualToString:(NSString *)aString;

@end

@interface SinaFace :NSObject
{
	NSString * facename;
	NSString * imgName;
}
@property (nonatomic, strong) NSString * facename;
@property (nonatomic, strong) NSString *  imgName;

@end

@interface TempData :NSObject
{
	BOOL boolValue;
	int  intValue;
	float floadValue;
    NSDictionary * dic;
	NSString * s1;
	NSString * s2;
    NSString * s3;
    NSString * deadLine;
    NSString * remainTimes;
}
@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, assign) int  intValue;
@property (nonatomic, assign) float   floadValue;
@property (nonatomic, strong) NSString *s1;
@property (nonatomic, strong) NSString *s2;
@property (nonatomic, strong) NSString *s3;
@property (nonatomic, strong) NSString * deadLine;
@property (nonatomic, strong) NSString * remainTimes;
@property (nonatomic, strong) NSDictionary * dic;
@end

 

@interface ApplicationData : NSObject
{
	NSString	* applicationName;
    int           applicationID;
	UIColor		* textColor;
	UIImage		* iconBackImage;
	UIImage		* iconHotImage;
	UIImage		* bigBackgroundImage;
	
	UIImage		* textPng;
}
@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIImage *iconBackImage;
@property (nonatomic, strong) UIImage *iconHotImage;
@property (nonatomic, strong) UIImage *textPng;
@property (nonatomic, strong) UIImage *bigBackgroundImage;
@property (nonatomic, assign) int applicationID;

@end


 

@interface ButtonURL : NSObject
{
	UIButton * pb;
	NSString * ps;
}
@property (nonatomic, strong) IBOutlet UIButton *pb;
@property (nonatomic, strong) NSString *ps;
-(id) initWithButton:(UIButton*)b andString:(NSString*)s; 

@end

#define RSA_KEY_BASE64 @"r2PCAnF1npsWjfFaPPLka0CBQL5SnjDdb49gvEx6vfMv69P1RC73KktL6SJUWb16cKeATONf1C0+smh0/ialXaJhVJCJ6VW+AakXw/Z+y7sLEnmhbftZlMnjW954egzsko/0f7ZBrJJzNYTOH9zvevkRxNNldyEUsAAKjJhsdps="

 
@protocol FISHUIViewDelegate<NSObject>
-(IBAction) viewWillHide: (UIView*) theView;

@end


@interface CommonData : NSObject {
    int                    iSyncCount;
	NSMutableArray *		typesCollection;
	NSMutableDictionary*	savedImages;
	NSMutableDictionary		* downloadedMagazings;
	NSMutableDictionary      * bookMarkes;
    NSMutableDictionary      * magaInfor;//记录所有的杂志，有的杂志不一定已经下载。
    NSMutableDictionary      * readedMagazines;
    NSMutableArray          * doNotReleaseViewControllers;
    NSMutableDictionary          * pendingTasks;
	NSString * savedImagesDictionaryPath;
	NSString * mainPageChangeableImagesPath;
	NSString * userFolder;
    NSString * userTaskFolder;//for az coaching project.
	
	UIButton * __unsafe_unretained belowBackButton;
	UIButton * __unsafe_unretained belowShareButton;
	NSString * shareString;
	NSString * shareSubject;
	UIImageView  * __unsafe_unretained shareImageView;
	NSString*		shareImageUrl;
	
	UIColor  * __unsafe_unretained curentSubjectColor;
	NSInteger  currentSubjectIndex;
	
	NSTimer * timer1;
	NSTimer * timer2;
	BOOL isTrueDevice;
    BOOL isAppActive;
	NSMutableDictionary * userDefaults;
    NSMutableDictionary * systemDefaults;
    NSMutableDictionary * recentShops;
    NSMutableDictionary * searchkeys;
	int iosVersion;
    NSString *  iosVersionString;
	UIActivityIndicatorView *__unsafe_unretained activityIndicatorView_EmptyView;
	 
    NSString *  bundle_version;
    NSString *   localeCode;
    SecKeyRef _public_key;
    NSString *currentPage;
    UILabel * offline_label;
    UIViewController    *theMainPageViewController;
    NSString *dbPath  ;
    WaitViewController * theWaitViewController;
  //  FMDatabase *sqlietedb;
    NSString    * token;
    long long     token_timestamp;
    NSString* macAddress;
    NSMutableArray * menuViewArray;
    UIButton * __unsafe_unretained preButton;
    UIButton * __unsafe_unretained nextButton;
    UIButton * __unsafe_unretained bookmarkButton;
    UIButton * profleButton;
    UIWebView * theWebView;
    
    NSMutableArray * preButtonTargets;
    NSMutableArray * preButtonActions;
    NSMutableArray * nextButtonTargets;
    NSMutableArray * nextButtonActions;
    NSMutableArray * delegateTo;
    
    BOOL  bGetNewToken;
    BOOL  bHadLogin;
    NSMutableArray * challengeReservedArray;
    NSManagedObjectContext *managedObjectContext;
    
    NSString *templete_path  ;
    NSDictionary * templeteDic  ;
    NSString * imageNode    ;
    NSString * imageTempNode;
    NSString * localeFileSchemaNode;
    NSURL * emotionHtmlBaseURL;
}
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)  UIWebView * theWebView;
@property (nonatomic, strong) UserController * currentUserController;;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *profileButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *preButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *nextButton;
@property (nonatomic) NSMutableArray *menuViewArray;
@property (nonatomic) NSMutableArray          * doNotReleaseViewControllers;
@property (nonatomic) NSMutableDictionary          * pendingTasks;
@property (nonatomic, strong) NSString* macAddress;
@property (nonatomic, strong)NSString * userFolder;
@property (nonatomic, strong)NSString * userTaskFolder;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) long long token_timestamp;
@property (nonatomic, readonly)  int                    iSyncCount;
//@property (nonatomic, readonly) FMDatabase *sqlietedb;
@property (nonatomic, strong) NSString *iosVersionString;
@property (nonatomic, strong) NSString *bundle_version;
@property ( nonatomic, strong) NSString *localeCode;
@property (nonatomic, readonly) NSMutableArray *typesCollection;
@property (  nonatomic, strong) NSMutableArray *sinafaceArray;
@property (  nonatomic, strong) NSDictionary * pushOption;//app launch by push
@property (nonatomic, readonly) NSMutableDictionary *savedImages;
@property (unsafe_unretained, nonatomic, readonly) NSMutableArray	*	mainPageChangeableImages;
@property (nonatomic,		unsafe_unretained)   UIButton *belowBackButton;
@property (nonatomic,		unsafe_unretained)   UIButton *belowShareButton; 
@property (nonatomic, copy  ) NSString *shareString;
@property (nonatomic, copy  ) NSString *shareSubject;
@property (nonatomic, copy  ) NSString*		shareImageUrl;
@property (nonatomic, unsafe_unretained) UIImageView  *  shareImageView;
@property (nonatomic, unsafe_unretained) UIColor  *  curentSubjectColor;
@property (nonatomic,assign) NSInteger  currentSubjectIndex; 
@property (nonatomic, assign, getter=isTrueDevice) BOOL isTrueDevice;
@property (nonatomic, assign) BOOL isAppActive;
@property (nonatomic, strong) KeyBoardTopBar* keyboardbar;
@property (nonatomic, readonly) NSMutableDictionary *userDefaults;
@property (nonatomic, readonly) NSMutableDictionary * systemDefaults;
@property (nonatomic, readonly) NSMutableDictionary * recentShops;
@property (nonatomic, readonly) NSMutableDictionary * searchkeys;
@property (nonatomic, assign) int iosVersion;
@property (nonatomic, unsafe_unretained) IBOutlet UIActivityIndicatorView *activityIndicatorView_EmptyView;
@property (nonatomic, readonly) NSMutableDictionary *downloadedMagazings;
@property (nonatomic, readonly) NSMutableDictionary *bookMarkes;
@property (nonatomic, readonly) NSMutableDictionary *magaInfor;
@property (nonatomic, readonly) NSMutableDictionary *readedMagazines;
@property (nonatomic, strong) NSString *currentPage;
@property (nonatomic, strong) IBOutlet UILabel *offline_label;
@property (nonatomic, strong) UIViewController * theMainPageViewController;
@property (nonatomic, assign) BOOL  bGetNewToken;
@property (nonatomic, assign) BOOL    bHadLogin;
@property (nonatomic, strong) NSMutableArray * delegateTo;
@property (nonatomic, strong) NSString * imServer;
@property (nonatomic, strong) NSString * imPort;
@property (nonatomic, strong) NSMutableArray * roleReservedArray;
@property (nonatomic, strong) NSMutableArray * challengeReservedArray;
@property (nonatomic, strong) NSMutableArray * subReservedArray;
@property (nonatomic, strong) NSMutableArray * challengeForSupportArray;
@property (nonatomic,strong) UIImage* sendImage;  //mzm add
@property (nonatomic,strong) NSData*  sendSoundData;  //mzm add
@property (nonatomic,strong) NSMutableArray* hintMsgArray;  //mzm add
@property (nonatomic,strong) NSString *templete_path  ;
@property (nonatomic,strong) NSDictionary * templeteDic  ;
@property (nonatomic,strong) NSString * imageNode    ;
@property (nonatomic,strong) NSString * imageTempNode    ;
@property (nonatomic,strong) NSString * localeFileSchemaNode;
@property (nonatomic,strong) NSURL * emotionHtmlBaseURL;
@property (nonatomic, strong) NSDictionary *emojiDic;
@property (nonatomic, strong) NSArray *emojiArray;
@property (nonatomic, strong) NSDictionary *baiduBindData;
-(void) initUserFolder ;
+(NSString*)PostString:(NSString*)str UsingSpecialURL:(NSString*) baseurl2 ;
+(BOOL) isPdfZipFileExit: (NSString *)Document_ID TrueFileSizeKB:(NSString*) sizeKB;//fish add this judgment 2012-07-18
+ (id)sharedCommonData;
+ (void)showAlertView:(NSString*)title message:(NSString*)msg;
-(NSString *) querySavedImage: (NSString *) imageURL;
-(void) saveSavedDatas;
-(NSString*) getBackUpButtonSelector:(UIControl*)control;
-(NSString*) getBackUpButtonSelector;
-(id)getBackUpButtonTarget;
-(id)getBackUpButtonTarget:(UIControl*) control;
-(void) saveBackUpButtonStateWithNewTarget:(id)newT andAction:(SEL) act  ;
-(void) restoreBackUpButtonStateWithOldTarget:(id) oldTarget andoldSelectorString:(NSString*) oldSelectorString;
-(void) restoreBackUpButtonState:(UIControl*) control WithOldTarget:(id) oldTarget andoldSelectorString:(NSString*) oldSelectorString;
-(void) dealloc;
-(void) postToSinaWithToken:(NSString*) token andSecret:(NSString*)secret; 

+(void) setViewControllerTopInNavigation:(UIViewController *)viewControl NavigationCtrl:(UINavigationController*) aNavi animated:(BOOL)animated;
+(void) hideBelowView:(BOOL)bHide;
+(void) hideShareView:(BOOL)bHide;
+(void) addArrowForUITableViewCell:(UITableViewCell *) cell withImageFileName:(NSString*) imageName; 
-(bool) getShareButtonState:(NSString*) willShareString andShareSubject:(NSString*) subject 
		  andShareImageView:(UIImageView*) imageView andShareImageURL:(NSString*)		imageUrl;
-(NSData*) rsaEncryptString:(NSString*) string;
+(NSMutableDictionary *) getInitialJSONNSDictionary;
+ (void) checkNetworkStatus: (id) value ;
-(void)ShowWaitView:(UIView*) parentView andTypeTag:(NSInteger) typeTag;//typeTag default value is 0;
-(void)HideWaitView;
-(void)RefreshWaitView;
-(void)ShowWaitView:(UIView*) parentView WithMsg:(NSString *)msg;//typeTag default value is 0;
+(NSString*)MacAddress;
+(NSString*)PostString:(NSString*)str  Error:(NSError ** )e;
+(BOOL) checkToken;
+(BOOL) checkTokenForOAuth;
+(BOOL) forceCheckToken:(NSString *)specialURL;
+(int) FindChannelIndexWithID:(NSString *) channelsID channels:(NSArray *)channels;
+(NSString*) FindChannelNameWithID:(NSString *) channelsID channels:(NSArray *)channels;
+(NSString*) MakeCategoryString:(NSArray *) ctids baseDB:(NSArray *)categorys;
+(int) FindTagIndexWithID:(NSNumber *) tagid tags:(NSArray *)tags;
+(int )FindTagIndexWithSTRID:(NSString *) tagid tags:(NSArray *)tags;
+(int) FindCatagaryIndexWithID:(NSString *) catid catagary:(NSArray *)catagarys;
+(NSDictionary *) FindZoneWithID:(NSString *) tagid zones:(NSArray *)zones;
+(NSDictionary *) FindProvinceWithID:(NSString *) tagid provinces:(NSArray *)provinces;
+(NSDictionary *) FindMagaWithID:(NSString *) tagid allMagaInfo:(NSDictionary*) allMagaInfo;
+(void)hideMenu;
+(void)showMenu;
-(void) setNavigateButtonTarget:(id)preTarget preAction:(SEL) preAct nextTarget:(id)nextTarget nextAction:(SEL) nextact;
+(void)postStringAsynchronously:(NSString*)str connectionDelegate:(id) delegate;
-(BOOL)checkDownloadedMagazing:(NSNumber*)magid;
-(NSArray*) mergeMagaInfor:(NSArray*)newMagalist forMagaID:(NSNumber*) magid;
-(NSString*) invokeJSFunction:(NSString*)function withParam:(NSString*) params;
+ (NSString *)createUUID;
-(void)retainIsSync;
-(void)releaseIsSync;
+ (NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding;
+(NSString*)formatDate:(NSDate*) date;
+(NSString*)formatTime:(NSDate*) date;
+(NSString*)formatSpecialDate:(NSDate*) date; // if date is today, just retun time.
+(NSInteger) heightOfLabel:(NSString *)text forLabel:(UILabel*)label;
+(void) forceMicrosoftYaHei  :(UILabel*)label;
+(void) forceMicrosoftYaHei_Bold  :(UILabel*)label;
+(void)forceAllControlsToMicrosoftYaHei:(UIView *)rootview indent:(NSInteger)indent;
-(NSString*) transformToHtml:(NSString*) source;//change the emotion tag to html
//模拟翻滚提示 mzm add
-(void) presentHitViewWithMsg:(NSString *)msg;
+ (void)showNetworkErrorAlertView;
- (void)creatAttributedLabel:(NSString *)o_text Label:(OHAttributedLabel *)label;
+(UIImage*)findImageForAICO:(NSString*)imageName   defaultImage:(NSString*) dImageName;

@end

 
