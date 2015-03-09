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
@property (nonatomic, strong) UIScrollView *groupSelectionView;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) MCPointingView *pointingView;
@property (nonatomic, strong) UILabel *remainingCharacters;
@property (nonatomic, strong) NSMutableArray *selectedGroups;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *windowOverlay;

@end

@implementation MCComposeView

static const int kContentDefaultHeight = 160;
static const int kContentFontSize = 18;
static const int kContentHorizontalMargin = 10;
static const int kContentMaxChars = 180;
static const int kContentVerticalMargin = 14;
static const int kGroupSelectionDividingSpaces = 4;
static const int kGroupSelectionFontSize = 14;
static const int kGroupSelectionHeight = 50;
static const CGFloat kSelectedGroupLabelBorderThickness = 1.5;
static const int kSelectedGroupLabelCornerRadius = 4;
static const int kSelectedGroupLabelPadding = 4;

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
    //update parent scroll view width
    if(self.groupSelectionField.text.length) {
        CGFloat totalWidth = [self.groupSelectionField.text sizeWithFont:self.groupSelectionField.font constrainedToWidth:MAXFLOAT].width;
        [self.groupSelectionField setFrame:CGRectMake(self.groupSelectionField.frame.origin.x, self.groupSelectionField.frame.origin.y, totalWidth+self.groupSelectionField.frame.origin.x, self.groupSelectionField.frame.size.height)];
    }
    else {
        [self.groupSelectionField setFrame:CGRectMake(self.groupSelectionField.frame.origin.x, self.groupSelectionField.frame.origin.y, self.groupSelectionView.bounds.size.width-self.groupSelectionField.frame.origin.x*2, self.groupSelectionField.frame.size.height)];
    }
    [self.groupSelectionView setContentSize:CGSizeMake(MAX(self.groupSelectionField.frame.origin.x+self.groupSelectionField.frame.size.width, self.groupSelectionView.bounds.size.width), self.groupSelectionField.frame.size.height)];
    [self.groupSelectionView setContentOffset:CGPointMake(MAX(self.groupSelectionView.contentSize.width-self.groupSelectionView.bounds.size.width, 0), 0)];
    
    NSDictionary *lastGroup = (self.selectedGroups.count?[self.selectedGroups lastObject]:nil);
    NSInteger splitIndex = (lastGroup?[[lastGroup objectForKey:@"offset"] integerValue]+[[lastGroup objectForKey:@"name"] length]+kGroupSelectionDividingSpaces:0);
    
    NSString *previousText = [self.groupSelectionField.text substringToIndex:splitIndex];
    NSString *searchText = [self.groupSelectionField.text substringFromIndex:splitIndex];
    CGFloat previousTextWidth = [previousText sizeWithFont:self.groupSelectionField.font constrainedToWidth:MAXFLOAT].width;
    CGFloat searchTextWidth = [searchText sizeWithFont:self.groupSelectionField.font constrainedToWidth:MAXFLOAT].width;
    
    int i;
    for(i=0;i<self.groups.count;i++) {
        NSString *groupName = [[[self.groups objectAtIndex:i] objectForKey:@"name"] uppercaseString];
        if([groupName hasPrefix:searchText]) {
            BOOL groupAlreadySelected = NO;
            for(int j=0;j<self.selectedGroups.count;j++) {
                if([[[self.selectedGroups objectAtIndex:j] objectForKey:@"name"] isEqualToString:groupName]) {
                    groupAlreadySelected = YES;
                    break;
                }
            }
            if(!groupAlreadySelected) {
                break;
            }
        }
    }
    
    if(self.pointingView) {
        [self.pointingView dismiss];
    }
    
    if(i<self.groups.count) {
        __weak MCComposeView *weakSelf = self;
        
        self.pointingView = [[MCPointingView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        [self.pointingView setPoint:CGPointMake(self.groupSelectionField.frame.origin.x+previousTextWidth+searchTextWidth/2, self.groupSelectionField.frame.origin.y+self.groupSelectionField.bounds.size.height)];
        [self.pointingView setTappedBlock:^{
            NSString *existingText = [weakSelf.groupSelectionField.text substringToIndex:(lastGroup?[[lastGroup objectForKey:@"offset"] integerValue]+[[lastGroup objectForKey:@"name"] length]+kGroupSelectionDividingSpaces:0)];
            
            NSString *name = [[weakSelf.groups objectAtIndex:i] objectForKey:@"name"];
            NSString *uppercaseName = [name uppercaseString];
            [weakSelf.groupSelectionField setText:[NSString stringWithFormat:@"%@%@%@", existingText, uppercaseName, [@"" stringByPaddingToLength:kGroupSelectionDividingSpaces withString:@" " startingAtIndex:0]]];
            
            CGFloat nameWidth = [uppercaseName sizeWithFont:weakSelf.groupSelectionField.font constrainedToWidth:MAXFLOAT].width;
            UILabel *label = [[UILabel alloc] init];
            [label setFont:[UIFont fontWithName:@"Avenir-Medium" size:kGroupSelectionFontSize]];
            [label setText:uppercaseName];
            [label setTextColor:[UIColor MCMainColor]];
            [label sizeToFit];
            
            UIView *labelContainer = [[UIView alloc] initWithFrame:CGRectInset(label.bounds, -kSelectedGroupLabelPadding, -kSelectedGroupLabelPadding)];
            [labelContainer setBackgroundColor:[UIColor MCOffWhiteColor]];
            [labelContainer.layer setBorderColor:[UIColor MCMainColor].CGColor];
            [labelContainer.layer setBorderWidth:kSelectedGroupLabelBorderThickness];
            [labelContainer.layer setCornerRadius:kSelectedGroupLabelCornerRadius];
            [labelContainer.layer setMasksToBounds:YES];
            
            [labelContainer setCenter:CGPointMake(weakSelf.groupSelectionField.frame.origin.x+previousTextWidth+nameWidth/2, weakSelf.groupSelectionField.frame.origin.y+weakSelf.groupSelectionField.bounds.size.height/2)];
            [label setCenter:CGPointMake(labelContainer.bounds.size.width/2, labelContainer.bounds.size.height/2)];
            [labelContainer addSubview:label];
            [weakSelf.groupSelectionView addSubview:labelContainer];
            
            [weakSelf.selectedGroups addObject:@{@"name":name, @"id":[[weakSelf.groups objectAtIndex:i] objectForKey:@"id"], @"offset":@(existingText.length), @"labelContainer":labelContainer}];
            
            [weakSelf.pointingView dismiss];
            
            [weakSelf groupSelectionFieldDidChange];
        }];
        [self.pointingView setTitle:[[self.groups objectAtIndex:i] objectForKey:@"name"]];
        [self.pointingView showInView:self.groupSelectionView];
    }
}

- (void)groupSelectionFieldOverlayTapped {
    [self.groupSelectionField becomeFirstResponder];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.pointingView && CGRectContainsPoint([self.pointingView convertRect:CGRectInset(self.pointingView.bounds, -5, -5) toView:self], point)) {
        return self.pointingView;
    }
    return [super hitTest:point withEvent:event];
}

