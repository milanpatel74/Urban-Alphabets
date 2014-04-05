//
//  C4WorkSpace.m
//  Nav
//
//  Created by moi on 12/5/2013.
//

#import "C4Workspace.h"
#import <AVFoundation/AVFoundation.h>

#import "SaveToDatabase.h"
#import "C4WorkSpace.h"
#import "LetterView.h"
#import "Write Postcard.h"
#import "ShareAlphabet.h"
#import "MyAlphabets.h"
#import "AlphabetInfo.h"
#import "TakePhotoViewController.h"

@implementation C4WorkSpace {
    AlphabetInfo *alphabetInfo;
    C4WorkSpace *workspace;
    LetterView *letterView;
    Write_Postcard *writePostcard;
    SaveToDatabase *save;
    ShareAlphabet *shareAlphabet;
    MyAlphabets *myAlphabetsView;
    TakePhotoViewController *takePhoto;

    
   
        
    //saving image
    CGContextRef graphicsContext;
    UIImage *currentImageToExport;
    
    //for intro
    NSMutableArray *introPics;
    NSMutableArray *introPicsViews;
    UITextView *userNameField;
    int currentNoInIntro;
    UIImage *nextButton;
    UIImageView *nextButtonView;
    UILabel *webadress;
    
    //images loaded from documents directory
    UIImageView *loadedImage;
    
    UIImagePickerController *picker;
    float yPosIntro;
    
    
    float imageWidth;
    float imageHeight;
    float alphabetFromLeft;
    NSMutableArray *greyRectArray;
    
    //location when saving alphabet to server
    CLLocationManager *locationManager;
    CLLocation *currentLocation;

}




