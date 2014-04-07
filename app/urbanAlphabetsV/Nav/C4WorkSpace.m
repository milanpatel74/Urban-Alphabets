//
//  C4WorkSpace.m
//  Nav
//
//  Created by moi on 12/5/2013.
//

#import "C4Workspace.h"
#import "CropPhoto.h"

@implementation C4WorkSpace {
    CropPhoto *cropPhoto;
    
    C4Camera *cam;
    

   // NSString *userName;
    C4Shape *backgroundRect;
    
    //saving image
    CGContextRef graphicsContext;
    C4Image *currentImageToExport;
    
    //for intro
    NSMutableArray *introPics;
    UITextView *userNameField;
    int currentNoInIntro;
    C4Image *nextButton;
    C4Label *webadress;
    
    //images loaded from documents directory
    C4Image *loadedImage;
}

-(void)setup {
    self.title=@"Take Photo";

    //load the defaults
    //[self loadDefaultAlphabet];
    self.currentLanguage= @"Finnish/Swedish";
    self.myAlphabets=[[NSMutableArray alloc]init];
    self.myAlphabetsLanguages=[[NSMutableArray alloc]init];
    self.alphabetName=@"Untitled";
    self.languages=[NSMutableArray arrayWithObjects:@"Danish/Norwegian", @"English", @"Finnish/Swedish", @"German", @"Russian", @"Spanish", nil];

    //to see when app becomes active/inactive
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    //setup the TakePhoto view
    [self cameraSetup];
    
    //setup the bottom bar
    //bottomNavbar WITH 2 ICONS
    CGRect bottomBarFrame = CGRectMake(0, self.canvas.height-UA_BOTTOM_BAR_HEIGHT, self.canvas.width, UA_BOTTOM_BAR_HEIGHT);
    self.bottomNavBar = [[BottomNavBar alloc] initWithFrame:bottomBarFrame leftIcon:UA_ICON_PHOTOLIBRARY withFrame:CGRectMake(0, 0, 45, 22.5) centerIcon:UA_ICON_TAKE_PHOTO withFrame:CGRectMake(0, 0, 90, 45)];
    [self.canvas addShape:self.bottomNavBar];
    //take photo button
    [self listenFor:@"touchesBegan" fromObject:self.bottomNavBar.centerImage andRunMethod:@"captureImage"];
    //photo library button
    [self listenFor:@"touchesBegan" fromObject:self.bottomNavBar.leftImage andRunMethod:@"goToPhotoLibrary"];
    
    
    [self numberOfTouchesRequired:1 forGesture:@"capture"];
    [self listenFor:@"imageWasCaptured" fromObject:cam andRunMethod:@"goToCropPhoto"];
    
    if (self.userName==nil) {
        self.title=@"Intro";
        introPics=[NSMutableArray arrayWithObjects:[C4Image imageNamed:@"intro_1_1.png"],[C4Image imageNamed:@"intro_3"],[C4Image imageNamed:@"intro_4"],[C4Image imageNamed:@"intro_5"], nil];

        currentNoInIntro=0;
        C4Image *intro1=[introPics objectAtIndex:currentNoInIntro];
        intro1.width=self.canvas.width;

        intro1.origin=CGPointMake(0, UA_TOP_BAR_HEIGHT+UA_TOP_WHITE+2);
        [self.canvas addImage:intro1];
        
        nextButton=[C4Image imageWithImage:UA_ICON_NEXT];
        nextButton.width=80;
        nextButton.origin=CGPointMake(self.canvas.width-nextButton.width-20, self.canvas.height-nextButton.height-20);
        [self.canvas addImage:nextButton];
        [self listenFor:@"touchesBegan" fromObject:nextButton andRunMethod:@"nextIntroPic"];
        
       }

}
-(void)nextIntroPic{
    //remove old
    C4Image *image=[introPics objectAtIndex:currentNoInIntro];
    
    [self.canvas removeObject:image];
    [self.canvas removeObject:nextButton];
    [self stopListeningFor:@"touchesBegan" object:nextButton];
    if (currentNoInIntro==1) {
        [webadress removeFromSuperview];
    }
    //next number
    currentNoInIntro++;
    if (currentNoInIntro<[introPics count]) {
        //add next
        image=[introPics objectAtIndex:currentNoInIntro];
        image.width=self.canvas.width;
        image.origin=CGPointMake(0, UA_TOP_BAR_HEIGHT+UA_TOP_WHITE+2);
        [self.canvas addImage:image];
        if (currentNoInIntro==1) {
            webadress=[C4Label labelWithText:@"www.ualphabets.com" font:UA_NORMAL_FONT];
            webadress.textColor=UA_GREY_TYPE_COLOR;
            webadress.origin=CGPointMake(25, self.canvas.height-150);
            [self.canvas addLabel:webadress];
            
        }
        if (currentNoInIntro==2) {
            //add text field
            CGRect textViewFrame = CGRectMake(20, 200, self.canvas.width-2*20, 25.0f);
            userNameField = [[UITextView alloc] initWithFrame:textViewFrame];
            userNameField.returnKeyType = UIReturnKeyDone;
            userNameField.layer.borderWidth=1.0f;
            userNameField.layer.borderColor=[UA_OVERLAY_COLOR CGColor];
            [userNameField becomeFirstResponder];
            userNameField.delegate = self;
            [self.view addSubview:userNameField];
        }
        [self.canvas addImage:nextButton];
        [self listenFor:@"touchesBegan" fromObject:nextButton andRunMethod:@"nextIntroPic"];
    } else{
        self.title=@"Take Photo";
    }
    
}


