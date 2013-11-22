//
//  MCProductShotCarousel.m
//  scrollTest
//
//  Created by Geoffrey Nix on 11/14/13.
//  Copyright (c) 2013 ModCloth. All rights reserved.
//

#import "MCRotatingCarousel.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - LayoutAttributes

//Private class to manage layout attributes
@interface LayoutAttributes : NSObject

@property (assign) BOOL shouldShow;
@property (assign) NSInteger zIndex;
@property (assign) CGFloat scale;
@property (assign) CGFloat xTranslation;

@end

@implementation LayoutAttributes

@end

@interface RotatingCarouselTap : UITapGestureRecognizer

@property (assign) NSInteger index;

@end

@implementation RotatingCarouselTap

@end

#pragma mark - MCRotatingCarousel

@interface MCRotatingCarousel () <UIScrollViewDelegate>

@property (retain) NSArray *cells;
@property (assign) NSInteger itemCount;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation MCRotatingCarousel

#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.sideOffset = self.bounds.size.width/4;
        self.sideScale = 0.7;
        self.originScale = 0.25;
        self.scrollScale = 0.65;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        self.pageControl = [UIPageControl new];
        self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.pageControl.center = CGPointMake(CGRectGetMidX(self.bounds), self.bounds.size.height - 12);
        self.pageControl.hidesForSinglePage = YES;
        
        [self addSubview:self.pageControl];
    }
    return self;
}

-(void)layoutSubviews
{
    NSInteger page = roundf(self.scrollIndex);
    
    self.scrollView.contentSize = [self contentSize];
    for (UIView *view in self.cells) {
        view.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    
    [self moveToPage:page];
}

#pragma mark - public
-(void)reloadData
{
    for (UIView *v in self.scrollView.subviews) {
        [v removeFromSuperview];
    }
    
    self.itemCount = [self.dataSource numberOfItemsInRotatingCarousel:self];
    self.cells = [self createCellArray];
    self.scrollView.contentSize = [self contentSize];
    
    [self configureSubviews];
    
    if (self.itemCount > 2) {
        [self moveToPage:2];
    } else {
        [self moveToPage:(self.itemCount - 1)];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configureSubviews];
    [self updatePagingControl];
    [self resetOffsetIfNeeded];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //This is the index of the "page" that we will be landing at
    NSUInteger nearestIndex = roundf(targetContentOffset->x / (scrollView.bounds.size.width*self.scrollScale));
    
    //This is the actual x position in the scroll view
    CGFloat xOffset = nearestIndex * scrollView.bounds.size.width * self.scrollScale;
    
    //I've found that scroll views will "stick" unless this is done
    xOffset = xOffset==0?1:xOffset;
    
    *targetContentOffset = CGPointMake(xOffset, targetContentOffset->y);
}

#pragma mark - Manage Image Views

-(NSArray*)createCellArray
{
    //We need to add copies of the views at the beginning and end for the looping effect to be seamless
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    if (self.itemCount == 1) {
        //If only 1, we will show only one view in the middle.  Scrolling will be disabled
        [itemViews addObject:[self createViewAtIndex:0]];
    } else if (self.itemCount == 2) {
        //show four, rotate infine between 1 and 2.  1 is visible on the top, with copies of 2 on right and left.
        for (int i = 0; i < 3; i++) {
            [itemViews addObject:[self createViewAtIndex:0]];
            [itemViews addObject:[self createViewAtIndex:1]];
        }
    } else if (self.itemCount > 2) {
        //If more than 2, append and prepend two additional copies of the views
        [itemViews addObject:[self createViewAtIndex:self.itemCount -2]];
        [itemViews addObject:[self createViewAtIndex:self.itemCount -1]];
        for (int i = 0; i < self.itemCount; i++){
            [itemViews addObject:[self createViewAtIndex:i]];
        }
        [itemViews addObject:[self createViewAtIndex:0]];
        [itemViews addObject:[self createViewAtIndex:1]];
    }
    
    return [NSArray arrayWithArray:itemViews];
}

-(void)updatePagingControl
{
    int currentPage = ((int)roundf(self.scrollIndex) - 2) % self.itemCount;
    if (self.itemCount == 1) {
        currentPage = 1;
    } if (self.itemCount == 2) {
        currentPage = (int)roundf(self.scrollIndex) % 2;
    }
    
    self.pageControl.numberOfPages = self.itemCount;
    self.pageControl.currentPage = currentPage;
}

-(void)resetOffsetIfNeeded
{
    if (self.scrollIndex > 0 && self.scrollIndex < 1.99) {
        //move to end
        CGFloat startX = self.bounds.size.width * (self.itemCount + self.scrollIndex) * self.scrollScale;
        self.scrollView.contentOffset = CGPointMake(startX, 0);
    }
    
    if(self.scrollIndex > self.itemCount + 2 && self.scrollIndex < self.itemCount + 3.99){
        //move to front
        CGFloat startX = self.bounds.size.width * (self.scrollIndex - self.itemCount) * self.scrollScale;
        self.scrollView.contentOffset = CGPointMake(startX, 0);
    }
}

//should update all cells based on scroll position
//add/remove from view heirarchy
//set transform for size and position
-(void)configureSubviews
{
    for (int i = 0; i<self.cells.count; i++) {
        UIView *cell = self.cells[i];
        [self configureCell:cell atIndex:i];
    }
    
    //set zIndex
    for (int i = 1; i <= 4; i++) {
        [self.scrollView bringSubviewToFront:[self.scrollView viewWithTag:i]];
    }
    
}

-(LayoutAttributes*)layoutAttributesForIndex:(NSInteger)index
{
    LayoutAttributes *attribs = [LayoutAttributes new];
    
    NSInteger offsetFromCenter = index - floorf(self.scrollIndex);
    switch (offsetFromCenter) {
        case -1: //Between "far left" and "left"
            attribs.shouldShow = YES;
            attribs.xTranslation =  -1*self.sideOffset*self.percentFromLeftToCenter;
            attribs.zIndex = 2;
            attribs.scale = self.originScale + (self.percentFromLeftToCenter * (self.sideScale - self.originScale));
            break;
        case 0: //Between "left" and center
            attribs.shouldShow = YES;
            attribs.xTranslation = -1*self.sideOffset*self.percentFromCenterToRight;
            attribs.zIndex = roundf(3 + self.percentFromLeftToCenter);
            attribs.scale = self.sideScale + (self.percentFromLeftToCenter * (1 - self.sideScale));
            break;
        case 1: //Between "right" and center
            attribs.shouldShow = YES;
            attribs.xTranslation = self.sideOffset*self.percentFromLeftToCenter;
            attribs.zIndex = roundf(3 + self.percentFromCenterToRight);
            attribs.scale = self.sideScale + (self.percentFromCenterToRight *(1 - self.sideScale));
            break;
        case 2: //Between "far right" and "right"
            attribs.shouldShow = YES;
            attribs.xTranslation = self.sideOffset*self.percentFromCenterToRight;
            attribs.zIndex = 1;
            attribs.scale = self.originScale + (self.percentFromCenterToRight * (self.sideScale - self.originScale));
            break;
        default: //Far on the "right" or "left" and not visible.
            attribs.shouldShow = NO;
            break;
    }
    
    return attribs;
}

-(void)configureCell:(UIView*)cell atIndex:(NSInteger)index
{
    
    LayoutAttributes *attribs = [self layoutAttributesForIndex:index];
    
    if (!attribs.shouldShow) {
        //We could release the cell from memory (cell array), but we don't tend to have too many, so we can just keep it simple.
        [cell removeFromSuperview];
        return;
    }
    
    if (![cell superview]) {
        [self.scrollView addSubview:cell];
    }
    
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, self.scrollView.contentOffset.x + attribs.xTranslation, 0);
    t = CGAffineTransformScale(t, attribs.scale, attribs.scale);
    cell.transform = t;
    cell.tag = attribs.zIndex;
}

