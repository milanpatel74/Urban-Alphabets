#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    ofSetFrameRate(FRAME_RATE);
    ofBackground(50, 50, 50);
	ofTrueTypeFont::setGlobalDpi(72);

    loading=true;
    ofRegisterURLNotification(this);
    URLsToLoad[0]="http://www.mlab.taik.fi/UrbanAlphabets/requests/MadridrecentLetters.php";
    URLsToLoad[1]="http://www.mlab.taik.fi/UrbanAlphabets/requests/requestMadrid.php";
    URLsToLoad[2]="http://www.mlab.taik.fi/UrbanAlphabets/requests/MadridrecentPostcards.php";
    currentURLNo=1;
    currentURL=URLsToLoad[currentURLNo];
    int id = ofLoadURLAsync(currentURL, "async_req");
    loadedURL=" ";
    
    spanishAlphabet[0]="A";
    spanishAlphabet[1]="B";
    spanishAlphabet[2]="C";
    spanishAlphabet[3]="D";
    spanishAlphabet[4]="E";
    spanishAlphabet[5]="F";
    spanishAlphabet[6]="G";
    spanishAlphabet[7]="H";
    spanishAlphabet[8]="I";
    spanishAlphabet[9]="J";
    spanishAlphabet[10]="K";
    spanishAlphabet[11]="L";
    spanishAlphabet[12]="M";
    spanishAlphabet[13]="N";
    spanishAlphabet[14]="O";
    spanishAlphabet[15]="P";
    spanishAlphabet[16]="Q";
    spanishAlphabet[17]="R";
    spanishAlphabet[18]="S";
    spanishAlphabet[19]="T";
    spanishAlphabet[20]="U";
    spanishAlphabet[21]="V";
    spanishAlphabet[22]="W";
    spanishAlphabet[23]="X";
    spanishAlphabet[24]="Y";
    spanishAlphabet[25]="Z";
    spanishAlphabet[26]="spanishN";
    spanishAlphabet[27]="+";
    spanishAlphabet[28]=",";
    spanishAlphabet[29]=".";
    spanishAlphabet[30]="!";
    spanishAlphabet[31]="?";
    spanishAlphabet[32]="0";
    spanishAlphabet[33]="1";
    spanishAlphabet[34]="2";
    spanishAlphabet[35]="3";
    spanishAlphabet[36]="4";
    spanishAlphabet[37]="5";
    spanishAlphabet[38]="6";
    spanishAlphabet[39]="7";
    spanishAlphabet[40]="8";
    spanishAlphabet[41]="9";

    counter=0;
    counterAlphabet=0;
    secsToNextRequest=45;
    
    //font for info
    infoFont.loadFont("Arial Black.ttf", 20, true, true);
    infoFont.setLineHeight(22.0f);
    secsFont.loadFont("Arial Black.ttf", 10, true, true);
}

//--------------------------------------------------------------
void testApp::update(){
    if (ofGetFrameNum()%2) {
        if (loading==false) {
            if (loadedURL==URLsToLoad[0]) {
                update_MadridrecentLetters();
            } else if (loadedURL==URLsToLoad[1]) {
                counterAlphabet++;
                if (counterAlphabet>FRAME_RATE*5) {
                    update_requestMadrid();
                }
            }else if (loadedURL==URLsToLoad[2]){
                update_MadridrecentPostcards();
            }
        }
    }
    fpmin=FRAME_RATE*secsToNextRequest;
    frameNum=ofGetFrameNum();
    //trying to figure out time to next request:
    
}

