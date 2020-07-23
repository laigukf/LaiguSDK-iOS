#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LGToast : NSObject

+ (void)showToast:(NSString*)message duration:(NSTimeInterval)interval window:(UIView*)window;

@end
