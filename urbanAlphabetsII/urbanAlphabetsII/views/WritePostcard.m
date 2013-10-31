//
//  WritePostcard.m
//  urbanAlphabetsII
//
//  Created by Suse on 31/10/13.
//  Copyright (c) 2013 Suse. All rights reserved.
//

#import "WritePostcard.h"

@implementation WritePostcard

-(void)transferVariables:(int) number topBarFromTop:(float)TopBarFromTopDefault topBarHeight:(float)TopNavBarHeightDefault bottomBarHeight:(float)BottomBarHeightDefault navBarColor:(UIColor*)navBarColorDefault navigationColor:(UIColor*)navigationColorDefault typeColor:(UIColor*)typeColorDefault  fatFont:(C4Font*)fatFontDefault normalFont:(C4Font*)normalFontDefault backImage:(C4Image*)iconBackDefault iconClose:(C4Image*)iconCloseDefault emptyLetter:(C4Image*)emptyLetterDefault{
    
    //nav bar heights
    topBarFromTop=TopBarFromTopDefault;
    topBarHeight=TopNavBarHeightDefault;
    bottomBarHeight=BottomBarHeightDefault;
    
    //colors
    navBarColor=navBarColorDefault;
    navigationColor=navigationColorDefault;
    typeColor=typeColorDefault;
    
    //fonts
    fatFont=fatFontDefault;
    normalFont=normalFontDefault;
    
    //icons
    iconClose=iconCloseDefault;
    iconBack=iconBackDefault;
    
    //setup postcard as empty
    postcardArray=[[NSMutableArray alloc]init];

    emptyLetter=emptyLetterDefault;
}
-(void)setup:(NSMutableArray*)passedAlphabet currentLanguage:(NSString*)passedLanguage{
    currentAlphabet=passedAlphabet;
    currentLanguage=passedLanguage;
    [self topBarSetup];
    [self setupTextField];

}
-(void)topBarSetup{
    //--------------------
    //white rect under top bar
    //--------------------
    defaultRect=[C4Shape rect:CGRectMake(0, 0, self.canvas.width, topBarFromTop)];
    defaultRect.fillColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.canvas addShape:defaultRect];
    defaultRect.lineWidth=0;
    
    //--------------------
    //top bar
    //--------------------
    topNavBar=[C4Shape rect:CGRectMake(0, topBarFromTop, self.canvas.width, topBarHeight)];
    topNavBar.fillColor=navBarColor;
    topNavBar.lineWidth=0;
    [self.canvas addShape:topNavBar];
    
    //title in center
    titleLabel = [C4Label labelWithText:@"Write Postcard" font:fatFont];
    titleLabel.center=topNavBar.center;
    [self.canvas addLabel:titleLabel];
    
    //--------------------
    //LEFT
    //--------------------
    //back text
    backLabel=[C4Label labelWithText:@"Back" font: normalFont];
    backLabel.center=CGPointMake(40, topNavBar.center.y);
    [self.canvas addLabel:backLabel];
    
    //back icon
    backButtonImage=iconBack;
    backButtonImage.width= 12.2;
    backButtonImage.center=CGPointMake(10, topNavBar.center.y);
    [self.canvas addImage:backButtonImage];
    
    //invisible rect for navigation
    navigateBackRect=[C4Shape rect: CGRectMake(0, topBarFromTop, 60, topNavBar.height)];
    navigateBackRect.fillColor=navigationColor;
    navigateBackRect.lineWidth=0;
    [self.canvas addShape:navigateBackRect];
    //[self listenFor:@"touchesBegan" fromObject:navigateBackRect andRunMethod:@"navigateBack"];
    //--------------------------------------------------
    //RIGHT
    //--------------------------------------------------
    //close icon
    closeButtonImage=iconClose;
    closeButtonImage.width= 25;
    closeButtonImage.center=CGPointMake(self.canvas.width-18, topNavBar.center.y);
    [self.canvas addImage:closeButtonImage];
    
    //invisible rect to interact with
    closeRect=[C4Shape rect:CGRectMake(self.canvas.width-35, topBarFromTop, 35, topNavBar.height)];
    closeRect.fillColor=navigationColor;
    closeRect.lineWidth=0;
    [self.canvas addShape:closeRect];
    //[self listenFor:@"touchesBegan" fromObject:closeRect andRunMethod:@"navigateBack"];
}
-(void)setupTextField{
    CGRect textViewFrame = CGRectMake(20.0f, topBarFromTop+topBarHeight+10, self.canvas.width-40, 124.0f);
    UITextView *textView = [[UITextView alloc] initWithFrame:textViewFrame];
    textView.returnKeyType = UIReturnKeyDone;
    [textView becomeFirstResponder];
    textView.delegate = self;
    [self.view addSubview:textView];
    NSLog(@"setupTextFieldDone");
}
//------------------------------------------------------------------------
//DISPLAY POSTCARD
//------------------------------------------------------------------------
-(void)displayPostcard{
    [self addLetterToPostcard];
    
    C4Log(@"postCardArrayLength:%i", [postcardArray count]);
    
    float imageWidth=53.53;
    float imageHeight=65.1;
    
    if (![newCharacter  isEqual:@""]) { //if something was added
        //draw only the last letter
        int lastLetter=[postcardArray count]-1;
        float xMultiplier=(lastLetter)%6;
        float yMultiplier= (lastLetter)/6;
        float xPos=xMultiplier*imageWidth;
        float yPos=topBarFromTop+topBarHeight+yMultiplier*imageHeight;
        C4Image *image=[postcardArray objectAtIndex:lastLetter ];
        image.origin=CGPointMake(xPos, yPos);
        image.width=imageWidth;
        [self.canvas addImage:image];
    }
    

}
-(void)addLetterToPostcard{
    if ([newCharacter isEqual: @"a"]||[newCharacter isEqual: @"A"]) {
        C4Image *image=[currentAlphabet objectAtIndex: 0];
        [postcardArray addObject: image];
    } else if ([newCharacter isEqual: @"b"]||[newCharacter isEqual: @"B"]){
        C4Image *image=[currentAlphabet objectAtIndex: 1];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"c"]||[newCharacter isEqual: @"C"]){
        C4Image *image=[currentAlphabet objectAtIndex: 2];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"d"]||[newCharacter isEqual: @"D"]){
        C4Image *image=[currentAlphabet objectAtIndex: 3];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"e"]||[newCharacter isEqual: @"E"]){
        C4Image *image=[currentAlphabet objectAtIndex: 4];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"f"]||[newCharacter isEqual: @"F"]){
        C4Image *image=[currentAlphabet objectAtIndex: 5];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"g"]||[newCharacter isEqual: @"G"]){
        C4Image *image=[currentAlphabet objectAtIndex: 6];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"h"]||[newCharacter isEqual: @"H"]){
        C4Image *image=[currentAlphabet objectAtIndex: 7];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"i"]||[newCharacter isEqual: @"I"]){
        C4Image *image=[currentAlphabet objectAtIndex: 8];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"j"]||[newCharacter isEqual: @"J"]){
        C4Image *image=[currentAlphabet objectAtIndex: 9];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"k"]||[newCharacter isEqual: @"K"]){
        C4Image *image=[currentAlphabet objectAtIndex: 10];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"l"]||[newCharacter isEqual: @"L"]){
        C4Image *image=[currentAlphabet objectAtIndex: 11];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"m"]||[newCharacter isEqual: @"M"]){
        C4Image *image=[currentAlphabet objectAtIndex: 12];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"n"]||[newCharacter isEqual: @"N"]){
        C4Image *image=[currentAlphabet objectAtIndex: 13];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"o"]||[newCharacter isEqual: @"O"]){
        C4Image *image=[currentAlphabet objectAtIndex: 14];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"p"]||[newCharacter isEqual: @"P"]){
        C4Image *image=[currentAlphabet objectAtIndex: 15];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"q"]||[newCharacter isEqual: @"Q"]){
        C4Image *image=[currentAlphabet objectAtIndex: 16];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"r"]||[newCharacter isEqual: @"R"]){
        C4Image *image=[currentAlphabet objectAtIndex: 17];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"s"]||[newCharacter isEqual: @"S"]){
        C4Image *image=[currentAlphabet objectAtIndex: 18];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"t"]||[newCharacter isEqual: @"T"]){
        C4Image *image=[currentAlphabet objectAtIndex: 19];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"u"]||[newCharacter isEqual: @"U"]){
        C4Image *image=[currentAlphabet objectAtIndex: 20];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"v"]||[newCharacter isEqual: @"V"]){
        C4Image *image=[currentAlphabet objectAtIndex: 21];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"w"]||[newCharacter isEqual: @"W"]){
        C4Image *image=[currentAlphabet objectAtIndex: 22];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"x"]||[newCharacter isEqual: @"X"]){
        C4Image *image=[currentAlphabet objectAtIndex: 23];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"y"]||[newCharacter isEqual: @"Y"]){
        C4Image *image=[currentAlphabet objectAtIndex: 24];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"z"]||[newCharacter isEqual: @"Z"]){
        C4Image *image=[currentAlphabet objectAtIndex: 25];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"ä"]||[newCharacter isEqual: @"Ä"]){
        C4Image *image=[currentAlphabet objectAtIndex: 26];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"ö"]||[newCharacter isEqual: @"Ö"]){
        C4Image *image=[currentAlphabet objectAtIndex: 27];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"å"]||[newCharacter isEqual: @"Å"]){
        C4Image *image=[currentAlphabet objectAtIndex: 28];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"."]){
        C4Image *image=[currentAlphabet objectAtIndex: 29];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"!"]){
        C4Image *image=[currentAlphabet objectAtIndex: 30];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"?"]){
        C4Image *image=[currentAlphabet objectAtIndex: 31];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"0"]){
        C4Image *image=[currentAlphabet objectAtIndex: 32];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"1"]){
        C4Image *image=[currentAlphabet objectAtIndex: 33];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"2"]){
        C4Image *image=[currentAlphabet objectAtIndex: 34];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"3"]){
        C4Image *image=[currentAlphabet objectAtIndex: 35];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"4"]){
        C4Image *image=[currentAlphabet objectAtIndex: 36];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"5"]){
        C4Image *image=[currentAlphabet objectAtIndex: 37];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"6"]){
        C4Image *image=[currentAlphabet objectAtIndex: 38];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"7"]){
        C4Image *image=[currentAlphabet objectAtIndex: 39];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"8"]){
        C4Image *image=[currentAlphabet objectAtIndex: 40];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @"9"]){
        C4Image *image=[currentAlphabet objectAtIndex: 41];
        [postcardArray addObject: image];
    }else if ([newCharacter isEqual: @" "]){
        [postcardArray addObject: emptyLetter];
    }else if([newCharacter isEqual: @""]){
        C4Image *image=[postcardArray objectAtIndex:[postcardArray count]-1];
        [image removeFromSuperview];
        [postcardArray removeLastObject];
        
    }
}
//------------------------------------------------------------------------
//STUFF TO HANDLE THE KEYBOARD INPUT
//------------------------------------------------------------------------

