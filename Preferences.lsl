/*==========================================================
DrizzleScript
Created By: Ryhn Teardrop
Original Date: Dec 3rd, 2011

Programming Contributors: Ryhn Teardrop, Brache Spyker
Resource Contributors: Murreki Fasching, Brache Spyker

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.


*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

/* Script used to offer and manage setting-changing menu options */

integer g_printTextueLength;
integer g_printCardLength;
integer g_uniqueChan;
integer g_mainListen; //needed to keep track of the listens
integer g_currCount;
string g_currMenu;
string g_currMenuMessage; //Potentially usable to determine which timer is being used?
list g_currMenuButtons;
list g_Skins;
list g_Tapes;
list g_BackFaces;
list g_Panels;
list g_Cuties;
list g_Printouts;
list g_settingsMenu = ["<--TOP", "★", "Gender", "Skins", "Printouts", "Chatter", "Potty", "Interactions", "Volume"];
list g_skinsMenu = ["<--BACK","Help", "*","Diaper❤Print","Tapes","Back❤Face","Panel","Cutie*Mark"];
list g_genderMenu = ["<--BACK", "★", "★", "Boy", "Girl"];
list g_chatterMenu = ["<--BACK", "★", "★", "Normal", "Whisper", "Private"];
list g_volumeMenu = ["<--BACK", "★", "★", "Crinkle❤Volume", "Wet❤Volume", "Mess❤Volume"];
list g_pottyMenu = ["<--BACK", "★", "★", "Wet❤Timer", "Mess❤Timer", "★", "Wet%", "Mess%", "★", "❤Tickle❤", "Tummy❤Rub", "★"];
list g_timerOptions = ["<--BACK", "★", "★", "40", "60", "120", "15", "20", "30", "0", "5", "10"]; // Backwards  (Ascending over 3) to make numbers have logical order.
list g_chanceOptions = ["<--BACK", "90%", "100%", "60%", "70%", "80%", "30%", "40%", "50%", "0%", "10%", "20%"]; // Backwards (Ascending over 3) to make numbers have logical order.
list g_interactionsOptions = ["<--BACK","★", "★","Everyone","Carers❤&❤Me"];
/* For Misc Diaper Models */
integer g_mainPrim;
string g_mainPrimName = ""; // By default, set to "".
//various diapers have different texture settings
//PiedPiper uses repeat 1.0, 1.0 and offset .03, -.5
string g_diaperType = "Fluffems";
integer isDebug = FALSE;

//menu variables passed to preferences
integer g_wetChance;
integer g_messChance;
integer g_wetTimer;
integer g_messTimer;
integer g_tummyRub;
integer g_tickle;
integer g_gender;
integer g_interact;
integer g_chatter;
float g_crinkleVolume;
float g_wetVolume;
float g_messVolume;

//Old variables used in my prim-sculptie based system.
//list g_Ruffles;
//list g_Panels;
//list g_TrainingMenu = ["<--BACK", "★", "★", "Infant", "Toddler", "Adult"];
//list g_Tapes;
//list g_ColorMenu = ["<--BACK", "★", "★", "Padding", "Ruffles", "Pins", "Cutesy", "Adult"];
//list g_AppearanceMenu = ["<--BACK", "★", "★", "Tapes", "Ruffles", "Color", "Skins", "Panel"];
//list g_ColorMenu = ["<--BACK", "★", "★"];

init()
{
    llListenRemove(g_mainListen);
    g_uniqueChan = generateChan(llGetOwner()) + 1; // Remove collision with Menu listen handler via +1
    loadInventoryList();
    findPrims();
    scanForResizerScript();
    if(isDebug==TRUE) {
        if(llList2String(g_settingsMenu,1)=="*") {
            g_settingsMenu = llListReplaceList(g_settingsMenu,["DEBUG"],1,1);
        }
    }
    g_mainListen = llListen(g_uniqueChan, "", "", "");
}

