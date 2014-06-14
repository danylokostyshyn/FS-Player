//
//  FSProgressButton.m
//  fs-player
//
//  Created by Danylo Kostyshyn on 6/16/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

#import "FSProgressButton.h"

@interface FSProgressButton ()
@property (strong, nonatomic) CAShapeLayer *backgroundLayer;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@end

@implementation FSProgressButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configure];
}

- (void)configure
{
    CGColorRef color = self.tintColor.CGColor;
    
    // Circle background layer
    self.backgroundLayer = [[CAShapeLayer alloc] init];
    self.backgroundLayer.frame = self.layer.bounds;
    self.backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    self.backgroundLayer.fillColor = nil;
    self.backgroundLayer.lineWidth = 1.0f;
    self.backgroundLayer.strokeColor = color;
    
    [self.layer addSublayer:self.backgroundLayer];
    
    
    // Progress layer
    CGFloat lineWidth = 3.0f;
    CGRect rect = CGRectInset(self.bounds, lineWidth / 2.0f, lineWidth / 2.0f);
    
    self.progressLayer = [[CAShapeLayer alloc] init];
    self.progressLayer.frame = self.layer.bounds;
    self.progressLayer.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
    self.progressLayer.fillColor = nil;
    self.progressLayer.lineWidth = lineWidth;
    self.progressLayer.strokeColor = color;
    self.progressLayer.transform = CATransform3DRotate(self.progressLayer.transform, -M_PI/2, 0, 0, 1);
    self.progressLayer.strokeEnd = self.progress;
    
    [self.layer addSublayer:self.progressLayer];
}

- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress) {
        _progress = progress;
        
        self.progressLayer.strokeEnd = _progress;
    }
}

@end
