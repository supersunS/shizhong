//
//  sz_selectCityView.m
//  shizhong
//
//  Created by sundaoran on 15/12/26.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_selectCityView.h"

@implementation sz_selectCityView
{
    UIPickerView  *_selectCityView;
    UIView *bgView;
    NSMutableArray  *_provienceArray;
    NSMutableArray  *_cityArray;
    NSMutableArray  *_zoneArray;
    BOOL            _isRoll;
    void(^_block)(sz_cityObject * cityObject);
}


-(void)selectCitySureActionBlock:(void(^)(sz_cityObject * cityObject))block
{
    _block=block;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        _provienceArray=[[NSMutableArray alloc]init];
        _cityArray=[[NSMutableArray alloc]init];
        _zoneArray=[[NSMutableArray alloc]init];
        _provienceArray=[[NSMutableArray alloc]initWithArray:[sz_CCLocationManager getAllProvince]];
        /*
        ProName = "\U9999\U6e2f\U7279\U522b\U884c\U653f\U533a";
        ProRemark = "\U7279\U522b\U884c\U653f\U533a";
        ProSort = 34;
         */
        if([_provienceArray count])
        {
            _cityArray=[[NSMutableArray alloc]initWithArray:[sz_CCLocationManager getAllCityByProvinceId:[[_provienceArray firstObject]objectForKey:@"ProSort"]]];
        }
        
        if([_cityArray count])
        {
            _zoneArray=[[NSMutableArray alloc]initWithArray:[sz_CCLocationManager getAllZoneByCityId:[[_cityArray firstObject] objectForKey:@"CitySort"]]];
        }
        [self addSubview];
    }
    return self;
}

-(void)addSubview
{
    if(!_selectCityView)
    {
        bgView=[[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor=[UIColor clearColor];
        [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMisView)]];
        [self addSubview:bgView];
        
        UIView *buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, bgView.frame.size.height-216-44, bgView.frame.size.width, 44)];
        buttonView.backgroundColor=sz_bgColor;
        [bgView addSubview:buttonView];
        
        UIButton *cancleButton=[UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame=CGRectMake(10, 0,(bgView.frame.size.width-20)/2, 44);
        cancleButton.titleLabel.textAlignment=NSTextAlignmentLeft;
        cancleButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [cancleButton setBackgroundColor:[UIColor clearColor]];
        [cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        cancleButton.titleLabel.font=sz_FontName(14);
        [buttonView addSubview:cancleButton];
        
        UIButton *sureButton=[UIButton buttonWithType:UIButtonTypeCustom];
        sureButton.frame=CGRectMake(cancleButton.frame.size.width+cancleButton.frame.origin.x, 0,(bgView.frame.size.width-20)/2, 44);
        sureButton.titleLabel.textAlignment=NSTextAlignmentRight;
        [sureButton setBackgroundColor:[UIColor clearColor]];
        sureButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        [sureButton setTitle:@"确定" forState:UIControlStateNormal];
        sureButton.titleLabel.font=sz_FontName(14);
        [buttonView addSubview:sureButton];
        
        _selectCityView=[[UIPickerView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:buttonView], self.frame.size.width, 216)];
        
        _selectCityView.dataSource=self;
        _selectCityView.delegate=self;
        _selectCityView.backgroundColor=[UIColor whiteColor];
        [bgView addSubview:_selectCityView];
    }
}

