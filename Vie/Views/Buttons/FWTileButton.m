//
// Created by Fabien Warniez on 14-11-25.
// Copyright (c) 2014 Fabien Warniez. All rights reserved.
//

#import "FWTileButton.h"

@implementation FWTileButton

- (instancetype)initWithMainColor:(UIColor *)mainColor image:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.mainColor = mainColor;
        self.image = image;
    }

    return self;
}

+ (instancetype)buttonWithMainColor:(UIColor *)mainColor image:(UIImage *)image
{
    return [[self alloc] initWithMainColor:mainColor image:image];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];

    [self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];

    [self removeTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Private Methods

- (void)buttonPressed:(id)buttonPressed
{
    if (!self.isSelected)
    {
        self.selected = YES;

        [self.delegate tileButtonWasSelected:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.isSelected)
    {
        CGPoint imagePoint = CGPointMake(
                (self.bounds.size.width - self.image.size.width) / 2.0f,
                (self.bounds.size.height - self.image.size.height) / 2.0f
        );

        [self.image drawAtPoint:imagePoint];
    }
}

@end