-(void)setup {
    

    //load the defaults
    self.currentLanguage= @"Finnish/Swedish";
    self.myAlphabets=[[NSMutableArray alloc]init];
    self.myAlphabetsLanguages=[[NSMutableArray alloc]init];
    self.alphabetName=@"Untitled";
    self.languages=[NSMutableArray arrayWithObjects:@"Danish/Norwegian", @"English", @"Finnish/Swedish", @"German", @"Russian", @"Spanish", nil];

    //to see when app becomes active/inactive
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

}
-(void)viewDidAppear:(BOOL)animated{
    self.title=self.alphabetName;
    self.userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if (self.userName==nil) {
        self.title=@"Intro";
        
        //check which device
        if ( UA_IPHONE_5_HEIGHT != [[UIScreen mainScreen] bounds].size.height) {
            yPosIntro=-88;
            introPics=[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"intro__1_iphone4"],[UIImage imageNamed:@"intro_3"],[UIImage imageNamed:@"intro__4_iphone4"],[UIImage imageNamed:@"intro_5"], nil];
        } else{
            yPosIntro=0;
            introPics=[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"intro_1_1.png"],[UIImage imageNamed:@"intro_3"],[UIImage imageNamed:@"intro_4"],[UIImage imageNamed:@"intro_5"], nil];
        }
        introPicsViews=[[NSMutableArray alloc]init];
        for (int i=0; i<[introPics count]; i++) {
            UIImageView *introView=[[UIImageView alloc]initWithFrame:CGRectMake(0,UA_TOP_BAR_HEIGHT+UA_TOP_WHITE, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width*1.57744)];
            introView.image=[introPics objectAtIndex:i];
            [introPicsViews addObject:introView];
        }
        currentNoInIntro=0;
        
        [self.view addSubview:[introPicsViews objectAtIndex:0]];
        
        
        
        nextButton=UA_ICON_NEXT;
        //nextButtonView=[[UIImageView alloc]initWithFrame:CGRectMake(self.canvas.width-nextButton.size.width-20, self.canvas.height-nextButton.size.height-20, 80, 34)];
        nextButtonView=[[UIImageView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-100, [[UIScreen mainScreen] bounds].size.height-100+yPosIntro, 80, 34)];
        nextButtonView.image=nextButton;
        [self.view addSubview:nextButtonView];
        nextButtonView.userInteractionEnabled=YES;
        //[self listenFor:@"touchesBegan" fromObject:nextButtonView andRunMethod:@"nextIntroPic"];
        UITapGestureRecognizer *nextButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextIntroPic)];
        nextButtonTap.numberOfTapsRequired = 1;
        [nextButtonView addGestureRecognizer:nextButtonTap];
    } else{
        //[self cameraSetup];
        [self alphabetSetup];
    }
    
}
-(void)nextIntroPic{
    //remove old
    UIImageView *image=[introPicsViews objectAtIndex:currentNoInIntro];
    
    [image removeFromSuperview];
    [nextButtonView removeFromSuperview];
    //[self stopListeningFor:@"touchesBegan" object:nextButton];
    if (currentNoInIntro==1) {
        [webadress removeFromSuperview];
    }
    //next number
    currentNoInIntro++;
    if (currentNoInIntro<[introPics count]) {
        //add next
        
        [self.view addSubview:[introPicsViews objectAtIndex:currentNoInIntro]];
        
        if (currentNoInIntro==1) {
            
            CGRect labelFrame = CGRectMake( 25, [[UIScreen mainScreen] bounds].size.height-150, 300, 30 );
            
            webadress=[[UILabel alloc] initWithFrame:labelFrame];
            [webadress setText:@"www.ualphabets.com"];
            [webadress setTextColor:UA_GREY_TYPE_COLOR];
           // webadress.origin=CGPointMake(25, [[UIScreen mainScreen] bounds].size.height-150);
            [self.view addSubview:webadress];
            
        }
        if (currentNoInIntro==2) {
            //add text field
            CGRect textViewFrame = CGRectMake(20, 200+yPosIntro, [[UIScreen mainScreen] bounds].size.width-2*20, 25.0f);
            userNameField = [[UITextView alloc] initWithFrame:textViewFrame];
            userNameField.returnKeyType = UIReturnKeyDone;
            userNameField.layer.borderWidth=1.0f;
            userNameField.layer.borderColor=[UA_OVERLAY_COLOR CGColor];
            [userNameField becomeFirstResponder];
            userNameField.delegate = self;
            [self.view addSubview:userNameField];
        }
        [self.view addSubview:nextButtonView];
        //[self listenFor:@"touchesBegan" fromObject:nextButtonView andRunMethod:@"nextIntroPic"];
    } else{
        self.title=self.alphabetName;
       // [self cameraSetup];
    }
    
}
-(void)alphabetSetup{
    //bottomNavbar WITH 2 ICONS
    CGRect bottomBarFrame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-UA_BOTTOM_BAR_HEIGHT, [[UIScreen mainScreen] bounds].size.width, UA_BOTTOM_BAR_HEIGHT);
    self.bottomNavBar = [[BottomNavBar alloc] initWithFrame:bottomBarFrame leftIcon:UA_ICON_TAKE_PHOTO withFrame:CGRectMake(0, 0, 60, 30)  centerIcon:UA_ICON_MENU withFrame:CGRectMake(0, 0, 45, 45)];
    [self.view addSubview:self.bottomNavBar];
    
    //make it touchable
    UITapGestureRecognizer *photoButtonRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToTakePhoto)];
    photoButtonRecognizer.numberOfTapsRequired = 1;
    [self.bottomNavBar.leftImageView addGestureRecognizer:photoButtonRecognizer];
    //[self listenFor:@"touchesBegan" fromObject:self.bottomNavBar.leftImage andRunMethod:@"goToTakePhoto"];
    
    //make it touchable
    UITapGestureRecognizer *menuButtonRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    menuButtonRecognizer.numberOfTapsRequired = 1;
    [self.bottomNavBar.centerImageView addGestureRecognizer:menuButtonRecognizer];
    //[self listenFor:@"touchesBegan" fromObject:self.bottomNavBar.centerImage andRunMethod:@"openMenu"];
    
    
    imageWidth=UA_LETTER_IMG_WIDTH_5;
    imageHeight=UA_LETTER_IMG_HEIGHT_5;
    alphabetFromLeft=0;
    if ( UA_IPHONE_5_HEIGHT != [[UIScreen mainScreen] bounds].size.height) {
        //if ( UA_IPHONE_5_HEIGHT == [[UIScreen mainScreen] bounds].size.height) {
        imageHeight=UA_LETTER_IMG_HEIGHT_4;
        imageWidth=UA_LETTER_IMG_WIDTH_4;
        alphabetFromLeft=UA_LETTER_SIDE_MARGIN_ALPHABETS;
    }
    [self drawCurrentAlphabet];
    [self initGreyGrid];
}
-(void)drawCurrentAlphabet{
    for (NSUInteger i=0; i<[self.currentAlphabet count]; i++) {
        float xMultiplier=(i)%6;
        float yMultiplier= (i)/6;
        float xPos=xMultiplier*imageWidth+alphabetFromLeft;
        float yPos=1+UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+yMultiplier*imageHeight;
        
        UIImageView *image=[self.currentAlphabet objectAtIndex:i ];
        image.frame=CGRectMake(xPos, yPos, imageWidth, imageHeight);
        [self.view addSubview:image];
    }
}
-(void)initGreyGrid{
    greyRectArray=[[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<42; i++) {
        float xMultiplier=(i)%6;
        float yMultiplier= (i)/6;
        float xPos=xMultiplier*imageWidth+alphabetFromLeft;
        float yPos=1+UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+yMultiplier*imageHeight;
        UIView *greyRect=[[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, imageWidth, imageHeight)];
        [greyRect setBackgroundColor:UA_NAV_CTRL_COLOR];
        
        greyRect.layer.borderColor=[UA_NAV_BAR_COLOR CGColor];
        greyRect.layer.borderWidth=1.0f;
        greyRect.userInteractionEnabled=YES;
        [greyRectArray addObject:greyRect];
        [self.view addSubview:greyRect];
        
        //make them touchable
        UITapGestureRecognizer *letterTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLetter:)];
        letterTapRecognizer.numberOfTapsRequired = 1;
        [greyRect addGestureRecognizer:letterTapRecognizer];
        //[self listenFor:@"touchesBegan" fromObject:greyRect andRunMethod:@"tappedLetter:"];
    }
}
//------------------------------------------------------------------------
//MENU
//------------------------------------------------------------------------
-(void)openMenu{
    //[self saveCurrentAlphabetAsImage];
    CGRect menuFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.menu=[[AlphabetMenu alloc]initWithFrame:menuFrame ];
    [self.view addSubview:self.menu];
    //start location updating
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    //all gesture recognizers
    //alphabet info
    UITapGestureRecognizer *alphabetInfoIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToAlphabetInfo)];
    alphabetInfoIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.alphabetInfoIcon addGestureRecognizer:alphabetInfoIconRecognizer];
    UITapGestureRecognizer *alphabetInfoShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToAlphabetInfo)];
    alphabetInfoShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.alphabetInfoShape addGestureRecognizer:alphabetInfoShapeRecognizer];
    UITapGestureRecognizer *alphabetInfoLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToAlphabetInfo)];
    alphabetInfoLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.alphabetInfoLabel addGestureRecognizer:alphabetInfoLabelRecognizer];
    
    //write postcard
    UITapGestureRecognizer *writePostcardShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToWritePostcard)];
    writePostcardShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.writePostcardShape addGestureRecognizer:writePostcardShapeRecognizer];
    UITapGestureRecognizer *writePostcardLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToWritePostcard)];
    writePostcardLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.writePostcardLabel addGestureRecognizer:writePostcardLabelRecognizer];
    UITapGestureRecognizer *writePostcardIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToWritePostcard)];
    writePostcardIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.writePostcardIcon addGestureRecognizer:writePostcardIconRecognizer];
    
    //share alphabet
    UITapGestureRecognizer *shareAlphabetShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToShareAlphabet)];
    shareAlphabetShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.shareAlphabetShape addGestureRecognizer:shareAlphabetShapeRecognizer];
    UITapGestureRecognizer *shareAlphabetLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToShareAlphabet)];
    shareAlphabetLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.shareAlphabetLabel addGestureRecognizer:shareAlphabetLabelRecognizer];
    UITapGestureRecognizer *shareAlphabetIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToShareAlphabet)];
    shareAlphabetIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.shareAlphabetIcon addGestureRecognizer:shareAlphabetIconRecognizer];
    
    
    //my alphabets
    UITapGestureRecognizer *myAlphabetsShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToMyAlphabets)];
    myAlphabetsShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.myAlphabetsShape addGestureRecognizer:myAlphabetsShapeRecognizer];
    UITapGestureRecognizer *myAlphabetsLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToMyAlphabets)];
    myAlphabetsLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.myAlphabetsLabel addGestureRecognizer:myAlphabetsLabelRecognizer];
    UITapGestureRecognizer *myAlphabetsIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToMyAlphabets)];
    myAlphabetsIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.myAlphabetsIcon addGestureRecognizer:myAlphabetsIconRecognizer];
    
    //saveAlphabet
    UITapGestureRecognizer *saveAlphabetShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSaveAlphabet)];
    saveAlphabetShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.saveAlphabetShape addGestureRecognizer:saveAlphabetShapeRecognizer];
    UITapGestureRecognizer *saveAlphabetLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSaveAlphabet)];
    saveAlphabetLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.saveAlphabetLabel addGestureRecognizer:saveAlphabetLabelRecognizer];
    UITapGestureRecognizer *saveAlphabetIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSaveAlphabet)];
    saveAlphabetIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.saveAlphabetIcon addGestureRecognizer:saveAlphabetIconRecognizer];
    
    //cancel
    UITapGestureRecognizer *cancelShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    cancelShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.cancelShape addGestureRecognizer:cancelShapeRecognizer];
    UITapGestureRecognizer *cancelLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    cancelLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.cancelLabel addGestureRecognizer:cancelLabelRecognizer];
    
}
-(void)closeMenu{
    //stop location updating
    [locationManager stopUpdatingLocation];
    [self.menu removeFromSuperview];
}

