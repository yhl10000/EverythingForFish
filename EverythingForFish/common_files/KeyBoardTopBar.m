
//
#import "KeyBoardTopBar.h"
#import "CommonData.h"
@implementation KeyBoardTopBar
@synthesize view;
//初始化控件和变量
-(id)init{
	if(self = [super init]) {
		prevButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上一项" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowPrevious)];
		nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowNext)];
		hiddenButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"结束编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(HiddenKeyBoard)];
		spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		view = [[UIToolbar alloc] initWithFrame:CGRectMake(0,568,320,44)];
        CommonData * gcd = [CommonData sharedCommonData];
        if (gcd.iosVersion>=7) {
            view.barStyle = UIBarStyleDefault;
        }
        else{
            view.barStyle = UIBarStyleBlackTranslucent;
        }
		 
		view.items = [NSArray arrayWithObjects:prevButtonItem,nextButtonItem,spaceButtonItem,hiddenButtonItem,nil];
		allowShowPreAndNext = YES;
		TextFields = nil;
		isInNavigationController = YES;
		currentTextField = nil;
        bShowing = NO;
	}
	return self;
}
//设置是否在导航视图中
-(void)setIsInNavigationController:(BOOL)isbool{
	isInNavigationController = isbool;
}
//显示上一项
-(void)ShowPrevious{
/*	if (TextFields==nil) {
		return;
	}
	NSInteger num = -1;
	for (NSInteger i=0; i<[TextFields count]; i++) {
		if ([TextFields objectAtIndex:i]==currentTextField) {
			num = i;
			break;
		}
	}
	if (num>0){
		[[TextFields objectAtIndex:num] resignFirstResponder];
		[[TextFields objectAtIndex:num-1 ] becomeFirstResponder];
		[self ShowBar:[TextFields objectAtIndex:num-1]];
	}*/
}
//显示下一项
-(void)ShowNext{
/*	if (TextFields==nil) {
		return;
	}
	NSInteger num = -1;
	for (NSInteger i=0; i<[TextFields count]; i++) {
		if ([TextFields objectAtIndex:i]==currentTextField) {
			num = i;
			break;
		}
	}
	if (num<[TextFields count]-1){
		[[TextFields objectAtIndex:num] resignFirstResponder];
		[[TextFields objectAtIndex:num+1] becomeFirstResponder];
		[self ShowBar:[TextFields objectAtIndex:num+1]];
	}*/
}
//显示工具条
-(void)ShowBar:(UIView *)textField KeyBoardFrame:(CGRect) keyBorardFrame AnimationDuration:(NSTimeInterval)animationDuration{
	
    if (![view superview]) {
        UIWindow * w = [[UIApplication sharedApplication] keyWindow];
        [w addSubview:view];
    }
    
    if (bShowing) {
        return;
    }
    currentTextField = textField;
	if (allowShowPreAndNext) {
		[view setItems:[NSArray arrayWithObjects:prevButtonItem,nextButtonItem,spaceButtonItem,hiddenButtonItem,nil]];
	}
	else {
		[view setItems:[NSArray arrayWithObjects:spaceButtonItem,hiddenButtonItem,nil]];
	}
	if (TextFields==nil) {
		prevButtonItem.enabled = NO;
		nextButtonItem.enabled = NO;
	}
	else {
		NSInteger num = -1;
		for (NSInteger i=0; i<[TextFields count]; i++) {
			if ([TextFields objectAtIndex:i]==currentTextField) {
				num = i;
				break;
			}
		}
		if (num>0) {
			prevButtonItem.enabled = YES;
		}
		else {
			prevButtonItem.enabled = NO;
		}
		if (num<[TextFields count]-1) {
			nextButtonItem.enabled = YES;
		}
		else {
			nextButtonItem.enabled = NO;
		}
	}
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];

//	CGRect rc = textField.frame;
    CommonData * gcd = [CommonData sharedCommonData];
    if (gcd.iosVersion>=7) {
        view.frame = CGRectMake(0, keyBorardFrame.origin.y-44, 320,  44);
    }
	else{
        view.frame = CGRectMake(0, keyBorardFrame.origin.y-64, 320,  44);
    }

	 [view.superview bringSubviewToFront:view];
	//view.frame = CGRectMake(0, rc.origin.y+ rc.size.height, 320, 44);
	/*if (isInNavigationController) {
		view.frame = CGRectMake(0, 201-40, 320, 44);
	}
	else {
		view.frame = CGRectMake(0, 100, 320, 44);
	} */
	[UIView commitAnimations];
    bShowing = YES;
}
//设置输入框数组
-(void)setTextFieldsArray:(NSArray *)array{
	TextFields = array;
}
//设置是否显示上一项和下一项按钮
-(void)setAllowShowPreAndNext:(BOOL)isShow{
	allowShowPreAndNext = isShow;
}
//隐藏键盘和工具条
-(void)HiddenKeyBoard{
    if (!bShowing) {
        return;
    }
	if (currentTextField!=nil) {
		[currentTextField  resignFirstResponder];
	}

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	view.frame = CGRectMake(0, 568, 320, 44);
	[UIView commitAnimations];
    bShowing = NO;
}
-(void)HiddenKeyBoard:(NSTimeInterval)animationDuration{
    if (!bShowing) {
        return;
    }
	if (currentTextField!=nil) {
		[currentTextField  resignFirstResponder];
	}

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	view.frame = CGRectMake(0, 568, 320, 44);
	[UIView commitAnimations];
    bShowing = NO;
}
//释放
@end