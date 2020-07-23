#import <Foundation/Foundation.h>
#import "LAIGU_FBFontSymbol.h"
#import <UIKit/UIKit.h>

@interface LAIGU_FBSquareFont : NSObject
+ (void)drawSymbol:(FBFontSymbolType)symbol
horizontalEdgeLength:(CGFloat)horizontalEdgeLength
  verticalEdgeLength:(CGFloat)verticalEdgeLength
          startPoint:(CGPoint)startPoint
           inContext:(CGContextRef)ctx;
@end