#pragma mark -
#pragma mark UITextViewDelegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    /*--
     * This method is called when the textView becomes active, or is the First Responder
     --*/
    
    NSLog(@"textViewDidBeginEditing:");
    textView.textColor = [UIColor greenColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    /*--
     * This method is called when the textView is no longer active
     --*/
    [self displayPostcard];
    NSLog(@"textViewDidEndEditing:");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"textView:shouldChangeTextInRange:replacementText:");
    
    NSLog(@"textView.text.length -- %i",textView.text.length);
    NSLog(@"text.length          -- %i",text.length);
    NSLog(@"text                 -- '%@'", text);
    NSLog(@"textView.text        -- '%@'", textView.text);
    
    newCharacter=text;
    entireText=textView.text;
    
    /*--
     * This method is called just before text in the textView is displayed
     * This is a good place to disallow certain characters
     * Limit textView to 140 characters
     * Resign keypad if done button pressed comparing the incoming text against the newlineCharacterSet
     * Return YES to update the textView otherwise return NO
     --*/
    [self displayPostcard];
    
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 20){//140 characters are in the textView
        if (location != NSNotFound){ //Did not find any newline characters
            [textView resignFirstResponder];
        }
        return NO;
    }
    else if (location != NSNotFound){ //Did not find any newline characters
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"textViewDidChange:");
    //This method is called when the user makes a change to the text in the textview
}
@end
