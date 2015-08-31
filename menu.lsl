/*==========================================================
DrizzleScript
Created By: Ryhn Teardrop
Original Date: Dec 3rd, 2011
GitHub Repository: https://github.com/DoomRater/DrizzleScript

Programming Contributors: Ryhn Teardrop, Brache Spyker
Resource Contributors: Murreki Fasching, Brache Spyker

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.

*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

// Main Script used for the Diaper, is the central hub of
// communication between all other scripts 
list g_userMenu = ["Show/Hide", "Options", "On/Off", "❤Flood❤", "Check", "Change", "Get❤Soggy", "Get❤Stinky", "Caretakers","Update"];
list g_careMenu = ["Check", "Change", "Tease", "Raspberry", "Poke", "Options","Show/Hide", "❤ ❤ ❤", "Carer❤List"];
list g_careMenuDiaper = ["Force❤Wet", "Force❤Mess","❤Tickle❤", "Tummy❤Rub", "Wedgie", "Spank"];
list g_userCareMenu = ["<--BACK", "*", "*", "Add", "Remove", "List"];
list g_inboundMenu = ["❤Tickle❤", "Tummy❤Rub", "Tease", "Check", "Change", "Raspberry", "Spank", "Wedgie", "Poke"];
list g_offMenu = ["On", "Options", "Show/Hide"];
string g_commandHandle;
list g_Carers;
list g_ButtonCarers;  //to address really long carer names
list g_detectedAvatars;
list g_ButtonizedAvatars; //for bugfix "cannot add carers whose names are really long"
list g_detectedKeys; // Used, for now, only to ask carers information.
key g_nameQuery;

integer g_addRemove = -1;
integer g_uniqueChan = -1;
integer g_mainListen;
integer g_carerListen;
integer g_userResponded = FALSE;

//Saved Non-Carer Settings
integer g_wetLevel = 0;    //0 - 5 times wet
integer g_messLevel = 0;   //0 - 2 times messed
integer g_wetChance = 40; //Percent
integer g_messChance = 20;//Percent
integer g_wetTimer = 20;   //Minutes
integer g_messTimer = 30;  //Minutes
integer g_tummyRub = 50;   //Percent
integer g_tickle = 50;     //Percent
integer g_gender = 1;      // 0:Male || 1:Female, this diaper was being edited for a girl
integer g_isOn = TRUE;
integer g_interact = TRUE;    //will control whether non-carers can interact with the diaper
integer g_chatter = 2;     // 0:self-chatter 1:Whisper chatter 2:say chatter
integer g_CrinkleVolume = 10;
integer g_WetVolume = 100;  //this value is thirded on normal wets
integer g_MessVolume = 100;
integer g_PlasticPants = FALSE;
integer g_timesHeldWetStrength = 3; //how many times you can hold it before you flood
integer g_timesHeldWetMultiplier = 10; //how much harder it gets each time you successfully hold it, in percent
integer g_timesHeldMessMultiplier = 10;
//End Saved Non-Carer Settings

integer g_mForecast = 0; // Determines how long until the next mess chance
integer g_wForecast = 0; // Determines how long until the next wet chance
integer timesHeldWet = 0;
integer timesHeldMess = 0;
string g_newCarer = "";

integer g_isCrinkling = FALSE;  //just to tell the diaper if someone is still walking

string g_exitText = ""; //text entered here will be spoken to the owner when the diaper is removed.
string g_diaperType = "";
string g_updateScript = "ME Wireless DrizzleScript Updater";
integer isDebug = FALSE;
//set isDebug to 1 (TRUE) to enable all debug messages, and to 2 to disable info messages

/* Puppy Pawz Pampers Variables */
integer g_wetPrim;
integer g_messPrim;
/* End of PPP variables*/

/* Nezzy's Brand Kawaii Diapers Variables */
//Kawaii doesn't use multiple prims for its settings, instead it uses faces
integer g_wetFace = 0;
integer g_errorCount = 0;
/*End of Kawaii variables*/

init()
{
    llListenRemove(g_mainListen);
    g_uniqueChan = generateChan(llGetOwner()); // Used to avoid diapers talking to one another via menus.
    if(g_isOn == FALSE) {
        llSetTimerEvent(0.0); // Used to check for wet/mess occurances
    }
    else if(g_isOn == TRUE) {
        llSetTimerEvent(60.0);
    }
    //find updater script and update the usermenu depending on results
    integer updateInMenu = llListFindList(g_userMenu,["Update"]);
    if(llGetInventoryType(g_updateScript) == INVENTORY_SCRIPT) {
        if(updateInMenu == -1) {
            g_userMenu += ["Update"];
        }
    }
    else {
        if(~updateInMenu) {
            g_userMenu = llDeleteSubList(g_userMenu,updateInMenu,updateInMenu);
        }
    }
    //If debug mode is active, add a Debug button to user menu
    integer debugInMenu = llListFindList(g_userMenu,["DEBUG"]);
    if(isDebug == TRUE) {
        llOwnerSay("Debug mode active.  Error messages will be printed out!");
        if(debugInMenu == -1) {
            g_userMenu += ["DEBUG"];
        }
    }
    else if(isDebug == 2) {
        llOwnerSay("Silent mode.  No info messages will be printed byond this point.");
    }
    llRequestPermissions(llGetOwner(),PERMISSION_TAKE_CONTROLS); //so we can see whether someone is moving and make them crinkle!
    if(g_diaperType == "") {
        detectDiaperType();
    }
    g_mainListen = llListen(g_uniqueChan, "", "", "");
}

