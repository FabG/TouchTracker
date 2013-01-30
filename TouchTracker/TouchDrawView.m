//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by Fabrice Guillaume on 1/29/13.
//  Copyright (c) 2013 Fabrice Guillaume. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"

// Class to track all the lines that have been drawn
// and any that are currently being drawn
@implementation TouchDrawView

@ synthesize selectedLine;

- (id)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];
    if (self) {
        linesInProcess = [[NSMutableDictionary alloc]init];
        completeLines = [[NSMutableArray alloc]init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // Enable Multi Touch events
        [self setMultipleTouchEnabled:YES];
        
        // Create an instance of UITaapGestureRecognizer and attach it to the TouchDrawView
        UITapGestureRecognizer * tapRecognizer =
                        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                   action:@selector(tap:)];
        
        [self addGestureRecognizer:tapRecognizer];
        // Now the UITapGestureRecognizer will send the message "tap:" when a tap occurs
        // Need to implement the tap: method...
    
    }
    
    return self;
}


// Implement tap: method
- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"UIGestureRecognizer tap");
    
    // Get tap point and make the returned line the SelectedLine
    CGPoint point = [gr locationInView:self];
    [self setSelectedLine:[self lineAtPoint:point]];
    
    // If we just tapped, remove all lines in process
    // so that a tap does not result in a new line
    [linesInProcess removeAllObjects];
    
    [self setNeedsDisplay];
    
}

// override drawRect: method to create lines using functions from Core Graphics
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // Draw complete lines in black
    [[UIColor blackColor] set];
    for (Line *line in completeLines) {
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    // Draw lines in process in red
    [[UIColor redColor] set];
    for (NSValue *v in linesInProcess) {
        Line *line = [linesInProcess objectForKey:v];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    // If there is a selected line, draw it
    if ([self selectedLine]) {
        [[UIColor greenColor]set];
        CGContextMoveToPoint(context, [[self selectedLine] begin].x  , [[self selectedLine]begin].y);
        CGContextAddLineToPoint(context, [[self selectedLine] end].x, [[self selectedLine] end].y);
        CGContextStrokePath(context);
    }
}

// Method to clear the collections and redraw the view
- (void)clearAll
{
    // Clear the collections
    [linesInProcess removeAllObjects];
    [completeLines removeAllObjects];
    
    // Redraw
    [self setNeedsDisplay];
}

// override touchesBegan:withEvent: to create a new Line instnce
// and store it in an NSMutableDictrionary
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     NSLog(@"touchesBegan");
    for (UITouch *t in touches)
    {
       // Is this a double tap? if Yes, clear screen
        if ([t tapCount] > 1) {
            NSLog(@"Double tap - clear screen");
            [self clearAll];
            return;
        }
        
        // Use the touch object (pached in an NSValue) as the key
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        // Create a line for the value
        CGPoint loc = [t locationInView:self];
        Line *newLine = [[Line alloc]init];
        [newLine setBegin:loc];
        [newLine setEnd:loc];
        
        // Put pair in dictionary
        [linesInProcess setObject:newLine forKey:key];
    }
}

// override touchesMoved:withEvent: to update the end point of the line
// associated with the moving touch
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved");
    for (UITouch *t in touches)
    {
        // Use the touch object (pached in an NSValue) as the key
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        // Find the line for this touch
        Line *line = [linesInProcess objectForKey:key];
        
        // Update the line
        CGPoint loc = [t locationInView:self];
        [line setEnd:loc];
    }
    // Redraw
    [self setNeedsDisplay];
}

// a touch can end for 2 reasons: user lifts the finger off the screen (touchesEnded:withEvent:)
// or the operation systemps interrupts our application (touchesCancelled:withEvent:)
- (void)endTouches:(NSSet *)touches
{
    // Remove ending touches from dictionary
    for (UITouch *t in touches)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        // if this is a double tap, 'line' will be nil,
        // so make sure not to add it to the array
        if (line)
        {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
        }
    }
    // Redraw
    [self setNeedsDisplay];
}

// override the 2 methods from UIResponder to call endTouches:
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

// implement method to find line close to a point
- (Line *)lineAtPoint:(CGPoint)p
{
    // Find a line clsoe to p
    for (Line *l in completeLines) {
        CGPoint start = [l begin];
        CGPoint end = [l end];
        
        // Check a few points in the line
        for (float t = 0.0; t <= 1.0; t+=0.05)
        {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            // If the tapped point is within 20 points, let's return this line
            if (hypot(x - p.x, y - p.y) < 20.0) {
                return l;
            }
        }
        
    }
    // If nothing is close enough to a line, then we didn't select any line
    return nil;
}

@end
