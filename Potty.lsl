/*==========================================================
DrizzleScript potty
Created By: Ryhn Teardrop
Original Date: Dec 3rd, 2011
GitHub Repository: https://github.com/DoomRater/DrizzleScript

Programming Contributors: Ryhn Teardrop, Brache Spyker, Napysusy Iadyl
Resource Contributors: Murreki Fasching, Brache Spyker

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.

*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

//This script offloads the adjusting of wet and mess prims and faces from Menu
string g_diaperType;

integer g_mainPrim;
integer g_uniqueChan;
integer g_mainListen;
string g_mainPrimName = ""; // by default, set to ""
key g_queueid = NULL_KEY; //keep track of people who are waiting in line to use the item


/* Puppy Pawz Pampers Variables */
integer g_wetPrim;
integer g_messPrim;
/* End of PPP variables*/

/* Nezzy's Brand Kawaii Diapers Variables */
//Kawaii doesn't use multiple prims for its settings, instead it uses faces
integer g_wetFace = 0;
integer g_errorCount = 0;
/*End of Kawaii variables*/

//menu variables passed to preferences
integer g_wetLevel;
integer g_messLevel;
integer g_wetChance;
integer g_messChance;
integer g_wetTimer;
integer g_messTimer;
integer g_tummyRub;
integer g_tickle;
integer g_gender;
integer g_isOn;
integer g_interact;
integer g_chatter;
integer g_crinkleVolume;
integer g_wetVolume;
integer g_messVolume;
integer g_mCalcForecast; // Calculation needet vor Determines how long until the next mess chance
integer g_wCalcForecast; // Calculation needet vor Determines how long until the next wet chance
integer mForecast; // Determines how long until the next mess chance
integer wForecast; // Determines how long until the next wet chance
integer g_timesHeldWet;
integer g_timesHeldMess;
integer g_PlasticPants;
integer g_TimerRandom;
integer g_allowPeePotty;
integer g_allowPooPottty;
integer g_allowHoldPee;
integer g_allowHoldPoo;
integer g_giveWarningPee;
integer g_giveWarningPoo;
integer g_allowSelfChange;
integer g_lockdetach;       // 1 = options an take off is forbitten
// End List from menu
integer g_timesHeldWetMultiplier = 10; //how much harder it gets each time you successfully hold it, in percent
integer g_timesHeldMessMultiplier = 10;
integer g_timesHeldWetStrength = 3; //how many times you can hold it before you flood
integer wMessageDone = 0;
integer mMessageDone = 0;
// Time sending Warning bevor wetting
integer wMessageForecast = 0 ;
integer mMessageForecast = 0 ;
integer wManualOK = 0;
integer mManualOK = 0;



integer isDebug = FALSE;
//set isDebug to 1 (TRUE) to enable all debug messages, and to 2 to disable info messages



list g_HoldMenu = ["Not now","❤Flood❤", "Big❤Load","Get❤Stinky", "Hold❤Poo", "Poo❤Potty","Get❤Soggy","Hold❤Pee","Pee❤Potty"];


init()
{
    llListenRemove(g_mainListen);
    g_uniqueChan = generateChan(llGetOwner()) + 2; // Remove collision with Menu listen handler via +2
    g_mainListen = llListen(g_uniqueChan, "", "", "");
    findPrims();
    detectDiaperType();

    llSetTimerEvent(15.0); // Used to check for wet/mess occurances
}

integer generateChan(key id) {
    string channel = "0xE" +  llGetSubString((string)id, 0, 6);
  return (integer) channel;}

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
    (string) g_crinkleVolume + "," +
    (string) g_wetVolume + "," +
    (string) g_messVolume + "," +
    (string) g_mCalcForecast + "," +
    (string) g_wCalcForecast + "," +
    (string) g_timesHeldWet + "," +
    (string) g_timesHeldMess + "," +
    (string) g_PlasticPants + "," +
    (string) g_TimerRandom + "," +
    (string) g_allowPeePotty + "," +
    (string) g_allowPooPottty + "," +
    (string) g_allowHoldPee + "," +
    (string) g_allowHoldPoo + "," +
    (string) g_giveWarningPee + "," +
    (string) g_giveWarningPoo + "," +
    (string) g_lockdetach + "," +
    (string) g_allowSelfChange;
    llMessageLinked(LINK_THIS, -9, csv, NULL_KEY);