string constructHandle() {
    string temp = llKey2Name(llGetOwner());
    integer space = llSubStringIndex(temp," ");
    temp = llGetSubString(temp,0,0) + llGetSubString(temp,space+1,space+1);
    return llToLower(temp) + "diaper";
}


checkForUpdates() {
    if(isDebug < 2) {
        llOwnerSay("Checking for updates!");
    }
    if(llGetInventoryType(g_updateScript) == INVENTORY_SCRIPT) {
        llResetOtherScript(g_updateScript);
    }
    else if(isDebug == TRUE) {
        llOwnerSay("No update script found!");
    }
}

detectDiaperType() {
    key mainPrimCreator = llGetCreator();
    //JDroo Resident, creator of Kawaii Diapers
    if(mainPrimCreator == "b9878483-a1fc-411f-8d9c-be53795eca6e") {
        g_diaperType = "Kawaii";
    }
    //our fallback is to use Fluffems
    else {
        g_diaperType = "Fluffems";
    }
}

playWetAnimation() {
    if(llGetInventoryType("DrizzleWetAnim") != -1) { // Animation exists in inventory
        llStartAnimation("DrizzleWetAnim");
    }
    else {
        if(isDebug==TRUE) {
            llOwnerSay("No Animation Found!\nPlease drop an animation named: DrizzleWetAnim into your model!");
        }
    }
}

startCrinkleSound(float volume) {
    if(llGetInventoryType("DrizzleCrinkleSound") != -1) { // Sound exists in inventory
        //todo: create adjustable volume settings
        llLoopSound("DrizzleCrinkleSound", volume); 
    }
    else {
        if(isDebug==TRUE) {
            llOwnerSay("No Sound Found!\nPlease drop a soundfile named: DrizzleCrinkleSound into your model!");
        }
    }
}

stopCrinkleSound() {
    llStopSound();
}

playWetSound(float volume) {
    if(llGetInventoryType("DrizzleWetSound") != -1) { // Sound exists in inventory
        llPlaySound("DrizzleWetSound", volume); 
    }
    else {
        if(isDebug==TRUE) {
            llOwnerSay("No Sound Found!\nPlease drop a soundfile named: DrizzleWetSound into your model!");
        }
    }
}

playMessAnimation() {
    if(llGetInventoryType("DrizzleMessAnim") != -1) {// Animation exists in inventory
        llStartAnimation("DrizzleMessAnim");
    }
    else {
        if(isDebug==TRUE) {
            llOwnerSay("No Animation Found!\nPlease drop an animation named: DrizzleMessAnim into your model!");
        }
    }
}

playMessSound(float volume) {
    if(llGetInventoryType("DrizzleMessSound") != -1) { // Sound exists in inventory
        //todo: create a mess sound
        llPlaySound("DrizzleMessSound", volume); 
    }
    else {
        if(isDebug==TRUE) {
            llOwnerSay("No Sound Found!\nPlease drop a soundfile named: DrizzleMessSound into your model!");
        }
    }
}

// This function receives a CSV(Comma Separated Values) of the current settings, and parses it to 
// properly set the current state of the diaper.
// @temp = A CSV of the settings sent from SaveSettings.lsl
parseSettings(string temp) {
    integer index; // Used to hold the location of a comma in the CSV
    
    //I opted to not use llCSV2List to avoid the overhead associated with storing and cutting up lists.
    //I'm simply finding commas in the string, and cutting out the values between them.
    
    index = llSubStringIndex(temp, ",");
    g_wetLevel = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1); // Remove the used data.
    
    index = llSubStringIndex(temp, ",");
    g_messLevel = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_wetChance = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_messChance = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    integer newTimer = (integer) llGetSubString(temp, 0, index-1);
    //This is messy but needed here
    if(g_wetTimer != newTimer) {
        if(newTimer == 0) {
            g_wForecast = 2000000000;
        }
        else {
            g_wForecast = myTimer(newTimer * 60);
        }
        g_wetTimer = newTimer;
    }
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    newTimer = (integer) llGetSubString(temp, 0, index-1);
    //A little more messy
    if(g_messTimer != newTimer) {
        if(newTimer == 0) {
            g_mForecast = 2000000000;
        }
        else {
            g_mForecast = myTimer(newTimer * 60);
        }
        g_messTimer = newTimer;
    }
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
    g_isOn = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_interact = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_chatter = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_CrinkleVolume = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_WetVolume = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_MessVolume = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    g_PlasticPants = (integer) temp;
    
}//End parseSettings(string)

