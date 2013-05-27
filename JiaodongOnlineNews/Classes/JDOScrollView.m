//
//  JDOScrollView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOScrollView.h"
#import "IIViewDeckController.h"
#import "JDONewsViewController.h"

@implementation JDOScrollView

int dragBeginPoint;
NSMutableArray *accumulator;
BOOL sendEventToParent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //add vertical gesture recognition
        UIPanGestureRecognizer *verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(verticalPan:)];
        [self addGestureRecognizer:verticalPan];
        
        //init the accumulator array
        accumulator = [NSMutableArray array];
        self.delaysContentTouches = false;
        self.pagingEnabled = true;
        
        NSArray *gestrues = self.gestureRecognizers;
        NSLog(@"%@",gestrues);
    }
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"==============gesture in scrollView================");
//    if( gestureRecognizer!=nil ){
//        NSLog(@"gesture:%@",[gestureRecognizer class]);
//        NSLog(@"delegate:%@",[gestureRecognizer.delegate class]);
//    }
//    if(otherGestureRecognizer!=nil){
//        NSLog(@"gesture:%@",[otherGestureRecognizer class]);
//        NSLog(@"delegate:%@",[otherGestureRecognizer.delegate class]);
//    }
    return false;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"==============should gesture================");
    return true;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"==============receive gesture================");
    return true;
}

//custom method
- (void)verticalPan :(UIPanGestureRecognizer *) sender {
    
//    CGPoint touch  = [sender translationInView:self];
//    NSValue *value = [NSValue valueWithCGPoint:touch];
//    [accumulator addObject:value];
//    
//    int firstXObjectValue = (int)[[accumulator objectAtIndex:0] CGPointValue].x ;
//    int lastXObjectValue =  (int)[[accumulator lastObject] CGPointValue].x;
//    
//    int firstYObjectValue = (int)[[accumulator objectAtIndex:0] CGPointValue].y;
//    int lastYObjectValue =  (int)[[accumulator lastObject] CGPointValue].y;
//    
//    if((lastXObjectValue - firstXObjectValue) >4 && _dragBeginInFirstContentView){
//        NSLog(@"yes");
//    }
//    if (abs(lastYObjectValue - firstYObjectValue) < 4 && abs(lastXObjectValue - firstXObjectValue) > 4) {
        NSLog(@"Horizontal Pan");
//        //do something here
//    }
//    else if (abs(lastYObjectValue - firstYObjectValue) > 4 && abs(lastXObjectValue - firstXObjectValue) < 4){
//        NSLog(@"Vertical Pan");
//        //do something here
//    }
    
//    if (accumulator.count > 3)
//        [accumulator removeAllObjects];
    
}

//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view{
//    return true;
//}
//
//- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
//    return true;
//}

// hitTest触发时机太早，切确定目标后无法修改，不能通过拖动方向来修改hit目标
// hitTest的通常目的是将事件传递到子视图
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    NSLog(@"hit test at (%g,%g)",point.x,point.y);
//    NSLog(@"%@",[event.allTouches anyObject] );
//    return [super hitTest:point withEvent:event];
//}

bool debug;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"============begin================");
    if( self.contentOffset.x == 0){
        self.dragBeginInFirstContentView = true;
    }else{
        self.dragBeginInFirstContentView = false;
    }
    CGPoint touch  = [[touches anyObject] locationInView:self];
    NSValue *value = [NSValue valueWithCGPoint:touch];
    [accumulator addObject:value];

    [[event allTouches] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if(debug)
        NSLog(@"%@",obj);
    }];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"============move================");
    CGPoint touch  = [[touches anyObject] locationInView:self];
    NSValue *value = [NSValue valueWithCGPoint:touch];
    [accumulator addObject:value];
    int firstXObjectValue = (int)[[accumulator objectAtIndex:0] CGPointValue].x ;
    int lastXObjectValue =  (int)[[accumulator lastObject] CGPointValue].x;
    NSLog(@"%d",lastXObjectValue - firstXObjectValue);
    if((lastXObjectValue - firstXObjectValue) >4 && _dragBeginInFirstContentView){
        NSLog(@"yes");
        [self.nextResponder.nextResponder touchesMoved:touches withEvent:event];
        NSLog(@"%@",self.nextResponder.nextResponder);
        sendEventToParent = true;
    }
    
    [[event allTouches] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if(debug)
        NSLog(@"%@",obj);
    }];
    if(self.dragBeginInFirstContentView){
        
    }
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"============end================");
    [accumulator removeAllObjects];
    sendEventToParent = false;
    [[event allTouches] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if(debug)
        NSLog(@"%@",obj);
    }];
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"============cancel================");
    [accumulator removeAllObjects];
    sendEventToParent = false;
    [[event allTouches] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if(debug)
        NSLog(@"%@",obj);
    }];
    [super touchesCancelled:touches withEvent:event];
}


@end
