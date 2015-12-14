//
//  AGSpriteButton.m
//  AGSpriteButton
//
//  Created by Akash Gupta on 18/06/14.
//  Copyright (c) 2014 Akash Gupta. All rights reserved.
//

#import "MGHoverColorButton.h"

#define DURATION_ANIMATION      0.0001

@implementation MGHoverColorButton
{
    UIColor *_color;
    UIColor *_selectedColor;
    
    SKSpriteNode *_iconNode;
    SKSpriteNode *_selectedIconNode;
    
    UITouch *currentTouch;
    NSMutableArray *marrSelectors;
    NSMutableArray *marrBlocks;
    NSMutableArray *marrActions;
    
    CGFloat _durationlastAnimation;
    
    BOOL isTouched;
}

#pragma mark - CLASS METHODS FOR INIT

+ (MGHoverColorButton *)buttonNodeWithRectOfSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    MGHoverColorButton *button = [MGHoverColorButton shapeNodeWithRectOfSize:size
                                                                cornerRadius:cornerRadius];
    button.lineWidth = 0;
    button.fillColor = [UIColor clearColor];
    return button;
}


#pragma mark - INIT OVERRIDING

-(instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super init])
    {
        _color = color;
        _selected = NO;
        _durationlastAnimation = 0;
    }
    
    return self;
}

-(id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

-(void)setBaseProperties
{
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = YES;
}

#pragma mark - LABEL FOR BUTTON


-(void)setLabelWithText:(NSString *)text andFont:(UIFont *)font withColor:(UIColor*)fontColor
{
    if (self.label == nil)
    {
        self.label = [SKLabelNode node];
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    }
    else
    {
        [self.label removeFromParent];
    }
    
    if (text != nil)
    {
        self.label.text = text;
    }
    
    if (font != nil)
    {
        self.label.fontName = font.fontName;
        self.label.fontSize = font.pointSize;
    }
    
    if (fontColor != nil)
    {
        self.label.fontColor = fontColor;
    }
    
    [self addChild:self.label];
    
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setFillColor:color];
    [self setBaseProperties];
}

- (void)setSelectedColor:(UIColor*)selectedColor
{
    _selectedColor = selectedColor;
    [self setBaseProperties];
}

- (void)setIconNode:(SKSpriteNode*)iconNode
{
    _iconNode = iconNode;
    iconNode.position = CGPointMake(0, 0);
    [self addChild:_iconNode];
    [self setBaseProperties];
}

- (void)setSelectedIconNode:(SKSpriteNode*)selectedIconNode
{
    _selectedIconNode = selectedIconNode;
    [self setBaseProperties];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected)
    {
        if (_selectedIconNode)
        {
            [_iconNode removeFromParent];
            [self addChild:_selectedIconNode];
        }
    }
    else
    {
        if (_selectedIconNode)
        {
            [_selectedIconNode removeFromParent];
            if (_iconNode.parent != self)
            {
                [self addChild:_iconNode];
            }
        }
    }
}