// Returns a forecast duration number of seconds in the future.
// @ param [duration] : number of seconds to forecast in script runtime. 
// @ return : the forcasted time for timer hub to execute associated command.
integer myTimer(integer duration) {
    integer x = llRound(llGetTime());
    
    if(x + duration > 2000000000) { // Failsafe, resets script time if approaching threshold for integer capacity.
        //we need to adjust the forecasts so they aren't unobtainable due to time reset
        g_wForecast -= x;
        g_mForecast -= x;
        llResetTime();
        x = llRound(llGetTime());
    }
    return x + duration;
}

/*
Sends a message to the SaveSettings script containing a CSV of all values stored here.
This can be arbitrarily expanded as long as the values fit within the description of a single prim. 
This function only uses global variables, so if those are changed within the script, this needs to be called again.
*/
sendSettings() {
    string csv = (string) g_wetLevel + "," +
    (string) g_messLevel + "," +
    (string) g_wetChance + "," +
    (string) g_messChance + "," +
    (string) g_wetTimer + "," +
    (string) g_messTimer + "," +
    (string) g_tummyRub + "," +
    (string) g_tickle + "," +
    (string) g_gender + "," +
    (string) g_isOn + "," +
    (string) g_interact + "," +
    (string) g_chatter + "," +
    (string) g_CrinkleVolume + "," +
    (string) g_WetVolume + "," +
    (string) g_MessVolume + "," +
    (string) g_PlasticPants;
    //llMessageLinked(LINK_ALL_OTHERS, 6, csv, NULL_KEY); //depreciated now that memory core is no longer attached
    //todo: detect if memory core is attached and has sent us data first before sending
    llSay(g_uniqueChan,"SETTINGS:"+csv); //tell memory core new data
    llMessageLinked(LINK_THIS, -6, csv, NULL_KEY);
}

integer generateChan(key id) {
    string channel = "0xE" +  llGetSubString((string)id, 0, 6);
    return (integer) channel;
}

// This function gives the wearer a chance to hold their potties
// A percentage is weighed.
// @type = The form of diaper use to be attempted.
// Case 1: Success, Held it, printout
// Case 2: Failure, Had an Accident,  printout
integer findPercentage(string type) {
    // Add check for trainer mode.
    integer toCheck;

    if(type == "Rub") {
        toCheck = (integer) llFrand(100); // Random number between 0 and 99
        ++toCheck;                       // ++i used to achieve 1 - 100 range.
        
        if(toCheck <= g_tummyRub) {
            return FALSE;
        }
        else {
            return TRUE;
        }
    }
    else if(type == "Tckl") {
        toCheck = (integer) llFrand(100); // Random number between 0 and 99
        ++toCheck;                       // ++i used to achieve 1 - 100 range.
        
        if(toCheck <= g_tickle) {
            return FALSE;
        }
        else {
            return TRUE;
        }
    }
    else if(type == "W") {
        toCheck = (integer) llFrand(100); // Random number between 0 and 99
        ++toCheck;                       // ++i used to achieve 1 - 100 range.
        if(toCheck + (timesHeldWet * g_timesHeldWetMultiplier) <= g_wetChance) { //timesHeldWet is a modifier that makes you less likely to hold it.
            timesHeldWet++; // The more times you hold it, the more likely you are to potty next time.
            return FALSE;
        }
        else {
            return TRUE;
        }
    }
    else if(type == "M") {// Use Mess Chance
        toCheck = (integer) llFrand(100); // Random number between 0 and 99
        ++toCheck;                       // ++i used to achieve 1 - 100 range.
        if(toCheck + (timesHeldMess * g_timesHeldMessMultiplier) <= g_messChance) {//timesHeldMess is a modifier that makes you less likely to hold it.
            timesHeldMess++; // The more times you hold it, the more likely you are to potty next time.
            return FALSE;
        }
        else
        {
            return TRUE;
        }
    }
    //If we get here, we clearly don't want something unknown to return TRUE.
    return FALSE;
} //End findPercentage(string)

// This function is called to manage diaper changes
// @msg = The type of change occuring, e.g. Changing yourself, being changed, and being changed by a carer.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleChange(string msg, key id) {
    g_wetLevel = 0;
    g_messLevel = 0;
    
    //Let Printouts 2 know to reset its forced variables.
    llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + "Change", NULL_KEY);
    
    if(msg == "Self") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Self Change" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Carer") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Carer Change" + ":" + llKey2Name(id), id);
    }
    else if(msg == "Other") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Normal Change" + ":" + llKey2Name(id), id);
    }
