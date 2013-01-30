//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by Fabrice Guillaume on 1/29/13.
//  Copyright (c) 2013 Fabrice Guillaume. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Line;

@interface TouchDrawView : UIView <UIGestureRecognizerDelegate>
{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
    
    UIPanGestureRecognizer *moveRecognizer;
}
@property (nonatomic, weak) Line *selectedLine;

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

- (Line *)lineAtPoint:(CGPoint)p;

@end
