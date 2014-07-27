//
//  PostcardView.m
//  UrbanAlphabets
//
//  Created by Suse on 16/12/13.
//  Copyright (c) 2013 moi. All rights reserved.
//

#import "PostcardView.h"
#import "SaveToDatabase.h"
#import "PostcardMenu.h"
#import "Write Postcard.h"
#import "SharePostcard.h"
#import "C4WorkSpace.h"
#import "MyAlphabets.h"
#import "TakePhotoViewController.h"

@interface PostcardView (){
    SaveToDatabase *save;
    Write_Postcard *writePostcard;
    SharePostcard *sharePostcard;
    C4WorkSpace *workspace;
    MyAlphabets *myAlphabets;
    TakePhotoViewController *takePhoto;
    
    //saving image
    CGContextRef graphicsContext;
    //location when saving alphabet to server
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    float imageWidth;
    float imageHeight;
    float alphabetFromLeft;
    
    //enter username
    UIImageView *enterUsername;
    UITextView *userNameField;
    float yPosUsername;
}
@property (nonatomic) BottomNavBar *bottomNavBar;
@property (readwrite) NSMutableArray  *postcardArray, *greyRectArray;
@property (nonatomic) PostcardMenu *menu;
@end
@implementation PostcardView

-(void)setupWithPostcard: (NSMutableArray*)postcardPassed Rect: (NSMutableArray*)postcardRect withLanguage:(NSString*)language withPostcardText:(NSString*)postcardText{
    self.title=@"Postcard";
    //back button
    CGRect frame = CGRectMake(0, 0, 60,20);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:UA_BACK_BUTTON forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *leftButton =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem=leftButton;
    
    
    self.postcardArray=[[NSMutableArray alloc]init];
    self.postcardArray=[postcardPassed mutableCopy];
    self.greyRectArray=[[NSMutableArray alloc]init];
    self.greyRectArray=[postcardRect mutableCopy];
    self.currentLanguage=language;
    self.postcardText=postcardText;
    
    //bottomNavbar WITH 3 ICONS
    CGRect bottomBarFrame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-UA_BOTTOM_BAR_HEIGHT, [[UIScreen mainScreen] bounds].size.width, UA_BOTTOM_BAR_HEIGHT);
    self.bottomNavBar = [[BottomNavBar alloc] initWithFrame:bottomBarFrame leftIcon:UA_ICON_TAKE_PHOTO withFrame:CGRectMake(0, 0, 60, 30)  centerIcon:UA_ICON_MENU withFrame:CGRectMake(0, 0, 45, 45) rightIcon:UA_ICON_ALPHABET withFrame:CGRectMake(0, 0, 70, 35)];
    [self.view addSubview:self.bottomNavBar];
    UITapGestureRecognizer *photoButtonRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToTakePhoto)];
    photoButtonRecognizer.numberOfTapsRequired = 1;
    [self.bottomNavBar.leftImageView addGestureRecognizer:photoButtonRecognizer];
    UITapGestureRecognizer *menuButtonRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    menuButtonRecognizer.numberOfTapsRequired = 1;
    [self.bottomNavBar.centerImageView addGestureRecognizer:menuButtonRecognizer];
    UITapGestureRecognizer *alphabetButtonRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    alphabetButtonRecognizer.numberOfTapsRequired = 1;
    [self.bottomNavBar.rightImageView addGestureRecognizer:alphabetButtonRecognizer];
    
    imageWidth=UA_LETTER_IMG_WIDTH_5;
    imageHeight=UA_LETTER_IMG_HEIGHT_5;
    alphabetFromLeft=0;
    if ( UA_IPHONE_5_HEIGHT != [[UIScreen mainScreen] bounds].size.height) {
        ///if ( UA_IPHONE_5_HEIGHT == [[UIScreen mainScreen] bounds].size.height) {
        imageHeight=UA_LETTER_IMG_HEIGHT_4;
        imageWidth=UA_LETTER_IMG_WIDTH_4;
        alphabetFromLeft=UA_LETTER_SIDE_MARGIN_ALPHABETS;
    }
    
    //display the postcard
    for (int i=0; i<[self.postcardArray count]; i++) {
        float xMultiplier=(i)%6;
        float yMultiplier= (i)/6;
        float xPos=xMultiplier*imageWidth+alphabetFromLeft;
        float yPos=UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+yMultiplier*imageHeight;
        //image
        UIImageView *image=[self.postcardArray objectAtIndex:i ];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, imageWidth, imageHeight)];
        imageView.image=image.image;
        [self.view addSubview:imageView];
        //grey grid
        UIView *greyRect=[[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, imageWidth, imageHeight)];
        [greyRect setBackgroundColor:UA_NAV_CTRL_COLOR];
        greyRect.layer.borderColor=[UA_NAV_BAR_COLOR CGColor];
        greyRect.layer.borderWidth=1.0f;
        [self.view addSubview:greyRect];
    }
}
//------------------------------------------------------------------------
//NAVIGATION FUNCTIONS
//------------------------------------------------------------------------
-(void)goToTakePhoto{
    takePhoto=[[TakePhotoViewController alloc]initWithNibName:@"TakePhotoViewController" bundle:[NSBundle mainBundle]];
    [takePhoto setup];
    [self.navigationController pushViewController:takePhoto animated:YES];
}
-(void)openMenu{
    [self saveCurrentPostcardAsImage];
    CGRect menuFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.menu=[[PostcardMenu alloc]initWithFrame:menuFrame];
    [self.view addSubview:self.menu];
    //start location updating
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
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
    UITapGestureRecognizer *sharePostcardShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSharePostcard)];
    sharePostcardShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.sharePostcardShape addGestureRecognizer:sharePostcardShapeRecognizer];
    UITapGestureRecognizer *sharePostcardLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSharePostcard)];
    sharePostcardLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.sharePostcardLabel addGestureRecognizer:sharePostcardLabelRecognizer];
    UITapGestureRecognizer *sharePostcardIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSharePostcard)];
    sharePostcardIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.sharePostcardIcon addGestureRecognizer:sharePostcardIconRecognizer];
    
    
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
    UITapGestureRecognizer *savePostcardShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSavePostcard)];
    savePostcardShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.savePostcardShape addGestureRecognizer:savePostcardShapeRecognizer];
    UITapGestureRecognizer *savePostcardLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSavePostcard)];
    savePostcardLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.savePostcardLabel addGestureRecognizer:savePostcardLabelRecognizer];
    UITapGestureRecognizer *savePostcardIconRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSavePostcard)];
    savePostcardIconRecognizer.numberOfTapsRequired = 1;
    [self.menu.savePostcardIcon addGestureRecognizer:savePostcardIconRecognizer];
    
    //cancel
    UITapGestureRecognizer *cancelShapeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    cancelShapeRecognizer.numberOfTapsRequired = 1;
    [self.menu.cancelShape addGestureRecognizer:cancelShapeRecognizer];
    UITapGestureRecognizer *cancelLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    cancelLabelRecognizer.numberOfTapsRequired = 1;
    [self.menu.cancelLabel addGestureRecognizer:cancelLabelRecognizer];
    
}
-(void)closeMenu{
    [self.menu removeFromSuperview];
    [locationManager stopUpdatingLocation];
}
-(void)goToSavePostcard{
    self.menu.savePostcardShape.backgroundColor=UA_HIGHLIGHT_COLOR;
    [self.menu removeFromSuperview];
    [self closeMenu];
    [self saveCurrentPostcardAsImage];
    [self savePostcard];
}
-(void)goToWritePostcard{
    id obj = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    writePostcard=(Write_Postcard*)obj;
    [writePostcard clearPostcard];
    [self.navigationController popViewControllerAnimated:NO];
    [self closeMenu];
    
}
-(void)goToMyAlphabets{
    [self closeMenu];
    [self postcardToMyAlphabets];
    
}
-(void)postcardToMyAlphabets{
    id obj = [self.navigationController.viewControllers objectAtIndex:0];
    workspace=(C4WorkSpace*)obj;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [workspace goToMyAlphabets];
}
-(void)closeView{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
-(void)goToSharePostcard{
    [self savePostcard];
    sharePostcard=[[SharePostcard alloc]initWithNibName:@"SharePostcard" bundle:[NSBundle mainBundle]];
    [sharePostcard setup:self.currentPostcardImageAsUIImage];
    [self.navigationController pushViewController:sharePostcard animated:NO];
    [self closeMenu];
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:NO];
}
//------------------------------------------------------------------------
//SAVING IMAGE FUNCTIONS
//------------------------------------------------------------------------
-(void)savePostcard{
    id obj = [self.navigationController.viewControllers objectAtIndex:0];
    workspace=(C4WorkSpace*)obj;

    if ([workspace.userName isEqualToString:@"defaultUsername" ]) {
        //ask for new username
        enterUsername=[[UIImageView alloc]initWithFrame:CGRectMake(0,UA_TOP_BAR_HEIGHT+UA_TOP_WHITE, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-UA_TOP_BAR_HEIGHT-UA_TOP_WHITE)];
        if ( UA_IPHONE_5_HEIGHT != [[UIScreen mainScreen] bounds].size.height) {
            //iphone 4
            enterUsername.image=[UIImage imageNamed:@"intro_iphone43"];
            yPosUsername=-75;
        } else {
            enterUsername.image=[UIImage imageNamed:@"intro_iphone53"];
        }
        [self.view addSubview:enterUsername];
        //add text field
        CGRect textViewFrame = CGRectMake(60, 180+yPosUsername, [[UIScreen mainScreen] bounds].size.width-60-20, 25.0f);
        userNameField = [[UITextView alloc] initWithFrame:textViewFrame];
        userNameField.returnKeyType = UIReturnKeyDone;
        userNameField.layer.borderWidth=1.0f;
        userNameField.layer.borderColor=[UA_OVERLAY_COLOR CGColor];
        userNameField.backgroundColor=UA_NAV_CTRL_COLOR;
        [userNameField becomeFirstResponder];
        userNameField.delegate = self;
        [self.view addSubview:userNameField];
    } else{
        [self exportHighResImage];
    }
}
-(void)saveCurrentPostcardAsImage{
    double screenScale = [[UIScreen mainScreen] scale];
    CGImageRef imageRef = CGImageCreateWithImageInRect([[self createScreenshot] CGImage], CGRectMake(0, (UA_TOP_WHITE+UA_TOP_BAR_HEIGHT) * screenScale, [[UIScreen mainScreen] bounds].size.width * screenScale, ([[UIScreen mainScreen] bounds].size.height-(UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+UA_BOTTOM_BAR_HEIGHT))*screenScale));
    if ( UA_IPHONE_4_HEIGHT == [[UIScreen mainScreen] bounds].size.height) {
        //if ( UA_IPHONE_5_HEIGHT == [[UIScreen mainScreen] bounds].size.height) {
        imageRef = CGImageCreateWithImageInRect([[self createScreenshot] CGImage], CGRectMake(alphabetFromLeft*screenScale, (UA_TOP_WHITE+UA_TOP_BAR_HEIGHT) * screenScale, ([[UIScreen mainScreen] bounds].size.width-alphabetFromLeft*2) * screenScale, ([[UIScreen mainScreen] bounds].size.height-(UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+UA_BOTTOM_BAR_HEIGHT))*screenScale));
    }
    self.currentPostcardImage = [UIImage imageWithCGImage:imageRef];
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
    graphicsContext = [self createHighResImageContext];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-(UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+UA_BOTTOM_BAR_HEIGHT)), YES, 5.0f);    NSString *fileName = [NSString stringWithFormat:@"exportedPostcard%@.jpg", [NSDate date]];
    [self saveImage:fileName];
    [self saveImageToLibrary];
}
-(CGContextRef)createHighResImageContext { //setting up image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-(UA_TOP_WHITE+UA_TOP_BAR_HEIGHT+UA_BOTTOM_BAR_HEIGHT)), YES, 5.0f);
    return UIGraphicsGetCurrentContext();
}
-(void)saveImage:(NSString *)fileName {
    UIImage  *image = self.currentPostcardImage;
    self.currentPostcardImageAsUIImage=[image copy];
    NSData *imageData = UIImagePNGRepresentation(image);
    //--------------------------------------------------
    //getting username from main view
    //--------------------------------------------------
    id obj = [self.navigationController.viewControllers objectAtIndex:0];
    workspace=(C4WorkSpace*)obj;
    NSString *userName=workspace.userName;
    //--------------------------------------------------
    //upload image to database
    //--------------------------------------------------
    save=[[SaveToDatabase alloc]init];
    [save sendPostcardToDatabase:imageData withLanguage: self.currentLanguage withText: self.postcardText withLocation:currentLocation withUsername:userName];
    //--------------------------------------------------
    //save to documents directory
    //--------------------------------------------------
    NSString *dataPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/postcards"];
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
    UIImage *image = self.currentPostcardImage;
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    //write to photo library
    NSString *albumName=@"Urban Alphabets";
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block ALAssetsGroup* groupToAddTo;
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                   groupToAddTo = group;
                               }
                           }
                         failureBlock:^(NSError* error) {
                         }];
    CGImageRef img = [image CGImage];
    [library writeImageToSavedPhotosAlbum:img
                                 metadata:nil
                          completionBlock:^(NSURL* assetURL, NSError* error) {
                              if (error.code == 0) {
                                  
                                  // try to get the asset
                                  [library assetForURL:assetURL
                                           resultBlock:^(ALAsset *asset) {
                                               // assign the photo to the album
                                               [groupToAddTo addAsset:asset];
                                           }
                                          failureBlock:^(NSError* error) {
                                          }];
                              }
                              else {
                              }
                          }];
}

