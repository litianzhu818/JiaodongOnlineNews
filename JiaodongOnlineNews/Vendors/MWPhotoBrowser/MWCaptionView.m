//
//  MWCaptionView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MWCaptionView.h"
#import "MWPhoto.h"

static const CGFloat labelPadding = 12;
static const CGFloat textPadding = 5;
static const CGFloat pageWidth = 38;
static const CGFloat titleHeight = 20;

// Private
@interface MWCaptionView () {
    UITextView *_label;
    UILabel *_title;
    UILabel *_pages;
}
@end

@implementation MWCaptionView

- (id)initWithFrame:(CGRect) frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_black_background.png"]];
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView];
        [self setupCaption];
    }
    return self;
}

- (void)setupCaption {
    _title = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, 0, 320-pageWidth-2*labelPadding, titleHeight)];
    _title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _title.textColor = [UIColor whiteColor];
    _title.backgroundColor = [UIColor clearColor];
    _title.textAlignment = UITextAlignmentLeft;
    _title.font = [UIFont boldSystemFontOfSize:16];
    [self addSubview:_title];
    float originY = [UIFont boldSystemFontOfSize:16].lineHeight - [UIFont systemFontOfSize:14].lineHeight-1;
    _pages = [[UILabel alloc] initWithFrame:CGRectMake(320-labelPadding-pageWidth, originY, pageWidth, titleHeight)];
    _pages.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _pages.textColor = [UIColor whiteColor];
    _pages.backgroundColor = [UIColor clearColor];
    _pages.textAlignment = UITextAlignmentRight;
    _pages.font = [UIFont systemFontOfSize:14];
    [self addSubview:_pages];
    _label = [[UITextView alloc] initWithFrame:CGRectMake(textPadding, titleHeight,320-textPadding*2, self.bounds.size.height-(titleHeight+5))];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = UITextAlignmentLeft;
    _label.editable = false;
    _label.textColor = [UIColor colorWithHex:@"c0c0c0"];
    _label.font = [UIFont systemFontOfSize:14];
    [self addSubview:_label];
}

- (void) setPhoto:(id<MWPhoto>)photo{
    _photo = photo;
    _title.text = [_photo title];
    _pages.text = [_photo pages];
    _label.text = [_photo caption];
}

@end
