//
//  FSViewController.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 3/18/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSViewController.h"

@interface FSViewController ()

@end

@implementation FSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNib
{
    NSString *nibName = [[self class] description];
    if ([[NSFileManager defaultManager] fileExistsAtPath:nibName]) {
        return [self initWithNibName:nibName bundle:nil];
    } else {
        return [[[self class] alloc] init];
    }
}

+ (id)controller
{
    return [[[self class] alloc] initWithNib];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