//    llMessageLinked(LINK_ALL_OTHERS, 6, csv, NULL_KEY);
}

parseSettings(string temp) {
    integer index; // Used to hold the location of a comma in the CSV
    
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
    g_isOn = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_interact = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_chatter = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_crinkleVolume = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_wetVolume = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_messVolume = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_mCalcForecast = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_wCalcForecast = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_timesHeldWet = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_timesHeldMess = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_PlasticPants = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    index = llSubStringIndex(temp, ",");
    g_TimerRandom  = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_allowPeePotty = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_allowPooPottty = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_allowHoldPee = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_allowHoldPoo = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_giveWarningPee = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);

    index = llSubStringIndex(temp, ",");
    g_giveWarningPoo = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    index = llSubStringIndex(temp, ",");
    g_lockdetach = (integer) llGetSubString(temp, 0, index-1);
    temp = llGetSubString(temp, index+1, -1);
    
    g_allowSelfChange = (integer) temp;
}

printDebugSettings() {
    llOwnerSay("Debug Potty: ");
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
    llOwnerSay("--------");
    llOwnerSay("Wet Prim: " + (string) g_wetPrim);
    llOwnerSay("Mess Prim: " + (string) g_messPrim);
    llOwnerSay("Crinkle Volume: "+(string) g_crinkleVolume);
    llOwnerSay("Wet Sound Volume: "+(string) g_wetVolume);
    llOwnerSay("Mess Sound Volume: "+(string) g_messVolume);
    llOwnerSay("Times Held (wet): "+(string) g_timesHeldWet);
    llOwnerSay("Times Held (mess): "+(string) g_timesHeldMess);
    llOwnerSay("Used Memory: " + (string) llGetUsedMemory());
    llOwnerSay("Free Memory: " + (string) llGetFreeMemory());
    llOwnerSay("Time next Mess: " + (string) mForecast);
    llOwnerSay("Time next Wet: " + (string) wForecast);
    llOwnerSay("Time: " + (string) llRound(llGetTime()));
}


findPrims() {
    integer i; // Used to loop through the linked objects
    integer primCount = llGetNumberOfPrims(); //should be attached, not sat on
    for(i = 0; i <= primCount; i++) { 
        string primName = (string) llGetLinkPrimitiveParams(i, [PRIM_NAME]); // Get the name of linked object i
        if(primName == "Pee") {
            g_wetPrim = i;
        }
        else if(primName == "Poo") {
            g_messPrim = i;
        }
        else if(primName == g_mainPrimName) {
            g_mainPrim = i;
        }
    }
    //just in case there is an unnamed prim in the linkset, do this here
    if(g_mainPrimName == "") { // No specified prim. Look for root.
        if(primCount == 1) { //not a linked set, so the first prim is 0
            g_mainPrim = 0;
        }
        else {
            g_mainPrim = 1;
        }
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

adjustWetMessPrims(string msg) {
    integer index;
    
    if(llGetAlpha(ALL_SIDES) != 0.0) { // Only adjust the prims if the model isn't hidden!
        if(g_diaperType == "Fluffems") {
            if(g_wetLevel == 0) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0.0]);
            }
            else if(g_wetLevel == 1) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,.666>, 0.20]);
            }
            else if(g_wetLevel == 2) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,.5>, 0.35]);
            }
            else if(g_wetLevel == 3) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,.333>, 0.45]);
            }
            else if(g_wetLevel == 4) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,.25>, 0.55]);
            }
            else if(g_wetLevel == 5) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,.1667>, 0.65]);
            }
            else if(g_wetLevel >= 6) {
                llSetLinkPrimitiveParamsFast(g_wetPrim, [PRIM_COLOR, ALL_SIDES, <1,1,0>, 0.85]);
            }
            //mess levels
            if(g_messLevel <= 2) {
                llSetLinkPrimitiveParamsFast(g_messPrim, [PRIM_COLOR, ALL_SIDES, <0.749, 0.588, 0.392>, 0.0]);
            }
            else if (g_messLevel = 3) {
                llSetLinkPrimitiveParamsFast(g_messPrim, [PRIM_COLOR, ALL_SIDES, <0.749, 0.588, 0.392>, 0.65]);
            }
            else {
                llSetLinkPrimitiveParamsFast(g_messPrim, [PRIM_COLOR, ALL_SIDES, <0.749, 0.588, 0.392>, 0.85]);
            }
        }
        else if(g_diaperType == "Kawaii") {
            if(g_wetLevel == 0) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,1>, 0.0]);
            }
            else if(g_wetLevel == 1) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,.666>, 0.20]);
            }
            else if(g_wetLevel == 2) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,.5>, 0.35]);
            }
            else if(g_wetLevel == 3) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,.333>, 0.45]);
            }
            else if(g_wetLevel == 4) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,.25>, 0.55]);
            }
            else if(g_wetLevel == 5) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,.1667>, 0.65]);
            }
            else if(g_wetLevel >= 6) {
                llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_COLOR, g_wetFace, <1,1,0>, 0.85]);
            }
        }
    }
}//End WetMessPrims()

