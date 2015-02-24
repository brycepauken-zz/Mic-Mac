//
//  MCTabView.m
//  micmac
//
//  Created by Bryce Pauken on 1/31/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCTabView.h"

#import <CoreText/CoreText.h>

@interface MCTabView()

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, copy) void (^buttonTapped)(int index);
@property (nonatomic) CGFloat currentHighlightOffset;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) CFTimeInterval displayLinkTimestamp;
@property (nonatomic) CGFloat goalHighlightOffset;
@property (nonatomic) CGFloat lastGoalHighlightOffset;
@property (nonatomic) CGFloat lastKnownWidth;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) CAShapeLayer *overlayMask;
@property (nonatomic) CGPathRef staticPath;

@end

@implementation MCTabView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _background = [[UIView alloc] initWithFrame:self.bounds];
        [_background setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
        [backgroundGradientLayer setColors:@[(id)[[UIColor MCOffWhiteColor] colorWithAlphaComponent:0].CGColor, (id)[UIColor MCOffWhiteColor].CGColor]];
        [backgroundGradientLayer setEndPoint:CGPointMake(0.5, (self.bounds.size.height-50)/self.bounds.size.height)];
        [backgroundGradientLayer setFrame:_background.bounds];
        [backgroundGradientLayer setStartPoint:CGPointMake(0.5, (self.bounds.size.height-54)/self.bounds.size.height)];
        [_background.layer insertSublayer:backgroundGradientLayer atIndex:0];
        
        _currentHighlightOffset = 0.25;
        _goalHighlightOffset = 0.25;
        _lastGoalHighlightOffset = 0.25;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCalled)];
        [_displayLink setFrameInterval:1];
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        _overlayMask = [[CAShapeLayer alloc] init];
        [_overlayMask setFillColor:[[UIColor blackColor] CGColor]];
        [_overlayMask setFillRule:kCAFillRuleEvenOdd];
        
        _overlay = [[UIView alloc] initWithFrame:self.bounds];
        [_overlay setAutoresizingMask:UIViewAutoResizingFlexibleSize];
        [_overlay setBackgroundColor:[UIColor MCMainColor]];
        [_overlay.layer setMask:_overlayMask];
        
        [self addSubview:_background];
        [self addSubview:_overlay];
        
        _buttons = @[[UIButton new], [UIButton new], [UIButton new], [UIButton new]];
        for(int i=0;i<4;i++) {
            UIButton *button = [_buttons objectAtIndex:i];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
            [button setTag:i];
            [self addSubview:button];
        }
        
        [self setNeedsLayout];
        [self updateStaticMask];
        [self updateMask];
    }
    return self;
}

+ (void)appendText:(NSString *)text toPath:(CGMutablePathRef)path atOffset:(CGPoint)offset {
    static NSDictionary *stringAttributes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CTFontRef fontRef = CTFontCreateWithName(CFSTR("Avenir-Medium"), 12, NULL);
        stringAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef, kCTFontAttributeName, nil];
        CFRelease(fontRef);
    });
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:stringAttributes];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    for(CFIndex i=0; i<CFArrayGetCount(runArray); i++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, i);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        for(CFIndex j=0; j<CTRunGetGlyphCount(run); j++) {
            CFRange thisGlyphRange = CFRangeMake(j, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            CGAffineTransform t = CGAffineTransformMakeTranslation(position.x+offset.x, position.y+offset.y);
            t = CGAffineTransformScale(t, 1, -1);
            CGPathAddPath(path, &t, letter);
            CGPathRelease(letter);
        }
    }
    CFRelease(line);
}

+ (void)appendMacroIconToPath:(CGMutablePathRef)path forSize:(CGFloat)size withOffset:(CGPoint)offset {
    CGFloat radius = size*0.45;
    
    UIBezierPath *iconPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(size/2-radius, size/2-radius, radius*2, radius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(offset.x, offset.y);
    CGPathAddPath(path, &translation, iconPath.CGPath);
}

+ (void)appendMeIconToPath:(CGMutablePathRef)path forSize:(CGFloat)size withOffset:(CGPoint)offset {
    UIBezierPath *iconPath = [UIBezierPath bezierPath];
    
    CGFloat headRadius = size*0.225;
    [iconPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(size/2-headRadius, 0, headRadius*2, headRadius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(headRadius, headRadius)]];
    
    CGFloat bodyOffset = headRadius*2 + size*0.1;
    CGFloat bodyWidth = size*0.6;
    [iconPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(size/2-bodyWidth/2, bodyOffset, bodyWidth, size-bodyOffset) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(size*4, size*4)]];
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(offset.x, offset.y);
    CGPathAddPath(path, &translation, iconPath.CGPath);
}

+ (void)appendMicroIconToPath:(CGMutablePathRef)path forSize:(CGFloat)size withOffset:(CGPoint)offset {
    UIBezierPath *iconPath = [UIBezierPath bezierPath];
    CGFloat radius = size*0.242;
    
    [iconPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(size*0.345-radius, size*0.757-radius, radius*2, radius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)]];
    [iconPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(size*0.250-radius, size*0.242-radius, radius*2, radius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)]];
    [iconPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(size*0.751-radius, size*0.416-radius, radius*2, radius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)]];
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(offset.x, offset.y);
    CGPathAddPath(path, &translation, iconPath.CGPath);
}