-(UIView*)createViewAtIndex:(NSUInteger)index
{
    UIView *itemView = [self.dataSource rotatingCarousel:self viewForItemAtIndex:index];
    RotatingCarouselTap *tap = [[RotatingCarouselTap alloc] initWithTarget:self action:@selector(didTapView:)];
    tap.index = index;
    itemView.userInteractionEnabled = YES;
    [itemView addGestureRecognizer:tap];
    
    itemView.layer.shouldRasterize = YES;
    itemView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [self.scrollView addSubview:itemView];
    itemView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    return itemView;
}

-(void)moveToPage:(NSInteger)page
{
    CGFloat x = self.bounds.size.width * (page) * self.scrollScale;
    [self.scrollView scrollRectToVisible:CGRectMake(x, 0, self.bounds.size.width, 1) animated:NO];
}

#pragma mark - helpers

//consider making these public properties

-(CGSize)contentSize
{
    CGFloat contentWidth = self.bounds.size.width * self.cells.count * self.scrollScale;
    return CGSizeMake(contentWidth, self.frame.size.height);
}

/** percentage scrolled, 0 = all the way to the left, 1 = all the way to the right */
-(CGFloat)scrollPercent
{
    CGFloat maxOrigin = (self.scrollView.contentSize.width - (self.scrollView.bounds.size.width * self.scrollScale));
    if (maxOrigin == 0) {
        return 0;
    }
    return self.scrollView.contentOffset.x / maxOrigin;
}

/** determine which item we are scrolled to */
-(CGFloat)scrollIndex
{
    return self.scrollPercent * (self.cells.count-1);
}

-(CGFloat)percentFromCenterToRight
{
    return self.scrollIndex - floorf(self.scrollIndex);
}

-(CGFloat)percentFromLeftToCenter
{
    return 1 - self.percentFromCenterToRight;
}

#pragma mark - recognizer callbacks

- (void)didTapView:(RotatingCarouselTap *)tap
{
    if ([self.delegate respondsToSelector:@selector(rotatingCarousel:didSelectView:atIndex:)]) {
        [self.delegate rotatingCarousel:self
                          didSelectView:tap.view
                                atIndex:tap.index];
    }
}

@end
