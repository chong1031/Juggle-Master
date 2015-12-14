//
//  SKButton.m
//


#import "MGButton.h"

@interface MGButton ()
{
    NSMutableArray *marrBlocks;
    UITouch *currentTouch;
}
@end

@implementation MGButton

+ (instancetype)buttonWithNormalImage:(NSString *)normalImage normalSelImage:(NSString *)normalSelImage
{
    return [[MGButton alloc] initWithNormalImage:normalImage normalSelImage:normalSelImage selectedImage:nil selectedSelImage:nil];
}

+ (instancetype)buttonWithNormalImage:(NSString *)normalImage normalSelImage:(NSString *)normalSelImage selectedImage:(NSString *)selectedImage selectedSelImage:(NSString *)selectedSelImage
{
    return [[MGButton alloc] initWithNormalImage:normalImage normalSelImage:normalSelImage selectedImage:selectedImage selectedSelImage:selectedSelImage];
}

- (id)initWithNormalImage:(NSString *)normalImage normalSelImage:(NSString *)normalSelImage selectedImage:(NSString *)selectedImage selectedSelImage:(NSString *)selectedSelImage
{
    self = [super initWithColor:[UIColor clearColor] size:CGSizeZero];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.selected = NO;
        self.normalImageNode = [SKSpriteNode spriteNodeWithImageNamed:normalImage];
        self.normalImageNode.position = CGPointMake(0, 0);
        self.normalSelImageNode = [SKSpriteNode spriteNodeWithImageNamed:normalSelImage];
        self.normalSelImageNode.position = CGPointZero;
        [self addChild:self.normalImageNode];
        [self addChild:self.normalSelImageNode];
        
        self.normalImageNode.hidden = NO;
        self.normalSelImageNode.hidden = YES;
        
        if (selectedImage)
        {
            self.selectedImageNode = [SKSpriteNode spriteNodeWithImageNamed:selectedImage];
            self.selectedImageNode.position = CGPointZero;
            [self addChild:self.selectedImageNode];
            self.selectedImageNode.hidden = YES;
        }
        if (selectedSelImage)
        {
            self.selectedSelImageNode = [SKSpriteNode spriteNodeWithImageNamed:selectedSelImage];
            self.selectedSelImageNode.position = CGPointZero;
            [self addChild:self.selectedSelImageNode];
            self.selectedSelImageNode.hidden = YES;
        }
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self transformForTouchUp];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentTouch == nil)
    {
        currentTouch = [touches anyObject];
        
        [self transformForTouchDown];
        
        [self controlEventOccured:MGButtonControlEventTouchDown];
    }
    else
    {
        //current touch occupied
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:currentTouch])
    {
        [self setSelected:!self.selected];
     
        [self transformForTouchUp];
        
        [self controlEventOccured:MGButtonControlEventTouchUp];
        [self controlEventOccured:MGButtonControlEventTouchUpInside];
        
        currentTouch = Nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:currentTouch])
    {
        currentTouch = Nil;
        
        [self transformForTouchUp];
    }
}

- (void)transformForTouchUp
{
    SKAction *scaleUp = [SKAction scaleTo:1.0 duration:0.2];
    [self runAction:scaleUp];
    
    self.normalImageNode.hidden = YES;
    self.normalSelImageNode.hidden = YES;
    self.selectedImageNode.hidden = YES;
    self.selectedSelImageNode.hidden = YES;
    
    if (self.selectedImageNode)
    {
        if (self.selected)
        {
            self.selectedImageNode.hidden = NO;
        }
        else
        {
            self.normalImageNode.hidden = NO;
        }
    }
    else
    {
        self.normalImageNode.hidden = NO;
    }
}

- (void)transformForTouchDown
{
    SKAction *scaleUp = [SKAction scaleTo:1.2 duration:0.2];
    [self runAction:scaleUp];
    
    self.normalImageNode.hidden = YES;
    self.normalSelImageNode.hidden = YES;
    self.selectedImageNode.hidden = YES;
    self.selectedSelImageNode.hidden = YES;
    
    if (self.selectedImageNode)
    {
        if (self.selected)
        {
            self.selectedSelImageNode.hidden = NO;
        }
        else
        {
            self.normalSelImageNode.hidden = NO;
        }
    }
    else
    {
        self.normalSelImageNode.hidden = NO;
    }
}

-(void)performOnEvent:(MGButtonControlEvent)event block:(void (^)())block
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


-(void)controlEventOccured:(MGButtonControlEvent)controlEvent
{
    //Execute blocks
    
    for (NSDictionary *dicBlock in marrBlocks)
    {
        if ([[dicBlock objectForKey:@"controlEvent"]integerValue] == controlEvent)
        {
            void (^block)() = [dicBlock objectForKey:@"block"];
            
            block();
        }
    }
}

@end