/*
    This function is customized to work with Zyriik's Puppy Pawz Pampers model.
    It assumes that the main model is named "Main Shape" and searches through the link set until it discovers it.
*/  
findPrims() {
    
    if(g_mainPrimName == "") { // No specified prim. Look for root.
        g_mainPrim = 1;
    }
    else {// Specified prim. Find it.
        integer i; // Used to loop through the linked objects
        integer primCount = llGetNumberOfPrims(); //should be attached, not sat on
        for(i = 1; i <= primCount; i++) {
            string primName = (string) llGetLinkPrimitiveParams(i, [PRIM_NAME]); // Get the name of linked object i
            if(g_mainPrimName == primName) { // Is this the prim?
                g_mainPrim = i;
            }    
        }

    }
}

//quick and dirty resizer check
scanForResizerScript() {
    if(llGetInventoryType("Controler") == INVENTORY_SCRIPT) {
        if(llListFindList(g_settingsMenu,["Resize"])==-1) {
            g_settingsMenu += ["Resize"];
        }
    }
}

//@l = list of dialog options
//@readLocation = The index used to determine where to start reading the list
//@id = Key used to dispatch finished page
//---- This function generates the page to be displayed (This function curiously is used to display page 1)
integer prevPage(string MenuText, list l, integer readLocation, key id) {
    if(readLocation < -1) return readLocation;
            
    readLocation -= 22; //Go back two pages (11 for current page, 11 more to get readLocation to the start of the page)
    
    if(readLocation == -1) {//First page
        //@temp = elements 0 through 9 in g_Skins, and then 10 and 11 are Back and Next-->
        list temp = ["<--BACK", "NEXT-->"] + llList2List(l, readLocation+1, readLocation+10);
        readLocation += 11;
        offerMenu(id, MenuText, temp);
        return readLocation;       
    }
    else {
        list temp = ["<--BACK", "<--PREV", "NEXT-->"] + llList2List(l, readLocation+1, readLocation+10);
        readLocation += 11;
        offerMenu(id, MenuText, temp);
        return readLocation;
    }
}

