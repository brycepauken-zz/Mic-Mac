//
//  MCComposeView.m
//  micmac
//
//  Created by Bryce Pauken on 2/22/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCComposeView.h"

@interface MCComposeView()

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UILabel *remainingCharacters;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *windowOverlay;

@end

@implementation MCComposeView

static const int kContentDefaultHeight = 140;
static const int kContentFontSize = 18;
static const int kContentHorizontalMargin = 10;
static const int kContentMaxChars = 180;
static const int kContentVerticalMargin = 14;

- (instancetype)initInView:(UIView *)view withPlaceholder:(NSString *)placeholder {
    self = [super init];
    if(self) {
        _placeholder = placeholder;
        
        [self setupInView:view];
    }
    return self;
}

- (void)dismiss {
    [self setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
        [self.windowOverlay setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.textView setFrame:CGRectMake(0, -kContentDefaultHeight, self.bounds.size.width, kContentDefaultHeight)];
    }];
}

- (void)setupInView:(UIView *)view {
    [self setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self setFrame:view.bounds];
    
    self.windowOverlay = [[UIView alloc] initWithFrame:self.bounds];
    [self.windowOverlay setAlpha:0];
    [self.windowOverlay setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self.windowOverlay setBackgroundColor:[UIColor blackColor]];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, -kContentDefaultHeight, self.bounds.size.width, kContentDefaultHeight)];
    [self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.textView setBackgroundColor:[UIColor MCOffWhiteColor]];
    [self.textView setDelegate:self];
    [self.textView setFont:[UIFont systemFontOfSize:kContentFontSize]];
    [self.textView setReturnKeyType:UIReturnKeyGo];
    [self.textView setTag:1];
    [self.textView setText:self.placeholder];
    [self.textView setTextColor:[UIColor lightGrayColor]];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(kContentVerticalMargin, kContentHorizontalMargin, kContentVerticalMargin, kContentHorizontalMargin)];
    
    self.remainingCharacters = [[UILabel alloc] init];
    [self.remainingCharacters setFont:[UIFont systemFontOfSize:kContentFontSize]];
    [self.remainingCharacters setTextColor:[UIColor lightGrayColor]];
    [self.textView addSubview:self.remainingCharacters];
    [self setRemainingCharacterCount:kContentMaxChars];
    
    [self addSubview:self.windowOverlay];
    [self addSubview:self.textView];
    
    [view addSubview:self];
}

- (void)setRemainingCharacterCount:(NSInteger)remainingCount {
    [self.remainingCharacters setText:[NSString stringWithFormat:@"%li",remainingCount]];
    [self.remainingCharacters sizeToFit];
    [self.remainingCharacters setCenter:CGPointMake(self.textView.frame.size.width-self.remainingCharacters.frame.size.width/2-kContentHorizontalMargin, self.textView.bounds.size.height-self.remainingCharacters.frame.size.height/2-kContentHorizontalMargin)];
}

- (void)show {
    [UIView animateWithDuration:0.2 animations:^{
        [self.windowOverlay setAlpha:0.5];
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.textView setFrame:CGRectMake(0, 0, self.bounds.size.width, kContentDefaultHeight)];
    }];
}

- (NSString *)text {
    return (self.textView.tag==1?@"":self.textView.text);
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(self.textView.tag==1) {
        [self.textView setTag:0];
        [self.textView setText:@""];
        [self.textView setTextColor:[UIColor MCOffBlackColor]];
    }
    [self.textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(![self.textView.text length]) {
        [self.textView setTag:1];
        [self.textView setText:self.placeholder];
        [self.textView setTextColor:[UIColor lightGrayColor]];
    }
    [self.textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self setRemainingCharacterCount:kContentMaxChars-textView.text.length+range.length-text.length];
    return YES;
}

@end
