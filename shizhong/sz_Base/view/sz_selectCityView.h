//
//  sz_selectCityView.h
//  shizhong
//
//  Created by sundaoran on 15/12/26.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface sz_selectCityView : UIView<UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate>


-(void)showSelectCityView;


-(void)selectCitySureActionBlock:(void(^)(sz_cityObject * cityObject))block;
@end