//------------------------------------------------------------------------
//NAVIGATION FUNCTIONS
//------------------------------------------------------------------------
-(void)goToTakePhoto{
    takePhoto=[[TakePhotoViewController alloc]initWithNibName:@"TakePhotoViewController" bundle:[NSBundle mainBundle]];
    [takePhoto setup];
    [self.navigationController pushViewController:takePhoto animated:YES];
}
-(void)goToSaveAlphabet{
    [self closeMenu];
    [self saveCurrentAlphabetAsImage];
    
    [self saveAlphabet];
}
-(void)goToWritePostcard{
    [self closeMenu];
    writePostcard=[[Write_Postcard alloc] initWithNibName:@"Write Postcard" bundle:[NSBundle mainBundle]];
    //NSLog(@"postcardLength: %lu", (unsigned long)[self.currentAlphabet count]);
    [writePostcard setupWithLanguage:self.currentLanguage Alphabet:self.currentAlphabet];
    [self.navigationController pushViewController:writePostcard animated:YES];
    
}
-(void)goToAlphabetInfo{
    //--------------------------------------------------
    //prepare alphabetInfo
    //--------------------------------------------------
    alphabetInfo=[[AlphabetInfo alloc]initWithNibName:@"AlphabetInfo" bundle:[NSBundle mainBundle]];
    [alphabetInfo setup];
    [self.navigationController pushViewController:alphabetInfo animated:YES];
    [alphabetInfo grabCurrentLanguageViaNavigationController ];
    [self closeMenu];
}
-(void)tappedLetter:(UIGestureRecognizer *)notification {
    UIView *currentImage = (UIView *)notification.view;
    
    float i=(currentImage.frame.origin.x-alphabetFromLeft)/imageWidth;
    float j=currentImage.frame.origin.y/imageHeight;
    int j1=j+1;
    if ( UA_IPHONE_5_HEIGHT != [[UIScreen mainScreen] bounds].size.height) {
        //if ( UA_IPHONE_5_HEIGHT == [[UIScreen mainScreen] bounds].size.height) {
        j1=floor(j);
    }
    self.letterTouched=((j1-1)*6)+i;
    [self openLetterView];
}
-(void)openLetterView{
    letterView=[[LetterView alloc] initWithNibName:@"LetterView" bundle:[NSBundle mainBundle]];
    [letterView setupWithLetterNo: self.letterTouched currentAlphabet:self.currentAlphabet];
    [self.navigationController pushViewController:letterView animated:YES];
}
-(void)goToShareAlphabet{
    //get the current alphabet as a photo
    [self closeMenu];
    shareAlphabet=[[ShareAlphabet alloc]initWithNibName:@"ShareAlphabet" bundle:[NSBundle mainBundle]];
    [shareAlphabet setup: self.currentAlphabetImageAsUIImage];
    [self.navigationController pushViewController:shareAlphabet animated:YES];
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)goToMyAlphabets{
    [self closeMenu];
    myAlphabetsView=[[MyAlphabets alloc] initWithNibName:@"MyAlphabets" bundle:[NSBundle mainBundle]];
    [myAlphabetsView setup];
    [self.navigationController pushViewController:myAlphabetsView animated:NO];
    [myAlphabetsView grabCurrentLanguageViaNavigationController];
}
//------------------------------------------------------------------------
//SAVING IMAGE FUNCTIONS
//------------------------------------------------------------------------
//------------------------------------------------------------------------
-(void)saveAlphabet{
    [self exportHighResImage];
}

