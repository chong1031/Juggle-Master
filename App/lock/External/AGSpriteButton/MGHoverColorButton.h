//
//  AGSpriteButton.h
//  AGSpriteButton
//
//  Created by Akash Gupta on 18/06/14.
//  Copyright (c) 2014 Akash Gupta. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_OPTIONS(NSInteger, AGButtonControlEvent)
{
    AGButtonControlEventTouchDown = 1,  //When button is held down.
    AGButtonControlEventTouchUp,        //When button is released.
    AGButtonControlEventTouchUpInside,  //When button is tapped.
    AGButtonControlEventAllEvents       //Convenience event for deletion of selector, block or action.
};


@interface MGHoverColorButton : SKShapeNode

@property (nonatomic) BOOL selected;

@property (setter = setExclusiveTouch:, getter = isExclusiveTouch) BOOL exclusiveTouch;

@property (strong, nonatomic) SKLabelNode *label;

//CLASS METHODS FOR CREATING BUTTON

+ (MGHoverColorButton*)buttonNodeWithRectOfSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

//LABEL METHOD

-(void)setLabelWithText:(NSString*)text andFont:(UIFont*)font withColor:(UIColor*)fontColor;

- (void)setColor:(UIColor*)color;
- (void)setSelectedColor:(UIColor*)selectedColor;
- (void)setIconNode:(SKSpriteNode*)iconNode;
- (void)setSelectedIconNode:(SKSpriteNode*)selectedIconNode;


//TARGET HANDLER METHODS (Similar to UIButton)

-(void)addTarget:(id)target selector:(SEL)selector withObject:(id)object forControlEvent:(AGButtonControlEvent)controlEvent;

-(void)removeTarget:(id)target selector:(SEL)selector forControlEvent:(AGButtonControlEvent)controlEvent;

-(void)removeAllTargets;


//EXECUTE BLOCKS ON EVENTS

-(void)performOnEvent:(AGButtonControlEvent)event block:(void (^)())block;


//EXECUTE ACTIONS ON EVENTS

-(void)performAction:(SKAction*)action onNode:(SKNode*)object withEvent:(AGButtonControlEvent)event;

//Explicit Transform method. Call these methods to transform the button using code.

-(void)transformForTouchDown;

-(void)transformForTouchUp;

@end
