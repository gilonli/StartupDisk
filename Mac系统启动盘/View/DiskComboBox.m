//
//  DiskComboBox.m
//  Mac系统启动盘
//
//  Created by Dasen on 2017/1/14.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "DiskComboBox.h"
#import "DADSDiskTool.h"

@interface DiskComboBox () <NSComboBoxDelegate,NSComboBoxDataSource,NSComboBoxCellDataSource, DADSDiskToolDelegate>

@property (nonatomic, strong)NSMutableArray *array;

@property (nonatomic, weak)NSMutableDictionary *diskDict;

@end

@implementation DiskComboBox

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        self.usesDataSource = YES;
        self.delegate    = self;
        self.dataSource  = self;
        self.stringValue = @"请重新插入U盘,以便于自动识别!";
    }
    return self;
}
- (void)setDiskTool:(DADSDiskTool *)diskTool
{
    _diskTool = diskTool;
    _diskTool.comBoxdelegate = self;
}

- (nullable id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    return [DADSDiskTool getApendDiskNameWithDisk:(__bridge DADiskRef)(self.diskDict.allValues[index])];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
    return self.diskDict.allKeys.count;
}


- (void)diskDidChangeState:(NSMutableDictionary *)diskDict
{
    self.stringValue = diskDict.allKeys.count ? @"请选择需要制作启动盘的分区：":@"请重新插入U盘,自动识别检测!";
    self.diskDict = diskDict;
    [self reloadData];
}
@end
