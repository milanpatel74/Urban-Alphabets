//
//  AssignLetter.h
//  urbanAlphabetsIII
//
//  Created by Suse on 05/11/13.
//  Copyright (c) 2013 Suse. All rights reserved.
//

#import "C4CanvasController.h"
#import "SaveToDatabase.h"

#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageDestination.h>

@interface AssignLetter : C4CanvasController<NSURLConnectionDelegate, CLLocationManagerDelegate>{
    SaveToDatabase *save;
}
@property (readwrite, strong)  NSMutableArray *currentAlphabet;//the current alphabet > will be changed so should be accessible from outside for next screen
@property (readwrite) NSUInteger chosenImageNumberInArray;

-(void)setup:(C4Image*)croppedImagePassed withAlphabet:(NSMutableArray*)currentAlphabetPassed withGreyGrid: (NSMutableArray*)greyRectArray;
@end
