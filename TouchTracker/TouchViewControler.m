//
//  TouchViewControler.m
//  TouchTracker
//
//  Created by Fabrice Guillaume on 1/29/13.
//  Copyright (c) 2013 Fabrice Guillaume. All rights reserved.
//

#import "TouchViewControler.h"
#import "TouchDrawView.h"

@implementation TouchViewControler

// overrride loadView method to set up an instance of TouchDrawView
// as TouchViewController's view
- (void) loadView
{
    [self setView:[[TouchDrawView alloc] initWithFrame:CGRectZero]];
}
@end
