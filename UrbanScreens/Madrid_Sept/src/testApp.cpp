#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    //base setup
    ofSetFrameRate(FRAME_RATE);
    ofBackground(100);
	ofTrueTypeFont::setGlobalDpi(72);
    ofRegisterURLNotification(this);
    
    //screen
    screenWidth=192;
    screenHeight=157;
    screenFull=32;
    
    //testing
    overlay.loadImage("intro/overlay.png");
    
    //
    recentPostcards="http://www.ualphabets.com/requests/Madrid/postcards.php";
    recentLetters="http://www.ualphabets.com/requests/Madrid/letters.php";
    currentAlphabet="http://www.ualphabets.com/requests/Madrid/alphabet.php";
 
    info="Info";
    
    //setup of the URLS that need to be loaded
    URLsToLoad[0]=info;
    URLsToLoad[1]=recentPostcards;
    URLsToLoad[2]=recentLetters;
    URLsToLoad[3]=recentPostcards;
    URLsToLoad[4]=currentAlphabet;
    URLsToLoad[5]=recentPostcards;
    
    currentURLNo=0; //first screen to be shown
    currentURL=URLsToLoad[currentURLNo];
    loading= true; //send the first request on start alphabets/postcards/...
    
   
    //setup for intro screens before actual
    loadingResponseDone=false;
    blendInfo=0;
    introLength=4;
    
    //setup for alphabet screen
    counterDrawAlphabet=0;
    alphabetLength=10;
    alphabetTitle.loadImage("intro/intro_currentAlphabet.png");
    
    //setup for postcards and letters screen
    lengthPostcards=8;//in secs
    lengthLetters=10;//in secs
    counterPostcardsAndLetters=0;
    counterNumberPostcards=0;
    lettersTitle.loadImage("intro/intro_titleLetters.png");
    
    postcardsTitle.loadImage("intro/intro_titlePostcards.png");

    
    //the German alphabet
    alphabet[0]="A";
    alphabet[1]="B";
    alphabet[2]="C";
    alphabet[3]="D";
    alphabet[4]="E";
    alphabet[5]="F";
    alphabet[6]="G";
    alphabet[7]="H";
    alphabet[8]="I";
    alphabet[9]="J";
    alphabet[10]="K";
    alphabet[11]="L";
    alphabet[12]="M";
    alphabet[13]="N";
    alphabet[14]="O";
    alphabet[15]="P";
    alphabet[16]="Q";
    alphabet[17]="R";
    alphabet[18]="S";
    alphabet[19]="T";
    alphabet[20]="U";
    alphabet[21]="V";
    alphabet[22]="W";
    alphabet[23]="X";
    alphabet[24]="Y";
    alphabet[25]="Z";
    alphabet[26]="NN";
    alphabet[27]=" ";
    alphabet[28]=",";
    alphabet[29]=".";
    alphabet[30]="!";
    alphabet[31]="?";
    alphabet[32]="0";
    alphabet[33]="1";
    alphabet[34]="2";
    alphabet[35]="3";
    alphabet[36]="4";
    alphabet[37]="5";
    alphabet[38]="6";
    alphabet[39]="7";
    alphabet[40]="8";
    alphabet[41]="9";
    
    
    //send the first request
    if (currentURL!="Info") {
        printf("now \n");
        int id = ofLoadURLAsync(currentURL, "async_req");
    } else {
        printf("%s", currentURL.c_str());
        loadingResponseDone=true;
    }
        
}

//--------------------------------------------------------------
void testApp::update(){
    //update screens
    if (loading==false) {
        if (currentURL==recentPostcards) {
            updatePostcards();
        } else if(currentURL==recentLetters){
            updateLetters();
        } else if(currentURL==currentAlphabet){
            updateAlphabet();
        } else if(currentURL==info){
            about.update();
            //send the request to the next screen
            if (about.counter==20){
                goToNextScreen();
            }
            if (about.over) {
                about.reset();
                //now go to that screen
                currentURL=URLsToLoad[currentURLNo];
                printf("next screen :%s\n", currentURL.c_str());
            }
        }
    }
}


//--------------------------------------------------------------
void testApp::draw(){
    ofPushMatrix();
    ofTranslate(40, 40);
    ofSetColor(0);
    ofRect(0, 0, screenWidth, screenHeight);
    ofSetColor(0);
    
    
    
    //start drawing
    if (loadingResponseDone) {
        loading=false;
        loadingResponseDone=false;
    }
    
    //the actual screens
    if(loading==false){
        //printf("currentURL: %s, recentPostcards: %s \n", currentURL.c_str(), recentPostcards.c_str());
        if(currentURL==recentPostcards){
            drawPostcards();
        }else if (currentURL==recentLetters){
            drawLetters();
        } else if(currentURL==currentAlphabet){
            drawAlphabet();
        } else if(currentURL==info){
            about.draw();
        }
    }
    ofPopMatrix();
}


