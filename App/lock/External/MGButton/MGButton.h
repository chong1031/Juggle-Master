//
//  SKButton.h
//


#import <SpriteKit/SpriteKit.h>

typedef NS_OPTIONS(NSInteger, MGButtonControlEvent)
{
    MGButtonControlEventTouchDown = 1,  //When button is held down.
    MGButtonControlEventTouchUp,        //When button is released.
    MGButtonControlEventTouchUpInside,  //When button is tapped.
    MGButtonControlEventAllEvents       //Convenience event for deletion of selector, block or action.
};


@interface MGButton : SKSpriteNode

@property (nonatomic, strong) SKSpriteNode *normalImageNode;
@property (nonatomic, strong) SKSpriteNode *normalSelImageNode;
@property (nonatomic, strong) SKSpriteNode *selectedImageNode;
@property (nonatomic, strong) SKSpriteNode *selectedSelImageNode;
@property (nonatomic) BOOL selected;
@property (nonatomic, readwrite) BOOL buttonActive;

+ (instancetype)buttonWithNormalImage:(NSString *)normalImage normalSelImage:(NSString *)normalSelImage;
+ (instancetype)buttonWithNormalImage:(NSString *)normalImage normalSelImage:(NSString *)normalSelImage selectedImage:(NSString *)selectedImage selectedSelImage:(NSString *)selectedSelImage;

- (void)performOnEvent:(MGButtonControlEvent)event block:(void (^)())block;

@end
