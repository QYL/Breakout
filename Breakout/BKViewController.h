//
//  BKViewController.h
//  Breakout
//
//  Created by QYL on 4/1/14.
//  Copyright (c) 2014 QYL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BKViewController : UIViewController

#pragma IBOutlets and properties
@property (strong, nonatomic) IBOutlet UIImageView *ballImageView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) IBOutlet UIImageView *paddleIamgeView;
@property (strong, nonatomic) IBOutlet UILabel *gameStateLabel;
@property (strong, nonatomic) IBOutlet UIButton *playAgainButtonView;
//砖块图像数组
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *brickImageViews;
@property (nonatomic, retain) AVAudioPlayer *player;

#pragma IBActions
- (IBAction)tapScreen:(UITapGestureRecognizer *)sender;
- (IBAction)dragPaddle:(UIPanGestureRecognizer *)sender;
- (IBAction)playAgainButtonPressed:(UIButton *)sender;


@end