// Returns a forecast duration number of seconds in the future.
// @ param [duration] : number of seconds to forecast in script runtime. 
// @ return : the forcasted time for timer hub to execute associated command.
integer myTimer(integer duration, string msg) {
    integer x = llRound(llGetTime());
    integer y = (integer) llFrand(duration);
    integer z;
    
    if(x + duration > 2000000000) { // Failsafe, resets script time if approaching threshold for integer capacity.
        //we need to adjust the forecasts so they aren't unobtainable due to time reset
        wForecast -= x;
        mForecast -= x;
        llResetTime();
        x = llRound(llGetTime());
    }
    if (g_TimerRandom == 0) { //timer exaktly
        z = duration;
    }
    else {
            z = duration/2 + y;
    }
    x += z;
    if (msg == "W") {
        wMessageDone = 0; // Reset Message is given
        wMessageForecast = x - 60 - (z/10); // time to give warning
                 // add one minute more to give a chance to potty
        wManualOK = x -z/2;
    }
    else if (msg == "M") {
        mMessageDone = 0;
        mMessageForecast = x - 60 - (z/10); // time to give warning
        mManualOK = x -z/2;
    }
       
    return x;
}

// This function gives the wearer a chance to hold their potties
// A percentage is weighed.
// @type = The form of diaper use to be attempted.
// Case 1: Success, Held it, printout
// Case 2: Failure, Had an Accident,  printout
integer findPercentage(string type) {
    // Add check for trainer mode.
    integer toCheck;

    if(type == "W") {
        toCheck = (integer) llFrand(100); // Random number between 0 and 99
        ++toCheck;                       // ++i used to achieve 1 - 100 range.
        if(toCheck + (g_timesHeldWet * g_timesHeldWetMultiplier) <= g_wetChance) { //timesHeldWet is a modifier that makes you less likely to hold it.
            return FALSE;
        }
        else {
            return TRUE;
        }
    }
    else if(type == "M") {// Use Mess Chance
        toCheck = (integer) llFrand(100); // Random number between 0 and 99
        ++toCheck;                       // ++i used to achieve 1 - 100 range.
        if(toCheck + (g_timesHeldMess * g_timesHeldMessMultiplier) <= g_messChance) {//timesHeldMess is a modifier that makes you less likely to hold it.
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

// This function is called to manage Holding
// @msg = The type of holding, e.g. holding button or Timer
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleHold(string msg, key id) {
    if(msg == "WHold_Timer") {
        //Example of what message looks like: 1:2:g_wetLevel:Name
        g_timesHeldWet++;
        wMessageDone = 0;
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "WHold_Timer" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            wForecast = myTimer(g_wetTimer * 60 / (g_timesHeldWet + 1),"W");
    }
    if(msg == "WHold_Button") {
        //Example of what message looks like: 1:2:g_wetLevel:Name
        if (wMessageDone == 1) {
          g_timesHeldWet++;
          wMessageDone = 0;
          llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "WHold_Button" + ":" + llKey2Name(llGetOwner()), llGetOwner());
          wForecast = myTimer(g_wetTimer * 60 / (g_timesHeldWet + 1),"W");
        }
        else {
            llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Forbitten" + ":" + llKey2Name(llGetOwner()), llGetOwner());
          }
    }
    if(msg == "MHold_Timer") {
        //Example of what message looks like: 1:2:g_wetLevel:Name
        g_timesHeldMess++;
        mMessageDone = 0;
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "MHold_Timer" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            mForecast = myTimer(g_messTimer * 60 / (g_timesHeldMess + 1),"M");
    }
    if(msg == "MHold_Button") {
        //Example of what message looks like: 1:2:g_wetLevel:Name
        if (mMessageDone == 1) {
            g_timesHeldMess++;
            mMessageDone = 0;
            llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "MHold_Button" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            mForecast = myTimer(g_messTimer * 60 / (g_timesHeldMess + 1),"M");
        }
        else {
            llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Forbitten" + ":" + llKey2Name(llGetOwner()), llGetOwner());
         }
    }
    sendSettings();
}//End handleHold(string, key)
// This function is called to manage messings
// @msg = The type of accident occuring, e.g. messing yourself, being squeezed/tummy rub, and being forced by a carer to get stinky.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleMessing(string msg, key id) {
    g_messLevel++;
    g_timesHeldMess = 0;
    //new forecast for messing
    mForecast = myTimer(g_messTimer * 60,"M");
    sendSettings();
    if(msg == "Self") {
        //Example of what message looks like: 1:2:g_wetLevel:Self
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_messLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Timer") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_messLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    playMessSound(g_messVolume);
}//End handleMessing(string, key)
// This function is called to manage wettings
// @msg = The type of accident occuring, e.g. wetting yourself, being tickled, and being forced by a carer to wet.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleWetting(string msg, key id) {
    g_wetLevel++;
    g_timesHeldWet = 0;
    //new forecast for wetting
    wForecast = myTimer(g_wetTimer * 60,"W");
    sendSettings();
    if(msg == "Self") {
        //Example of what message looks like: 1:2:g_wetLevel:Name
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_wetLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Timer") {
        llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "g_wetLevel" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    playWetSound(g_wetVolume * .00333);
}//End handleWettings(string, key)
// This function is called to manage a special-case wetting.
// @msg = The type of accident occuring, e.g. naturally flooding yourself, or being potentially forced by a carer.
// @id = The key of the user who triggered this function. We use this to identify what message to send to the printouts script(s).
handleFlooding(string msg, key id) {
    g_wetLevel = g_wetLevel + 4;
    g_timesHeldWet = 0;
    //new forecast for wetting
    wForecast = myTimer(g_wetTimer * 60,"W");
    sendSettings();
    if(msg == "Self") {
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Self Flood" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    else if(msg == "Timer") { //added to allow separation of timer floods and forced floods
        llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Self Flood" + ":" + llKey2Name(llGetOwner()), llGetOwner());
    }
    playWetSound(g_wetVolume * .02);  //todo: add a special flooding sound
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

playMessSound(float volume) {
    if(llGetInventoryType("SusyMessSound") != -1) { // Sound exists in inventory
        //todo: create a mess sound
        llPlaySound("SusyMessSound", volume); 
    }
    else {
        if(isDebug==TRUE) {
            llOwnerSay("No Sound Found!\nPlease drop a soundfile named: SusyMessSound into your model!");
        }
    }
}


default {
    state_entry() {
        init();
    }
 
    changed(integer change) {
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY)) {
            init();
        }
    }
    
    link_message(integer sender_num, integer num, string msg, key id) {
        if(num == -2 || num == -4) {
            integer index = llSubStringIndex(msg, ":"); //Pull out the gender *Always first in list
            msg = llGetSubString(msg, index+1, -1); //Cut msg down to reflect change and move on
            if(~llSubStringIndex(msg, ":")) { // We got a message from main, let's adjust the wet and mess prims!
                adjustWetMessPrims(msg);
            }
        }
        else if (num == -6 || num == -3 || num == -10) { //save global Variables from menu or Preferences
            integer index = llSubStringIndex(msg, ":");
            if(index == -1) { //received settings from Preferences
                parseSettings(msg);
                return;
            }
        }
        else if(num == -8) {
            if(msg == "❤Potty❤" ) {
                llDialog(id, "What should I do?", g_HoldMenu, g_uniqueChan);
           }
        }
    }
    //menu
    listen(integer chan, string name, key id, string msg)
    { //list g_HoldMenu = ["Not now","★", "DEBUG","Get❤Stinky", "Hold❤Poo", "Poo❤Potty","Get❤Soggy","Hold❤Pee","Pee❤Potty"];
        if(msg == "★") {// Someone misclicked in the menu!
            llRegionSayTo(id, 0, "The stars are just there to look pretty! =p");
        }
        else if(msg == "Not now") {
            //llRegionSayTo(id, 0, msg + "gedrückt");
        }
        else if(msg=="DEBUG") {
            printDebugSettings();
        }
        else if(msg == "Get❤Stinky") {
            handleMessing("Self", llGetOwner()); 
        }
        else if(msg == "Hold❤Poo") {
          if (g_allowHoldPoo == 1) {
            handleHold("MHold_Button",  llGetOwner()); // "Timer" is the cause of the holding wenn Holding success
          }
          else {
            llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Forbitten" + ":" + llKey2Name(llGetOwner()), llGetOwner());
          }  
        }
        else if(msg == "Poo❤Potty") {
            if (g_allowPooPottty == 1) {
                if (mManualOK < llRound(llGetTime())) {
                g_timesHeldMess = 0;
                g_timesHeldWet = 0;
                //new forecast for messing
                mForecast = myTimer(g_messTimer * 60,"M");
                wForecast = myTimer(g_wetTimer * 60,"W");
                playMessSound(g_messVolume);
                sendSettings();
                llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Potty_M" + ":" + llKey2Name(llGetOwner()), llGetOwner());
              }
              else {
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "noPotty_M" + ":" + llKey2Name(llGetOwner()), llGetOwner());
              }    
            }
            else {
              llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Forbitten" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }  
        }
        else if(msg == "Get❤Soggy") {
            handleWetting("Self", llGetOwner());
        }
        else if(msg == "Hold❤Pee") {
          if (g_allowHoldPee == 1) {
            handleHold("WHold_Button",  llGetOwner()); // "Timer" is the cause of the holding wenn Holding success
          }
          else {
            llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Forbitten" + ":" + llKey2Name(llGetOwner()), llGetOwner());
          }
        }
        else if(msg == "Pee❤Potty") {
          if (g_allowPeePotty == 1) {
              if (wManualOK < llRound(llGetTime())) {
              g_timesHeldWet = 0;
              //new forecast for wetting
              wForecast = myTimer(g_wetTimer * 60,"W");
              playWetSound(g_wetVolume * .023);
              sendSettings();
              llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Potty_W" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }
            else {
              llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "noPotty_W" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }    
          }
          else {
            llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Forbitten" + ":" + llKey2Name(llGetOwner()), llGetOwner());
          }  
        }
        else if(msg == "❤Flood❤") {
            handleFlooding("Self", llGetOwner());
        }
        else if(msg == "Big❤Load") {
            g_messLevel += 2;
            handleMessing("Self", llGetOwner()); 
        }
    } // end listen
    // This event is used to evaluate/reset the forecasts for wetting or messing, as well 
    // as determining whether a user succeeds in holding it.
    timer() {
        integer currentTime = llRound(llGetTime());
        //Check other Skrit force to calculate Forecast
        if(g_wCalcForecast == 1) {
            wForecast = myTimer(g_wetTimer * 60,"W"); // New Forecast Regardless
            g_wCalcForecast = 0;       
            sendSettings();       
        }        
        else if(g_wCalcForecast == 2) {
            if (wManualOK < currentTime) {
                g_timesHeldWet = 0;
                wForecast = myTimer(g_wetTimer * 60,"W"); // New Forecast Regardless
                playWetSound(g_wetVolume * .023);
                llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Potty_W" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }
            else {
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "noPotty_W" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }    
            g_wCalcForecast = 0;       
            sendSettings();       
        }        
        if(g_mCalcForecast == 1) {
            mForecast = myTimer(g_messTimer * 60,"M"); // New Forecast Regardless
            g_mCalcForecast = 0;
            sendSettings();       
        }        
        else if(g_mCalcForecast == 2) {
            if (mManualOK < currentTime) {
                mForecast = myTimer(g_messTimer * 60,"M"); // New Forecast Regardless
                g_timesHeldMess = 0;
                playMessSound(g_messVolume);
                llMessageLinked(LINK_THIS, -2, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "Potty_M" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }
            else {
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "noPotty_M" + ":" + llKey2Name(llGetOwner()), llGetOwner());
            }    
            g_mCalcForecast = 0;
            sendSettings();       
        }        


        if(g_isOn == TRUE) { //only if Diaper switches on
            if(currentTime <= 60) {
                return;
            }
            //Timer of 0 (Off) prevent accidents.
            if(g_wetTimer == 0) {
                wForecast = 2000000000;
            }
            //Timer of 0 (Off) prevent accidents.
            if(g_messTimer == 0) {
                mForecast = 2000000000;
            }
            // If both wet and mess forecasts are past their time. . .
            if(wForecast <= currentTime && mForecast <= currentTime) {
                // New wet forecast. This means the user will mess by default. :D
                wForecast += 30;  // and a bit lader wet :D
            }
 
            if(wForecast <= currentTime) { // The forecasted time is in the past
               if(findPercentage("W") == TRUE) {
                    if(g_timesHeldWet >= g_timesHeldWetStrength) { // If the user has held it a lot. This time they flood.
                        handleFlooding("Timer", llGetOwner());
                    }
                    else {
                        handleWetting("Timer", llGetOwner()); // "Timer" is the cause of the wetting, llGetOwner is to determine what printout to trigger.
                    }
               }
                else {
                    //todo: potty training handler will go here!
                    handleHold("WHold_Timer",  llGetOwner()); // "Timer" is the cause of the holding wenn Holding success
                }
            }
            else if(wMessageForecast <= currentTime && wMessageDone == 0) { // Message bladder has a message
                if (g_giveWarningPee == 1) {
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "havetoPee" + ":" + llKey2Name(llGetOwner()), llGetOwner());
              }
              wMessageDone = 1;
            }
            
            if(mForecast <= currentTime) { 
                if(findPercentage("M") == TRUE) {
                    handleMessing("Timer", llGetOwner()); 
                }
                else {
                    //todo: potty training handler will go here!
                    handleHold("WHold_Timer",  llGetOwner()); // "Timer" is the cause of the holding wenn Holding success
                  }
            }
            else if(mMessageForecast <= currentTime && mMessageDone == 0 ) { // Message bowel has a message
                if (g_giveWarningPoo == 1) {
                llMessageLinked(LINK_THIS, -4, (string) g_gender + ":" + (string) g_wetLevel + ":" + (string) g_messLevel + ":" + "havetoPoo" + ":" + llKey2Name(llGetOwner()), llGetOwner());
              }
              mMessageDone = 1;
            }
    
        /*    llOwnerSay("----\nwetting to go: " + (string) (wForecast-currentTime));
            llOwnerSay("messing to go: " + (string) (mForecast-currentTime));
            llOwnerSay("wetting warning: " + (string) (wMessageForecast-currentTime));
            llOwnerSay("wetting posible: " + (string) (wManualOK-currentTime));
            llOwnerSay("wetting warning done: " + (string) wMessageDone);*/
        } // End g_isOn
    }// End timer
}
