//
//  MCComposeView.m
//  micmac
//
//  Created by Bryce Pauken on 2/22/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCComposeView.h"

#import "MCPointingView.h"

@interface MCComposeView()

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) UITextField *groupSelectionField;
@property (nonatomic, strong) UIView *groupSelectionView;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) MCPointingView *pointingView;
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
static const int kGroupSelectionHFontSize = 14;
static const int kGroupSelectionHeight = 40;

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
        [self.textView setFrame:CGRectMake(0, -kContentDefaultHeight-kGroupSelectionHeight, self.bounds.size.width, kContentDefaultHeight)];
        [self.groupSelectionView setFrame:CGRectMake(0, -kGroupSelectionHeight, self.bounds.size.width, kGroupSelectionHeight)];
    }];
}

- (void)groupSelectionFieldDidChange {
    NSString *lowercaseSearchText = [self.groupSelectionField.text lowercaseString];
    CGFloat searchTextWidth = [self.groupSelectionField.text sizeWithFont:self.groupSelectionField.font constrainedToWidth:MAXFLOAT].width;
    
    CGFloat textOffset = 0;
    int i;
    for(i=0;i<self.groups.count;i++) {
        if([[[[self.groups objectAtIndex:i] objectForKey:@"name"] lowercaseString] hasPrefix:lowercaseSearchText]) {
            break;
        }
    }
    
    if(self.pointingView) {
        [self.pointingView dismiss];
    }
    
    if(i<self.groups.count) {
        self.pointingView = [[MCPointingView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        [self.pointingView setPoint:CGPointMake(self.groupSelectionField.frame.origin.x+textOffset+searchTextWidth/2, self.groupSelectionField.frame.origin.y+self.groupSelectionField.bounds.size.height)];
        [self.pointingView setTitle:[[self.groups objectAtIndex:i] objectForKey:@"name"]];
        [self.pointingView showInView:self.groupSelectionView];
    }
}

- (void)setGroups:(NSArray *)groups {
    _groups = groups;
    
    if(groups) {
        self.groupSelectionView = [[UIView alloc] initWithFrame:CGRectMake(0, -kGroupSelectionHeight, self.bounds.size.width, kGroupSelectionHeight)];
        [self.groupSelectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.groupSelectionView setBackgroundColor:[UIColor MCOffWhiteColor]];
        
        self.groupSelectionField = [[UITextField alloc] initWithFrame:CGRectInset(self.groupSelectionView.bounds, 16, 5)];
        [self.groupSelectionField addTarget:self action:@selector(groupSelectionFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.groupSelectionField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.groupSelectionField setDelegate:self];
        [self.groupSelectionField setFont:[UIFont systemFontOfSize:kGroupSelectionHFontSize]];
        [self.groupSelectionField setPlaceholder:@"Enter Bubbles to Post In"];
        [self.groupSelectionView addSubview:self.groupSelectionField];
        
        UIView *groupSelectionViewDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupSelectionView.bounds.size.width, 1)];
        [groupSelectionViewDivider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [groupSelectionViewDivider setBackgroundColor:[UIColor MCLightGrayColor]];
        [self.groupSelectionView addSubview:groupSelectionViewDivider];
        
        [self addSubview:self.groupSelectionView];
    }
    else if(self.groupSelectionView && self.groupSelectionView.superview) {
        [self.groupSelectionView removeFromSuperview];
        self.groupSelectionView = nil;
    }
}

- (void)setupInView:(UIView *)view {
    [self setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self setFrame:view.bounds];
    
    self.windowOverlay = [[UIView alloc] initWithFrame:self.bounds];
    [self.windowOverlay setAlpha:0];
    [self.windowOverlay setAutoresizingMask:UIViewAutoResizingFlexibleSize];
    [self.windowOverlay setBackgroundColor:[UIColor blackColor]];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, -kContentDefaultHeight-kGroupSelectionHeight, self.bounds.size.width, kContentDefaultHeight)];
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
    [self.remainingCharacters setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
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
        [self.groupSelectionView setFrame:CGRectMake(0, kContentDefaultHeight, self.bounds.size.width, kGroupSelectionHeight)];
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
