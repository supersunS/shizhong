//
//  sz_musicSortChangeView.m
//  shizhong
//
//  Created by ios developer on 16/9/9.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_musicSortChangeView.h"

@implementation sz_musicSortChangeView
{
    UIView      *_bgView;
    NSMutableArray  *_buttonArray;
}

-(id)init
{
    self=[super init];
    if(self)
    {
        self.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.8];
        self.frame=CGRectZero;
        self.hidden=YES;
        self.layer.masksToBounds=YES;
        [self creatSubView];
    }
    return self;
}

-(void)creatSubView
{
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(40, 155, ScreenWidth-80, 235)];
    _bgView.backgroundColor=[UIColor whiteColor];
    [self addSubview:_bgView];
    
    CGFloat height=235/4;
    UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    titleLbl.text=@"选择排序方式";
    titleLbl.font=sz_FontName(16);
    titleLbl.textColor=sz_RGBCOLOR(9, 5, 4);
    [titleLbl sizeToFit];
    titleLbl.textAlignment=NSTextAlignmentLeft;
    titleLbl.frame=CGRectMake(50, (height-titleLbl.frame.size.height)/2, titleLbl.frame.size.width, titleLbl.frame.size.height);
    [_bgView addSubview:titleLbl];
    
    _buttonArray=[[NSMutableArray alloc]init];
    for(int i=0;i<3;i++)
    {
        UIButton *selectButton=[UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame=CGRectMake(0, height *(i+1), _bgView.frame.size.width, height);
        [selectButton setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [selectButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateSelected];
        [selectButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        selectButton.tag=i;
        [_bgView addSubview:selectButton];
        
        UIImageView *leftImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"music_sort_%d",i+1]]];
        [leftImageView sizeToFit];
        leftImageView.userInteractionEnabled=NO;
        leftImageView.frame=CGRectMake(50, (height-leftImageView.frame.size.height)/2, leftImageView.frame.size.width, leftImageView.frame.size.height);
        [selectButton addSubview:leftImageView];
        
        [_buttonArray addObject:selectButton];
        
        UILabel *rightLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:leftImageView]+15, 0,selectButton.frame.size.width-([UIView getFramWidth:leftImageView]+15), height)];
        switch (i) {
            case 0:
            {
                rightLbl.text=@"默 认";
                selectButton.selected=YES;
            }
                break;
            case 1:
            {
                rightLbl.text=@"下 载 量";
            }
                break;
            case 2:
            {
                rightLbl.text=@"点 赞 量";
            }
                break;
                
            default:
                break;
        }
        rightLbl.font=sz_FontName(16);
        rightLbl.textColor=sz_RGBCOLOR(9, 5, 4);
        rightLbl.textAlignment=NSTextAlignmentLeft;
        [selectButton addSubview:rightLbl];
    }
}

-(void)sortViewShow
{
    self.frame=CGRectMake(ScreenWidth-90, 20, 50, 50);
    self.layer.cornerRadius=50/2;
    self.hidden=NO;
    self.alpha=1;
    [UIView animateWithDuration:.3 animations:^{
        self.frame=CGRectMake(0, 64, ScreenWidth, ScreenHeight-64);
        self.layer.cornerRadius=0;
    } completion:^(BOOL finished) {

    }];
}
-(void)sortViewHidden
{
        self.alpha=1;
    [UIView animateWithDuration:.3 animations:^{
        self.alpha=0;
        self.frame=CGRectMake(ScreenWidth-90, 20, 50, 50);
        self.layer.cornerRadius=50/2;
        self.layer.masksToBounds=YES;
    } completion:^(BOOL finished) {
        self.hidden=YES;
    }];
}

-(void)buttonAction:(UIButton *)button
{
    if(button.selected)
    {
        return;
    }
    for (UIButton *btn  in _buttonArray)
    {
        if(button.tag==btn.tag)
        {
            button.selected=YES;

        }
        else
        {
            btn.selected=NO;
        }
    }
    [self sortViewHidden];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
