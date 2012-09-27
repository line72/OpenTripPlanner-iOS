/**
 * Copyright (c) 2012 Muh Hon Cheng
 * Created by honcheng on 6/2/12.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 * IN CONNECTION WITH THE SOFTWARE OR
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2012	Muh Hon Cheng
 * @version
 *
 */


#import "UIView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>
#import "RouteMe.h"

@implementation UIView (Screenshot)

- (UIImage*)screenshot
{
    return [((RMMapView *)[self.subviews objectAtIndex:0]) takeSnapshotAndIncludeOverlay:YES];
    
    // take screenshot of the view
    if ([self isKindOfClass:NSClassFromString(@"MKMapView")])
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)
        {
            // in iOS6, there is no problem using a non-retina screenshot in a retina display screen
            UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
        }
        else
        {
            // if the view is a mapview in iOS5.0 and below, screenshot has to take the screen scale into consideration
            // else, the screen shot in retina display devices will be of a less detail map (note, it is not the size of the screenshot, but it is the level of detail of the screenshot
            UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
        }
    }
    else if ([self isKindOfClass:NSClassFromString(@"RMMapView")])
    {
        return [((RMMapView *)self) takeSnapshotAndIncludeOverlay:YES];
    }
    else 
    {
        // for performance consideration, everything else other than mapview will use a lower quality screenshot
        UIGraphicsBeginImageContext(self.frame.size);
    }
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return screenshot;
}

- (void)takeScreenshot:(CompletionBlock)block
{
    dispatch_queue_t queue = dispatch_queue_create("screenshot", 0);
    dispatch_async(queue, ^(void) {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^{
            block(screenshot);
        });
        dispatch_release(queue);
    });
}

@end