#pragma mark - TOUCH DELEGATES

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.exclusiveTouch)
    {
        if (currentTouch == nil)
        {
            isTouched = YES;
            currentTouch = [touches anyObject];
            
            [self controlEventOccured:AGButtonControlEventTouchDown];
            
            [self transformForTouchDown];
            
        }
        else
        {
            //current touch occupied
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.exclusiveTouch)
    {
        if ([touches containsObject:currentTouch])
        {
            CGPoint touchPoint = [currentTouch locationInNode:self];
            float lenX = self.frame.size.width / 2;
            float lenY = self.frame.size.height / 2;
            
            if ((touchPoint.x > lenX + 10)|| (touchPoint.x < (-lenX - 10)) || (touchPoint.y > lenY + 10) || (touchPoint.y < (-lenY - 10)))
            {
                [self touchesCancelled:touches withEvent:Nil];
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.exclusiveTouch)
    {
        if ([touches containsObject:currentTouch])
        {
            //touchupinside
            isTouched = NO;
            
            [self controlEventOccured:AGButtonControlEventTouchUp];
            [self controlEventOccured:AGButtonControlEventTouchUpInside];
            
            currentTouch = Nil;
            
            [self setSelected:!self.selected];
            
            [self transformForTouchUp];
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.exclusiveTouch)
    {
        if ([touches containsObject:currentTouch])
        {
            currentTouch = Nil;
            
            [self transformForTouchUp];
        }
    }
}

#pragma mark - BUTTON TRANSFORM ON SELECTION

-(void)transformForTouchDown
{
    [self removeAllActions];
    //    NSLog(@"touch down %@", self.fillColor);
    SKAction *action = [self getColorFadeActionFrom:self.fillColor toColor:_selectedColor selecting:YES];
    [self runAction:action];
}

-(void)transformForTouchDrag
{
    //You can define your custom transformation here.
    
}

-(void)transformForTouchUp
{
    [self removeAllActions];
    //    NSLog(@"touch up %@", self.fillColor);
    SKAction *action = [self getColorFadeActionFrom:self.fillColor toColor:_color selecting:NO];
    [self runAction:action];
}

#pragma mark - TARGET/SELECTOR HANDLING

-(void)addTarget:(id)target selector:(SEL)selector withObject:(id)object forControlEvent:(AGButtonControlEvent)controlEvent
{
    //check whether selector is already saved, otherwise it will get called twice
    
    if (marrSelectors == nil)
    {
        marrSelectors = [NSMutableArray new];
    }
    
    NSMutableDictionary *mdicSelector = [[NSMutableDictionary alloc]init];
    
    [mdicSelector setObject:target forKey:@"target"];
    [mdicSelector setObject:[NSValue valueWithPointer:selector] forKey:@"selector"];
    
    if (object)
    {
        [mdicSelector setObject:object forKey:@"object"];
    }
    
    [mdicSelector setObject:[NSNumber numberWithInt:controlEvent] forKey:@"controlEvent"];
    
    [marrSelectors addObject:mdicSelector];
}

-(void)removeTarget:(id)target selector:(SEL)selector forControlEvent:(AGButtonControlEvent)controlEvent
{
    NSMutableArray *arrSelectors = [marrSelectors mutableCopy]; //Copied to prevent inconsistency
    
    for (int i = 0; i < [arrSelectors count]; i++)
    {
        
        NSDictionary *dicSelector = [arrSelectors objectAtIndex: i];
        
        BOOL shouldRemove = NO;
        BOOL shouldCheckSelector = NO;
        BOOL shouldCheckControlEvent = NO;
        
        id selTarget = [dicSelector objectForKey:@"target"];
        
        NSValue *valSelector = [dicSelector objectForKey:@"selector"];
        
        SEL selSelector = nil;
        
        if (valSelector)
        {
            selSelector = [valSelector pointerValue];
        }
        
        AGButtonControlEvent selControlEvent = [[dicSelector objectForKey:@"controlEvent"]intValue];
        
        if (target != nil)
        {
            if ([selTarget isEqual:target])
            {
                shouldCheckSelector = YES;
            }
        }
        else
        {
            shouldCheckSelector = YES;
        }
        
        if (shouldCheckSelector)
        {
            if (selector != nil)
            {
                if (selSelector == selector)
                {
                    shouldCheckControlEvent = YES;
                }
            }
            else
            {
                shouldCheckControlEvent = YES;
            }
        }
        
        if (shouldCheckControlEvent)
        {
            if (controlEvent == AGButtonControlEventAllEvents)
            {
                shouldRemove = YES;
            }
            else
            {
                if (selControlEvent == controlEvent)
                {
                    shouldRemove = YES;
                }
            }
        }
        
        if (shouldRemove)
        {
            [arrSelectors removeObject:dicSelector];
            i--; //To make sure the next item is checked
        }
    }
    
    marrSelectors = arrSelectors;
}

-(void)removeAllTargets
{
    [marrSelectors removeAllObjects];
    marrSelectors = nil;
}

#pragma mark - CODE BLOCKS

-(void)performOnEvent:(AGButtonControlEvent)event block:(void (^)())block
{
    NSDictionary *dicBlock = [NSDictionary dictionaryWithObjectsAndKeys:block, @"block", [NSNumber numberWithInteger:event], @"controlEvent", nil];
    
    if (dicBlock)
    {
        if (marrBlocks == nil)
        {
            marrBlocks = [NSMutableArray new];
        }
        
        [marrBlocks addObject:dicBlock];
    }
}

#pragma mark - ACTIONS HANDLING

-(void)performAction:(SKAction *)action onNode:(SKNode*)object withEvent:(AGButtonControlEvent)event
{
    if ([object respondsToSelector:@selector(runAction:)])
    {
        NSDictionary *dicAction = [NSDictionary dictionaryWithObjectsAndKeys:action, @"action", object, @"object", [NSNumber numberWithInteger:event], @"controlEvent",  nil];
        
        if (marrActions == nil)
        {
            marrActions = [NSMutableArray new];
        }
        
        [marrActions addObject:dicAction];
    }
    else
    {
        [NSException raise:@"Incompatible object." format:@"Object %@ cannot perform actions.", object];
    }
}

#pragma mark - Internal

-(void)controlEventOccured:(AGButtonControlEvent)controlEvent
{
    //Execute selectors
    for (NSDictionary *dicSelector in marrSelectors) {
        
        if ([[dicSelector objectForKey:@"controlEvent"]integerValue] == controlEvent)
        {
            id target = [dicSelector objectForKey:@"target"];
            
            SEL selector = [[dicSelector objectForKey:@"selector"]pointerValue];
            
            id object = [dicSelector objectForKey:@"object"];
            
            IMP imp = [target methodForSelector:selector];
            
            if (object)
            {
                void (*func)(id, SEL, id) = (void*)imp;
                func (target, selector, object);
            }
            else
            {
                void (*func)(id, SEL) = (void *)imp;
                func(target, selector);
            }
        }
    }
    
    //Execute blocks
    
    for (NSDictionary *dicBlock in marrBlocks)
    {
        if ([[dicBlock objectForKey:@"controlEvent"]integerValue] == controlEvent)
        {
            void (^block)() = [dicBlock objectForKey:@"block"];
            
            block();
        }
    }
    
    //Execute actions
    
    for (NSDictionary *dicAction in marrActions)
    {
        if ([[dicAction objectForKey:@"controlEvent"] integerValue] == controlEvent)
        {
            SKAction *action = [dicAction objectForKey:@"action"];
            SKNode *object = [dicAction objectForKey:@"object"];
            
            [object runAction:action];
        }
    }
}


-(SKAction*)getColorFadeActionFrom:(UIColor*)col1 toColor:(UIColor*)col2 selecting:(BOOL)selecting {
    
    col1 = self.fillColor;
    
    // get the Color components of col1 and col2
    CGFloat r1 = 0.0, g1 = 0.0, b1 = 0.0, a1 =0.0;
    CGFloat r2 = 0.0, g2 = 0.0, b2 = 0.0, a2 =0.0;
    [col1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [col2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    if (isnan(r1) && isnan(g1) && isnan(b1))
    {
        [_color getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    }
    
    CGFloat timeToRun = 1.0;
    if (selecting) {
        timeToRun = DURATION_ANIMATION;
    }
    else
    {
        timeToRun = _durationlastAnimation;
        if (timeToRun == 0)
        {
            timeToRun = 0.0001;
        }
    }
    
    return [SKAction customActionWithDuration:timeToRun actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat fraction = elapsedTime / timeToRun;
        
        UIColor *col3 = [UIColor colorWithRed:lerp(r1,r2,fraction)
                                        green:lerp(g1,g2,fraction)
                                         blue:lerp(b1,b2,fraction)
                                        alpha:lerp(a1,a2,fraction)];
        
        [(SKShapeNode*)node setFillColor:col3];
        //        NSLog(@"filled color: %@", ((SKShapeNode*)node).fillColor);
        [(SKShapeNode*)node setStrokeColor:col3];
        
        _durationlastAnimation = elapsedTime;
    }];
}

double lerp(double a, double b, double fraction) {
    return (b-a)*fraction + a;
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