- (NSArray *)selectedGroupIDs {
    NSMutableArray *selectedGroupIDs = [[NSMutableArray alloc] initWithCapacity:self.selectedGroups.count];
    
    for(NSDictionary *selectedGroup in self.selectedGroups) {
        [selectedGroupIDs addObject:[selectedGroup objectForKey:@"id"]];
    }
    
    return selectedGroupIDs;
}

- (void)setGroups:(NSArray *)groups {
    _groups = groups;
    
    if(groups) {
        self.selectedGroups = [[NSMutableArray alloc] init];
        
        self.groupSelectionView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -kGroupSelectionHeight, self.bounds.size.width, kGroupSelectionHeight)];
        [self.groupSelectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.groupSelectionView setBackgroundColor:[UIColor MCOffWhiteColor]];
        [self.groupSelectionView setClipsToBounds:NO];
        [self.groupSelectionView setScrollEnabled:NO];
        [self.groupSelectionView setShowsHorizontalScrollIndicator:NO];
        [self.groupSelectionView setShowsVerticalScrollIndicator:NO];
        
        self.groupSelectionField = [[UITextField alloc] initWithFrame:CGRectInset(self.groupSelectionView.bounds, 16, 5)];
        [self.groupSelectionField addTarget:self action:@selector(groupSelectionFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.groupSelectionField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.groupSelectionField setClipsToBounds:NO];
        [self.groupSelectionField setDelegate:self];
        [self.groupSelectionField setFont:[UIFont fontWithName:@"Avenir-Medium" size:kGroupSelectionFontSize]];
        [self.groupSelectionField setPlaceholder:@"Enter Bubbles to Post In"];
        [self.groupSelectionField setTextColor:[UIColor grayColor]];
        [self.groupSelectionField setTintColor:[UIColor lightGrayColor]];
        [self.groupSelectionView addSubview:self.groupSelectionField];
        
        UIView *groupSelectionViewDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupSelectionView.bounds.size.width*10, 1)];
        [groupSelectionViewDivider setBackgroundColor:[UIColor MCLightGrayColor]];
        [self.groupSelectionView addSubview:groupSelectionViewDivider];
        
        UIView *groupSelectionFieldOverlay = [[UIView alloc] initWithFrame:self.groupSelectionField.frame];
        [groupSelectionFieldOverlay setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [groupSelectionFieldOverlay setUserInteractionEnabled:YES];
        [self.groupSelectionView addSubview:groupSelectionFieldOverlay];
        UITapGestureRecognizer *groupSelectionFieldOverlayRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groupSelectionFieldOverlayTapped)];
        [groupSelectionFieldOverlay addGestureRecognizer:groupSelectionFieldOverlayRecognizer];
        
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
    [self.textView setTintColor:[UIColor lightGrayColor]];
    
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
    [self.remainingCharacters setText:[NSString stringWithFormat:@"%li",(long)remainingCount]];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    while(true) {
        NSDictionary *lastGroup = (self.selectedGroups.count?[self.selectedGroups lastObject]:nil);
        NSInteger groupNameLength = [[lastGroup objectForKey:@"name"] length]+kGroupSelectionDividingSpaces;
        NSInteger groupNameOffset = [[lastGroup objectForKey:@"offset"] integerValue];
        if(!lastGroup || NSIntersectionRange(NSMakeRange(groupNameOffset, groupNameLength), range).length<=0) {
            break;
        }
        [textField setText:[textField.text stringByReplacingCharactersInRange:NSMakeRange(groupNameOffset, groupNameLength-1) withString:@""]];
        [[lastGroup objectForKey:@"labelContainer"] removeFromSuperview];
        [self.selectedGroups removeLastObject];
        range.length = MAX(0, range.length-[[lastGroup objectForKey:@"name"] length]+kGroupSelectionDividingSpaces);
    }
    
    if([string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location != NSNotFound) {
        [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]]];
        [self groupSelectionFieldDidChange];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSDictionary *lastGroup = (self.selectedGroups.count?[self.selectedGroups lastObject]:nil);
    NSInteger groupEndOffset = [[lastGroup objectForKey:@"offset"] integerValue]+[[lastGroup objectForKey:@"name"] length]+kGroupSelectionDividingSpaces;
    if(textField.text.length > groupEndOffset) {
        [textField setText:[textField.text substringToIndex:groupEndOffset]];
    }
    
    return YES;
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
