//
//  ChangeLanguage.h
//  UrbanAlphabets
//
//  Created by Suse on 12/12/13.
//  Copyright (c) 2013 moi. All rights reserved.
//

#import "C4CanvasController.h"

@interface ChangeLanguage : UIViewController


-(void) setupWithLanguage: (NSString*)passedLanguage Name:(NSString*)passedName;
-(void)updateLanguage;
-(void)changeLanguage;
@end