//--------------------------------------------------------------
void testApp::keyPressed(int key){
    
}



//--------------------------------------------------------------
//http request and ordering
//--------------------------------------------------------------

void testApp::urlResponse(ofHttpResponse & response){
    printf("  received response\n");
    loadingResponseDone=true;
    theResponse=ofToString(response.data);
    ofStringReplace(theResponse, "[{", "");
    ofStringReplace(theResponse, "}]", "");
    //printf("%s", theResponse.c_str());
    
    allEntries=ofSplitString(theResponse, "},{");
    //printf("\nURLs to load: %s\n", URLsToLoad[currentURLNo].c_str());
    //printf(" all Entries size %lu \n", allEntries.size());
    if (URLsToLoad[currentURLNo]==recentPostcards){
        loadURL_recentPostcards(response);
    } else if (URLsToLoad[currentURLNo]==recentLetters){
        loadURL_recentLetters(response);
    } else if(URLsToLoad[currentURLNo]==currentAlphabet){
        loadURL_alphabet(response);
    }

}
void testApp::loadURL_recentPostcards(ofHttpResponse &response){
    if (allEntries.size()>1) {
        for(int i=0; i<allEntries.size(); i++){
            vector<string> cutEntries =ofSplitString(allEntries[i], ",");
            /*for (int i=0; i<cutEntries.size(); i++) {
                printf("%s\n", cutEntries[i].c_str());
            }*/
            //delete the first parts in all of them
            ofStringReplace(cutEntries[0], "\"ID\":\"", "");
            ofStringReplace(cutEntries[1], "\"longitude\":\"", "");
            ofStringReplace(cutEntries[2], "\"latitude\":\"", "");
            ofStringReplace(cutEntries[3], "\"postcardText\":\"", "");
            ofStringReplace(cutEntries[4], "\"owner\":\"", "");
            //delete the last " in all of them
            ofStringReplace(cutEntries[0], "\"", "");
            ofStringReplace(cutEntries[1], "\"", "");
            ofStringReplace(cutEntries[2], "\"", "");
            ofStringReplace(cutEntries[3], "\"", "");
            ofStringReplace(cutEntries[4], "\"", "");
            //printf("cutEntries0=%s", cutEntries[0].c_str());
            Postcard entry(cutEntries[0], cutEntries[1], cutEntries[2],cutEntries[3],cutEntries[4]);
            
            if(allPostcards.size()<5){
                allPostcards.push_back(entry);
                allPostcards[allPostcards.size()-1].loadImage();
            } else{
                for (int i=0; i<allPostcards.size(); i++) {
                    /*printf("allPostcardssize-1: %i", (int)allPostcardsBerlin.size()-1);
                     printf("i: %i", i);
                     printf("entry id: %i  ", entry._id);
                     printf("postcard id: %i\n", allPostcards[i]._id);*/
                    if (entry._id==allPostcards[i]._id) {
                        break;
                    }
                    if (i==allPostcards.size()-1) {
                        allPostcards.insert(allPostcards.begin(),entry);
                        allPostcards[0].loadImage();
                        allPostcards.pop_back();
                        break;
                    }
                }
            }
        }
    }
    
    //just for testing
    //printf("allPostcards size %lu \n", allPostcards.size());
    /*for (int i=0; i<allPostcardsBerlin.size(); i++) {
     allPostcardsBerlin[i].print();
     }*/
    if (response.status==200 && response.request.name=="async_req") {
        //setup which ones are shown first
        currImgNo=allPostcards.size()-1;
    } else{
        //printf("not loaded \n");
        
    }

}
void testApp::loadURL_recentLetters(ofHttpResponse &response){
    for (int i=0; i<allEntries.size(); i++) {
        vector<string> cutEntries=ofSplitString(allEntries[i], ",");
        //delete the first parts in all of them
        ofStringReplace(cutEntries[0], "\"ID\":\"", "");
        ofStringReplace(cutEntries[1], "\"letter\":\"", "");
        ofStringReplace(cutEntries[2], "\"owner\":\"", "");
        //delete the last " in all of them
        ofStringReplace(cutEntries[0], "\"", "");
        ofStringReplace(cutEntries[1], "\"", "");
        ofStringReplace(cutEntries[2], "\"", "");
        Letter entry(cutEntries[0], cutEntries[1], cutEntries[2], i);
        if(allLetters.size()<5){
            allLetters.push_back(entry);
            allLetters[allLetters.size()-1].loadImage();
        } else{
            for (int i=0; i<allLetters.size(); i++) {
                /*printf("allPostcardsBerlinsize-1: %i", (int)allPostcardsBerlin.size()-1);
                 printf("i: %i", i);
                 printf("entry id: %i  ", entry._id);
                 printf("postcard id: %i\n", allPostcardsBerlin[i]._id);*/
                if (entry._id==allLetters[i]._id) {
                    break;
                }
                if (i==allLetters.size()-1) {
                    allLetters.insert(allLetters.begin(),entry);
                    allLetters[0].loadImage();
                    allLetters.pop_back();
                    break;
                }
            }
        }
    }
    if (response.status==200 && response.request.name=="async_req") {
        //setup which ones are shown first
        currLetterImgNo1=allLetters.size()-1;
        currLetterImgNo2=allLetters.size()-2;
        currLetterImgNo3=allLetters.size()-3;
        currLetterImgNo4=allLetters.size()-4;
        currLetterImgNo5=allLetters.size()-5;
    }
}
void testApp::loadURL_alphabet(ofHttpResponse &response){
    newAlphabet.clear();
    int numberOfLettersAdded=0;
    vector<AlphabetEntry> allLetters;
    for (int i=0; i<allEntries.size(); i++) {
        ofStringReplace(allEntries[i], "letter\":\"", "");
        vector<string> cutEntries =ofSplitString(allEntries[i], "\",\"");
        //delete the first parts in all of them
        ofStringReplace(cutEntries[0], "\"ID\":\"","");
        ofStringReplace(cutEntries[0], "\"", "");
        ofStringReplace(cutEntries[1], "\"", "");
        string letter=cutEntries[1];
        if (i>1) {
            if (allLetters[numberOfLettersAdded-1]._letter!=letter) {
                AlphabetEntry entry(cutEntries[0], cutEntries[1], numberOfLettersAdded);
                allLetters.push_back(entry);
                numberOfLettersAdded++;
            }
        } else{
            AlphabetEntry entry(cutEntries[0], cutEntries[1], i);
            allLetters.push_back(entry);
            numberOfLettersAdded++;
        }
    }
    //printf("number of Letters received: %i\n", numberOfLettersAdded);
    
    for (int j=0; j<42; j++) {
        //go through all letters we have
        for (int i=0; i<allLetters.size(); i++){
            if (allLetters[i]._letter==alphabet[j]) {
                AlphabetEntry entry(ofToString(allLetters[i]._id), allLetters[i]._letter, j);
                newAlphabet.push_back(entry);
                break;
            } else if (i==allLetters.size()-1){
                AlphabetEntry entry("0000", alphabet[j], j);
                newAlphabet.push_back(entry);
                break;
            }
        }
    }
    //if first time load > put the letters directly into the alphabet
    if (allAlphabet.size()<1) {
        for (int j=0; j<newAlphabet.size(); j++) {
            allAlphabet.push_back(newAlphabet[j]);
            if (allAlphabet[j]._id!=0) {
                allAlphabet[j].loadImage();
            }else{
                //load letter from image directory
                allAlphabet[j].loadImageDirectory();
            }

        }
    }else{//if there is already something in the alphabet
        for (int j=0; j<42; j++) {
            if (allAlphabet[j]._id!=newAlphabet[j]._id) {
                allAlphabet[j]=newAlphabet[j];
                allAlphabet.push_back(newAlphabet[j]);
                if (allAlphabet[j]._id!=0) {
                    allAlphabet[j].loadImage();
                }else{
                    //load letter from image directory
                    allAlphabet[j].loadImageDirectory();
                }

            }else{
                allAlphabet[j].reset();
            }
        }
    }
    if (response.status==200 && response.request.name=="async_req") {
        currImgNo1=0;
        currImgNo2=1;
        currImgNo3=2;
        currImgNo4=3;
        currImgNo5=4;
    }
}