//--------------------------------------------------------------
void testApp::draw(){
    if (frameNum%fpmin==0  && frameNum>=fpmin) {
        if (counter==0) {
            printf("now\n");
            drawInfo();
            individualEntries.clear();
            counter++; //making sure request is only sent 1x
            loading=true;
            int id = ofLoadURLAsync(currentURL, "async_req");

        }
    }
    if(loading==true){
        drawInfo();
        ofSleepMillis(10000);
    }else
        if (loadedURL==URLsToLoad[0]) { //recent letter
            if(recentLetters.size()>0){
                recentLetters[currImg1].draw();
            }
            if(recentLetters.size()>1){
                recentLetters[currImg2].draw();
            }
            if(recentLetters.size()>2){
                recentLetters[currImg3].draw();
            }
            if(recentLetters.size()>3){
                recentLetters[currImg4].draw();
            }
            if(recentLetters.size()>4){
                recentLetters[currImg5].draw();
            }
        } else if (loadedURL==URLsToLoad[1]) { //current alphabet
            /*
            */
            if (counterAlphabet<FRAME_RATE*5) {
                for (int i=0; i<allEntriesAlphabet.size(); i++) {
                    allEntriesAlphabet[i].drawWhole();
                }
            }else{
                allEntriesAlphabet[currImg1].draw();
                allEntriesAlphabet[currImg2].draw();
                allEntriesAlphabet[currImg3].draw();
                allEntriesAlphabet[currImg4].draw();
                allEntriesAlphabet[currImg5].draw();
            }
            
        }else if (loadedURL==URLsToLoad[2]) {
            if (recentPostcards.size()>0) {
                recentPostcards[currImg1].draw();
            }
            if (recentPostcards.size()>1) {
                recentPostcards[currImg2].draw();
            }
            if (recentPostcards.size()>2) {
                recentPostcards[currImg3].draw();
            }
            if (recentPostcards.size()>3) {
                recentPostcards[currImg4].draw();
            }
            if (recentPostcards.size()>4) {
                recentPostcards[currImg5].draw();
            }
        }
        //printf("\n");
    testOverlayMediaLabPrado();
    testSecsToNextRequest();
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){
    if (key==OF_KEY_UP) {
        secsToNextRequest++;
        printf("UP   current secsToNextRequest: %i\n", secsToNextRequest);
    }
    if (key==OF_KEY_DOWN) {
        secsToNextRequest--;
        printf("DOWN current secsToNextRequest: %i\n", secsToNextRequest);
    }
    if (key==OF_KEY_RIGHT) {
        currentURLNo++;
        if(currentURLNo>=LENGTH_OF_URL_ARRAY){ currentURLNo=0;}
        currentURL=URLsToLoad[currentURLNo];
        printf("RIGHT currentURL: %s \n", currentURL.c_str());
    }
    if (key==OF_KEY_LEFT) {
        currentURLNo--;
        if(currentURLNo<0){ currentURLNo=LENGTH_OF_URL_ARRAY-1;}
        currentURL=URLsToLoad[currentURLNo];
        printf("LEFT  currentURL: %s\n", currentURL.c_str());
    }
}
void testApp::drawInfo(){
    /*ofSetColor(50,50,50);
    ofRect(0, 0, ofGetWidth(), ofGetHeight());*/
    ofSetColor(200, 200, 200);
    /*string myString="Urban";
    ofRectangle box=infoFont.getStringBoundingBox(myString, 0, 0);
    infoFont.drawString(myString, ofGetWidth()/2-box.width/2, (ofGetHeight()-box.height)/2);
    myString="Alphabets";
    box=infoFont.getStringBoundingBox(myString, 0, 0);
    infoFont.drawString(myString, ofGetWidth()/2-box.width/2, (ofGetHeight()-box.height)/2+22);*/
    if (currentURL==URLsToLoad[0]) { //recent letters
        string myString ="recent Letters";
        ofRectangle box=infoFont.getStringBoundingBox(myString, 0, 0);
        infoFont.drawString(myString, ofGetWidth()/2-box.width/2, 15+(ofGetHeight()-box.height)/2);
        myString="from Madrid";
        box=infoFont.getStringBoundingBox(myString, 0, 0);
        infoFont.drawString(myString, ofGetWidth()/2-box.width/2, 15+(ofGetHeight()-box.height)/2+22);
    } else if (currentURL==URLsToLoad[1]) { //current alphabet
        string myString ="current";
        ofRectangle box=infoFont.getStringBoundingBox(myString, 0, 0);
        infoFont.drawString(myString, ofGetWidth()/2-box.width/2, 15+(ofGetHeight()-box.height)/2);
        myString="Madrid Alphabet";
        box=infoFont.getStringBoundingBox(myString, 0, 0);
        infoFont.drawString(myString, ofGetWidth()/2-box.width/2, 15+(ofGetHeight()-box.height)/2+22);
    }   else if (currentURL==URLsToLoad[2]) { //recent postcards
        string myString ="recent";
        ofRectangle box=infoFont.getStringBoundingBox(myString, 0, 0);
        infoFont.drawString(myString, ofGetWidth()/2-box.width/2, 15+(ofGetHeight()-box.height)/2);
        myString="Madrid Postcards";
        box=infoFont.getStringBoundingBox(myString, 0, 0);
        infoFont.drawString(myString, ofGetWidth()/2-box.width/2, 15+(ofGetHeight()-box.height)/2+22);
    }

    
    ofSetColor(255);
}
void testApp::testOverlayMediaLabPrado(){
    ofSetColor(255);
    ofRect(0, 0, 36, 32);
    ofRect(36, 0, 36, 16);
    ofRect(36*2+48, 0, 36, 16);
    ofRect(36*3+48, 0, 36, 32);
}
void testApp::testSecsToNextRequest(){
    ofSetColor(0);
    int secs=(fpmin-(frameNum%fpmin))/FRAME_RATE;
    secsFont.drawString(ofToString(secs), 3, 10);
    //printf("time to next request: %i\n", secs);
    ofSetColor(255);

}

