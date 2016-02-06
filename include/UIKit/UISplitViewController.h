//******************************************************************************
//
// Copyright (c) 2016 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#pragma once

#import <UIKit/UIKitExport.h>
#import <Foundation/NSObject.h>
#import <UIKit/UIAppearanceContainer.h>
#import <UIKit/UIContentContainer.h>
#import <UIKit/UIFocusEnvironment.h>
#import <UIKit/UITraitEnvironment.h>
#import <UIKit/UIViewController.h>

@class NSArray;
@class UIBarButtonItem;
@protocol UISplitViewControllerDelegate;

typedef enum UISplitViewControllerDisplayMode : NSInteger {
    UISplitViewControllerDisplayModeAutomatic,
    UISplitViewControllerDisplayModePrimaryHidden,
    UISplitViewControllerDisplayModeAllVisible,
    UISplitViewControllerDisplayModePrimaryOverlay,
} UISplitViewControllerDisplayMode;

UIKIT_EXPORT const CGFloat UISplitViewControllerAutomaticDimension;

UIKIT_EXPORT_CLASS
@interface UISplitViewController
    : UIViewController <NSCoding, NSObject, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UITraitEnvironment>
@property (copy, nonatomic) NSArray* viewControllers STUB_PROPERTY;
@property (nonatomic) BOOL presentsWithGesture STUB_PROPERTY;
@property (nonatomic) UISplitViewControllerDisplayMode preferredDisplayMode STUB_PROPERTY;
@property (readonly, nonatomic) UISplitViewControllerDisplayMode displayMode STUB_PROPERTY;
- (UIBarButtonItem*)displayModeButtonItem STUB_METHOD;
@property (readonly, getter=isCollapsed, nonatomic) BOOL collapsed STUB_PROPERTY;
@property (assign, nonatomic) CGFloat preferredPrimaryColumnWidthFraction STUB_PROPERTY;
@property (readonly, nonatomic) CGFloat primaryColumnWidth STUB_PROPERTY;
@property (assign, nonatomic) CGFloat minimumPrimaryColumnWidth STUB_PROPERTY;
@property (assign, nonatomic) CGFloat maximumPrimaryColumnWidth STUB_PROPERTY;
@property (nonatomic) id<UISplitViewControllerDelegate> delegate STUB_PROPERTY;
- (void)showDetailViewController:(UIViewController*)vc sender:(id)sender STUB_METHOD;
- (void)showViewController:(UIViewController*)vc sender:(id)sender STUB_METHOD;
@end
