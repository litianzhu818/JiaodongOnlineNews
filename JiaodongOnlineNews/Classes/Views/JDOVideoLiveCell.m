//
//  JDOVideoLiveCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoLiveCell.h"
#import "JDOVideoModel.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "JDOVideoEPGModel.h"

#define Default_Image @"news_image_placeholder.png"
#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 7.5f
#define Bottom_Margin 10.0f
#define Padding 7.5f
#define Image_Width 72.0f
#define Image_Height (News_Cell_Height-Top_Margin-Bottom_Margin)

@interface JDOVideoLiveCell ()

@property (nonatomic,strong) UIImageView *leftItemView;
@property (nonatomic,strong) UIImageView *rightItemView;

@end

@implementation JDOVideoLiveCell{
    UITableViewCellStateMask _currentState;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier models:(NSArray *)models
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.models = models;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
        self.detailTextLabel.numberOfLines = 2;
        
        self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.detailTextLabel.highlightedTextColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];  
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setContentByIndex:(NSInteger) index{
    int modelIndex = 2*index;
    JDOVideoModel *leftItemModel = (JDOVideoModel *)self.models[modelIndex];
    self.leftItemView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 146, 151)];
    self.leftItemView.tag = modelIndex; // 利用tag传递变量，在接收手势时知道是哪个项目被点击的
    [self fillItemView:self.leftItemView withModel:leftItemModel];
    
    modelIndex = 2*index+1;
    if( self.models.count > modelIndex ){
        JDOVideoModel *rightItemModel = (JDOVideoModel *)self.models[modelIndex];
        self.rightItemView = [[UIImageView alloc] initWithFrame:CGRectMake(10+146+8, 25, 146, 151)];
        self.rightItemView.tag = modelIndex;
        [self fillItemView:self.rightItemView withModel:rightItemModel];
    }
    
//    __block UIImageView *blockImageView = self.imageView;
//    // 电台的图标地址中有中文“台标”,需要先转编码
//    [self.imageView setImageWithURL:[NSURL URLWithString:[videoModel.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:Default_Image]  options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
//        if(!cached){    // 非缓存加载时使用渐变动画
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.3;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = kCATransitionFade;
//            [blockImageView.layer addAnimation:transition forKey:nil];
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"%@",error.debugDescription);
//    }];
    
//    self.detailTextLabel.text = videoModel.liveUrl;
//    self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
//    self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
    
}

- (void) fillItemView:(UIImageView *)itemView withModel:(JDOVideoModel *)itemModel  {
    itemView.userInteractionEnabled = true;
    itemView.image = [UIImage imageNamed:itemModel.name];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 151-116-5, 136, 116)];
    logoView.image = [UIImage imageNamed:[itemModel.name stringByAppendingString:@"-logo.jpg"] ];
    [itemView addSubview:logoView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 151-24-5, 136, 24)];
    backgroundView.image = [UIImage imageNamed:@"ytv_channel_background"];
    [itemView addSubview:backgroundView];
    UILabel *epgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+5, 151-24-5, 136-10, 24) ];
    epgLabel.font = [UIFont boldSystemFontOfSize:13];
    epgLabel.textColor = [UIColor whiteColor];
    epgLabel.backgroundColor = [UIColor clearColor];
    if ( !JDOIsEmptyString(itemModel.currentProgram) ) {
        epgLabel.text = itemModel.currentProgram;
    } else {
        epgLabel.text = @"加载中...";
        [self loadCurrentEPG:@{@"epgLabel":epgLabel,@"itemModel":itemModel}];
    }
    [itemView addSubview:epgLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onItemClick:)];
    [itemView addGestureRecognizer:tap];
    [self.contentView addSubview:itemView];
}

// 从后台获取当前播放节目的名称
-(void)loadCurrentEPG:(NSDictionary *)obj{
    UILabel *epgLabel = obj[@"epgLabel"];
    JDOVideoModel *itemModel = obj[@"itemModel"];
    
    NSTimeInterval interval = [[itemModel currentTime] timeIntervalSince1970];
    NSString *currentTime = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:interval] intValue]];
    NSString *epgURL = [itemModel.epgApi stringByReplacingOccurrencesOfString:@"{timestamp}" withString:currentTime];
    
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:epgURL]] getJSONByServiceName:@"" modelClass:nil config:nil params:nil success:^(NSDictionary *responseObject) {
        if(responseObject[@"result"]){
            NSArray *list = responseObject[@"result"][0];
            if(list == nil || list.count == 0){
                epgLabel.text = @"无节目单";
            }else{
                DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: [JDOVideoEPGModel class] andConfiguration:[DCParserConfiguration configuration]];
                NSArray *epgModels = [mapper parseArray:list];
                JDOVideoEPGModel *currentEPG;
                for (int i=0; i<epgModels.count; i++) {
                    JDOVideoEPGModel *epgModel = [epgModels objectAtIndex:i];
                    if( [[itemModel currentTime] compare:epgModel.start_time] == NSOrderedDescending &&
                       [[itemModel currentTime] compare:epgModel.end_time] == NSOrderedAscending ){
                        currentEPG = epgModel;
                        break;
                    }
                }
                if (currentEPG) {
//                    epgLabel.text = [NSString stringWithFormat:@"%@ %@",[JDOCommonUtil formatDate:currentEPG.start_time withFormatter: DateFormatHM],currentEPG.name ];
                    epgLabel.text = currentEPG.name; // 页面空间不足，暂时不显示时间
                    itemModel.currentProgram = currentEPG.name;
                }else{
                    epgLabel.text = @"当前无直播节目";
                    NSLog(@"无直播节目时候的服务器时间:%@",[itemModel currentTime]);
                }
            }
        }else{
            epgLabel.text = @"无法获取当前节目";
        }
        
    } failure:^(NSString *errorStr) {
        NSLog(@"加载当前视频节目名称错误：%@", errorStr);
        epgLabel.text = @"无法获取当前节目";
    }];
}

- (void)onItemClick:(UITapGestureRecognizer *)tap{
    [self.delegate onLiveChannelClick:tap.view.tag];
}

@end