//--------------------------------------------------------------
//http request and ordering
//--------------------------------------------------------------

void testApp::urlResponse(ofHttpResponse & response){
    //drawInfo();
    fullResponse=ofToString(response.data);
    //printf("urlResponse %s \n",fullResponse.c_str());
    ofStringReplace(fullResponse, "[{", "");
    ofStringReplace(fullResponse, "}]", "");
    individualEntries=ofSplitString(fullResponse, "},{");
    if (currentURL==URLsToLoad[0]) {
        loadURL_MadridrecentLetters(response);
    }else if (currentURL==URLsToLoad[1]) {
        loadURL_requestMadrid(response);
    } else if (currentURL==URLsToLoad[2]){
        loadURL_MadridrecentPostcards(response);
    }
    loading=false;

}
void testApp::loadURL_MadridrecentLetters(ofHttpResponse &response){
    recentLetters.clear();
    for(int i=0; i<individualEntries.size(); i++){
        vector<string> cutEntries =ofSplitString(individualEntries[i], ",");
        //delete the first parts in all of them
        ofStringReplace(cutEntries[0], "\"ID\":\"", "");
        ofStringReplace(cutEntries[1], "\"letter\":\"", "");
        ofStringReplace(cutEntries[2], "\"owner\":\"", "");
        //delete the last " in all of them
        ofStringReplace(cutEntries[0], "\"", "");
        ofStringReplace(cutEntries[1], "\"", "");
        ofStringReplace(cutEntries[2], "\"", "");

        //printf("%i ", i);
        Letter entry(cutEntries[0], cutEntries[1], cutEntries[2], i);
        recentLetters.push_back(entry);
        //printf("size: %i\n", (int)allEntriesLastLetters.size());
    }
    
   /* for (int i=0; i<recentLetters.size()-1; i++) {
        recentLetters[i].print();
    }*/
    if (response.status==200 && response.request.name=="async_req") {
        for (int i=0; i<recentLetters.size(); i++) {
            recentLetters[i].loadImage();
        }
        currImg1=recentLetters.size()-1;
        currImg2=recentLetters.size()-2;
        currImg3=recentLetters.size()-3;
        currImg4=recentLetters.size()-4;
        currImg5=recentLetters.size()-5;
        counter=0;
        loadedURL=currentURL;
        printf("loaded  %s \n", currentURL.c_str());
        currentURLNo++;
        if(currentURLNo>=LENGTH_OF_URL_ARRAY){ currentURLNo=0;}
        currentURL=URLsToLoad[currentURLNo];
        printf("current %s \n", currentURL.c_str());
    } else{
        printf("not loaded \n");
        
    }
}
void testApp::loadURL_requestMadrid(ofHttpResponse &response){
    allEntriesAlphabet.clear();
    int numberOfLettersAdded=0;
    vector <SingleEntry> allLetters;
    for(int i=0; i<individualEntries.size(); i++){
        vector<string> cutEntries =ofSplitString(individualEntries[i], ",");
        //delete the first parts in all of them
        ofStringReplace(cutEntries[0], "\"ID\":\"", "");
        ofStringReplace(cutEntries[1], "\"letter\":\"", "");
        //delete the last " in all of them
        ofStringReplace(cutEntries[0], "\"", "");
        ofStringReplace(cutEntries[1], "\"", "");
        //printf("%i ", i);
        string letter=cutEntries[1];
        if (i>1) {
           // printf("currentLetter:lastLetter= %s,%s\n", letter.c_str(), allLetters[numberOfLettersAdded-1]._letter.c_str());
            if (allLetters[numberOfLettersAdded-1]._letter!=letter) {
                SingleEntry entry(cutEntries[0], cutEntries[1], numberOfLettersAdded);
                allLetters.push_back(entry);
                numberOfLettersAdded++;
            }
        } else{
            SingleEntry entry(cutEntries[0], cutEntries[1], i);
            allLetters.push_back(entry);
            numberOfLettersAdded++;
        }
        
        //printf("size: %i\n", (int)allEntriesAlphabet.size());
    }
    /*for (int i=0; i<allLetters.size()-1; i++) {
        printf("%i", i);
        allLetters[i].print();
    }*/
    //trying to put it into a proper alphabet
    //go through spanish alphabet

    for (int j=0; j<42; j++) {
        //go through all letters we have
        for (int i=0; i<allLetters.size(); i++) {
            if (allLetters[i]._letter==spanishAlphabet[j]) {
                SingleEntry entry(ofToString(allLetters[i]._id), allLetters[i]._letter, j);
                allEntriesAlphabet.push_back(entry);
                //printf("letter added(right): %s, position: %i\n", spanishAlphabet[j].c_str(), j);
                break;
            } else if (i==allLetters.size()-1){
                SingleEntry entry("0000", spanishAlphabet[j], j);
                allEntriesAlphabet.push_back(entry);
                //printf("letter added (fake): %s, position: %i\n", spanishAlphabet[j].c_str(), j);

                break;
            }
        }
    }
    

   /* for (int i=0; i<allEntriesAlphabet.size()-1; i++) {
        printf("%i", i);
        allEntriesAlphabet[i].print();
    }*/
    if (response.status==200 && response.request.name=="async_req") {
        for (int i=0; i<allEntriesAlphabet.size(); i++) {
            if (allEntriesAlphabet[i]._id!=0) {
                 allEntriesAlphabet[i].loadImage();
            }else{
                //load letter from image directory
                allEntriesAlphabet[i].loadImageDirectory();
            }
           
        }
        currImg1=0;
        currImg2=1;
        currImg3=2;
        currImg4=3;
        currImg5=4;

        counter=0;
        loadedURL=currentURL;
        printf("loaded %s \n", currentURL.c_str());
        currentURLNo++;
        if(currentURLNo>=LENGTH_OF_URL_ARRAY){ currentURLNo=0;}
        currentURL=URLsToLoad[currentURLNo];
        printf("current %s \n", currentURL.c_str());
    } else{
        printf("not loaded \n");
        
    }
}
void testApp::loadURL_MadridrecentPostcards(ofHttpResponse &response){
    recentPostcards.clear();
    //printf(" number of entries: %i \n",(int) individualEntries.size());
    for(int i=0; i<individualEntries.size(); i++){
        vector<string> cutEntries =ofSplitString(individualEntries[i], ",");
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
        //printf("%i ", i);
        Postcard entry(cutEntries[0], cutEntries[1], cutEntries[2],cutEntries[3],cutEntries[4], i);
        recentPostcards.push_back(entry);
 
    }
    /*for (int i=0; i<recentPostcards.size(); i++) {
        recentPostcards[i].print();
    }*/
    
    if (response.status==200 && response.request.name=="async_req") {
        for (int i=0; i<recentPostcards.size(); i++) {
            recentPostcards[i].loadImage();
        }
        currImg1=recentPostcards.size()-1;
        currImg2=recentPostcards.size()-2;
        currImg3=recentPostcards.size()-3;
        currImg4=recentPostcards.size()-4;
        currImg5=recentPostcards.size()-5;
        counter=0;
        loadedURL=currentURL;
        printf("loaded  %s \n", currentURL.c_str());
        currentURLNo++;
        if(currentURLNo>=LENGTH_OF_URL_ARRAY){ currentURLNo=0;}
        currentURL=URLsToLoad[currentURLNo];
        printf("current %s \n", currentURL.c_str());
    } else{
        printf("not loaded \n");
        
    }

}
//--------------------------------------------------------------
//updates
//--------------------------------------------------------------
void testApp::update_MadridrecentLetters(){
    if(recentLetters.size()>0){
        recentLetters[currImg1].update();
    }
    if(recentLetters.size()>1){
        recentLetters[currImg2].update();
    }
    if(recentLetters.size()>2){
        recentLetters[currImg3].update();
    }
    if(recentLetters.size()>3){
        recentLetters[currImg4].update();
    }
    if(recentLetters.size()>4){
        recentLetters[currImg5].update();
    }
}
void testApp::update_requestMadrid(){
    if (allEntriesAlphabet[currImg1].nextImage()) {
        currImg1+=5;
        if(currImg1>allEntriesAlphabet.size()-4){
            currImg1=0;
        }
        //printf("currImg1  after = %i\n", currImg1);
    }
    if (allEntriesAlphabet[currImg2].nextImage()) {
        currImg2+=5;
        if(currImg2>allEntriesAlphabet.size()-4){
            currImg2=1;
        }
       // printf("currImg2  after = %i\n", currImg2);

    }
    if (allEntriesAlphabet[currImg3].nextImage()) {
        currImg3+=5;
        if(currImg3>allEntriesAlphabet.size()-4){
            currImg3=2;
        }
       // printf("currImg3  after = %i\n", currImg3);

    }
    if (allEntriesAlphabet[currImg4].nextImage()) {
        currImg4+=5;
        if(currImg4>allEntriesAlphabet.size()-4){
            currImg4=3;
        }
       // printf("currImg4  after = %i\n", currImg4);

    }
    if (allEntriesAlphabet[currImg5].nextImage()) {
        currImg5+=5;
        if(currImg5>allEntriesAlphabet.size()-4){
            currImg5=4;
        }
       // printf("currImg5  after = %i\n", currImg5);

    }
    allEntriesAlphabet[currImg1].update();
    allEntriesAlphabet[currImg2].update();
    allEntriesAlphabet[currImg3].update();
    allEntriesAlphabet[currImg4].update();
    allEntriesAlphabet[currImg5].update();
}
void testApp::update_MadridrecentPostcards(){
    
    int recentPostcardSize=(int)recentPostcards.size();
    
        if (recentPostcardSize>0) {
            recentPostcards[currImg1].update();
        }
        if (recentPostcardSize>1) {
            recentPostcards[currImg2].update();
        }
        if (recentPostcardSize>2) {
            recentPostcards[currImg3].update();
        }
        if (recentPostcardSize>3) {
            recentPostcards[currImg4].update();
        }
        if (recentPostcardSize>4) {
            recentPostcards[currImg5].update();
        }
        //printf("xpositions: %i: %i \n", recentPostcards[currImg1]._xPos, recentPostcards[currImg2]._xPos);
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