//@id = The key used to send the menu out.
//This function determines which page needs to be generated
handlePrev(key id) {
    if(g_currMenu == "Skins") {
         g_currCount = prevPage(m_skinMenu(), g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Printouts") {
        g_currCount = prevPage(m_printMenu(),g_Printouts, g_currCount, id);
    }
    //handling for Kawaii Diapers
    else if(g_currMenu == "Diaper❤Print") {
        g_currCount = prevPage(m_skinMenu(), g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Tapes") {
        g_currCount = prevPage(m_tapesMenu(),g_Tapes, g_currCount, id);
    }
    else if(g_currMenu == "Back❤Face") {
        g_currCount = prevPage(m_backFaceMenu(),g_BackFaces, g_currCount, id);
    }
    else if(g_currMenu == "Panel") {
        g_currCount = prevPage(m_panelMenu(),g_Panels, g_currCount, id);
    }
    else if(g_currMenu == "Cutie*Mark") {
        g_currCount = prevPage(m_cutieMenu(),g_Cuties, g_currCount, id);
    }
}

//@l = list of dialog options
//@readLocation = The index used to determine where to start reading the list
//@id = Key used to dispatch finished page
//---- This function generates the page to be displayed
integer nextPage(string MenuText, list l, integer readLocation, key id) {
    integer maxReadLocation = llGetListLength(l);
    integer i;
    list temp;
    list stars;
    
    if(readLocation > maxReadLocation) return readLocation; // Invalid readLocation
    if(readLocation+11 > maxReadLocation) { //This is the last page, and it wont be full
        temp = llList2List(l, readLocation, readLocation+10);
        readLocation += 11;
        integer numStars = 10 - (llGetListLength(temp)); // 10 stars leaves room for Back and <--PREV
        //Add the stars for filler
        for(i = 0; i < numStars; i++) {
            stars += ["★"];
        }
        temp = ["<--BACK", "<--PREV"] + stars + temp;
        g_currMenuButtons = temp;
        offerMenu(id, MenuText, temp);
    }
    else { // Full page.
        temp = ["<--BACK","<--PREV","NEXT-->"] + llList2List(l, readLocation, readLocation+10); 
        readLocation += 11;
        offerMenu(id, MenuText, temp);
    }
    return readLocation;
}

//@id = The key used to send the menu out.
//This function determines which page needs to be generated
handleNext(key id) {
    if(g_currMenu == "Skins") {
         g_currCount = nextPage(m_skinMenu() ,g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Printouts") {
        g_currCount = nextPage(m_printMenu(), g_Printouts, g_currCount, id);
    }
    else if(g_currMenu == "Diaper❤Print") {
        g_currCount = nextPage(m_skinMenu(), g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Tapes") {
        g_currCount = nextPage(m_tapesMenu(), g_Tapes, g_currCount, id);
    }
    else if(g_currMenu == "Back❤Face") {
        g_currCount = nextPage(m_backFaceMenu(),g_BackFaces, g_currCount, id);
    }
    else if(g_currMenu == "Panel") {
        g_currCount = nextPage(m_panelMenu(),g_Panels, g_currCount, id);
    }
    else if(g_currMenu == "Cutie*Mark") {
        g_currCount = nextPage(m_cutieMenu(),g_Cuties, g_currCount, id);
    }
}

loadAllTextures(list l) {
    integer i;
    g_Skins = [];
    for(i = 0; i < g_printTextueLength; i++) {
        string temp = llList2String(l, i);  //seems less confusing to just use llList2String than typecasting a single List2list entry...
        string prefix = llGetSubString(temp, 0, llSubStringIndex(temp, ":"));
        string name = llGetSubString(temp, llSubStringIndex(temp, ":") + 1, llStringLength(temp));
        if(prefix == "SKIN:") {
            g_Skins += name;  
        }
        else if(prefix == "TAPE:") {
            g_Tapes += name;
        }
        else if(prefix == "BACKFACE:") {
            g_BackFaces += name;
        }
        else if(prefix == "PANEL:") {
            g_Panels += name;
        }
        else if(prefix == "CUTIE:") {
            g_Cuties += name;
        }
    }
}

loadPrintouts(list l) {
    integer i;
    g_Printouts = [];
    for(i = 0; i < g_printCardLength; i++) {
        string temp = llList2String(l, i);
        string prefix = llGetSubString(temp, 0, llSubStringIndex(temp, ":"));
        string name = llGetSubString(temp, llSubStringIndex(temp, ":") + 1, llStringLength(temp));
        if(prefix == "PRINT:") {
            g_Printouts += name;
        }
    }
}

loadInventoryList() {
    list result = [];
    integer n = llGetInventoryNumber(INVENTORY_TEXTURE);
    while(n) {
        result = llGetInventoryName(INVENTORY_TEXTURE, --n) + result;
    }
    g_printTextueLength = llGetListLength(result);
    loadAllTextures(result);
    result = [];
    n = llGetInventoryNumber(INVENTORY_NOTECARD);
    while(n) {
        result = llGetInventoryName(INVENTORY_NOTECARD, --n) + result;
    }
    g_printCardLength = llGetListLength(result);
    loadPrintouts(result);
}
integer generateChan(key id) {
    string channel = "0xE" +  llGetSubString((string)id, 0, 6);
    return (integer) channel;
}

//Identical to llDialog except channel isn't passed, and
//this function tucks in a few lines of code to track the last menu accessed
offerMenu(key id, string dialogMessage, list buttons) {
    g_currMenuButtons = buttons;
    g_currMenuMessage = dialogMessage;
    llDialog(id, dialogMessage, buttons,g_uniqueChan);   
}

handleMenuChoice(string msg, key id) {

    /* Old code from a prim-sculptie based build.
    
    if(msg == "Tapes") {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_Tapes, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Choose a the tape texture you'd like: ", temp);
        g_currCount += 11;
    }
    else if(msg == "Panel") {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_Panels, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Choose a the panel texture you'd like: ", temp);
        g_currCount += 11;   
    }
    else if(msg == "Ruffles") {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_Ruffles, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Choose a panel texture you'd like: ", temp);
        //llDialog(id, "Choose a the panel texture you'd like: ", temp, g_uniqueChan);
        g_currCount += 11;   
    }
    else if(msg == "WetTex") {
        g_currMenu = msg;
        //Incomplete
    }
    else if(msg == "MessTex") {
        g_currMenu = msg;
        //Incomplete
    }
    else if(msg == "Colors") {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_ColorMenu, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Adjust your colors!", temp);
        g_currCount += 11;  
    }
    else if(msg == "Training") {
        g_currMenu = msg;
        g_currCount = -1;
        offerMenu(id, "How potty trained are you?", g_TrainingMenu);   
    }
    */
}

//@name = Texture name
//@prefix = Texture's type
applyTexture(string name, string prefix) {
    string texture = prefix + name;
    vector repeats;
    vector offset;
    float radRotation;
    
    repeats.x = 1.0;
    repeats.y = 1.0;
    
    if(g_diaperType=="Fluffems") {
        offset.x = 0.0;
        offset.y = 0.0;
    }
    else if(g_diaperType=="PiedPiper") {
        offset.x = 0.03;
        offset.y = -.5;
    }
    
    radRotation = 0.0;
    
    llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, ALL_SIDES, texture, repeats, offset, radRotation]);
}

integer contains(list l, string test) {
    if(~llListFindList(l, [test])) {// test found, it's in the list!
        return TRUE;   
    }
    else {
        return FALSE;
    }
}

parseSettings(string temp) {
    integer index; // Used to hold the location of a comma in the CSV
    
    //I opted to not use llCSV2List to avoid the overhead associated with storing and cutting up lists.
    //I'm simply finding commas in the string, and cutting out the values between them.
    
    index = llSubStringIndex(temp, ",");
//  g_wetLevel = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1); // Remove the used data.
    
    index = llSubStringIndex(temp, ",");
//  g_messLevel = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_wetChance = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_messChance = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_wetTimer = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_messTimer = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_tummyRub = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_tickle = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_gender = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
//  g_isOn = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_interact = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_chatter = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_crinkleVolume = (float) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_wetVolume = (float) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    //The last value is all that remains, just store it.
    g_messVolume = (float) temp;
}

printDebugSettings() {
    llOwnerSay("Wet Hold: " + (string) g_wetChance + "%");
    llOwnerSay("Mess Hold: " + (string) g_messChance + "%");
    llOwnerSay("Wet Frequency: " + (string) g_wetTimer + " Minute(s)");
    llOwnerSay("Mess Frequency: " + (string) g_messTimer + " Minute(s)");
    llOwnerSay("TummyRub Resist: " +  (string) g_tummyRub + "%");
    llOwnerSay("Tickle Resist: " + (string) g_tickle + "%");
    llOwnerSay("Gender: " + (string) g_gender);
    llOwnerSay("Other Interaction: " + (string) g_interact);
    llOwnerSay("Channel: " + (string) g_uniqueChan);
    llOwnerSay("Crinkle Volume: "+(string) g_crinkleVolume);
    llOwnerSay("Wet Sound Volume: "+(string) g_wetVolume);
    llOwnerSay("Mess Sound Volume: "+(string) g_messVolume);
    llOwnerSay("Used Memory: " + (string) llGetUsedMemory());
    llOwnerSay("Free Memory: " + (string) llGetFreeMemory());
}

//Function calls to ensure that preferences menu options update correctly.
string m_topMenu() {
    return "Adjust "+llKey2Name(llGetOwner())+"'s settings!";
}

string m_pottyMenu() {
    return "Adjust "+llKey2Name(llGetOwner())+"'s potty settings!";
}

string m_volumeMenu() {
    return "Adjust "+llKey2Name(llGetOwner())+"'s volume settings!";
}

string m_wetTimer() {
    return "Wet Frequency (How often you wet)\n\n==This is in Minutes==\nCurrent Value: "+(string)g_wetTimer;
}

string m_messTimer() {
    return "Mess Frequency (How often you potty)\n\n==This is in Minutes==\nCurrent Value: "+(string)g_messTimer;
}

string m_wetChance() {
    return "Chance to hold it! (Wet)\nCurrent Chance: "+(string)g_wetChance+"%";
}

string m_messChance() {
    return "Chance to hold it! (Mess)\nCurrent Chance: "+(string)g_messChance+"%";
}

string m_tickleChance() {
    return "Chance to resist tickles!\nCurrent Chance: "+(string)g_tickle+"%";
}

string m_tummyRubChance() {
    return "Chance to resist tummy rubs!\nCurrent Chance: "+(string)g_tummyRub+"%";
}

string m_interactions() {
    string allowedInteractions;
    if(g_interact==0) {
        allowedInteractions = "only carers and the owner are";
    }
    else if(g_interact==1) {
        allowedInteractions = "everyone is";
    }
    return "Who should be able to interact with this diaper?\n\nCurrently "+allowedInteractions+" allowed.";
}

string m_chatter() {
    string chatSpam;
    if(g_chatter==0) {
        chatSpam = "private.  Only the owner and whoever interacts will see messages.";
    }
    else if(g_chatter==1) {
        chatSpam = "whisper.  The public will hear messages up to 10m away.";
    }
    else if(g_chatter==2) {
        chatSpam = "normal.  The public will hear messages up to 20m away!";
    }
    return "How far should the diaper chatter go?\n\nThe current setting is "+chatSpam;
}

string m_crinkleVolume() {
    return "How loud should the crinkling be?\nCurrent value: "+(string)llRound(g_crinkleVolume*200.0)+"%";
}

string m_wetVolume() {
    return "How loud should the wetting sound be?\nCurrent value: "+(string)llRound(g_wetVolume*300)+"%";
}

string m_messVolume() {
    return "How loud should the messing sound be?\nCurrent value: "+(string)llRound(g_messVolume*100)+"%";
}

string m_skinMenu() {
    return "Choose a diaper print:";
}

string m_tapesMenu() {
    return "Choose a tape texture:";
}

string m_panelMenu() {
    return "Choose a panel print:";
}

string m_backFaceMenu() {
    return "Choose a butt print:";
}

string m_cutieMenu() {
    return "Yay cutie marks!\n\nChoose a cutie mark:";
}

string m_printMenu() {
    return "Choose a Printout style:";
}

default {
    
    state_entry() {
        init();
    }
    
    attach(key id) {
        if(id) { // Attached
            findPrims();    
        }
    }
    
    changed(integer change) {
        if(change & CHANGED_OWNER | CHANGED_INVENTORY) {
            init();
        }
    }
    
    link_message(integer sender_num, integer num, string msg, key id) {
        if(num == 6) {
            parseSettings(msg);
        }
        else if(num == -1) {
            if(msg == "Options") {
                offerMenu(id, m_topMenu(), g_settingsMenu);
            }
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if(msg == "★") {// Someone misclicked in the menu!
            if(isDebug < 2) {
                llOwnerSay("The stars are just there to look pretty! =p");
            }
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "<--BACK") {
            if(~llListFindList(g_pottyMenu,[g_currMenu])) {
                g_currMenu = "";
                offerMenu(id, m_pottyMenu(),g_pottyMenu);
            }
            else if(~llListFindList(g_volumeMenu,[g_currMenu])) {
                g_currMenu = "";
                offerMenu(id, m_volumeMenu(),g_volumeMenu);
            }
            else {
                g_currMenu = "";
                offerMenu(id, m_topMenu(), g_settingsMenu);
            }
        }
        else if(msg=="DEBUG") {
            printDebugSettings();
        }
        else if(contains(g_Skins, msg) && g_currMenu == "Skins") {
            applyTexture(msg, "SKIN:");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
            }
        else if(contains(g_Printouts, msg)  && g_currMenu == "Printouts") {// new printout notecard!
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY); //whew!
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "NEXT-->") {
            handleNext(id);
        }
        else if(msg == "<--PREV") {
            handlePrev(id);
        }
        else if(g_currMenu == "Crinkle❤Volume") {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_crinkleVolume = (float) msg * .005;
            offerMenu(id, m_crinkleVolume(), g_currMenuButtons);
        }
        else if(g_currMenu == "Wet❤Volume") {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_wetVolume = (float) msg * .00333;
            offerMenu(id, m_wetVolume(), g_currMenuButtons);
        }
        else if(g_currMenu == "Mess❤Volume") {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_messVolume = (float) msg * .01;
            offerMenu(id, m_messVolume(), g_currMenuButtons);
        }            
        else if(g_currMenu == "Mess%") {
            //Mess%:10%
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_messChance = (integer) msg;
            offerMenu(id, m_messChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Wet%") {
            //Wet%:10%
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_wetChance = (integer) msg;
            offerMenu(id, m_wetChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Mess❤Timer") {
            //Mess❤Timer:10
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_messTimer = (integer) msg;
            offerMenu(id, m_messTimer(), g_currMenuButtons);
        }
        else if(g_currMenu == "Wet❤Timer") {
            //Wet❤Timer:10
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_wetTimer = (integer) msg;
            offerMenu(id, m_wetTimer(), g_currMenuButtons);
        }
        else if(g_currMenu == "❤Tickle❤") {
            //❤Tickle❤:??
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_tickle = (integer) msg;
            offerMenu(id, m_tickleChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Tummy❤Rub") {
            //Tummy❤Rub:??
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            msg = llGetSubString(msg, 0, -2);
            g_tummyRub = (integer) msg;
            offerMenu(id, m_tummyRubChance(), g_currMenuButtons);
        }
        else if(msg == "Boy") { //Sent to main to update values and pass to Printouts
            llMessageLinked(LINK_THIS, -3, "Gender:0", NULL_KEY);
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "Girl") {
            llMessageLinked(LINK_THIS, -3, "Gender:1", NULL_KEY);
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        //Security settings
        else if(msg == "Everyone") {
            llMessageLinked(LINK_THIS, -3, "Others:1", NULL_KEY);
            g_interact = 1;
            offerMenu(id, m_interactions(), g_currMenuButtons);
        }
        else if(msg == "Carers❤&❤Me") {
            llMessageLinked(LINK_THIS, -3, "Others:0", NULL_KEY);
            g_interact = 0;
            offerMenu(id, m_interactions(), g_currMenuButtons);
        }
        //chat spam level
        else if(msg == "Normal") {
            llMessageLinked(LINK_THIS, -3, "Chatter:2", NULL_KEY);
            g_chatter = 2;
            offerMenu(id, m_chatter(), g_currMenuButtons);
        }
        else if(msg == "Whisper") {
            llMessageLinked(LINK_THIS, -3, "Chatter:1", NULL_KEY);
            g_chatter = 1;
            offerMenu(id, m_chatter(), g_currMenuButtons);
        }
        else if(msg == "Private") {
            llMessageLinked(LINK_THIS, -3, "Chatter:0", NULL_KEY);
            g_chatter = 0;
            offerMenu(id, m_chatter(), g_currMenuButtons);
        }
        else if(msg == "Skins") {
            g_currMenu = msg;
            if(g_diaperType == "Fluffems" || g_diaperType == "PiedPiper") {
                //these two diapers only use one prim for skins
                g_currCount = -1;
                list temp;
                if(llGetListLength(g_Skins) <= 11) {
                    temp = ["<--BACK"] + llList2List(g_Skins, g_currCount+1, g_currCount+11);
                    g_currCount += 12; //g_currCount is now 11 (starts at -1)
                }
                else {
                    temp = ["<--BACK", "NEXT-->"] + llList2List(g_Skins, g_currCount+1, g_currCount+10); // This is a list of 10 skins
                    g_currCount += 11; //g_currCount is now 10 (starts at -1)
                }
                offerMenu(id, "Choose a Skin:", temp);
            }
            else if(g_diaperType == "Kawaii") {
                //this diaper can use tapes, panels, and the like, so show the skin menu instead
                offerMenu(id, "Change the diaper's appearance!", g_skinsMenu);
            }
        }
        else if(msg == "Help") {
            llOwnerSay("Adding your own skins and notecards is easy!  Just prefix your textures with the appropriate tag for where you want it to be and drag it into the diaper!  I'll take care of the rest.");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "Potty") {
            g_currMenu = msg;
            offerMenu(id, m_pottyMenu(), g_pottyMenu);  
        }
        else if(msg == "Volume") {
            g_currMenu = msg;
            offerMenu(id, m_volumeMenu(), g_volumeMenu);  
        }
        else if(msg == "Mess❤Timer") {
            g_currMenu = msg;
            offerMenu(id, m_messTimer(), g_timerOptions);   
        }
        else if(msg == "Wet❤Timer") {
            g_currMenu = msg;
            offerMenu(id, m_wetTimer(), g_timerOptions);   
        }
        else if(msg == "Wet%") {
            g_currMenu = msg;
            offerMenu(id, m_wetChance(), g_chanceOptions);   
        }
        else if(msg == "Mess%") {
            g_currMenu = msg;
            offerMenu(id, m_messChance(), g_chanceOptions);
        }
        else if(msg == "❤Tickle❤") {
            g_currMenu = msg;
            offerMenu(id, m_tickleChance(), g_chanceOptions);   
        }
        else if(msg == "Tummy❤Rub") {
            g_currMenu = msg;
            offerMenu(id, m_tummyRubChance(), g_chanceOptions);   
        }
        else if(msg == "Printouts") {
            g_currMenu = msg;
            g_currCount = -1;
            list temp;
        
            if(llGetListLength(g_Printouts) <= 11) {
                temp = ["<--BACK"] + llList2List(g_Printouts, g_currCount+1, g_currCount+11);
                g_currCount += 12; //g_currCount is now 11 (starts at -1)
            }
            else {
                temp = ["<--BACK", "NEXT-->"] + llList2List(g_Printouts, g_currCount+1, g_currCount+10); // This is a list of 10 skins
                g_currCount += 11; //g_currCount is now 10 (starts at -1)
            }
            offerMenu(id, "Choose a Printout style:", temp);
        }
        else if(msg == "Gender") {
            g_currMenu = msg;
            offerMenu(id, "Are you a boy or a girl?", g_genderMenu);   
        }
        else if(msg == "Interactions") {
            g_currMenu = msg;
            offerMenu(id, m_interactions(), g_interactionsOptions);
        }
        else if(msg == "Chatter") {
            g_currMenu = msg;
            offerMenu(id, m_chatter(), g_chatterMenu);
        }
        else if(msg == "Crinkle❤Volume") {
            g_currMenu = msg;
            offerMenu(id, m_crinkleVolume(), g_chanceOptions);
        }
        else if(msg == "Wet❤Volume") {
            g_currMenu = msg;
            offerMenu(id, m_wetVolume(), g_chanceOptions);
        }
        else if(msg == "Mess❤Volume") {
            g_currMenu = msg;
            offerMenu(id, m_messVolume(), g_chanceOptions);
        }
        else if(msg == "Resize") {
            llMessageLinked(LINK_THIS, 900, "MENU", NULL_KEY);
        }
        else if(msg == "<--TOP") {
            llMessageLinked(LINK_THIS, -3, "Cancel:"+(string)id, NULL_KEY);
        }
    }
}
