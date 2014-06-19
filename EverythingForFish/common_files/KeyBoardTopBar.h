//
 
#import <Foundation/Foundation.h>

@interface KeyBoardTopBar : NSObject {
	UIToolbar *view;//工具条
	NSArray *TextFields;//输入框数组
	BOOL allowShowPreAndNext;//是否显示上一项下一项
	BOOL isInNavigationController;//是否在导航视图中
	UIBarButtonItem *prevButtonItem;//上一项按钮
	UIBarButtonItem *nextButtonItem;//下一项按钮
	UIBarButtonItem *hiddenButtonItem;//隐藏按钮
	UIBarButtonItem *spaceButtonItem;//空白按钮
	UIView *currentTextField;//当前输入框
    BOOL   bShowing;
}
@property(nonatomic,strong) UIToolbar *view;
-(id)init; //初始化
-(void)setAllowShowPreAndNext:(BOOL)isShow; //设置是否显示上一项下一项
-(void)setIsInNavigationController:(BOOL)isbool; //设置是否在导航视图中
-(void)setTextFieldsArray:(NSArray *)array; //设置输入框数组
-(void)ShowPrevious; //显示上一项
-(void)ShowNext;     //显示下一项
-(void)ShowBar:(UIView *)textField  KeyBoardFrame:(CGRect) keyBorardFrame  AnimationDuration:(NSTimeInterval)animationDuration; //显示工具条
-(void)HiddenKeyBoard:(NSTimeInterval)animationDuration;  //隐藏键盘
@end