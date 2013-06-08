//
//  JDOStatusView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOStatusView.h"

@implementation JDOStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.noNetWorkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bad_net"]];
        self.noNetWorkView.center = self.center;
        self.noNetWorkView.userInteractionEnabled = true;
        [self addSubview:self.noNetWorkView];
        
        self.retryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retry"]];
        self.retryView.center = self.center;
        self.retryView.userInteractionEnabled = true;
        [self addSubview:self.retryView];
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_logo"]];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator sizeToFit];
        self.activityIndicator.center = CGPointMake(self.logoView.center.x,self.logoView.center.y-50);
        [self.logoView addSubview:self.activityIndicator];
        self.logoView.center = self.center;
        [self addSubview:self.logoView];
    }
    return self;
}

- (void) setReloadTarget:(id)target selector:(SEL)selector{
    [self.retryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:selector]];
    [self.noNetWorkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:selector]];
}



- (void) setStatus:(ViewStatusType)status{
    _status = status;
    switch (status) {
        case ViewStatusNormal:
            self.hidden = true;
            break;
        case ViewStatusNoNetwork:
            self.hidden = false;
            self.noNetWorkView.hidden = false;
            self.logoView.hidden = self.retryView.hidden = true;
            break;
        case ViewStatusLogo:
            self.hidden = false;
            self.logoView.hidden = false;
            self.activityIndicator.hidden = true;
            self.noNetWorkView.hidden = self.retryView.hidden = true;
            break;
        case ViewStatusLoading:
            self.hidden = false;
            self.logoView.hidden = false;
            self.activityIndicator.hidden = false;
            self.noNetWorkView.hidden = self.retryView.hidden = true;
            break;
        case ViewStatusRetry:
            self.hidden = false;
            self.retryView.hidden = false;
            self.noNetWorkView.hidden = self.logoView.hidden = true;
            break;
    }
    if(status == ViewStatusLoading){
        [self.activityIndicator startAnimating];
    }else{
        [self.activityIndicator stopAnimating];
    }
}


@end
