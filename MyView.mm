#import "MyView.h"

@implementation MyView
- (instancetype)initWithFrame:(NSRect)frameRect
{
//	sranddev();
	if ((self = [super initWithFrame:frameRect]) != nil) {
		points = [NSMutableArray array];
//		srand(0);
		for(NSUInteger i=0; i<50; ++i)
		{
			[points addObject:@{@"X": @(rand() / (CGFloat)RAND_MAX),
                                @"Y": @(rand() / (CGFloat)RAND_MAX)
                                }];
		}
	}
	return self;
}

// Nudge the labels slightly if they overlap
- (void)nudge_rectlist:(NSMutableArray<NSValue *> *)theRects areaRect:(NSRect)theArea
{
	NSUInteger	size = theRects.count;
	NSInteger	againCounter = 0;

again:
	for(NSUInteger i=0; i<size; ++i)
	{
		// move the label into the area, if necessary
		NSRect	r1 = [theRects[i] rectValue];
		BOOL	changed = NO;
		if(r1.origin.x < theArea.origin.x)
		{
			r1.origin.x = theArea.origin.x;
			changed = YES;
		}
		if(r1.origin.y < theArea.origin.y)
		{
			r1.origin.y = theArea.origin.y;
			changed = YES;
		}
		CGFloat	dx = (r1.origin.x + r1.size.width) - (theArea.origin.x + theArea.size.width);
		if(dx > 0.0)
		{
			r1.origin.x -= dx;
			changed = YES;
		}
		CGFloat	dy = (r1.origin.y + r1.size.height) - (theArea.origin.y + theArea.size.height);
		if(dy > 0.0)
		{
			r1.origin.y -= dy;
			changed = YES;
		}
		if(changed)
			theRects[i] = [NSValue valueWithRect:r1];

		for(NSUInteger j=0; j<i; ++j)
		{
			NSRect	r2 = [theRects[j] rectValue];

			NSRect	overlapRect = NSIntersectionRect(r1, r2);
			CGFloat	overlapArea = overlapRect.size.width * overlapRect.size.height;
			if(overlapArea == 0.0)			// no overlap => next one!
				continue;

			CGFloat	overlapInPercent = overlapArea / (r1.size.width * r1.size.height + r2.size.width * r2.size.height);
			if(overlapInPercent <= 1.00)	// compare with overlap in %?
			{
				CGFloat	xd1 = r1.origin.x + r1.size.width - r2.origin.x;	// right overlap
				CGFloat	xd2 = r2.origin.x + r2.size.width - r1.origin.x;	// left overlap
				if(xd1 > xd2)	// nudge left or right?
					xd1 = -xd2;

				CGFloat	yd1 = r1.origin.y + r1.size.height - r2.origin.y;	// bottom overlap
				CGFloat	yd2 = r2.origin.y + r2.size.height - r1.origin.y;	// top overlap
				if(yd1 > yd2)	// nudge up or down?
					yd1 = -yd2;
				if(xd1 * xd1 < yd1 * yd1)
					yd1 = 0;
				else
					xd1 = 0;

				// nudge both rectangles away from each other
				theRects[i] = [NSValue valueWithRect:NSOffsetRect(r1, -xd1 * 0.5, -yd1 * 0.5)];
				r1 = [theRects[i] rectValue];	// update the changed value
				theRects[j] = [NSValue valueWithRect:NSOffsetRect(r2,  xd1 * 0.5,  yd1 * 0.5)];
				if(++againCounter < 100)	// don't try forever!
					goto again;
			}
		}
	}
}

- (void)drawRect:(NSRect)rect
{
	//NSLog(@"drawRect:NSMakeRect(%f,%f %f,%f)", rect.origin.x, rect.origin.y, rect.size.width,rect.size.height);

	NSMutableArray<NSValue *>	*rects = [NSMutableArray array];
    for(NSDictionary *key in points)
	{
		CGFloat	x = [key[@"X"] floatValue] * rect.size.width;
		CGFloat	y = [key[@"Y"] floatValue] * rect.size.height;
		NSSize	size = NSMakeSize(30,15);
		[rects addObject:[NSValue valueWithRect:NSMakeRect(x,y, size.width,size.height)]];
	}
	NSUInteger	size = rects.count;

    // before
	[[NSColor lightGrayColor] set];
	for(NSUInteger i=0; i<size; ++i)
		NSFrameRect([rects[i] rectValue]);

	[self nudge_rectlist:rects areaRect:rect];

    // after
	[[NSColor blackColor] set];
	for(NSUInteger i=0; i<size; ++i)
		NSFrameRect([rects[i] rectValue]);
}

@end