-(void)viewDidLoad{
    self.userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
}

-(void)saveUserName{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.userName=userNameField.text;
    [defaults setValue:self.userName forKey:@"userName"];
    [defaults synchronize];
    //and remove the username stuff
    [userNameField removeFromSuperview];
}
-(void)cameraSetup{
    cam = [C4Camera cameraWithFrame:CGRectMake(0,0, self.canvas.width, self.canvas.height)];
    cam.cameraPosition = CAMERABACK;
    [self.canvas addCamera:cam];
    [cam initCapture];
    
}
-(void)captureImage{
    self.bottomNavBar.centerImage.backgroundColor=UA_HIGHLIGHT_COLOR;
    [cam captureImage];
}

-(void)goToCropPhoto {
    self.img = cam.capturedImage;
    cropPhoto = [[CropPhoto alloc] initWithNibName:@"CropPhoto" bundle:[NSBundle mainBundle]];
    [cropPhoto displayImage:self.img];
    [cropPhoto setup];
    
    [self.navigationController pushViewController:cropPhoto animated:YES];
}
-(void)goToPhotoLibrary{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
 //--------------------------------------------------
//load image from photo library
 //--------------------------------------------------
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.img = [C4Image imageWithUIImage:image];
    cropPhoto = [[CropPhoto alloc] initWithNibName:@"CropPhoto" bundle:[NSBundle mainBundle]];
    [cropPhoto displayImage:self.img];
    [cropPhoto setup];
    [self.navigationController pushViewController:cropPhoto animated:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
//--------------------------------------------------
//load default alphabet
//--------------------------------------------------
-(void)loadDefaultAlphabet{
    if ([self.currentLanguage isEqualToString:@"Finnish/Swedish"] ||[self.currentLanguage isEqualToString:@"German"]||[self.currentLanguage isEqualToString:@"Danish/Norwegian"]||[self.currentLanguage isEqualToString:@"English"]||[self.currentLanguage isEqualToString:@"Spanish"]) {
        self.currentAlphabet=[NSMutableArray arrayWithObjects:
                              //first row
                              [C4Image imageNamed:@"letter_A.png"],
                              [C4Image imageNamed:@"letter_B.png"],
                              [C4Image imageNamed:@"letter_C.png"],
                              [C4Image imageNamed:@"letter_D.png"],
                              [C4Image imageNamed:@"letter_E.png"],
                              [C4Image imageNamed:@"letter_F.png"],
                              //second row
                              [C4Image imageNamed:@"letter_G.png"],
                              [C4Image imageNamed:@"letter_H.png"],
                              [C4Image imageNamed:@"letter_I.png"],
                              [C4Image imageNamed:@"letter_J.png"],
                              [C4Image imageNamed:@"letter_K.png"],
                              [C4Image imageNamed:@"letter_L.png"],
                              
                              [C4Image imageNamed:@"letter_M.png"],
                              [C4Image imageNamed:@"letter_N.png"],
                              [C4Image imageNamed:@"letter_O.png"],
                              [C4Image imageNamed:@"letter_P.png"],
                              [C4Image imageNamed:@"letter_Q.png"],
                              [C4Image imageNamed:@"letter_R.png"],
                              
                              [C4Image imageNamed:@"letter_S.png"],
                              [C4Image imageNamed:@"letter_T.png"],
                              [C4Image imageNamed:@"letter_U.png"],
                              [C4Image imageNamed:@"letter_V.png"],
                              [C4Image imageNamed:@"letter_W.png"],
                              [C4Image imageNamed:@"letter_X.png"],
                              
                              [C4Image imageNamed:@"letter_Y.png"],
                              [C4Image imageNamed:@"letter_Z.png"],
                              //here the special characters will be inserted
                              [C4Image imageNamed:@"letter_.png"],//.
                              
                              [C4Image imageNamed:@"letter_!.png"],
                              [C4Image imageNamed:@"letter_-.png"],//?
                              [C4Image imageNamed:@"letter_0.png"],
                              [C4Image imageNamed:@"letter_1.png"],
                              [C4Image imageNamed:@"letter_2.png"],
                              [C4Image imageNamed:@"letter_3.png"],
                              
                              [C4Image imageNamed:@"letter_4.png"],
                              [C4Image imageNamed:@"letter_5.png"],
                              [C4Image imageNamed:@"letter_6.png"],
                              [C4Image imageNamed:@"letter_7.png"],
                              [C4Image imageNamed:@"letter_8.png"],
                              [C4Image imageNamed:@"letter_9.png"],
                              nil];
        if ([self.currentLanguage isEqualToString:@"Finnish/Swedish"]) {
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Ä.png"] atIndex:26];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Ö.png"] atIndex:27];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Å.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"German"]) {
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Ä.png"] atIndex:26];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Ö.png"] atIndex:27];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Ü.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"Danish/Norwegian"]) {
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_ae.png"] atIndex:26];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_danisho.png"] atIndex:27];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_Å.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"English"]) {
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_+.png"] atIndex:26];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_$.png"] atIndex:27];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_,.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"Spanish"]) {
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_spanishN.png"] atIndex:26];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_+.png"] atIndex:27];
            [self.currentAlphabet insertObject:[C4Image imageNamed:@"letter_,.png"] atIndex:28];
        }
    } else{
        self.currentAlphabet=[NSMutableArray arrayWithObjects:
                              //first row
                              [C4Image imageNamed:@"letter_A.png"],
                              [C4Image imageNamed:@"letter_RusB.png"],
                              [C4Image imageNamed:@"letter_B.png"],
                              [C4Image imageNamed:@"letter_RusG.png"],
                              [C4Image imageNamed:@"letter_RusD.png"],
                              [C4Image imageNamed:@"letter_E.png"],
                              //second row
                              [C4Image imageNamed:@"letter_RusJo.png"],
                              [C4Image imageNamed:@"letter_RusSche.png"],
                              [C4Image imageNamed:@"letter_RusSe.png"],
                              [C4Image imageNamed:@"letter_RusI.png"],
                              [C4Image imageNamed:@"letter_RusIkratkoje.png"],
                              [C4Image imageNamed:@"letter_K.png"],
                              
                              [C4Image imageNamed:@"letter_RusL.png"],
                              [C4Image imageNamed:@"letter_M.png"],
                              [C4Image imageNamed:@"letter_RusN.png"],
                              [C4Image imageNamed:@"letter_O.png"],
                              [C4Image imageNamed:@"letter_RusP.png"],
                              [C4Image imageNamed:@"letter_P.png"],
                              
                              [C4Image imageNamed:@"letter_C.png"],
                              [C4Image imageNamed:@"letter_T.png"],
                              [C4Image imageNamed:@"letter_Y.png"],
                              [C4Image imageNamed:@"letter_RusF.png"],
                              [C4Image imageNamed:@"letter_X.png"],
                              [C4Image imageNamed:@"letter_RusZ.png"],
                              
                              [C4Image imageNamed:@"letter_RusTsche.png"],
                              [C4Image imageNamed:@"letter_RusScha.png"],
                              [C4Image imageNamed:@"letter_RusTschescha.png"],
                              [C4Image imageNamed:@"letter_RusMjachkiSnak.png"],
                              [C4Image imageNamed:@"letter_RusUi.png"],
                              [C4Image imageNamed:@"letter_RusE.png"],
                              
                              [C4Image imageNamed:@"letter_RusJu.png"],
                              [C4Image imageNamed:@"letter_RusJa.png"],
                              [C4Image imageNamed:@"letter_0.png"],
                              [C4Image imageNamed:@"letter_1.png"],
                              [C4Image imageNamed:@"letter_2.png"],
                              [C4Image imageNamed:@"letter_3.png"],
                              
                              [C4Image imageNamed:@"letter_4.png"],
                              [C4Image imageNamed:@"letter_5.png"],
                              [C4Image imageNamed:@"letter_6.png"],
                              [C4Image imageNamed:@"letter_7.png"],
                              [C4Image imageNamed:@"letter_8.png"],
                              [C4Image imageNamed:@"letter_9.png"],
                              nil];
    }
    self.finnish=[NSArray arrayWithObjects:@"A",@"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"Ä", @"Ö", @"Å", @".", @"!", @"?", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.german=[NSArray arrayWithObjects:@"A",@"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"Ä", @"Ö", @"Ü", @".", @"!", @"?", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.danish=[NSArray arrayWithObjects:@"A",@"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"ae", @"danisho", @"Å", @".", @"!", @"?", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.english=[NSArray arrayWithObjects:@"A",@"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"+", @"$", @",", @".", @"!", @"?", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.spanish=[NSArray arrayWithObjects:@"A",@"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"spanishN", @"+", @",", @".", @"!", @"?", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.russian=[NSArray arrayWithObjects:@"A", @"RusB", @"B", @"RusG", @"RusD", @"E", @"RusJo", @"RusSche", @"RusSe", @"RusI", @"RusIkratkoje", @"K", @"RusL", @"M", @"RusN", @"O", @"RusP", @"P", @"C", @"T", @"Y", @"RusF", @"X", @"RusZ", @"RusTsche", @"RusScha", @"RusTschescha", @"RusMjachkiSnak", @"RusUi", @"RusE", @"RusJu", @"RusJa", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",nil];
    
}
//--------------------------------------------------
//save alphabet when app becomes inactive
//--------------------------------------------------
-(void)appWillResignActive:(NSNotification*)note
{
    //save all images under alphabetName
    [self writeAlphabetsUserDefaults];
}
-(void)writeAlphabetsUserDefaults{
    NSUserDefaults *alphabetName=[NSUserDefaults standardUserDefaults];
    [alphabetName setValue:self.alphabetName forKey:@"alphabetName"];
    [alphabetName setValue:self.currentLanguage forKey:@"language"];
    [alphabetName setValue:self.myAlphabets forKey:@"myAlphabets"];
    [alphabetName setValue:self.myAlphabetsLanguages forKey:@"myAlphabetsLanguages"];
    [alphabetName synchronize];
}
-(void)appWillBecomeActive:(NSNotification*)note{
    NSString *loadedName;
    loadedName=[[NSUserDefaults standardUserDefaults] objectForKey:@"alphabetName"];
    if (!loadedName) {
        self.alphabetName=@"Untitled";
        //[self.myAlphabets addObject:self.alphabetName];
        [self.myAlphabetsLanguages addObject:self.currentLanguage];
        //set default alphabet name as first user default
        NSUserDefaults *alphabetName=[NSUserDefaults standardUserDefaults];
        [alphabetName setValue:self.alphabetName forKey:@"alphabetName"];
        [alphabetName synchronize];
    } else{
        self.alphabetName=loadedName;
    }
    
    NSString *loadedLanguage=[[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
    if (loadedLanguage) {
        self.currentLanguage=loadedLanguage;
    }
    NSMutableArray *alphabets=[[NSUserDefaults standardUserDefaults]objectForKey:@"myAlphabets"];
    if (alphabets) {
        self.myAlphabets=[alphabets mutableCopy];
    }  else{
        [self.myAlphabets addObject:self.alphabetName];
    }
    NSMutableArray *AlphabetsLanguages=[[NSUserDefaults standardUserDefaults]objectForKey:@"myAlphabetsLanguages"];
    if (AlphabetsLanguages) {
        self.myAlphabetsLanguages=[AlphabetsLanguages mutableCopy];
    }else{
        [self.myAlphabetsLanguages addObject:self.currentLanguage];
    }
    [self loadCorrectAlphabet];
    }
-(void)loadCorrectAlphabet{
    //load default alphabet (in case needed)
    [self loadDefaultAlphabet];
    //loading all letters
    NSString *path= [[self documentsDirectory] stringByAppendingString:@"/"];
    path=[path stringByAppendingPathComponent:self.alphabetName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSMutableArray *defaultAlphabet=[self.currentAlphabet mutableCopy];
        self.currentAlphabet=[[NSMutableArray alloc]init];
        for (int i=0; i<42; i++) {
            NSString *letterToAdd=@" ";
            if ([self.currentLanguage isEqualToString:@"Finnish/Swedish"]) {
                letterToAdd=[self.finnish objectAtIndex:i];
            }else if([self.currentLanguage isEqualToString:@"German"]){
                letterToAdd=[self.german objectAtIndex:i];
            }else if([self.currentLanguage isEqualToString:@"English"]){
                letterToAdd=[self.english objectAtIndex:i];
            }else if([self.currentLanguage isEqualToString:@"Danish/Norwegian"]){
                letterToAdd=[self.danish objectAtIndex:i];
            }else if([self.currentLanguage isEqualToString:@"Spanish"]){
                letterToAdd=[self.spanish objectAtIndex:i];
            }else if([self.currentLanguage isEqualToString:@"Russian"]){
                letterToAdd=[self.russian objectAtIndex:i];
            }
            
            NSString *filePath=[[path stringByAppendingPathComponent:letterToAdd] stringByAppendingString:@".jpg"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                UIImage *img = [UIImage imageWithData:imageData];
                loadedImage=[C4Image imageWithUIImage:img];
            }else{
                loadedImage=[C4Image imageWithImage:[defaultAlphabet objectAtIndex:i]];
            }
            [self.currentAlphabet addObject:loadedImage];
        }
    }

}

-(CGContextRef)createHighResImageContext { //setting up image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(currentImageToExport.width, currentImageToExport.height), YES, 5.0f);
    return UIGraphicsGetCurrentContext();
}
-(void)saveImage:(NSString *)fileName {
    UIImage  *image = UIGraphicsGetImageFromCurrentImageContext();
    //NSData *imageData = UIImagePNGRepresentation(image);
    NSData *imageData = UIImageJPEGRepresentation(image,80);
    //save in a certain folder
    NSString *dataPath = [[self documentsDirectory] stringByAppendingString:@"/"];
    dataPath=[dataPath stringByAppendingPathComponent:self.alphabetName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *savePath = [dataPath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:savePath atomically:YES];
}
-(NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
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
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //prepare next view and go there
    [self saveUserName];
    [self nextIntroPic];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 40){//140 characters are in the textView
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
    //NSLog(@"textViewDidChange:");
    //This method is called when the user makes a change to the text in the textview
}

@end
