#import "UnderlineUILabel.h"
#import<QuartzCore/QuartzCore.h>

@implementation UnderlineUILabel
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
    }
    return self;
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize fontSize =[self.text sizeWithFont:self.font
                                    forWidth:self.bounds.size.width
                               lineBreakMode:UILineBreakModeTailTruncation];
    
    
    // Get the fonts color.
    
    const float * colors = CGColorGetComponents(self.textColor.CGColor);
    // Sets the color to draw the line
    CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], 1.0f); // Format : RGBA
    
    // Line Width : make thinner or bigger if you want
    CGContextSetLineWidth(ctx, 1.0f);
    
    // Calculate the starting point (left) and target (right)
    CGPoint l = CGPointMake(0,
                            self.frame.size.height/2.0 +fontSize.height/2.0);
    
    CGPoint r = CGPointMake(fontSize.width,
                            self.frame.size.height/2.0 + fontSize.height/2.0);
    
    
    // Add Move Command to point the draw cursor to the starting point
    CGContextMoveToPoint(ctx, l.x, l.y);
    
    // Add Command to draw a Line
    CGContextAddLineToPoint(ctx, r.x, r.y);
    
    
    // Actually draw the line.
    CGContextStrokePath(ctx);
    
    // should be nothing, but who knows...
    [super drawRect:rect];
}
@end