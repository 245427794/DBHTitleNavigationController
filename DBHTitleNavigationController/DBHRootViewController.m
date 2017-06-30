//
//  DBHRootViewController.m
//  DBHTitleNavigationController
//
//  Created by DBH on 17/6/29.
//  Copyright © 2017年 邓毕华. All rights reserved.
//

#import "DBHRootViewController.h"

#define  SCREENWIDTH [UIScreen mainScreen].bounds.size.width // 屏幕宽度
#define  SCREENHEIGHT [UIScreen mainScreen].bounds.size.height // 屏幕高度

static const CGFloat titleLabelWidth = 100; // label宽度
static const CGFloat scale = 1.3; // 选中形变倍数

@interface DBHRootViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak) UILabel *currentSelectedTitleLabel; // 当前选中标题Label
@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, copy) NSArray *titleArray; // 标题数组
@property (nonatomic, copy) NSArray *contentVCClassArray; // 内容控制器类名数组

@end

@implementation DBHRootViewController

#pragma mark - Getters And Setters
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"色彩世界";
    
    // iOS7会给导航控制器下所有的UIScrollView顶部添加额外滚动区域，最好关闭
    self.automaticallyAdjustsScrollViewInsets = NO;
 
    [self setUI];
}

#pragma mark - UI
- (void)setUI {
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.contentScrollView];
    
    [self addChildViewControllers];
    [self addTitleLabels];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取当前页数
    CGFloat currentPage = scrollView.contentOffset.x / SCREENWIDTH;
    
    // 获取当前选中label
    UILabel *currentSelectedLabel = [self.titleScrollView viewWithTag:200 + currentPage];
    // 获取上一个选中label
    UILabel *lastSelectedLabel;
    if (currentPage + 1 < self.contentVCClassArray.count - 1) {
        lastSelectedLabel = [self.titleScrollView viewWithTag:201 + currentPage];
    }
    
    // 计算上一个选中label缩放比例
    CGFloat lastSelectedLabelScale = currentPage - (NSInteger)currentPage;
    // 计算当前选中label缩放比例
    CGFloat currentSelectedLabelScale = 1 - lastSelectedLabelScale;
    
    // 缩放
    currentSelectedLabel.transform = CGAffineTransformMakeScale(currentSelectedLabelScale * 0.3 + 1, currentSelectedLabelScale * 0.3 + 1);
    lastSelectedLabel.transform = CGAffineTransformMakeScale(lastSelectedLabelScale * 0.3 + 1, lastSelectedLabelScale * 0.3 + 1);
    
    // 颜色渐变
    currentSelectedLabel.textColor = [UIColor colorWithRed:currentSelectedLabelScale green:0 blue:0 alpha:1];
    lastSelectedLabel.textColor = [UIColor colorWithRed:lastSelectedLabelScale green:0 blue:0 alpha:1];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 选中label
    [self selectedLabel:(UILabel *)[self.titleScrollView viewWithTag:200 + scrollView.contentOffset.x / SCREENWIDTH]];
    
    // 显示对应控制器的view
    [self showContentVC:scrollView.contentOffset.x / SCREENWIDTH];
}

#pragma mark - Event Responds
- (void)respondsToTitleLabel:(UITapGestureRecognizer *)tapGR {
    // 选中label
    [self selectedLabel:(UILabel *)tapGR.view];
    
    // 显示对应控制器的view
    [self showContentVC:tapGR.view.tag - 200];
}

#pragma mark - Private Methods
/**
 添加所有子控制器对应的标题
 */
- (void)addTitleLabels {
    for (NSInteger i = 0; i < self.contentVCClassArray.count; i++) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 200 + i;
        titleLabel.frame = CGRectMake(titleLabelWidth * i, 0, titleLabelWidth, 44);
        titleLabel.text = self.titleArray[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.highlightedTextColor = [UIColor redColor];
        titleLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTitleLabel:)];
        [titleLabel addGestureRecognizer:tapGR];
        
        // 默认选中第1个titleLabel
        if (!i) {
            [self respondsToTitleLabel:tapGR];
        }
        
        [self.titleScrollView addSubview:titleLabel];
    }
}
/**
 添加所有子控制器
 */
- (void)addChildViewControllers {
    for (NSInteger i = 0; i < self.contentVCClassArray.count; i++) {
        NSString *contentVCClassName = self.contentVCClassArray[i];
        UIViewController *contentVC = [[NSClassFromString(contentVCClassName) alloc] init];
        [self addChildViewController:contentVC];
        
        contentVC.view.frame = CGRectMake(SCREENWIDTH * i, 0, SCREENWIDTH, SCREENHEIGHT);
        [self.contentScrollView addSubview:contentVC.view];
    }
}
/**
 选中label
 */
- (void)selectedLabel:(UILabel *)label {
    // 还原前一个选中label的属性
    self.currentSelectedTitleLabel.highlighted = NO;
    self.currentSelectedTitleLabel.transform = CGAffineTransformIdentity;
    self.currentSelectedTitleLabel.textColor = [UIColor blackColor];
    
    // 修改选中label的属性
    label.highlighted = YES;
    label.transform = CGAffineTransformMakeScale(scale, scale);
    
    // 更改选中的label
    self.currentSelectedTitleLabel = label;
    
    // 居中选中的label
    CGFloat offsetX = label.center.x - SCREENWIDTH * 0.5;
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - SCREENWIDTH;
    if (offsetX < 0) {
        offsetX = 0;
    } else if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

/**
 显示选中标题对面的控制器view

 @param index 选中标题的下标
 */
- (void)showContentVC:(NSInteger)index {
    // 移动内容scrollView到指定位置
    self.contentScrollView.contentOffset = CGPointMake(SCREENWIDTH * index, 0);
}

#pragma mark - Getters And Setters
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, 44)];
        _titleScrollView.contentSize = CGSizeMake(titleLabelWidth * self.contentVCClassArray.count, 0);
        // 隐藏水平滚动条
        _titleScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _titleScrollView;
}
- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleScrollView.frame), SCREENWIDTH, SCREENHEIGHT - 44)];
        _contentScrollView.contentSize = CGSizeMake(SCREENWIDTH * self.contentVCClassArray.count, 0);
        // 开启分页
        _contentScrollView.pagingEnabled = YES;
        // 关闭回弹
        _contentScrollView.bounces = NO;
        // 隐藏水平滚动条
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        // 设置代理
        _contentScrollView.delegate = self;
    }
    return _contentScrollView;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"红", @"蓝", @"绿", @"黄", @"紫", @"橘"];
    }
    return _titleArray;
}
- (NSArray *)contentVCClassArray {
    if (!_contentVCClassArray) {
        _contentVCClassArray = @[@"DBHRedViewController",
                                 @"DBHBlueViewController",
                                 @"DBHGreenViewController",
                                 @"DBHYellowViewController",
                                 @"DBHPurPleViewController",
                                 @"DBHOrangeViewController"];
    }
    return _contentVCClassArray;
}

@end
