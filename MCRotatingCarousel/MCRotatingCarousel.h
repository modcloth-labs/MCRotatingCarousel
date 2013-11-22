//
//  MCProductShotCarousel.h
//  scrollTest
//
//  Created by Geoffrey Nix on 11/14/13.
//  Copyright (c) 2013 ModCloth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCRotatingCarousel;

@protocol MCRotatingCarouselDataSource <NSObject>

@required
/**
 The number of items in the carousel
 */
-(NSUInteger)numberOfItemsInRotatingCarousel:(MCRotatingCarousel*)carousel;
/**
 Return the view for a given index.
 This will only be called once for each view.
 Unlike UITableView or UICollectionView, all "cells" are kept in memory
 So this isn't suitable for large data sets.
 
 The view should be sized as desired for display when it is in the center position.
 */
-(UIView*)rotatingCarousel:(MCRotatingCarousel*)carousel viewForItemAtIndex:(NSUInteger)index;


@end

#pragma mark -
/**
 Delegate protocol for MCRotatingCarousel
 */
@protocol MCRotatingCarouselDelegate <NSObject>

@optional
/**
 Called when the user taps on a sub-view
 */
-(void)rotatingCarousel:(MCRotatingCarousel *)carousel didSelectView:(UIView*)view atIndex:(NSUInteger)index;

@end

#pragma mark -
/**
 A looping carousel view designed to show the content
 in a circular fashion.
 
 Designed for small number of subviews - eg, 1 to 20.  All the subviews are kept in memory.
 
 Subclassing Note:
 if you set the scroll view delegate, you need to call super in your implementation.
 
 Future optimization could incorporate a cell reuse/dequeue feature.
 */
@interface MCRotatingCarousel : UIView

/**
 Provides user interaction feedback to the delegate
 */
@property (weak) id<MCRotatingCarouselDelegate> delegate;
/**
 Allows the MCRotatingCarousel to get configuration information
 */
@property (weak) id<MCRotatingCarouselDataSource> dataSource;
/**
 A reference to the page control
 you can set hidden = YES, and/or adjust the currentPageIndicatorTintColor and pageIndicatorTintColor
 */
@property (strong) UIPageControl *pageControl;
/**
 How far off the center the side images should be.
 Defaults to 25% of the size of the MCRotationgCarousel view
 */
@property (assign) CGFloat sideOffset;
/**
 Define what percentage to scale down when the subviews are in the side position.
 Defaults to 0.7 if not specified
 
 @returns percentage to scale down for side images, between 0 and 1;
 */
@property (assign) CGFloat sideScale;
/**
 Define what percentage to scale down when the subviews are in the origin position.
 The origin position is when the views are obscured behind the left and right positions
 
 Defaults to 0.25 if not specified
 
 @returns percentage to scale down for origin images, between 0 and 1;
 */
@property (assign) CGFloat originScale;
/**
 determines how fast the scroll view scrolls based on user input.  Small number = faster scrolling
 1 = swipe from end to end will advance one rotation
 
 Defaults to 0.65
 */
@property (assign) CGFloat scrollScale;

/**
 resets the scroll view.
 Call this after initializing the data source, and if the data source changes.
 */
-(void)reloadData;

@end
