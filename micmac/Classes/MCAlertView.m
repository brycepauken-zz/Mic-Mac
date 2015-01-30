//
//  MCAlertView.m
//  micmac
//
//  Created by Bryce Pauken on 1/27/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCAlertView.h"

#import "MCAlertViewButton.h"
#import "MCMainView.h"

@interface MCAlertView()

@property (nonatomic, strong) UIView *alertContainer;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic) MCAlertViewButtonType buttonType;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, copy) void (^onButtonTapped)(int index);
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *windowOverlay;

@end


@implementation MCAlertView

- (instancetype)initWithAlertWithTitle:(NSString *)title message:(NSString *)message buttonType:(MCAlertViewButtonType)buttonType {
    self = [super init];
    if(self) {
        [self setButtonType:buttonType];
        [self.titleLabel=[[UILabel alloc] init] setText:title];
        [self.messageLabel=[[UILabel alloc] init] setText:message];
        [self setup];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)button {
    if(self.onButtonTapped) {
        self.onButtonTapped((int)button.tag);
    }
}

- (void)dismiss {
    [self setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:0];
        [self.alertContainer setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [self.alertContainer setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
}

- (void)setup {
    [self setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self setFrame:[[MCCommon mainView] bounds]];
    
    self.windowOverlay = [[UIView alloc] initWithFrame:self.bounds];
    [self.windowOverlay setAlpha:0];
    [self.windowOverlay setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self.windowOverlay setBackgroundColor:[UIColor blackColor]];
    
    self.alertContainer = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.alertView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.alertView setBackgroundColor:[UIColor MCOffWhiteColor]];
    [self.alertView.layer setCornerRadius:5];
    [self.alertView.layer setMasksToBounds:YES];
    [self.alertContainer addSubview:self.alertView];
    
    for(int i=0;i<2;i++) {
        UILabel *label = (i==0?self.titleLabel:self.messageLabel);
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:(i==0?24:16)]];
        [label setNumberOfLines:0];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor MCOffBlackColor]];
        [self.alertView addSubview:label];
    }
    
    static int alertPadding = 24;
    static int alertWidth = 216;
    static int buttonHeight = 40;
    
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToWidth:alertWidth-alertPadding*2];
    CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font constrainedToWidth:alertWidth-alertPadding*2];
    
    [self.alertView setFrame:CGRectMake(0, 0, alertWidth, titleSize.height+messageSize.height+alertPadding*3)];
    [self.titleLabel setFrame:CGRectMake(alertPadding, alertPadding, alertWidth-alertPadding*2, titleSize.height)];
    [self.messageLabel setFrame:CGRectMake(alertPadding, titleSize.height+alertPadding*2, alertWidth-alertPadding*2, messageSize.height)];
    
    if(self.buttonType == MCAlertViewButtonTypeNone) {
        [self.alertContainer setFrame:CGRectMake(0, 0, alertWidth, self.alertView.frame.size.height)];
    }
    else {
        [self setButtonContainer:[[UIView alloc] initWithFrame:CGRectMake(0, self.alertView.frame.size.height+alertPadding, alertWidth, buttonHeight)]];
        [self setupButtonsWithAlertWidth:alertWidth Padding:alertPadding];
        [self.alertContainer setFrame:CGRectMake(0, 0, alertWidth, self.alertView.frame.size.height+alertPadding+self.buttonContainer.frame.size.height)];
        [self.alertContainer addSubview:self.buttonContainer];
    }
    
    [self addSubview:self.windowOverlay];
    [self addSubview:self.alertContainer];
    
    [[MCCommon mainView] addSubview:self];
}

- (void)setupButtonsWithAlertWidth:(int)width Padding:(int)padding {
    self.buttons = [[NSMutableArray alloc] init];
    
    switch(self.buttonType) {
        case MCAlertViewButtonTypeYesNo: {
            CGFloat buttonWidth = (width-padding*1)/2.0f;
            for(int i=0;i<2;i++) {
                MCAlertViewButton *button = [[MCAlertViewButton alloc] initWithFrame:CGRectMake((buttonWidth+padding)*i, 0, buttonWidth, self.buttonContainer.bounds.size.height)];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [button setBackgroundColor:[UIColor MCOffWhiteColor]];
                [button setImage:[UIImage imageNamed:(i==0?@"ButtonNo":@"ButtonYes")]];
                [button setTag:i];
                [button setTitle:(i==0?@"NO":@"YES")];
                [self.buttonContainer addSubview:button];
            }
            break;
        }
        default:
            break;
    }
}

- (void)show {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:scale1],[NSValue valueWithCATransform3D:scale2],[NSValue valueWithCATransform3D:scale3],[NSValue valueWithCATransform3D:scale4], nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:1.0], nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.duration = 0.3;
    
    [self.alertContainer.layer addAnimation:animation forKey:@"popup"];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.windowOverlay setAlpha:0.5];
    }];
}

@end