-(void)saveCurrentAlphabetAsImage{
    double screenScale = [[UIScreen mainScreen] scale];
    CGImageRef imageRef = CGImageCreateWithImageInRect([[self createScreenshot] CGImage], CGRectMake(0, (UA_TOP_WHITE+UA_TOP_BAR_HEIGHT) * screenScale, [[UIScreen mainScreen] bounds].size.width * screenScale, ([[UIScreen mainScreen] bounds].size.height-(UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+UA_BOTTOM_BAR_HEIGHT))*screenScale));
    self.currentAlphabetImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
}

- (UIImage *)createScreenshot
{
    //    UIGraphicsBeginImageContext(pageSize);
    CGSize pageSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    UIGraphicsBeginImageContextWithOptions(pageSize, YES, 0.0f);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)exportHighResImage {
    NSString *fileName = [NSString stringWithFormat:@"exportedAlphabet%@.jpg", [NSDate date]];
    [self saveImage:fileName];
    [self saveImageToLibrary];
}
-(CGContextRef)createHighResImageContext { //setting up image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-(UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+UA_BOTTOM_BAR_HEIGHT)), YES, 5.0f);
    return UIGraphicsGetCurrentContext();
}
-(void)saveImage:(NSString *)fileName {
    UIImage  *image = self.currentAlphabetImage;
    self.currentAlphabetImageAsUIImage=[image copy];
    NSData *imageData = UIImagePNGRepresentation(image);
    //--------------------------------------------------
    //upload image to database
    //--------------------------------------------------
    save=[[SaveToDatabase alloc]init];
    [save sendAlphabetToDatabase:imageData withLanguage: self.currentLanguage withLocation:currentLocation withUsername:self.userName];
    //--------------------------------------------------
    //save to documents directory
    //--------------------------------------------------
    NSString *dataPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/alphabets"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *savePath = [dataPath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:savePath atomically:YES];
}
-(NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}
-(void)saveImageToLibrary {
    UIImage *image = self.currentAlphabetImageAsUIImage;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}