//--------------------------------------------------------------
//next screen
//--------------------------------------------------------------
void testApp::goToNextScreen(){
    currentURLNo++;
    if (currentURLNo>=LENGTH_OF_URL_ARRAY) {
        currentURLNo=0;
    }
    sendRequest();
}
//--------------------------------------------------------------
void testApp::sendRequest(){
    if (URLsToLoad[currentURLNo]!="Info") {
        string requestURL=URLsToLoad[currentURLNo];
        int id = ofLoadURLAsync(requestURL, "async_req");
        printf("sending request to %s\n", requestURL.c_str());
    }else{
        loadingResponseDone=true;
        printf("%s", URLsToLoad[currentURLNo].c_str());
    }
}
//--------------------------------------------------------------
//updating
//--------------------------------------------------------------
void testApp::updatePostcards(){
    int noOfPostcards=(int)allPostcards.size();
    counterPostcardsAndLetters++;
    counterNumberPostcards++;
    if (currentURL==recentPostcards && counterNumberPostcards>lengthPostcards*FRAME_RATE*4 && noOfPostcards>3) {
        currImgNo=4;
        if (counterNumberPostcards==lengthPostcards*FRAME_RATE*5) {
            counterPostcardsAndLetters=0;
            blendInfo=0;
        }
    }else if (currentURL==recentPostcards && counterNumberPostcards>lengthPostcards*FRAME_RATE*3 && noOfPostcards>3) {
        currImgNo=3;
        if (counterNumberPostcards==lengthPostcards*FRAME_RATE*4) {
            counterPostcardsAndLetters=0;
            blendInfo=0;
        }
    }else if (currentURL==recentPostcards && counterNumberPostcards>lengthPostcards*FRAME_RATE*2 && noOfPostcards>2) {
        currImgNo=2;
        if (counterNumberPostcards==lengthPostcards*FRAME_RATE*3) {
            counterPostcardsAndLetters=0;
            blendInfo=0;
        }
    }else if (currentURL==recentPostcards && counterNumberPostcards>lengthPostcards*FRAME_RATE && noOfPostcards>1) {
        currImgNo=1;
        if (counterNumberPostcards==lengthPostcards*FRAME_RATE*2) {
            counterPostcardsAndLetters=0;
            blendInfo=0;
        }
    } else{
        currImgNo=0;
        if (counterNumberPostcards==lengthPostcards*FRAME_RATE) {
            counterPostcardsAndLetters=0;
            blendInfo=0;
        }
    }
    
    //send request for next thing
    int changeToNextNumber=lengthPostcards*FRAME_RATE*(noOfPostcards-0.8);
    if (counterNumberPostcards==changeToNextNumber) {
        goToNextScreen();
    }
    //determining when this is over
    if (currentURL==recentPostcards && currImgNo==noOfPostcards-1 && counterNumberPostcards>lengthPostcards*FRAME_RATE*(noOfPostcards)) {
        counterPostcardsAndLetters=0;
        counterNumberPostcards=0;
        currImgNo=0;
        blendInfo=0;
        //loading=true;
        
        //now go to that screen
        currentURL=URLsToLoad[currentURLNo];
        printf("next screen :%s\n", currentURL.c_str());
        
    }
}
void testApp::updateLetters(){
    counterPostcardsAndLetters++;
    
    //send request for next thing
    if (counterPostcardsAndLetters==FRAME_RATE) {
        goToNextScreen();
    }
    //determining when it is over
    if (currentURL==recentLetters && counterPostcardsAndLetters>lengthLetters*FRAME_RATE) {
        counterPostcardsAndLetters=0;
        blendInfo=0;
        
        //now go to that screen
        currentURL=URLsToLoad[currentURLNo];
        printf("next screen :%s\n", currentURL.c_str());
    }
}
void testApp::updateAlphabet(){
    counterDrawAlphabet++;
    //start updating for the individual letters only
    if(counterDrawAlphabet>FRAME_RATE*alphabetLength){
        
        if(counterDrawAlphabet>FRAME_RATE*alphabetLength){
            if (allAlphabet[currImgNo1].nextImage()) {
                currImgNo1+=5;
                if(currImgNo1>allAlphabet.size()-1){
                    currImgNo1=currImgNo1-allAlphabet.size();
                }
            }
            if (allAlphabet[currImgNo2].nextImage()) {
                currImgNo2+=5;
                if(currImgNo2>allAlphabet.size()-1){
                    currImgNo2=currImgNo2-allAlphabet.size();
                }
            }
            if (allAlphabet[currImgNo3].nextImage()) {
                currImgNo3+=5;
                if(currImgNo3>allAlphabet.size()-1){
                    currImgNo3=currImgNo3-allAlphabet.size();
                }
            }
            if (allAlphabet[currImgNo4].nextImage()) {
                currImgNo4+=5;
                if(currImgNo4>allAlphabet.size()-1){
                    currImgNo4=currImgNo4-allAlphabet.size();
                }
            }
            if (allAlphabet[currImgNo5].nextImage()) {
                currImgNo5+=5;
                if(currImgNo5>allAlphabet.size()-1){
                    currImgNo5=currImgNo5-allAlphabet.size();
                }
            }
            //update
            allAlphabet[currImgNo1].update();
            allAlphabet[currImgNo2].update();
            allAlphabet[currImgNo3].update();
            allAlphabet[currImgNo4].update();
            allAlphabet[currImgNo5].update();
        }
    }
    //send request to next screen already
    if (counterDrawAlphabet==FRAME_RATE*(alphabetLength-3)) {
        goToNextScreen();
    }
    //determining when it's over
    if (currentURL==currentAlphabet && currImgNo2>39 && allAlphabet[currImgNo2]._xPos<-100) {
        counterDrawAlphabet=0;
        blendInfo=0;
        //now go to that screen
        currentURL=URLsToLoad[currentURLNo];
        printf("next screen :%s\n", currentURL.c_str());
    }
}
//--------------------------------------------------------------
//drawing
//--------------------------------------------------------------
void testApp::drawPostcards(){
    int noOfPostcards=(int)allPostcards.size();
    ofEnableAlphaBlending();
    //blend in
    if(counterPostcardsAndLetters<FRAME_RATE){
        blendInfo+=8;
        ofSetColor(255, 255, 255, blendInfo);
    }
    //blend out
    else if(counterPostcardsAndLetters>FRAME_RATE*(lengthPostcards-1) && counterPostcardsAndLetters<FRAME_RATE*lengthPostcards){
        blendInfo-=8;
        ofSetColor(255, 255, 255, blendInfo);
    } else{
        ofSetColor(255);
    }
    
    //draw postcard
    if(allPostcards.size()-1>=currImgNo){
        allPostcards[currImgNo].draw();
    }
   
    //draw title
    ofSetColor(255);
    postcardsTitle.draw((screenWidth-postcardsTitle.width), screenHeight-postcardsTitle.height);
    ofDisableAlphaBlending();
}
void testApp::drawLetters(){

    ofEnableAlphaBlending();
    //blend in
    if(counterPostcardsAndLetters<FRAME_RATE){
        blendInfo+=8;
        ofSetColor(255, 255, 255, blendInfo);
    }
    //blend out
    else if(counterPostcardsAndLetters>FRAME_RATE*(lengthLetters-1)){
        blendInfo-=8;
        ofSetColor(255, 255, 255, blendInfo);
    } else{
        ofSetColor(255);
    }
    //draw letters Berlin
    int noOfLetters=(int)allLetters.size();

    if(noOfLetters>0){
        allLetters[currLetterImgNo1].draw();
    }
    if(noOfLetters>1){
        allLetters[currLetterImgNo2].draw();
    }
    if(noOfLetters>2){
        allLetters[currLetterImgNo3].draw();
    }
    if(noOfLetters>3){
        allLetters[currLetterImgNo4].draw();
    }
    if(noOfLetters>4){
        allLetters[currLetterImgNo5].draw();
    }
    
    //draw title
    ofSetColor(255);
    lettersTitle.draw((screenWidth-lettersTitle.width), screenHeight-lettersTitle.height);
    
    ofDisableAlphaBlending();
}
void testApp::drawAlphabet(){
    ofEnableAlphaBlending();
    //blend in
    if(counterDrawAlphabet<FRAME_RATE){
        blendInfo+=8;
        ofSetColor(255, 255, 255, blendInfo);
    }
    //blend out
    else if(counterDrawAlphabet>FRAME_RATE*(alphabetLength-1)){
        blendInfo-=8;
        ofSetColor(255, 255, 255, blendInfo);
    } else{
        ofSetColor(255);
    }
    //draw entire alphabet
    for (int i=0; i<allAlphabet.size(); i++) {
        allAlphabet[i].drawWhole();
    }
    if(counterDrawAlphabet>FRAME_RATE*alphabetLength){
        allAlphabet[currImgNo1].draw();
        allAlphabet[currImgNo2].draw();
        allAlphabet[currImgNo3].draw();
        allAlphabet[currImgNo4].draw();
        allAlphabet[currImgNo5].draw();
    }
    ofSetColor(255);
    alphabetTitle.draw((screenWidth-alphabetTitle.width), screenHeight-alphabetTitle.height);
    ofDisableAlphaBlending();
}

//-------------------------------------------------
void testApp::keyReleased(int key){
    
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y){
    
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){
    
}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){
    
}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){
    
}