//------------------------------------------------------------------------
//LOCATION UPDATING
//------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    currentLocation = newLocation;
}
//------------------------------------------------------------------------
//STUFF TO HANDLE THE KEYBOARD INPUT
//------------------------------------------------------------------------
#pragma mark -
#pragma mark UITextViewDelegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView{
    /*--
     * This method is called when the textView becomes active, or is the First Responder
     --*/
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self saveUserName];
}
-(void)saveUserName{
    if ([userNameField.text isEqualToString: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                        message:@"Your username cannot be empty."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else{
        workspace.userName=userNameField.text;
        [workspace saveUsernameToUserDefaults];
        //and remove the username stuff
        [userNameField removeFromSuperview];
        [enterUsername removeFromSuperview];
        [self exportHighResImage];
    }
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
    NSString *lastChar= [NSString stringWithFormat:@"%c",[textView.text characterAtIndex: [textView.text length]-1]];
    if ([lastChar isEqualToString:@"ä"]||[lastChar isEqualToString:@"Ä"]||[lastChar isEqualToString:@"ö"]||[lastChar isEqualToString:@"Ö"]||[lastChar isEqualToString:@"ü"]||[lastChar isEqualToString:@"Ü"]||[lastChar isEqualToString:@"å"]||[lastChar isEqualToString:@"Å"]||[lastChar isEqualToString:@"!"]||[lastChar isEqualToString:@"?"]||[lastChar isEqualToString:@"ß"]||[lastChar isEqualToString:@"Ñ"]||[lastChar isEqualToString:@"ñ"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid user name"
                                                        message:@"Your username cannot include any of the following characters: Ä, Ö, Å, Ü, Ñ, !, ?, ß."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        textView.text=[textView.text substringToIndex:[textView.text length] - 1];
    }
    
}

@end