-(void)showSelectCityView
{
    bgView.hidden=NO;
    bgView.alpha=0.0;
    [UIView animateWithDuration:0.5 animations:^{
        bgView.frame=CGRectMake(bgView.frame.origin.x, 0, bgView.frame.size.width, bgView.frame.size.height);
        bgView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)disMisView
{
    [UIView animateWithDuration:0.5 animations:^{
        bgView.alpha=0.0;
        bgView.frame=CGRectMake(bgView.frame.origin.x, ScreenHeight, bgView.frame.size.width, bgView.frame.size.height);
    } completion:^(BOOL finished) {
        bgView.hidden=YES;
        [self removeFromSuperview];
    }];
}

-(void)cancleAction
{
    [self disMisView];
}

-(void)sureAction
{
    sz_cityObject *cityObject=[[sz_cityObject alloc]init];
    NSInteger provience=[_selectCityView selectedRowInComponent:0];
    NSDictionary *provienceDict=[NSDictionary new];
    cityObject.sz_province_Id=[NSString stringWithFormat:@""];
    cityObject.sz_province_Name=[NSString stringWithFormat:@""];
    if((int)([_provienceArray count]-1)>=provience)
    {
        provienceDict=[_provienceArray objectAtIndex:provience];
        cityObject.sz_province_Id=[NSString stringWithFormat:@"%@",[provienceDict objectForKey:@"ProSort"]];
        cityObject.sz_province_Name=[NSString stringWithFormat:@"%@",[provienceDict objectForKey:@"ProName"]];
    }
    
    NSInteger city=[_selectCityView selectedRowInComponent:1];
    NSDictionary *cityDict=[NSDictionary new];
    cityObject.sz_city_Id=[NSString stringWithFormat:@""];
    cityObject.sz_city_Name=[NSString stringWithFormat:@""];
    if((int)([_cityArray count]-1)>=city)
    {
        cityDict=[_cityArray objectAtIndex:city];
        if([[cityDict objectForKey:@"ProID"]isEqualToString:[provienceDict objectForKey:@"ProSort"]])
        {
            cityObject.sz_city_Id=[NSString stringWithFormat:@"%@",[cityDict objectForKey:@"CitySort"]];
            cityObject.sz_city_Name=[NSString stringWithFormat:@"%@",[cityDict objectForKey:@"CityName"]];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"城市选择出现错误"];
            return;
        }
    }
    
    NSInteger zone=[_selectCityView selectedRowInComponent:2];
    NSDictionary *zoneDict=[NSDictionary new];
    cityObject.sz_zone_Id=[NSString stringWithFormat:@""];
    cityObject.sz_zone_name=[NSString stringWithFormat:@""];
    if((int)([_zoneArray count]-1)>=zone)
    {
        zoneDict=[_zoneArray objectAtIndex:zone];
        if([[zoneDict objectForKey:@"CityID"]isEqualToString:[cityDict objectForKey:@"CitySort"]])
        {
            cityObject.sz_zone_Id=[NSString stringWithFormat:@"%@",[zoneDict objectForKey:@"ZoneID"]];
            cityObject.sz_zone_name=[NSString stringWithFormat:@"%@",[zoneDict objectForKey:@"ZoneName"]];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"城市选择出现错误"];
            return;
        }
    }
    _block(cityObject);
    [self disMisView];
}

#pragma mark pickerDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component==0)
    {
        return [_provienceArray count];
    }
    else if (component==1)
    {
        return [_cityArray count];
    }
    else
    {
        return [_zoneArray count];
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component==0)
    {
        return [[_provienceArray objectAtIndex:row]objectForKey:@"ProName"];
    }
    else if (component==1)
    {
        return [[_cityArray objectAtIndex:row]objectForKey:@"CityName"];
    }
    else
    {
        return [[_zoneArray objectAtIndex:row]objectForKey:@"ZoneName"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component==0)
    {
        if([_provienceArray count])
        {
            _cityArray=[[NSMutableArray alloc]initWithArray:[sz_CCLocationManager getAllCityByProvinceId:[[_provienceArray objectAtIndex:row]objectForKey:@"ProSort"]]];
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
        if([_cityArray count])
        {
            _zoneArray=[[NSMutableArray alloc]initWithArray:[sz_CCLocationManager getAllZoneByCityId:[[_cityArray firstObject] objectForKey:@"CitySort"]]];
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
        _isRoll=NO;
    }
    else if(component==1)
    {
        if([_cityArray count])
        {
            _zoneArray=[[NSMutableArray alloc]initWithArray:[sz_CCLocationManager getAllZoneByCityId:[[_cityArray objectAtIndex:row] objectForKey:@"CitySort"]]];
        }
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        _isRoll=NO;
    }
    else
    {
        NSLog(@"改变区域");
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
