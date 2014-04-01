//
//  BKViewController.m
//  Breakout
//
//  Created by QYL on 4/1/14.
//  Copyright (c) 2014 QYL. All rights reserved.
//

#import "BKViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BKViewController ()
{
    //小球的初始位置
    CGPoint _initialBallCenterPosition;
    CGPoint _initialPaddleCenterPosition;
    //游戏时钟,iPhone屏幕每秒钟刷新60次，CADisplayLink每次刷新都会通知
    //BKViewController，这样小球的位置就可以每秒钟更新60次
    CADisplayLink *_gameTimer;
    //小球的速度
    CGPoint _ballVelocity;
    //挡板的水平速度
    CGFloat _paddleVelocityX;
}

@end

@implementation BKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //记录小球初始中心位置
    _initialBallCenterPosition = self.ballImageView.center;
    _initialPaddleCenterPosition = self.paddleIamgeView.center;
    [self.gameStateLabel setHidden:NO];
    self.gameStateLabel.text =@"Tap to Start.";
    [self.playAgainButtonView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//与屏幕碰撞检测方法
-(void)collisionWithScreen
{
    if (CGRectGetMinY(self.ballImageView.frame) <= 0)
    {
        _ballVelocity.y = abs(_ballVelocity.y);
        
    }
    //检测小球是否掉出屏幕下方,如果是显示游戏结束，关闭游戏时钟
    if (CGRectGetMinY(self.ballImageView.frame) >= self.view.bounds.size.height)
    {
        [self.gameStateLabel setHidden:NO];
        self.gameStateLabel.text =@"Game Over!";
        [self playSound:@"gameover" andSoundFormat:@"wav"];
        [self.playAgainButtonView setHidden:NO];
        [_gameTimer invalidate];
    }
    if (CGRectGetMinX(self.ballImageView.frame) <= 0)
    {
        _ballVelocity.x = ABS(_ballVelocity.x);
    }
    if (CGRectGetMaxX(self.ballImageView.frame) >= self.view.bounds.size.width)
    {
        _ballVelocity.x = -ABS(_ballVelocity.x);
    }
}
//与挡板的碰撞检测
-(void)collisionWithPaddle
{
    if (CGRectIntersectsRect(self.ballImageView.frame, self.paddleIamgeView.frame))
    {
        _ballVelocity.y = -ABS(_ballVelocity.y);
        _ballVelocity.x += _paddleVelocityX/130.0;
    }
}
//与砖块的碰撞检测
-(void)collisionWithBricks
{
    for (UIImageView *brick in self.brickImageViews)
    {
        
        if (CGRectIntersectsRect(brick.frame, self.ballImageView.frame) && ![brick isHidden])
        {
            //当小球与砖块碰撞时翻转小球Y方向的速度，并让相应砖块消失
            brick.hidden = YES;
            NSLog(@"碰到转款了,小球的速度：%@", NSStringFromCGPoint(_ballVelocity));
            _ballVelocity.y = abs(_ballVelocity.y);
            
//          NSLog(@"小球碰撞后的速度：%@", NSStringFromCGPoint(_ballVelocity));
            
            [self playSound:@"crash" andSoundFormat:@"mp3"];
        }
    }
    
    BOOL isWin = YES;
    for (UIImageView *brick in self.brickImageViews)
    {
        if(![brick isHidden])
        {
            isWin = NO;
            break;
        }
    }
    if (isWin) {
        [self.gameStateLabel setHidden:NO];
        self.gameStateLabel.text =@"You Win!";
        [self.playAgainButtonView setHidden:NO];
        [_gameTimer invalidate];
    }
}

//屏幕刷新执行此方法
-(void)step
{
    //更新小球位置
    [self collisionWithScreen];
    [self collisionWithBricks];
    [self collisionWithPaddle];

    [self.ballImageView setCenter:CGPointMake(self.ballImageView.center.x + _ballVelocity.x,
                                              self.ballImageView.center.y + _ballVelocity.y)];
    NSLog(@"Timing!");
    
    
    
}

- (IBAction)tapScreen:(UITapGestureRecognizer *)sender
{
    //禁用手势识别
    [self.tapGesture setEnabled:NO];
    [self.gameStateLabel setHidden:YES];
    
    //给小球设置初始速度,速度在二维世界里有水平方向的速度和垂直方向的速度，因此可以使用CGPoint
    //坐标原点在左上角，因此为了让小球向上运动，Y轴就会减少，这样Y得用负数,即每秒向上移动5个点。
    _ballVelocity = CGPointMake(0.0, -5.0);
    
    //************定义游戏时钟*****************
    
    //displaylink更新屏幕时要通知BKViewController，因此其它target就是BKViewController,
    //由于BKViewController就是本文件，因此用self即可。
    //selector就是当屏幕更新时，由哪个方法负责响应。
    _gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
    
    //把游戏时钟添加到主运行循环中
    [_gameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

//挡板移动时调用此方法
- (IBAction)dragPaddle:(UIPanGestureRecognizer *)sender
{
    //用户滑动手指时，改变挡板的位置
    if (UIGestureRecognizerStateChanged == sender.state)
    {
        //获得手指当前的位置
        CGPoint location = [sender locationInView:self.view];
        //将挡板当前的位置设为手指的位置
        [self.paddleIamgeView setCenter:CGPointMake(location.x,self.paddleIamgeView.center.y)];
    }
    //记录挡板的移动速度
    _paddleVelocityX = [sender velocityInView:self.view].x;
    
}

- (IBAction)playAgainButtonPressed:(UIButton *)sender
{
    [self.paddleIamgeView setCenter:CGPointMake(_initialPaddleCenterPosition.x,_initialPaddleCenterPosition.y)];
    [self.ballImageView setCenter:CGPointMake(_initialBallCenterPosition.x,_initialBallCenterPosition.y)];
    [self.tapGesture setEnabled:YES];
    [self.gameStateLabel setHidden:YES];
    [self.playAgainButtonView setHidden:YES];
    for (UIImageView *brick in self.brickImageViews)
    {
        [brick setHidden:NO];
    }

}

-(void)playSound:(NSString *)soundType andSoundFormat:(NSString *)format
{
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:soundType ofType:format];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    self.player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [self.player prepareToPlay];
    [self.player play];
}

@end
