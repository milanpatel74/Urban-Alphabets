//
//  ShareAlphabet.h
//  UrbanAlphabets
//
//  Created by Suse on 16/12/13.
//  Copyright (c) 2013 moi. All rights reserved.
//

#import "C4ViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ShareAlphabet : UIViewController<MFMailComposeViewControllerDelegate, UITextViewDelegate>
-(void)setup:(UIImage*)imageToShare;
@end