+ (void)appendMoreIconToPath:(CGMutablePathRef)path forSize:(CGFloat)size withOffset:(CGPoint)offset {
    UIBezierPath *iconPath = [UIBezierPath bezierPath];
    CGFloat radius = size*0.13;
    CGFloat padding = (size-(radius*6))/4.0;
    
    for(int i=0;i<3;i++) {
        [iconPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(padding+(padding+radius*2)*i, (size-radius)/2, radius*2, radius*2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)]];
    }
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(offset.x, offset.y);
    CGPathAddPath(path, &translation, iconPath.CGPath);
}

- (void)buttonTapped:(UIButton *)button {
    if(self.buttonTapped) {
        self.buttonTapped((int)button.tag);
    }
    
    self.goalHighlightOffset = 0.25*button.tag;
}

- (void)displayLinkCalled {
    if(!self.displayLinkTimestamp) {
        self.displayLinkTimestamp = self.displayLink.timestamp;
    }
    CFTimeInterval progress = MAX(0,MIN(1,(self.displayLink.timestamp-self.displayLinkTimestamp)/0.25))*2;
    
    if(progress==2) {
        [self.displayLink setPaused:YES];
    }
    
    if(progress<1) {
        self.currentHighlightOffset = self.lastGoalHighlightOffset+(self.goalHighlightOffset-self.lastGoalHighlightOffset)/2*progress*progress*progress;
    }
    else {
        progress-=2;
        self.currentHighlightOffset = self.lastGoalHighlightOffset+(self.goalHighlightOffset-self.lastGoalHighlightOffset)/2*(progress*progress*progress+2);
    }
    
    [self updateMask];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for(UIButton *button in self.buttons) {
        [button setFrame:CGRectMake(self.bounds.size.width*button.tag*0.25, self.bounds.size.height-50, self.bounds.size.width*0.25, 50)];
    }
    
    if(self.bounds.size.width != self.lastKnownWidth) {
        self.lastKnownWidth = self.bounds.size.width;
        
        [self updateStaticMask];
        [self updateMask];
    }
}

- (void)setGoalHighlightOffset:(CGFloat)goalHighlightOffset {
    if(_goalHighlightOffset != goalHighlightOffset) {
        _lastGoalHighlightOffset = _goalHighlightOffset;
        _goalHighlightOffset = goalHighlightOffset;
        self.displayLinkTimestamp = 0;
        
        [self.displayLink setPaused:NO];
    }
}

- (void)updateStaticMask {
    static CGFloat iconSize = 24;
    
    CGMutablePathRef mutableStaticPath = CGPathCreateMutable();
    
    CGPathAddPath(mutableStaticPath, NULL, CGPathCreateWithRect(self.bounds, NULL));
    
    NSArray *names = @[@"Macro", @"Micro", @"Me", @"More"];
    for(int i=0;i<4;i++) {
        CGFloat horizontalCenterOffset = self.bounds.size.width*(1.0/8 + (1.0/4)*i);
        
        NSString *name = [names objectAtIndex:i];
        CGSize nameSize = [name sizeWithFont:[UIFont fontWithName:@"Avenir-Medium" size:12] constrainedToWidth:MAX(0,self.bounds.size.width/4-4)];
        [[self class] appendText:name toPath:mutableStaticPath atOffset:CGPointMake(horizontalCenterOffset-nameSize.width/2, self.bounds.size.height-nameSize.height/3)];
        
        CGPoint iconOffset = CGPointMake(horizontalCenterOffset-iconSize/2, self.bounds.size.height-32-iconSize/2);
        
        SEL iconSelector = NSSelectorFromString([NSString stringWithFormat:@"append%@IconToPath:forSize:withOffset:",name]);
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[[self class] methodSignatureForSelector:iconSelector]];
        [inv setSelector:iconSelector];
        [inv setTarget:[self class]];
        [inv setArgument:&(mutableStaticPath) atIndex:2];
        [inv setArgument:&(iconSize) atIndex:3];
        [inv setArgument:&(iconOffset) atIndex:4];
        [inv invoke];
    }
    
    self.staticPath = CGPathCreateCopy(mutableStaticPath);
}

- (void)updateMask {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, NULL, self.staticPath);
    
    UIBezierPath *highlightPath = [UIBezierPath bezierPath];
    [highlightPath moveToPoint:CGPointMake(self.bounds.size.width*(self.currentHighlightOffset+0.25), self.bounds.size.height)];
    [highlightPath addLineToPoint:CGPointMake(self.bounds.size.width*(self.currentHighlightOffset+0.25), self.bounds.size.height-50)];
    [highlightPath addCurveToPoint:CGPointMake(self.bounds.size.width, 0) controlPoint1:CGPointMake(self.bounds.size.width*(self.currentHighlightOffset+0.25), (self.bounds.size.height-50)*0.2) controlPoint2:CGPointMake(self.bounds.size.width, (self.bounds.size.height-50)*0.8)];
    [highlightPath addLineToPoint:CGPointMake(0, 0)];
    [highlightPath addCurveToPoint:CGPointMake(self.bounds.size.width*self.currentHighlightOffset, self.bounds.size.height-50) controlPoint1:CGPointMake(0, (self.bounds.size.height-50)*0.8) controlPoint2:CGPointMake(self.bounds.size.width*self.currentHighlightOffset, (self.bounds.size.height-50)*0.2)];
    [highlightPath addLineToPoint:CGPointMake(self.bounds.size.width*self.currentHighlightOffset, self.bounds.size.height)];
    [highlightPath closePath];
    
    CGPathAddPath(path, NULL, highlightPath.CGPath);
    [self.overlayMask setPath:path];
    CGPathRelease(path);
}

@end
