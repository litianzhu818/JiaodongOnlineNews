//
//  MWCaptionView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MWCaptionView.h"
#import "MWPhoto.h"

static const CGFloat labelPadding = 5;

// Private
@interface MWCaptionView () {
    id<MWPhoto> _photo;
    UITextView *_label;
}
@end

@implementation MWCaptionView

- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 86.0)]; // Random initial frame
    if (self) {
        _photo = [photo retain];
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_black_background.png"]];
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView];
        [self setupCaption];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
//    CGFloat maxHeight = 9999;
//    if (_label.numberOfLines > 0) maxHeight = _label.font.leading*_label.numberOfLines;
//    CGSize textSize = [_label.text sizeWithFont:_label.font 
//                              constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
//                                  lineBreakMode:_label.lineBreakMode];
//    return CGSizeMake(size.width, textSize.height + labelPadding * 2);
    return CGSizeMake(size.width, 86.0);
}

- (void)setupCaption {
    _label = [[UITextView alloc] initWithFrame:CGRectMake(labelPadding, 0,
                                                       self.bounds.size.width-labelPadding*2,
                                                       self.bounds.size.height)];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = UITextAlignmentLeft;
    _label.editable = false;
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:14];
    if ([_photo respondsToSelector:@selector(caption)]) {
        _label.text = [_photo caption] ? [_photo caption] : @" ";
    }
    [self addSubview:_label];
}

- (void)dealloc {
    [_label release];
    [_photo release];
    [super dealloc];
}

@end