//    adjustWetMessPrims();
    sendSettings();
}//End handleChange(string, id)
// This function is called to manage wettings
// @msg = The type of accident occuring, e.g. wetting yourself, being tickled, and being forced by a carer to wet.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleWetting(string msg, key id) {
    g_wetLevel++;
    if(msg == "Self") {
        //Example of what message looks like: 1:2:g_wetLevel:Name
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_wetLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Timer") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_wetLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Tckl") {
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Tickle Success" + ":" + llKey2Name(id), id);   
    }
    else if(msg == "Force") {
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Force Wet" + ":" + llKey2Name(id), id); 
    }
    playWetSound(g_WetVolume * .00333);
    timesHeldWet = 0;
    //new forecast for wetting
    g_wForecast = myTimer(g_wetTimer * 60);
    sendSettings();
}//End handleWettings(string, key)

// This function is called to manage messings
// @msg = The type of accident occuring, e.g. messing yourself, being squeezed/tummy rub, and being forced by a carer to get stinky.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleMessing(string msg, key id) {
    g_messLevel++;
    if(msg == "Self") {
        //Example of what message looks like: 1:2:g_wetLevel:Self
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_messLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Timer") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_messLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Rub") {
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Rub Success" + ":" + llKey2Name(id), id);
    }
    else if(msg == "Force") {
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Force Mess" + ":" + llKey2Name(id), id);
    }
    timesHeldMess = 0;
    //new forecast for messing
    g_mForecast = myTimer(g_messTimer * 60);
    sendSettings();
}//End handleMessing(string, key)

// This function is called to manage a special-case wetting.
// @msg = The type of accident occuring, e.g. naturally flooding yourself, or being potentially forced by a carer.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleFlooding(string msg, key id) {
    g_wetLevel = g_wetLevel + 4;
    if(msg == "Self") {
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Self Flood" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Timer") { //added to allow separation of timer floods and forced floods
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Self Flood" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    playWetSound(g_WetVolume * .01);  //todo: add a special flooding sound
    timesHeldWet = 0;
    //new forecast for wetting
    g_wForecast = myTimer(g_wetTimer * 60);
    sendSettings();
}

