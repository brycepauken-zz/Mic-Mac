//
//  MCGroupSelectionView.m
//  micmac
//
//  Created by Bryce Pauken on 2/24/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCGroupSelectionView.h"

#import "MCGroupButton.h"

@interface MCGroupSelectionView()

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic) NSInteger nextButtonIndex;
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) NSMutableArray *selectedButtons;
@property (nonatomic, copy) void (^selectionChanged)();

@end

@implementation MCGroupSelectionView

CGFloat *_rowEndingOffsets;
static const int kButtonMargins = 16;
static const int kExtraButtonDistance = 50;
static const int kHorizontalMargins = 0;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _rowEndingOffsets = malloc(sizeof(CGFloat));
        _selectedButtons = [[NSMutableArray alloc] init];
        
        [self setDelegate:self];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)button {
    @synchronized(self) {
        NSUInteger selectionIndex = [self.selectedButtons indexOfObject:@(button.tag)];
        if(selectionIndex==NSNotFound) {
            [button setSelected:YES];
            [self.selectedButtons addObject:@(button.tag)];
        }
        else {
            [button setSelected:NO];
            [self.selectedButtons removeObjectAtIndex:selectionIndex];
        }
        if(self.selectionChanged) {
            self.selectionChanged();
        }
    }
}

- (void)reloadButtons {
    @synchronized(self) {
        [self setContentSize:CGSizeMake(self.bounds.size.width*self.groups.count, self.bounds.size.height)];
        
        int numberOfRows = (kButtonMargins+self.bounds.size.height)/([MCGroupButton buttonHeight]+kButtonMargins);
        self.nextButtonIndex = 0;
        free(_rowEndingOffsets);
        _rowEndingOffsets = calloc(numberOfRows, sizeof(CGFloat));
        
        if(self.rows && self.rows.count) {
            for(NSArray *row in self.rows) {
                for(MCGroupButton *button in row) {
                    [button removeFromSuperview];
                }
            }
        }
        self.rows = [[NSMutableArray alloc] init];
        for(int i=0;i<numberOfRows;i++) {
            [self.rows addObject:[[NSMutableArray alloc] init]];
            _rowEndingOffsets[i] = kHorizontalMargins;
        }
    }
    [self updateButtons];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateButtons];
}

- (NSArray *)selectedIndexes {
    return self.selectedButtons;
}

- (void)setFrame:(CGRect)frame {
    CGSize lastSize = self.bounds.size;
    [super setFrame:frame];
    if(self.groups && !CGSizeEqualToSize(lastSize, self.bounds.size)) {
        [self reloadButtons];
    }
}

- (void)setGroups:(NSArray *)groups {
    if(groups && ![groups isEqual:[NSNull null]] && groups.count) {
        _groups = groups;
        [self reloadButtons];
    }
}

- (void)updateButtons {
    if(self.rows.count) {
        @synchronized(self) {
            CGFloat buttonHeight = [MCGroupButton buttonHeight];
            CGFloat totalButtonHeight = (self.rows.count*buttonHeight)+((self.rows.count-1)*kButtonMargins);
            CGFloat verticalOffset = (self.bounds.size.height-totalButtonHeight)/2;
            
            //add cells after visible cells
            while(true) {
                CGFloat minEndingOffset = _rowEndingOffsets[0];
                int rowIndex = 0;
                for(int i=1;i<self.rows.count;i++) {
                    if(_rowEndingOffsets[i]<minEndingOffset) {
                        minEndingOffset = _rowEndingOffsets[i];
                        rowIndex = i;
                    }
                }
                
                //if next button exists
                if(self.nextButtonIndex < self.groups.count) {
                    CGFloat horizontalOffset = _rowEndingOffsets[rowIndex]+kButtonMargins;
                    
                    //if button will be visible
                    if(horizontalOffset<=self.contentOffset.x+self.bounds.size.width+kExtraButtonDistance) {
                        MCGroupButton *button = [[MCGroupButton alloc] init];
                        [button setTag:self.nextButtonIndex];
                        [button setTitleAndReframe:[[self.groups objectAtIndex:self.nextButtonIndex++] objectForKey:@"name"]];
                        _rowEndingOffsets[rowIndex] = horizontalOffset+button.frame.size.width;
                        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                        [button setFrame:CGRectMake(horizontalOffset, verticalOffset+(buttonHeight+kButtonMargins)*rowIndex, button.frame.size.width, button.frame.size.height)];
                        if([self.selectedButtons indexOfObject:@(button.tag)]!=NSNotFound) {
                            [button setSelected:YES];
                        }
                        [self addSubview:button];
                        [[self.rows objectAtIndex:rowIndex] addObject:button];
                        continue;
                    }
                }
                else {
                    CGFloat maxEndingOffset = _rowEndingOffsets[0];
                    int rowWithFurthestButtonIndex = 0;
                    for(int i=1;i<self.rows.count;i++) {
                        if(_rowEndingOffsets[i]>maxEndingOffset) {
                            maxEndingOffset = _rowEndingOffsets[i];
                            rowWithFurthestButtonIndex = i;
                        }
                    }
                    [self setContentSize:CGSizeMake(_rowEndingOffsets[rowWithFurthestButtonIndex]+kHorizontalMargins, self.bounds.size.height)];
                }
                break;
            }
            
            //remove cells over border
            for(int i=0;i<self.rows.count;i++) {
                NSMutableArray *row = [self.rows objectAtIndex:i];
                //remove cells on right
                while(_rowEndingOffsets[i]-[[row lastObject] frame].size.width>self.contentOffset.x+self.bounds.size.width+kExtraButtonDistance*1.5) {
                    [[row lastObject] removeFromSuperview];
                    [row removeLastObject];
                    CGRect lastObjectFrame = [[row lastObject] frame];
                    _rowEndingOffsets[i] = (row.count?lastObjectFrame.origin.x+lastObjectFrame.size.width:kHorizontalMargins);
                    self.nextButtonIndex--;
                }
            }
        }
    }
}

@end
