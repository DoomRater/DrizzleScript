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

//This script offloads the adjusting of wet and mess prims and faces from Menu
string g_diaperType;
integer g_wetLevel;
integer g_messLevel;

integer g_mainPrim;
string g_mainPrimName = ""; // by default, set to ""

/* Puppy Pawz Pampers Variables */
integer g_wetPrim;
integer g_messPrim;
/* End of PPP variables*/

/* Nezzy's Brand Kawaii Diapers Variables */
//Kawaii doesn't use multiple prims for its settings, instead it uses faces
integer g_wetFace = 0;
integer g_errorCount = 0;
/*End of Kawaii variables*/

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

adjustWetMessPrims() {
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
            if(g_messLevel < 3) {
                llSetLinkPrimitiveParamsFast(g_messPrim, [PRIM_COLOR, ALL_SIDES, <0.749, 0.588, 0.392>, 0.0]);
            }
            else {
                llSetLinkPrimitiveParamsFast(g_messPrim, [PRIM_COLOR, ALL_SIDES, <0.749, 0.588, 0.392>, 0.65]);
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

parseLinkedMessage(string msg) {
    integer index;
    
    index = llSubStringIndex(msg, ":"); // Pull out wet level
    g_wetLevel = (integer) llGetSubString(msg, 0, index - 1);
    msg = llGetSubString(msg, index+1, -1);
    
    index = llSubStringIndex(msg, ":"); // Pull out mess level
    g_messLevel = (integer) llGetSubString(msg, 0, index - 1);
}

default {
    state_entry() {
        findPrims();
        detectDiaperType();
    }
    
    link_message(integer sender_num, integer num, string msg, key id) {
        if(num == -2 || num == -4) {
            integer index = llSubStringIndex(msg, ":"); //Pull out the gender *Always first in list
            msg = llGetSubString(msg, index+1, -1); //Cut msg down to reflect change and move on
            if(llGetSubString(msg,0,5) == "Update") {
                return;
            }
            else if (msg == "Gender") {
                return;
            }
            else if (msg == "Silent") {
                return;
            }
            else if (msg == "High") {
                return;
            }
            else if (msg == "Low") {
                return;
            }
            else { // We got a message from main, let's adjust the wet and mess prims!
                parseLinkedMessage(msg);
                adjustWetMessPrims();
            }
        }
    }
}
