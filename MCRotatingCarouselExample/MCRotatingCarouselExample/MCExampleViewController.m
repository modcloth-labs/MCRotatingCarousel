//
//  MCExampleViewController.m
//  MCRotatingCarouselExample
//
//  Created by Geoffrey Nix on 11/22/13.
//  Copyright (c) 2013 ModCloth. All rights reserved.
//

#import "MCExampleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MCRotatingCarousel.h"

@interface MCExampleViewController ()<MCRotatingCarouselDataSource, MCRotatingCarouselDelegate>

@property (strong) NSArray *items;

@end

@implementation MCExampleViewController

#pragma mark - UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.items = @[
                       [UIColor redColor],
                       [UIColor orangeColor],
                       [UIColor yellowColor],
                       [UIColor greenColor],
                       [UIColor blueColor],
                       [UIColor purpleColor],
                       ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    MCRotatingCarousel *carousel = [[MCRotatingCarousel alloc]initWithFrame:self.view.bounds];
    carousel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    carousel.delegate = self;
    carousel.dataSource = self;
    carousel.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    carousel.pageControl.pageIndicatorTintColor = [UIColor cyanColor];
    [self.view addSubview:carousel];
    
    [carousel reloadData];
}

#pragma mark - MCRotatingCarouselDataSource
-(UIView *)rotatingCarousel:(MCRotatingCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    //Create your view here - it could be any kind of view, eg. a UIImageView.
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 250)];
    view.backgroundColor = self.items[index];
    view.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    view.layer.borderWidth = 2;
    
    return view;
}

-(NSUInteger)numberOfItemsInRotatingCarousel:(MCRotatingCarousel *)carousel
{
    return self.items.count;
}

#pragma mark - MCRotatingCarouselDelegate
-(void)rotatingCarousel:(MCRotatingCarousel *)carousel didSelectView:(UIView *)view atIndex:(NSUInteger)index
{
    NSLog(@"did select item at index: %i",index);
}

#pragma mark - private
 
@end