//-----------------------------------------------------------

-(void)saveUserName{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.userName=userNameField.text;
    [defaults setValue:self.userName forKey:@"userName"];
    [defaults synchronize];
    //and remove the username stuff
    [userNameField removeFromSuperview];
}
//--------------------------------------------------
//load default alphabet
//--------------------------------------------------
-(void)loadDefaultAlphabet{
    if ([self.currentLanguage isEqualToString:@"Finnish/Swedish"] ||[self.currentLanguage isEqualToString:@"German"]||[self.currentLanguage isEqualToString:@"Danish/Norwegian"]||[self.currentLanguage isEqualToString:@"English"]||[self.currentLanguage isEqualToString:@"Spanish"]) {
        self.currentAlphabetUIImage=[NSMutableArray arrayWithObjects:
                              //first row
                              [UIImage imageNamed:@"letter_A.png"],
                              [UIImage imageNamed:@"letter_B.png"],
                              [UIImage imageNamed:@"letter_C.png"],
                              [UIImage imageNamed:@"letter_D.png"],
                              [UIImage imageNamed:@"letter_E.png"],
                              [UIImage imageNamed:@"letter_F.png"],
                              //second row
                              [UIImage imageNamed:@"letter_G.png"],
                              [UIImage imageNamed:@"letter_H.png"],
                              [UIImage imageNamed:@"letter_I.png"],
                              [UIImage imageNamed:@"letter_J.png"],
                              [UIImage imageNamed:@"letter_K.png"],
                              [UIImage imageNamed:@"letter_L.png"],
                              
                              [UIImage imageNamed:@"letter_M.png"],
                              [UIImage imageNamed:@"letter_N.png"],
                              [UIImage imageNamed:@"letter_O.png"],
                              [UIImage imageNamed:@"letter_P.png"],
                              [UIImage imageNamed:@"letter_Q.png"],
                              [UIImage imageNamed:@"letter_R.png"],
                              
                              [UIImage imageNamed:@"letter_S.png"],
                              [UIImage imageNamed:@"letter_T.png"],
                              [UIImage imageNamed:@"letter_U.png"],
                              [UIImage imageNamed:@"letter_V.png"],
                              [UIImage imageNamed:@"letter_W.png"],
                              [UIImage imageNamed:@"letter_X.png"],
                              
                              [UIImage imageNamed:@"letter_Y.png"],
                              [UIImage imageNamed:@"letter_Z.png"],
                              //here the special characters will be inserted
                              [UIImage imageNamed:@"letter_.png"],//.
                              
                              [UIImage imageNamed:@"letter_!.png"],
                              [UIImage imageNamed:@"letter_-.png"],//?
                              [UIImage imageNamed:@"letter_0.png"],
                              [UIImage imageNamed:@"letter_1.png"],
                              [UIImage imageNamed:@"letter_2.png"],
                              [UIImage imageNamed:@"letter_3.png"],
                              
                              [UIImage imageNamed:@"letter_4.png"],
                              [UIImage imageNamed:@"letter_5.png"],
                              [UIImage imageNamed:@"letter_6.png"],
                              [UIImage imageNamed:@"letter_7.png"],
                              [UIImage imageNamed:@"letter_8.png"],
                              [UIImage imageNamed:@"letter_9.png"],
                              nil];
        if ([self.currentLanguage isEqualToString:@"Finnish/Swedish"]) {
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Ä.png"] atIndex:26];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Ö.png"] atIndex:27];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Å.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"German"]) {
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Ä.png"] atIndex:26];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Ö.png"] atIndex:27];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Ü.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"Danish/Norwegian"]) {
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_ae.png"] atIndex:26];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_danisho.png"] atIndex:27];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_Å.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"English"]) {
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_+.png"] atIndex:26];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_$.png"] atIndex:27];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_,.png"] atIndex:28];
        }
        if ([self.currentLanguage isEqualToString:@"Spanish"]) {
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_spanishN.png"] atIndex:26];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_+.png"] atIndex:27];
            [self.currentAlphabetUIImage insertObject:[UIImage imageNamed:@"letter_,.png"] atIndex:28];
        }
    } else{
        self.currentAlphabetUIImage=[NSMutableArray arrayWithObjects:
                              //first row
                              [UIImage imageNamed:@"letter_A.png"],
                              [UIImage imageNamed:@"letter_RusB.png"],
                              [UIImage imageNamed:@"letter_B.png"],
                              [UIImage imageNamed:@"letter_RusG.png"],
                              [UIImage imageNamed:@"letter_RusD.png"],
                              [UIImage imageNamed:@"letter_E.png"],
                              //second row
                              [UIImage imageNamed:@"letter_RusJo.png"],
                              [UIImage imageNamed:@"letter_RusSche.png"],
                              [UIImage imageNamed:@"letter_RusSe.png"],
                              [UIImage imageNamed:@"letter_RusI.png"],
                              [UIImage imageNamed:@"letter_RusIkratkoje.png"],
                              [UIImage imageNamed:@"letter_K.png"],
                              
                              [UIImage imageNamed:@"letter_RusL.png"],
                              [UIImage imageNamed:@"letter_M.png"],
                              [UIImage imageNamed:@"letter_RusN.png"],
                              [UIImage imageNamed:@"letter_O.png"],
                              [UIImage imageNamed:@"letter_RusP.png"],
                              [UIImage imageNamed:@"letter_P.png"],
                              
                              [UIImage imageNamed:@"letter_C.png"],
                              [UIImage imageNamed:@"letter_T.png"],
                              [UIImage imageNamed:@"letter_Y.png"],
                              [UIImage imageNamed:@"letter_RusF.png"],
                              [UIImage imageNamed:@"letter_X.png"],
                              [UIImage imageNamed:@"letter_RusZ.png"],
                              
                              [UIImage imageNamed:@"letter_RusTsche.png"],
                              [UIImage imageNamed:@"letter_RusScha.png"],
                              [UIImage imageNamed:@"letter_RusTschescha.png"],
                              [UIImage imageNamed:@"letter_RusMjachkiSnak.png"],
                              [UIImage imageNamed:@"letter_RusUi.png"],
                              [UIImage imageNamed:@"letter_RusE.png"],
                              
                              [UIImage imageNamed:@"letter_RusJu.png"],
                              [UIImage imageNamed:@"letter_RusJa.png"],
                              [UIImage imageNamed:@"letter_0.png"],
                              [UIImage imageNamed:@"letter_1.png"],
                              [UIImage imageNamed:@"letter_2.png"],
                              [UIImage imageNamed:@"letter_3.png"],
                              
                              [UIImage imageNamed:@"letter_4.png"],
                              [UIImage imageNamed:@"letter_5.png"],
                              [UIImage imageNamed:@"letter_6.png"],
                              [UIImage imageNamed:@"letter_7.png"],
                              [UIImage imageNamed:@"letter_8.png"],
                              [UIImage imageNamed:@"letter_9.png"],
                              nil];
    }
    self.currentAlphabet=[[NSMutableArray alloc]init];
    for (int i=0; i<[self.currentAlphabetUIImage count]; i++) {
        [self.currentAlphabet addObject:[[UIImageView alloc]initWithImage:[self.currentAlphabetUIImage objectAtIndex:i]]];
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
                UIImageView *imgView=[[UIImageView alloc]initWithImage:img];
                loadedImage=imgView;
            }else{
                loadedImage=[defaultAlphabet objectAtIndex:i];
            }
            [self.currentAlphabet addObject:loadedImage];
        }
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
    //This method is called when the user makes a change to the text in the textview
}

@end
