//
//  FFRunkeeperSwitch.m
//  FFSwitchDemo
//
//  Created by Stephen Hu on 2018/11/11.
//  Copyright © 2018 Stephen Hu. All rights reserved.
//

#import "QZPageSwitch.h"
#import <objc/runtime.h>

@interface QZPageSwitch()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView  *titleLabelsContentView;
@property (nonatomic, strong) NSMutableArray<UILabel *> *titleLabels;
@property (nonatomic, strong) UIView  *selectedTitleLabelsContentView;
@property (nonatomic, strong) NSMutableArray<UILabel *> *selectedTitleLabels;
@property (nonatomic, strong) UIImageView  *selectedBackgroundView;
@property (nonatomic, strong) UIView  *titleMaskView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, copy)   NSString *titleFontFamily;
@property (nonatomic, strong) NSMutableArray<UILabel *> *badgeLabels;
@property (nonatomic, assign) CGRect initialSelectedBackgroundViewFrame;
@property (nonatomic, assign) CGFloat titleFontSize;
@property (nonatomic, assign) CGFloat animationSpringDamping;
@property (nonatomic, assign) CGFloat animationInitialSpringVelocity;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@end
@implementation QZPageSwitch

#pragma mark ————— 取值 —————
- (NSInteger)badgeValueFromIndex:(NSInteger)index {
    return self.badgeLabels[index].text.integerValue;
}
#pragma mark ————— 赋值 —————
- (void)setSelectedBackgroundInset:(CGFloat)selectedBackgroundInset {
    _selectedBackgroundInset = selectedBackgroundInset;
    [self setNeedsLayout];
}
- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    for (NSString *str in titles) {
        UILabel *label = [[UILabel alloc] init];
        label.text = str;
        label.font = self.titleFont;
        label.textColor = self.titleColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.titleLabelsContentView addSubview:label];
        [self.titleLabels addObject:label];
        UILabel *selectlabel = [[UILabel alloc] init];
        selectlabel.text = str;
        selectlabel.font = self.titleFont;
        selectlabel.textColor = self.selectedTitleColor;
        selectlabel.textAlignment = NSTextAlignmentCenter;
        selectlabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.selectedTitleLabelsContentView addSubview:selectlabel];
        [self.selectedTitleLabels addObject:selectlabel];
        UILabel *badgeLabel = [[UILabel alloc] init];
        badgeLabel.text = @"";
        badgeLabel.font = self.badgeValueFont;
        badgeLabel.textColor = self.badgeValueTextColor;
        badgeLabel.backgroundColor = self.badgeValueBackgroundColor;
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:badgeLabel];
        [self.badgeLabels addObject:badgeLabel];
    }
}
- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    for (UILabel *lable in self.selectedTitleLabels) {
        lable.textColor = selectedTitleColor;
    }
}
- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (UILabel *label in self.selectedTitleLabels) {
        label.font = titleFont;
    }
    for (UILabel *label in self.titleLabels) {
        label.font = titleFont;
    }
}
- (void)setBadgeValueFont:(UIFont *)badgeValueFont {
    _badgeValueFont = badgeValueFont;
    for (UILabel *label in self.badgeLabels) {
        label.font = badgeValueFont;
    }
}
- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    for (UILabel *label in self.titleLabels) {
        label.textColor = titleColor;
    }
}
- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
    self.selectedBackgroundView.backgroundColor = selectedBackgroundColor;
}
- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage {
    _selectedBackgroundImage = selectedBackgroundImage;
    self.selectedBackgroundView.image = selectedBackgroundImage;
}
- (void)setBadgeValue:(NSInteger)badgeValue forIndex:(NSInteger)index {
    if (badgeValue == 0) {
        self.badgeLabels[index].text = @"";
    } else {
        self.badgeLabels[index].text = [NSString stringWithFormat:@"%ld",badgeValue];
    }
    [self setNeedsLayout];
}
- (void)setBadgeValueTextColor:(UIColor *)badgeValueTextColor {
    _badgeValueTextColor = badgeValueTextColor;
    [self.badgeLabels setValue:badgeValueTextColor forKeyPath:@"textColor"];
    [self setNeedsLayout];
}
- (void)setBadgeValueBackgroundColor:(UIColor *)badgeValueBackgroundColor {
    _badgeValueBackgroundColor = badgeValueBackgroundColor;
    [self.badgeLabels setValue:badgeValueBackgroundColor forKeyPath:@"backgroundColor"];
}
- (void)setSwitchPageView:(UIScrollView *)switchPageView {
    _switchPageView = switchPageView;
    if (switchPageView) {
        switchPageView.pagingEnabled = YES;
        switchPageView.contentSize = CGSizeMake(switchPageView.bounds.size.width * self.titles.count, switchPageView.bounds.size.height);
        [switchPageView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}
#pragma mark ————— 事件 —————
- (void)tapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    int index = (int)(location.x / (self.bounds.size.width  / (1.0 * self.titleLabels.count)));
    BOOL animated =  (self.selectedIndex + 1 == index || self.selectedIndex - 1 == index) ? YES : NO;
    [self setSelectedIndex:index animated:animated];
}
- (void)pan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.initialSelectedBackgroundViewFrame = self.selectedBackgroundView.frame;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.initialSelectedBackgroundViewFrame;
        frame.origin.x += [gesture translationInView:self].x;
        frame.origin.x = MAX(MIN(frame.origin.x, self.bounds.size.width - self.selectedBackgroundInset - frame.size.width), self.selectedBackgroundInset);
        self.selectedBackgroundView.frame = frame;
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled) {
        int index = MAX(0, MIN(self.titleLabels.count - 1, (self.selectedBackgroundView.center.x / (self.bounds.size.width / (1.0 * self.titleLabels.count)))));
        [self setSelectedIndex:index animated:YES];
    }
}
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (selectedIndex <= self.titleLabels.count) {
        BOOL catchHalfSwitch = NO;
        if (self.selectedIndex == selectedIndex) {
            catchHalfSwitch = YES;
        }
        self.selectedIndex = selectedIndex;
        if (animated) {
            if (!catchHalfSwitch) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            [UIView animateWithDuration:self.animationDuration delay:0.0 usingSpringWithDamping:self.animationSpringDamping initialSpringVelocity:self.animationInitialSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut animations:^{
                [self setNeedsLayout];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) { // 动画结束切换scrollview的位置
                if (self.switchPageView) {
                    CGPoint contentOffset = CGPointMake(selectedIndex * self.switchPageView.bounds.size.width, 0);
                    [self.switchPageView setContentOffset:contentOffset animated:NO];
                }
            }];
        } else {
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            if (self.switchPageView) {
                CGPoint contentOffset = CGPointMake(selectedIndex * self.switchPageView.bounds.size.width, 0);
                [self.switchPageView setContentOffset:contentOffset animated:NO];
            }
        }
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat selectedBackgroundWidth = self.bounds.size.width / (CGFloat)(self.titleLabels.count) - self.selectedBackgroundInset * 2.0;
    self.selectedBackgroundView.frame = CGRectMake(self.selectedBackgroundInset + (CGFloat)(self.selectedIndex) * (selectedBackgroundWidth + self.selectedBackgroundInset * 2.0), self.selectedBackgroundInset, selectedBackgroundWidth, self.bounds.size.height - self.selectedBackgroundInset * 2.0);
    self.titleLabelsContentView.frame = self.selectedTitleLabelsContentView.frame = self.bounds;
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
    self.selectedBackgroundView.layer.cornerRadius = self.selectedBackgroundView.frame.size.height * 0.5;
    self.selectedBackgroundView.layer.masksToBounds = YES;
    CGFloat titleLabelMaxWidth = selectedBackgroundWidth;
    CGFloat titleLabelMaxHeight = self.bounds.size.height - self.selectedBackgroundInset * 2.0;
    [self.titleLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize size = [label sizeThatFits:CGSizeMake(titleLabelMaxWidth, titleLabelMaxHeight)];
        size.width = MIN(size.width, titleLabelMaxWidth);
        double x = floor((self.bounds.size.width / (CGFloat)self.titleLabels.count) * (CGFloat)idx + (self.bounds.size.width / (CGFloat)self.titleLabels.count - size.width) / 2.0);
        double y = floor((self.bounds.size.height - size.height) / 2);
        CGRect frame = CGRectMake(x, y, size.width, size.height);
        CGPoint badgeCenter = CGPointMake(x + size.width , y);
        UILabel *badgeLabel = self.badgeLabels[idx];
        CGSize badgeSize = [badgeLabel sizeThatFits:CGSizeMake(50, 30)];
        if (badgeSize.width > 50) {
            badgeSize.width = 50;
            if (badgeLabel.text.integerValue > 100) {
                badgeLabel.text = @"100+";
            }
        }
        badgeSize.width = badgeSize.height > badgeSize.width ? badgeSize.height : badgeSize.width;
        label.frame = frame;
        ((UILabel *)self.selectedTitleLabels[idx]).frame = frame;
        badgeLabel.center = badgeCenter;
        CGFloat badgeWidth = badgeSize.width;
        CGFloat badgeHeight = badgeSize.height;
        if (badgeSize.width != 0) {
            badgeWidth  += 2;
            badgeHeight += 2;
        }
        badgeLabel.bounds = CGRectMake(0, 0, badgeWidth, badgeHeight);
        badgeLabel.layer.cornerRadius = badgeHeight * 0.5;
        badgeLabel.layer.masksToBounds = YES;
    }];
}
- (void)moveSwitchBySwitchPageView:(UIScrollView *)switchPageView {
    if (!switchPageView.isDragging && !switchPageView.isDecelerating) {return;}
    if (switchPageView.contentOffset.x < 0 || switchPageView.contentOffset.x > switchPageView.contentSize.width - switchPageView.bounds.size.width) {return;}
    CGFloat currentOffSetX = switchPageView.contentOffset.x;
    CGFloat offsetProgress = currentOffSetX / switchPageView.bounds.size.width;
    NSLog(@"switchPageView的偏移量是%f",offsetProgress);
    CGRect bgFrame = self.selectedBackgroundView.frame;
    NSLog(@"selectedBackgroundView的frame是：%@",NSStringFromCGRect(bgFrame));
    bgFrame.origin.x = (self.bounds.size.width / self.titles.count) * offsetProgress + self.selectedBackgroundInset;
    NSLog(@"向上取整%f",ceilf(offsetProgress + 1));
    self.selectedBackgroundView.frame = bgFrame;
    NSInteger index = ceilf(offsetProgress);
    if (switchPageView.contentOffset.x == index * switchPageView.bounds.size.width) {
        self.selectedIndex = index;
    }
}
#pragma mark ————— 基础设置 —————
- (instancetype)initWithTitles:(NSArray *)titles {
    if (self = [super initWithFrame:CGRectZero]) {
        [self finishInit];
        self.titles = titles;
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self finishInit];
    return self;
}
- (void)makeupUI {
    self.backgroundColor = [UIColor redColor];
}
- (void)finishInit {
    // 添加view
    [self addSubview:self.titleLabelsContentView];
    [self addSubview:self.selectedBackgroundView];
    [self addSubview:self.selectedTitleLabelsContentView];
    self.titleMaskView.backgroundColor = [UIColor blackColor];
    self.selectedTitleLabelsContentView.layer.mask = self.titleMaskView.layer;
    [self addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.panGesture];
    
    // 给变量赋值
    self.titleFontFamily = @"HelveticaNeue";
    self.selectedIndex = 0;
    self.selectedBackgroundInset = 2;
    self.titleFontSize = 16.0;
    self.animationDuration = 0.3;
    self.animationSpringDamping = 0.75;
    self.animationInitialSpringVelocity = 0.0;
    self.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundColor = [UIColor whiteColor];
    self.titleColor = [UIColor whiteColor];
    self.selectedTitleColor = [UIColor blackColor];
    [self.selectedBackgroundView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    self.titleFont = [UIFont fontWithName:self.titleFontFamily size:self.titleFontSize];
    self.badgeValueFont = [UIFont fontWithName:self.titleFontFamily size:self.titleFontSize];
    self.badgeValueTextColor = [UIColor whiteColor];
    self.badgeValueBackgroundColor = [UIColor redColor];
}
- (void)dealloc {
    [self.selectedBackgroundView removeObserver:self forKeyPath:@"frame"];
}

#pragma mark ————— kvo —————
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"] && object == self.selectedBackgroundView) {
        self.titleMaskView.frame = self.selectedBackgroundView.frame;
    } else if ([keyPath isEqualToString:@"contentOffset"] && object == self.switchPageView) {// 根据scrollview的偏移量来设置滑块的位置
        [self moveSwitchBySwitchPageView:self.switchPageView];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark ————— UIGestureRecognizerDelegate —————
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return CGRectContainsPoint(self.selectedBackgroundView.frame, [gestureRecognizer locationInView:self]);
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark ————— lazyLoad —————
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        panGesture.delegate = self;
        _panGesture = panGesture;
    }
    return _panGesture;
}
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        _tapGesture = tapGesture;
    }
    return _tapGesture;
}
- (UIView *)titleMaskView {
    if (!_titleMaskView) {
        UIView *titleMaskView = [UIView new];
        _titleMaskView = titleMaskView;
    }
    return _titleMaskView;
}
- (UIImageView *)selectedBackgroundView {
    if (!_selectedBackgroundView) {
        UIImageView *selectedBackgroundView = [UIImageView new];
        _selectedBackgroundView = selectedBackgroundView;
    }
    return _selectedBackgroundView;
}
- (UIView *)selectedTitleLabelsContentView {
    if (!_selectedTitleLabelsContentView) {
        UIView *selectedTitleLabelsContentView = [UIView new];
        _selectedTitleLabelsContentView = selectedTitleLabelsContentView;
    }
    return _selectedTitleLabelsContentView;
}
- (UIView *)titleLabelsContentView {
    if (!_titleLabelsContentView) {
        UIView *titleLabelsContentView = [UIView new];
        _titleLabelsContentView = titleLabelsContentView;
    }
    return _titleLabelsContentView;
}
- (NSMutableArray<UILabel *> *)badgeLabels {
    if (!_badgeLabels) {
        NSMutableArray *badgeLabels = [NSMutableArray array];
        _badgeLabels = badgeLabels;
    }
    return _badgeLabels;
}
- (NSMutableArray<UILabel *> *)titleLabels {
    if (!_titleLabels) {
        NSMutableArray *titleLabels = [NSMutableArray array];
        _titleLabels = titleLabels;
    }
    return _titleLabels;
}
- (NSMutableArray<UILabel *> *)selectedTitleLabels {
    if (!_selectedTitleLabels) {
        NSMutableArray *selectedTitleLabels = [NSMutableArray array];
        _selectedTitleLabels = selectedTitleLabels;
    }
    return _selectedTitleLabels;
}
@end
