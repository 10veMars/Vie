//
// Created by Fabien Warniez on 14-11-25.
// Copyright (c) 2014 Fabien Warniez. All rights reserved.
//

#import "FWReflectiveButton.h"

@class FWTileButton;

@protocol FWTileButtonDelegate <NSObject>

- (void)tileButtonWasSelected:(FWTileButton *)tileButton;

@end

@interface FWTileButton : FWReflectiveButton

@property (nonatomic, weak) id<FWTileButtonDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithMainColor:(UIColor *)mainColor image:(UIImage *)image;
+ (instancetype)buttonWithMainColor:(UIColor *)mainColor image:(UIImage *)image;

@end