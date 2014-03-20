//
//  DDTAppDelegate.h
//  TurboGel
//
//  Created by Daren David Taylor on 20/10/2013.
//  Copyright (c) 2013 DarenDavidTaylor.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface DDTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) AVAudioPlayer *player;

@end
