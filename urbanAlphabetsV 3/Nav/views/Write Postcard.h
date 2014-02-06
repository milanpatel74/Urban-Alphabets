//
//  Write Postcard.h
//  UrbanAlphabets
//
//  Created by Suse on 16/12/13.
//  Copyright (c) 2013 moi. All rights reserved.
//


@interface Write_Postcard : UIViewController<UITextViewDelegate>
@property (readwrite, strong) NSMutableArray *postcardArray, *greyRectArray, *currentAlphabet, *postcardViewArray;
@property (readwrite)     NSString *entireText;
@property (readwrite) NSString *postcardText;

-(void)setupWithLanguage: (NSString*)passedLanguage Alphabet:(NSMutableArray*)passedAlphabet;
-(void)clearPostcard;
@end