/* 
    Updates wet/mess prims to show as required.
    Refer to Potty.lsl for exact details
*/
adjustWetMessPrims() {
    llMessageLinked(LINK_THIS, -2,(string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel, NULL_KEY);
}//End WetMessPrims()

// Shows or hides the full model of the diaper.
// Note: If multiple overlapping models are used to display wet/mess
// this function would need to adjust based on the wetness/messyness of the diaper.
// Example: Crinklebutt hides or shows multiple faces for its front and back
toggleHide() {   
    if(llGetAlpha(ALL_SIDES) == 0.0) {  // Hidden; Show it.
        llSetLinkAlpha(LINK_SET, 1.0, ALL_SIDES);
    }
    else {    // Shown; Hide it.
        llSetLinkAlpha(LINK_SET, 0.0, ALL_SIDES);
    }
}

//This function flips the value of a boolean variable, and
//turns the Timer event on and off as appropriate.
toggleOnOff() {
    g_isOn = !g_isOn;
    if(g_isOn == FALSE) {
        llSetTimerEvent(0.0);
    }
    else {
        llResetTime();
        llSetTimerEvent(60.0);  //Check to see if a user wet/messed themselves once a minute.
    }
    sendSettings();
}

printDebugSettings() {
    llOwnerSay("Wetness: " + (string) g_wetLevel);
    llOwnerSay("Messiness: " + (string) g_messLevel);
    llOwnerSay("Wet Hold: " + (string) g_wetChance + "%");
    llOwnerSay("Mess Hold: " + (string) g_messChance + "%");
    llOwnerSay("Wet Frequency: " + (string) g_wetTimer + " Minute(s)");
    llOwnerSay("Mess Frequency: " + (string) g_messTimer + " Minute(s)");
    llOwnerSay("TummyRub Resist: " +  (string) g_tummyRub + "%");
    llOwnerSay("Tickle Resist: " + (string) g_tickle + "%");
    llOwnerSay("Gender: " + (string) g_gender);
    llOwnerSay("On/Off: " + (string) g_isOn);
    llOwnerSay("Other Interaction: " + (string) g_interact);
    llOwnerSay("Channel: " + (string) g_uniqueChan);
    llOwnerSay("Detected Avatars: " + llDumpList2String(g_detectedAvatars,", "));
    llOwnerSay("Wet Prim: " + (string) g_wetPrim);
    llOwnerSay("Mess Prim: " + (string) g_messPrim);
    llOwnerSay("Crinkle Volume: "+(string) g_CrinkleVolume);
    llOwnerSay("Wet Sound Volume: "+(string) g_WetVolume);
    llOwnerSay("Mess Sound Volume: "+(string) g_MessVolume);
    llOwnerSay("Times Held (wet): "+(string) timesHeldWet);
    llOwnerSay("Times Held (mess): "+(string) timesHeldMess);
    llOwnerSay("Used Memory: " + (string) llGetUsedMemory());
    llOwnerSay("Free Memory: " + (string) llGetFreeMemory());
}

/* Basic function for printing out the carer's list with a header */
printCarers(key id) {
    llRegionSayTo(id, 0, "Carer List: " + llDumpList2String(g_Carers,", "));
    if(isDebug == TRUE) {
        llRegionSayTo(id, 0, "Buttonized List: "+ llDumpList2String(g_ButtonCarers,", "));
    }
}

//Called at Startup to initialize variables from the memory core.
loadCarers() {
    llSay(g_uniqueChan,"CARERS:Load"); //Tell the memory core to send us its data!
}

// If a given name is not already in the carer's list, we add them to the carer's list.
// @name - The name to be tested for carer status
addCarer(string name) {
    if(~llListFindList(g_Carers, [name])) {
        llOwnerSay("You've already added that carer once silly!");   
    }
    else {
        llSay(g_uniqueChan, "CARERS:Add:"+name); //Tell the memory core to remember this carer.
        g_Carers += name;
        makeButtonsForCarers();
    }
}

// If a given name is already in the carer's list, we remove them from the carer's list.
// Otherwise the user is informed of their mistake.
// @name - The name to be tested for carer status
removeCarer(string name) {
    integer carerIndex =llListFindList(g_ButtonCarers, [name]);
    if(~carerIndex) {
        llSay(g_uniqueChan, "CARERS:Remove:"+name); //Tell the memory core to remove this carer.
        g_Carers = llDeleteSubList(g_Carers,carerIndex,carerIndex);
        makeButtonsForCarers();
    }
    else {
        llOwnerSay("That person isn't on your list!");
    }
}

makeButtonsForCarers() { //construct g_ButtonCarers from g_Carers
    integer index = llGetListLength(g_Carers) - 1;
    g_ButtonCarers = []; //clear the button list
    while (~index) {
    //Ew, this is long and convoluted.
        g_ButtonCarers = [llBase64ToString(llGetSubString(llStringToBase64(llList2String(g_Carers,index)), 0, 31))] + g_ButtonCarers;
        index--;
    }
}

// Returns a value from 0 to 2 to classify the menu access level for a given user.
// @id - The user whose access level is to be assessed.
// 0 = Owner, 1 = Carer, 2 = Outsider
integer getToucherRank(key id) {
    if(llGetOwnerKey(id) == llGetOwner()) {
        return 0;
    }
    else if(~llListFindList(g_Carers, [llKey2Name(id)])) {
        return 1;
    }
    else {
        return 2;
    }
}
 
mainMenu(key id) {
    integer userRank = getToucherRank(id);
    if(g_isOn) { // Diaper's On
        if(userRank == 0) {
            llDialog(llGetOwner(), "User Menu for " + llKey2Name(llGetOwner()) + "'s diaper.", g_userMenu, g_uniqueChan);
        }
        else if(userRank == 1) {
            llDialog(id, "Carer Menu for " + llKey2Name(llGetOwner()) + "'s diaper.", g_careMenu, g_uniqueChan);
        }
        //todo: Allow restriction to this menu!
        else if(userRank == 2 && g_interact == 1) {
            llDialog(id, "General Menu for " + llKey2Name(llGetOwner()) + "'s diaper.", g_inboundMenu, g_uniqueChan);
        }
        else if(g_diaperType == "Kawaii") {
            nedryError(id);
        }
    }
        else { // Diaper's Off
        if(userRank == 0) {
            llDialog(llGetOwner(), "Your diaper is off.  No pottying or carer scanning will be done, but you can still change settings!", g_offMenu, g_uniqueChan);
        }
        else if(userRank == 1) {
            llDialog(id, "Good news! You're a carer. This means you can turn this diaper back on if you wish!", g_offMenu, g_uniqueChan);
        }
        else if(g_diaperType == "Kawaii") {
            nedryError(id);
        }
    } 
}

//function for Kawaii Diapers
//emulates Nedry's "ah ah ah!" speech if someone tries to do things they shouldn't
nedryError(key id) {
    g_errorCount++;
    if(g_errorCount < 3) {
        llRegionSayTo(id, 0, "Access Denied!");
    }
    else {
        llRegionSayTo(id, 0, "Access Denied! And....");
        llSleep(2.0);
        integer spamCount = 10;
        while(spamCount) {
            llRegionSayTo(id, 0, "YOU DIDN'T SAY THE MAGIC WORD!");
            spamCount--;
        }
        //Send message to Kawaii plugin to trigger the error
        g_errorCount = 0;
    }
}


default {
    state_entry() {
        init();
        loadCarers();
        //this only needs to be done once, for now
        g_commandHandle = constructHandle();
        if(isDebug == TRUE) {
            llOwnerSay("Your command handle is "+g_commandHandle);
        }
        llListen(1,"","",g_commandHandle);
    }
    
    run_time_permissions(integer perm) {
        if(perm&PERMISSION_TAKE_CONTROLS) {
            llTakeControls(CONTROL_FWD|CONTROL_BACK|CONTROL_LEFT|CONTROL_RIGHT,TRUE,TRUE);
        }
    }
    
    control(key id, integer l, integer e) {
        if((~l & e) || (llGetAgentInfo(llGetOwner()) & (AGENT_IN_AIR |AGENT_SITTING | AGENT_ON_OBJECT))) { //are they in the air, sitting, or did they stop moving?
            stopCrinkleSound();
            g_isCrinkling = FALSE;
        }
        else {
            if(g_isCrinkling == FALSE) { //only start playing the sound if we weren't already looping it, so not to spam sound events.
                startCrinkleSound(g_CrinkleVolume * .005); //half as loud
            }
            g_isCrinkling = TRUE;
        }
    }
        
    attach(key id) {
        if(id) { // Attached
            
        }
        else if(g_exitText)
        {
            if(isDebug<2) {
                llOwnerSay(g_exitText); //bye bye :(
            }
        }
    }
    
    changed(integer change) {
        if(change & CHANGED_OWNER) {
            init();
        }
    }
    //Searches the area, stashing the names of those nearby in one list, and their keys in another
    sensor(integer num_detected) {
        integer i = 0;
        //flush the old names because they might not be around anymore
        g_detectedAvatars = [];
        g_ButtonizedAvatars = [];
        g_detectedKeys = [];
        
        while(i < num_detected && i < 12) {  //only get the first 12 people in range
            string temp = llDetectedName(i);
            g_detectedAvatars += temp;
            g_detectedKeys += llDetectedKey(i);
            if(llStringLength(temp)>24) {
                g_ButtonizedAvatars += llBase64ToString(llGetSubString(llStringToBase64(temp), 0, 31));
            }
            else {
                g_ButtonizedAvatars += temp;
            }
            i++;
        }
    }
    
    no_sensor() { // Take this moment of silence to clean out the lists
        g_detectedAvatars = [];
        g_ButtonizedAvatars = [];
        g_detectedKeys = [];
    }
    
    on_rez(integer start_param) {
        init(); // Pulls new data
    }
    
    touch_start(integer total_number) {
        key id = llDetectedOwner(0);
        integer userRank = getToucherRank(id); // 0 = Owner, 1 = Carer, 2 = Outsider
        mainMenu(id);
    }//End touch_start(integer)
    
    listen(integer chan, string name, key id, string msg) {
        integer userRank = getToucherRank(id); // Used to secure the diaper against tomfoolery
        if(msg == g_commandHandle) {
            mainMenu(id);
        }
        else if(msg == "DEBUG" && userRank == 0) {
            printCarers(id);
            printDebugSettings();
            mainMenu(id);
        }
        else if(msg == "Show/Hide" && userRank < 2) {
            toggleHide(); // Needs to keep in mind what Should and SHOULD NOT be visible
            adjustWetMessPrims(); // Ensure prims are properly hidden/shown after a state change.
            mainMenu(id);
        }
        else if(msg == "Options" && userRank < 2) {
            sendSettings(); //make sure preferences knows the current settings
            llMessageLinked(LINK_THIS, -1, msg, id); // Tell Preferences script to talk to id
        }
        else if(msg == "❤ ❤ ❤" && userRank == 1) {
            llDialog(id, "For the mischievous brat in us all.",  g_careMenuDiaper, g_uniqueChan);        
        }
        else if(msg == "On/Off" || msg == "On"){
            if(userRank < 2) {
                toggleOnOff();
                mainMenu(id);
            }
            else if(g_diaperType == "Kawaii") {
                nedryError(id);
            }
        }
        else if(g_isOn) {
            //for future use with potty training
            if(msg == "Hold❤It" && userRank == 0) {
                g_userResponded = TRUE;
            }
            else if(msg == "Go❤Potty" && userRank == 0) {
                g_userResponded = TRUE;
            }
            //Carers stuff
            else if(llKey2Name(id) == g_newCarer) { //shaping up security
                if(msg == "Accept") {
                    llOwnerSay(g_newCarer+" has agreed to be your caretaker!");
                    addCarer(g_newCarer);
                    g_addRemove = -1;   
                    llListenRemove(g_carerListen);
                }
                else if(msg == "Decline") {
                    llOwnerSay("Your offer was declined, sorry. )=");
                    llListenRemove(g_carerListen);
                }
                g_newCarer = "";
            }
            else if(~llListFindList(g_ButtonizedAvatars,[msg]) && userRank == 0) { //Start of Caretaker handling
                if(g_addRemove == 1) { //Adding a carer
                    integer temp = llListFindList(g_ButtonizedAvatars,[msg]);
                    g_newCarer = llList2String(g_detectedAvatars,temp);
                    g_carerListen = llListen(g_uniqueChan-1, "", "", ""); //determine if this is necessary anymore
                    llDialog(llList2Key(g_detectedKeys, temp), llKey2Name(llGetOwner()) + " would like to add you as a carer.", ["Accept", "Decline"], g_uniqueChan-1);
                }
                else if(g_addRemove == 0) {// Deleting a carer
                    removeCarer(msg);
                    g_addRemove = -1;
                }

            }
            else if(~llListFindList(g_ButtonCarers,[msg]) && userRank == 0) {
                if(g_addRemove == 0) {// Deleting a carer
                    removeCarer(msg);
                    g_addRemove = -1;
                }
            }
            else if(msg == "Caretakers" && userRank == 0) {
                llSensor("", "", AGENT, 96.0, PI); // Populate the nearby avatar menus
                llDialog(id, "Customize your carers!", g_userCareMenu, g_uniqueChan);
            }
            else if(msg == "Add" && userRank == 0) {
                llDialog(id, "Who would you like to care for you?", g_ButtonizedAvatars, g_uniqueChan);
                g_addRemove = 1;
            }
            else if(msg == "Remove" && userRank == 0) {
                llDialog(id, "Who would you like to remove?", g_ButtonCarers, g_uniqueChan);
                g_addRemove = 0;   
            }
            else if(msg == "Carer❤List" && userRank == 1) {
                printCarers(id);
                mainMenu(id);
            }
            else if(msg == "List" && userRank == 0) {
                printCarers(id);
                llDialog(id, "Customize your carers!", g_userCareMenu, g_uniqueChan);
            }//End of Caretaker handling
            else if(msg == "<--BACK") {
                mainMenu(id);
            }
            else if(msg == "Get❤Soggy" && userRank == 0) {
                handleWetting("Self", id);
                mainMenu(id);
            }
            else if(msg == "Get❤Stinky" && userRank == 0) {
                handleMessing("Self", id);    
                mainMenu(id);
            }
            else if(msg == "❤Flood❤" && userRank == 0) {
                handleFlooding("Self", id);
                mainMenu(id);
            }
            else if(msg == "Force❤Mess" && userRank == 1) {
                handleMessing("Force", id);
                mainMenu(id);
            }
            else if(msg == "Force❤Wet"  && userRank == 1) {
                handleWetting("Force", id);
                mainMenu(id);
            }
            else if(msg == "Check") {
                if(userRank == 0) { // User checked self
                    llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Self Check" + ":" + llKey2Name(llGetOwner()), llGetOwner());
                }
                else if(userRank == 1) { // Carer
                    llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Carer Check" + ":" + llKey2Name(id), id);
                }
                else if(userRank == 2 && g_interact == 1) { // Outsider, with permission of course
                     llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Other Check" + ":" + llKey2Name(id), id);
                }
                else if(userRank == 2) {
                    if(g_diaperType == "Kawaii") {
                        nedryError(id);
                    }
                    return;
                }
                mainMenu(id);
            }
            else if(msg == "Change") {
                if(userRank == 0) {
                    handleChange("Self", id);
                }
                else if(userRank == 1) {
                    handleChange("Carer", id);   
                }
                else if(userRank == 2 && g_interact == 1) {
                    handleChange("Other", id);
                }
                else if(userRank == 2) {
                    if(g_diaperType == "Kawaii") {
                        nedryError(id);
                    }
                    return;
                }
                mainMenu(id);
            }
            else if(msg == "Update" && userRank == 0) {
                checkForUpdates();
                mainMenu(id);
            }
            //check for carer userrank or if outsiders are allowed to trigger events
            else if(userRank == 1 || g_interact == TRUE) {
                if(msg == "Tummy❤Rub") {
                    if(findPercentage("Rub")) { // They messied!
                        handleMessing("Rub", id);
                    }
                    else { // No mess this time!
                         llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Rub Fail" + ":" + llKey2Name(id), id);
                    }
                    mainMenu(id);
                }
                else if(msg == "❤Tickle❤") {
                    if(findPercentage("Tckl")) { // They wet!
                        handleWetting("Tckl", id);
                    }
                    else {
                        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Tickle Fail" + ":" + llKey2Name(id), id);
                    }
                    mainMenu(id);
                }
                else if(msg == "Raspberry") {
                     llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Raspberry" + ":" + llKey2Name(id), id);
                    mainMenu(id);
                }
                else if(msg == "Poke") {
                    llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Poke" + ":" + llKey2Name(id), id);            
                    mainMenu(id);
                }
                else if(msg == "Spank") { // ouch!
                    llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Spank" + ":" + llKey2Name(id), id);
                    mainMenu(id);
                }
                else if(msg == "Tease") { // wah!
                    llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Tease" + ":" + llKey2Name(id), id);
                    mainMenu(id);
                }
                else if(msg == "Wedgie") {
                    llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Wedgie" + ":" + llKey2Name(id), id);
                    mainMenu(id);
                }
            }
        }
    }//End of listen(integer, string, key, string)
            
    // This event is used to evaluate/reset the forecasts for wetting or messing, as well 
    // as determining whether a user succeeds in holding it.
    timer() {
        if(g_isOn == TRUE) {
            //Timer of 0 (Off) prevent accidents.
            if(g_wetTimer == 0) {
                g_wForecast = 2000000000;
            }
            //Timer of 0 (Off) prevent accidents.
            if(g_messTimer == 0) {
                g_mForecast = 2000000000;
            }
            integer currentTime = llRound(llGetTime());
            if(currentTime <= 60) {
                return;
            }
            // If both wet and mess forecasts are past their time. . .
            if(g_wForecast <= currentTime && g_mForecast <= currentTime) {
                // New wet forecast. This means the user will mess by default. :D
                g_wForecast = myTimer(g_wetTimer * 60);
            }
           
            if(g_wForecast <= currentTime) { // The forecasted time is in the past
                if(findPercentage("W") == TRUE) {
                    if(timesHeldWet >= g_timesHeldWetStrength) { // If the user has held it a lot. This time they flood.
                        handleFlooding("Timer", llGetOwner());
                    }
                    else {
                        handleWetting("Timer", llGetOwner()); // "Timer" is the cause of the wetting, llGetOwner is to determine what printout to trigger.
                    }
                }
                else {
                    //todo: potty training handler will go here!
                }
                g_wForecast = myTimer(g_wetTimer * 60); // New Forecast Regardless
            }
            
            if(g_mForecast <= currentTime) { 
                if(findPercentage("M") == TRUE) {
                    handleMessing("Timer", llGetOwner()); 
                }
                g_mForecast = myTimer(g_messTimer * 60);
            }
        }//End g_isOn if
        //reset the Kawaii error count each minute
        g_errorCount = 0;
    }//End of timer
    
    //This is the main communications relay from other scripts.
    //todo: move these comments to documentation
    // -1       = Preferences Script
    // -2 or -4 = Printouts Script
    // -7       = reserved for Particles
    //  1 to 5  = Storage Prim Messages
    //  6       = Setting Message from Memory Core
    // -6       = Setting Message to Preferences
    link_message(integer sender_num, integer num, string msg, key id) {
        string temp;
        
        if(msg == "") return;
        /*
        else if(num == -1) return; // Preferences is being used
        else if(num == -2 || num == -4) return; // Printouts is being used
        else if(num == -7) return; // Particles is being used
        */
        else if(num == -3) { //Update from Preferences
            integer index = llSubStringIndex(msg, ":");
            if(index == -1) { //received settings from Preferences
                parseSettings(msg);
                return;
            }
            string setting = llGetSubString(msg, 0, index-1);
            msg = llGetSubString(msg, index+1, -1);
            if(setting == "Printouts") { //send the new notecard to load to printouts so they update.
                llMessageLinked(LINK_THIS, -2, (string) g_gender + ":Update:"+msg, NULL_KEY);
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":Update:"+msg, NULL_KEY);
                return;
            }
            else if(setting == "Chatter") {
                g_chatter = (integer) msg;
                if(g_chatter == 0) {
                    temp = "Silent";
                }
                else if(g_chatter == 1) {
                    temp = "Low";
                }
                else if(g_chatter == 2) {
                    temp = "High";
                }
                llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + temp, NULL_KEY);
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + temp, NULL_KEY);
            }
            else if(setting == "Cancel") {
                mainMenu(msg);
                return;
            }
            sendSettings();
            return;
        }
        if(num <= 5 && num > 0) { // Carer List or a "List is Full" Message
            if(msg != "I'm sorry! There is no more room for carers, please delete one.") { // Valid send
                if(msg != "") {
                    list tempList = llCSV2List(msg);
                    g_Carers += tempList;
                    makeButtonsForCarers();
                }
            }
            else { // No more room for carers!
                llOwnerSay(msg);
                return;   
            }
        }
        else if(num == 6) { // Settings!
            parseSettings(msg); // Pulls apart msg to set appropriate values for this script.
            return;
        }
    }//End of link_message(integer, integer, string, key)
}
