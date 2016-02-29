/*==========================================================
DrizzleScript
Created By: Ryhn Teardrop
Original Date: Dec 3rd, 2011
GitHub Repository: https://github.com/DoomRater/DrizzleScript

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.


*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

//* Local Variables used by Prinouts2.lsl to handle loading/displaying printouts.

integer g_wetLevel; // 0, 1, 2, . . .
integer g_messLevel;
integer g_gender = 1; // 0, 1, edited for a girl
integer g_chatter = 2; //0, 1, 2 affects loudness!
integer g_lineNum;
integer g_forcedWet = FALSE; //Set to true if the user has been forced to wet since last change.
integer g_forcedMess = FALSE; // ^^ mess ^^
key g_lineQuery;
string g_printoutType; // Used in coupling with nextLineTest when a multi-liner is encountered!
string g_toucherName; // "Self" or "Tickle" or "Forced"
key g_toucherKey; //in case we need to print to the toucher
string g_useType; // "Wet" "Mess"
string g_PrintoutCard = "Default";
integer isDebug = FALSE;
//set isDebug to 1 (TRUE) to enable all debug messages, and to 2 to disable info messages

//Variables which hold all printouts in memory for speed.

//Wet Prints in Printouts1 (6)

//Mess Prints in Printous1 (3)

//Diaper Check from Carers
string carer_checkClean;
string carer_checkWet1;
string carer_checkWet2;
string carer_checkWet3;
string carer_checkWet4; 
string carer_checkWet5;
string carer_checkWet6;
string carer_checkMess1;
string carer_checkMess2;
string carer_checkMess3;
string carer_CheckWet1to2Mess1;
string carer_CheckWet3to4Mess1;
string carer_CheckWet5to6Mess1;
string carer_CheckWet1to2Mess2;
string carer_CheckWet3to4Mess2;
string carer_checkWet5to6Mess2;
string carer_checkWet1to2Mess3;
string carer_checkWet3to4Mess3;
string carer_CheckWet5to6Mess3;
string carer_forceWet1;         //Prints for carer 'Force' options
string carer_forceWet2;
string carer_forceMess1; 
string carer_forceMess2;
string carer_forcePotty;

//Potty stuff
string havetoPee;
string havetoPoo;
string noPotty_W;
string noPotty_M;
string forbitten;

//Other Check in Printouts1 (19)

//Self Check in Printouts1 (19)

//Special Print for Super-Flooding
string instantFlood;

//Rubbing and Tickles
string tummyRub1;
string tummyRub2;
string tummyRub_fail;
string tickle1;
string tickle2;
string tickle3;
string tickle4;
string tickle5;
string tickle6;
string tickle_fail;
string tickle_close; // Unused

//Changing in Printouts1 (3)

//Spanking Prints
string cleanSpank;
string wetSpank1to2;
string wetSpank3to4;
string wetSpank5to6;
string messSpank1;
string messSpank2;

//Poke Prints Handled in Printouts1 (4)

//Wedgies
string cleanWedgie;
string wetWedgie1to2;
string wetWedgie3to4;
string wetWedgie5to6;
string messWedgie1;
string messWedgie2;

//Raspberry in Printouts1 (1)

//Tease in Prinouts1 (4)

clearCustomPrints() {
    carer_checkClean="";
    carer_checkWet1="";
    carer_checkWet2="";
    carer_checkWet3="";
    carer_checkWet4=""; 
    carer_checkWet5="";
    carer_checkWet6="";
    carer_checkMess1="";
    carer_checkMess2="";
    carer_checkMess3="";
    carer_CheckWet1to2Mess1="";
    carer_CheckWet3to4Mess1="";
    carer_CheckWet5to6Mess1="";
    carer_CheckWet1to2Mess2="";
    carer_CheckWet3to4Mess2="";
    carer_checkWet5to6Mess2="";
    carer_checkWet1to2Mess3="";
    carer_checkWet3to4Mess3="";
    carer_CheckWet5to6Mess3="";
    carer_forceWet1="";
    carer_forceWet2="";
    carer_forceMess1=""; 
    carer_forceMess2="";
    carer_forcePotty="";;

//Potty stuff
    havetoPee="";
    havetoPoo="";
    noPotty_W="";
    noPotty_M="";
    forbitten="";

    instantFlood="";

    tummyRub1="";
    tummyRub2="";
    tummyRub_fail="";
    tickle1="";
    tickle2="";
    tickle3="";
    tickle4="";
    tickle5="";
    tickle6="";
    tickle_fail="";
    tickle_close="";

    cleanSpank="";
    wetSpank1to2="";
    wetSpank3to4="";
    wetSpank5to6="";
    messSpank1="";
    messSpank2="";

    cleanWedgie="";
    wetWedgie1to2="";
    wetWedgie3to4="";
    wetWedgie5to6="";
    messWedgie1="";
    messWedgie2="";
}

loadCustomPrints() {
    if(isDebug < 2) {
        llOwnerSay("Printouts2: Loading "+g_PrintoutCard+" notecard, this may take a minute or two!");
    }
    g_lineNum = 0;
    
    if(llGetInventoryType("PRINT:" + g_PrintoutCard) != -1) {
        g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
    }
    else {
        llOwnerSay("No Notecard Found!\n Please drag this notecard into your model: PRINT:" + g_PrintoutCard);
    }
}

// This function takes a message (presumably sent by the main menu)
// and pulls it apart, gathering values for the global values:
// g_useLevel, g_useType, and g_toucherName
// @msg = Example - "1:g_wetLevel:Ryhn Teardrop"
parseLinkedMessage(string msg) {
    integer index;
    
    //I need to handle parsing the information for a change now.
    
    index = llSubStringIndex(msg, ":"); // Pull out wet level
    g_wetLevel = (integer) llGetSubString(msg, 0, index - 1);
    msg = llGetSubString(msg, index+1, -1);

    index = llSubStringIndex(msg, ":"); // Pull out mess level
    g_messLevel = (integer) llGetSubString(msg, 0, index - 1);
    msg = llGetSubString(msg, index+1, -1);

    index = llSubStringIndex(msg, ":"); //Pull the usage type out
    g_useType = llGetSubString(msg, 0, index - 1);
    msg = llGetSubString(msg, index+1, -1);

    index = llSubStringIndex(msg, ":"); //Pull the sent name out
    g_toucherName = llGetSubString(msg, 0, index);
    msg = llGetSubString(msg, index+1, -1);
}

//@data = Unprocessed line of text from printout
//@append = Flags True/False if this is an addition to a prior printout
//@printoutType = Information that identifies which variable should be updated
constructPrint(string data, integer append, string printoutType) {
    if(append == TRUE) {
        if(printoutType == "@CareCheckClean") {
            carer_checkClean += data;
        }
        else if(printoutType == "@CareCheckWet1") {
            carer_checkWet1 += data;
        }
        else if(printoutType == "@CareCheckWet2") {
            carer_checkWet2 += data;
        }
        else if(printoutType == "@CareCheckWet3") {
            carer_checkWet3 += data;
        }
        else if(printoutType == "@CareCheckWet4") {
            carer_checkWet4 += data;
        }
        else if(printoutType == "@CareCheckWet5") {
            carer_checkWet5 += data;
        }
        else if(printoutType == "@CareCheckWet6") {
            carer_checkWet6 += data;
        }
        else if(printoutType == "@CareCheckMess1") {
            carer_checkMess1 += data;
        }
        else if(printoutType == "@CareCheckMess2") {
            carer_checkMess2 += data;
        }
        else if(printoutType == "@CareCheckMess3") {
            carer_checkMess3 += data;
        }
        else if(printoutType == "@CareCheckWet1-2Mess1") {
            carer_CheckWet1to2Mess1 += data;
        }
        else if(printoutType == "@CareCheckWet3-4Mess1") {
            carer_CheckWet3to4Mess1 += data;
        }
        else if(printoutType == "@CareCheckWet5-6Mess1") {
            carer_CheckWet5to6Mess1 += data;
        }
        else if(printoutType == "@CareCheckWet1-2Mess2") {
            carer_CheckWet1to2Mess2 += data;
        }
        else if(printoutType == "@CareCheckWet3-4Mess2") {
            carer_CheckWet3to4Mess2 += data;
        }
        else if(printoutType == "@CareCheckWet5-6Mess2") {
            carer_checkWet5to6Mess2 += data;
        }
        else if(printoutType == "@CareCheckWet1-2Mess3") {
            carer_checkWet1to2Mess3 += data;
        }
        else if(printoutType == "@CareCheckWet3-4Mess3") {
            carer_checkWet3to4Mess3 += data;
        }
        else if(printoutType == "@CareCheckWet5-6Mess3") {
            carer_CheckWet5to6Mess3 += data;
        }
        else if(printoutType == "@CareForceWet1") {
            carer_forceWet1 += data;
        }
        else if(printoutType == "@CareForceWet2") {
            carer_forceWet2 += data;
        }
        else if(printoutType == "@CareForceMess1") {
            carer_forceMess1 += data;
        }
        else if(printoutType == "@CareForceMess2") {
            carer_forceMess2 += data;
        }
        else if(printoutType == "@uInstantFlood") {
            instantFlood += data;
        }
        else if(printoutType == "@oSpank") {
            cleanSpank += data;
        }
        else if(printoutType == "@oSpankWet1-2") {
            wetSpank1to2 += data;
        }
        else if(printoutType == "@oSpankWet3-4") {
            wetSpank3to4 += data;
        }
        else if(printoutType == "@oSpankWet5-6") {
            wetSpank5to6 += data;
        }
        else if(printoutType == "@oSpankMess1") {
            messSpank1 += data;
        }
        else if(printoutType == "@oSpankMess2") {
            messSpank2 += data;
        }
         else if(printoutType == "@oDefault_Tickle") {
            tickle_fail += data;
        }
        else if(printoutType == "@oTickle1") {
            tickle1 += data;
        }
        else if(printoutType == "@oTickle2") {
            tickle2 += data;
        }
        else if(printoutType == "@oTickle3") {
            tickle3 += data;
        }
        else if(printoutType == "@oTickle4") {
            tickle4 += data;
        }
        else if(printoutType == "@oTickle5") {
            tickle5 += data;
        }
        else if(printoutType == "@oTickle6") {
            tickle6 += data;
        }
        else if(printoutType == "@oDefault_TummyRub") {
            tummyRub_fail += data;
        }
        else if(printoutType == "@oTummyRub1") {
            tummyRub1 += data;
        }
        else if(printoutType == "@oTummyRub2") {
            tummyRub2 += data;
        }
        else if(printoutType == "@oWedgieWet1-2") {
            wetWedgie1to2 += data;
        }
        else if(printoutType == "@oWedgieWet3-4") {
            wetWedgie3to4 += data;
        }
        else if(printoutType == "@oWedgieWet5-6") {
            wetWedgie5to6 += data;
        }
        else if(printoutType == "@oWedgieMess1") {
            messWedgie1 += data;
        }
        else if(printoutType == "@oWedgieMess2") {
            messWedgie2 += data;
        }
        else if(printoutType == "@forcePotty") {
            carer_forcePotty += data;
        }
        else if(printoutType == "@havetoPee") {
            havetoPee += data;
        }
        else if(printoutType == "@havetoPoo") {
            havetoPoo += data;
        }
        else if(printoutType == "@noPotty_W") {
            noPotty_W += data;
        }
        else if(printoutType == "@noPotty_M") {
            noPotty_M += data;
        }
        else if(printoutType == "@forbitten") {
            forbitten += data;
        }
    }
    else { // Not appending, replace the printout!
        if(printoutType == "@CareCheckClean") {
            carer_checkClean = data;
        }
        else if(printoutType == "@CareCheckWet1") {
            carer_checkWet1 = data;
        }
        else if(printoutType == "@CareCheckWet2") {
            carer_checkWet2 = data;
        }
        else if(printoutType == "@CareCheckWet3") {
            carer_checkWet3 = data;
        }
        else if(printoutType == "@CareCheckWet4") {
            carer_checkWet4 = data;
        }
        else if(printoutType == "@CareCheckWet5") {
            carer_checkWet5 = data;
        }
        else if(printoutType == "@CareCheckWet6") {
            carer_checkWet6 = data;
        }
        else if(printoutType == "@CareCheckMess1") {
            carer_checkMess1 = data;
        }
        else if(printoutType == "@CareCheckMess2") {
            carer_checkMess2 = data;
        }
        else if(printoutType == "@CareCheckMess3") {
            carer_checkMess3 = data;
        }
        else if(printoutType == "@CareCheckWet1-2Mess1") {
            carer_CheckWet1to2Mess1 = data;
        }
        else if(printoutType == "@CareCheckWet3-4Mess1") {
            carer_CheckWet3to4Mess1 = data;
        }
        else if(printoutType == "@CareCheckWet5-6Mess1") {
            carer_CheckWet5to6Mess1 = data;
        }
        else if(printoutType == "@CareCheckWet1-2Mess2") {
            carer_CheckWet1to2Mess2 = data;
        }
        else if(printoutType == "@CareCheckWet3-4Mess2") {
            carer_CheckWet3to4Mess2 = data;
        }
        else if(printoutType == "@CareCheckWet5-6Mess2") {
            carer_checkWet5to6Mess2 = data;
        }
        else if(printoutType == "@CareCheckWet1-2Mess3") {
            carer_checkWet1to2Mess3 = data;
        }
        else if(printoutType == "@CareCheckWet3-4Mess3") {
            carer_checkWet3to4Mess3 = data;
        }
        else if(printoutType == "@CareCheckWet5-6Mess3") {
            carer_CheckWet5to6Mess3 = data;
            return;    
        }
        else if(printoutType == "@CareForceWet1") {
            carer_forceWet1 = data;
        }
        else if(printoutType == "@CareForceWet2") {
            carer_forceWet2 = data;
        }
        else if(printoutType == "@CareForceMess1") {
            carer_forceMess1 = data;
        }
        else if(printoutType == "@CareForceMess2") {
            carer_forceMess2 = data;
        }
        else if(printoutType == "@uInstantFlood") {
            instantFlood = data;
        }
        else if(printoutType == "@oSpank") {
            cleanSpank = data;
        }
        else if(printoutType == "@oSpankWet1-2") {
            wetSpank1to2 = data;
        }
        else if(printoutType == "@oSpankWet3-4") {
            wetSpank3to4 = data;
        }
        else if(printoutType == "@oSpankWet5-6") {
            wetSpank5to6 = data;
        }
        else if(printoutType == "@oSpankMess1") {
            messSpank1 = data;
        }
        else if(printoutType == "@oSpankMess2") {
            messSpank2 = data;
        }
        else if(printoutType == "@oDefault_Tickle") {
            tickle_fail = data;
        }
        else if(printoutType == "@oTickle1") {
            tickle1 = data;
        }
        else if(printoutType == "@oTickle2") {
            tickle2 = data;
        }
        else if(printoutType == "@oTickle3") {
            tickle3 = data;
        }
        else if(printoutType == "@oTickle4") {
            tickle4 = data;
        }
        else if(printoutType == "@oTickle5") {
            tickle5 = data;
        }
        else if(printoutType == "@oTickle6") {
            tickle6 = data;
        }
        else if(printoutType == "@oDefault_TummyRub") {
            tummyRub_fail = data;
        }
        else if(printoutType == "@oTummyRub1") {
            tummyRub1 = data;
        }
        else if(printoutType == "@oTummyRub2") {
            tummyRub2 = data;
        }
        else if(printoutType == "@oWedgieWet1-2") {
            wetWedgie1to2 = data;
        }
        else if(printoutType == "@oWedgieWet3-4") {
            wetWedgie3to4 = data;
        }
        else if(printoutType == "@oWedgieWet5-6") {
            wetWedgie5to6 = data;
        }
        else if(printoutType == "@oWedgieMess1") {
            messWedgie1 = data;
        }
        else if(printoutType == "@oWedgieMess2") {
            messWedgie2 = data;
        }
        else if(printoutType == "@forcePotty") {
            carer_forcePotty = data;
        }
        else if(printoutType == "@havetoPee") {
            havetoPee = data;
        }
        else if(printoutType == "@havetoPoo") {
            havetoPoo = data;
        }
        else if(printoutType == "@noPotty_W") {
            noPotty_W = data;
        }
        else if(printoutType == "@noPotty_M") {
            noPotty_M = data;
        }
        else if(printoutType == "@forbitten") {
            forbitten = data;
        }
    }
}

//Function by Haravikk Mistral for Combined Library
string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

//This function is passed a (potentially) tokenized (*first, *oFullName, etc) string,
//it's job is to remove the tokens if they exist, and replace them with the proper information (First name, Full name, etc.)
//@printout = A potentially tokenized string in need of processing.
string processPrint(string printout) {
    string temp = printout; // Preserves the original data
    string fName; // First name of the User/Carer/Outsider, re-used.
    integer spaceLocation; // Holds the location of the space in a user name. I use this to cut out the first name.

    fName = llKey2Name(llGetOwner());
    spaceLocation = llSubStringIndex(fName, " ");
    fName = llDeleteSubString(fName, spaceLocation, -1);
    temp = strReplace(temp, "*first", fName);

    temp = strReplace(temp, "*fullName", llKey2Name(llGetOwner()));

    fName = g_toucherName;
    spaceLocation = llSubStringIndex(fName, " ");
    fName = llDeleteSubString(fName, spaceLocation, -1);
    temp = strReplace(temp, "*oFirstName", fName);

    temp = strReplace(temp, "*oFullName", g_toucherName);

    temp = strReplace(temp, "*Sub", llList2String(["He","She"], g_gender));

    temp = strReplace(temp, "*sub", llList2String(["he","she"], g_gender));

    temp = strReplace(temp, "*Obj", llList2String(["Him","Her"], g_gender));

    temp = strReplace(temp, "*obj", llList2String(["him","her"], g_gender));

    temp = strReplace(temp, "*Con", llList2String(["He's","She's"], g_gender));

    temp = strReplace(temp, "*con", llList2String(["he's","she's"], g_gender));

    temp = strReplace(temp, "*Ref", llList2String(["Himself","Herself"], g_gender));

    temp = strReplace(temp, "*ref", llList2String(["himself","herself"], g_gender));

    temp = strReplace(temp, "*Pos1", llList2String(["His","Her"], g_gender));

    temp = strReplace(temp, "*pos1", llList2String(["his","her"], g_gender));

    temp = strReplace(temp, "*Pos2", llList2String(["His","Hers"], g_gender));

    temp = strReplace(temp, "*pos2", llList2String(["his","hers"], g_gender));

    //todo: add species specific replacements for gender instead of or in addition to current system
    temp = strReplace(temp, "*Per", llList2String(["Boy","Girl"], g_gender));

    temp = strReplace(temp, "*per", llList2String(["boy","girl"], g_gender));

    temp = llStringTrim(temp, STRING_TRIM); // Remove any spaces that could potentially be hanging at the start or end of the string.
    return temp; // Send back the fully modified string
}


// Displays the appropriate printout given a usage type
// @msg = g_useType
displayPrintout() {
    string temp; // Used to prevent the original printouts from being altered.
    string name;
    integer index;
    
    name = llGetObjectName(); // Preserve the name of the Diaper
    if(g_useType == "Carer Check") { // Carer change printouts
        if(g_wetLevel == 0 && g_messLevel == 0) {
            temp = processPrint(carer_checkClean);
        }
        //wet
        else if(g_wetLevel == 1 && g_messLevel == 0) {
            temp = processPrint(carer_checkWet1);
        }
        else if(g_wetLevel == 2 && g_messLevel == 0) {
            temp = processPrint(carer_checkWet2);
        }
        else if(g_wetLevel == 3 && g_messLevel == 0) {
            temp = processPrint(carer_checkWet3);
        }
        else if(g_wetLevel == 4 && g_messLevel == 0) {
            temp = processPrint(carer_checkWet4);
        }
        else if(g_wetLevel == 5 && g_messLevel == 0) {
            temp = processPrint(carer_checkWet5);
        }
        else if(g_wetLevel >= 6 && g_messLevel == 0) {// Catch all for very soggy diapers.
            temp = processPrint(carer_checkWet6);
        }
        //messy
        else if(g_wetLevel == 0 && g_messLevel == 1) {
            temp = processPrint(carer_checkMess1);
        }
        else if(g_wetLevel == 0 && g_messLevel == 2) {
            temp = processPrint(carer_checkMess2);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 3) {// Catch all for very stinky diapers.
            temp = processPrint(carer_checkMess3);
        }
        //Wet and messy
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 1) {
            temp = processPrint(carer_CheckWet1to2Mess1);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 1) {
            temp = processPrint(carer_CheckWet3to4Mess1);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 1) {//Catch all for very wet diapers.
            temp = processPrint(carer_CheckWet5to6Mess1);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 2) {
            temp = processPrint(carer_CheckWet1to2Mess2);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 2) {
            temp = processPrint(carer_CheckWet3to4Mess2);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 2) {//catch all for very wet diapers.
            temp = processPrint(carer_checkWet5to6Mess2);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel >= 3) {
            temp = processPrint(carer_checkWet1to2Mess3);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel >= 3) {
            temp = processPrint(carer_checkWet3to4Mess3);
        }
        else if(g_wetLevel >= 5 && g_messLevel >= 3) {// Catch all for very used diapers.
            temp = processPrint(carer_CheckWet5to6Mess3);
        }
    }
    else if(g_useType == "Self Flood") {// Flood Printout!
        temp = processPrint(instantFlood);
    }
    else if(g_useType == "Tickle Fail") { // Default Tickle.
        temp = processPrint(tickle_fail);
    }
    else if(g_useType == "Tickle Success") { // Vary printout based on g_wetlevel
        if(g_wetLevel == 1) {
            temp = processPrint(tickle1);
        }
        else if(g_wetLevel == 2) {
            temp = processPrint(tickle2);
        }
        else if(g_wetLevel == 3) {
            temp = processPrint(tickle3);
        }
        else if(g_wetLevel == 4) {
            temp = processPrint(tickle4);
        }
        else if(g_wetLevel == 5) {
            temp = processPrint(tickle5);
        }
        else if(g_wetLevel > 5) { //Catch all for very wet diapers.
            temp = processPrint(tickle6);
        }
    }
    else if(g_useType == "Rub Fail") {
        temp = processPrint(tummyRub_fail);
    }
    else if(g_useType == "Rub Success") {
        if(g_messLevel == 1) {
            temp = processPrint(tummyRub1);
        }
        else if(g_messLevel >= 2) {
            temp = processPrint(tummyRub2);
        }
    }
    else if(g_useType == "Spank") {
        if(g_messLevel > 0) { // Messy Takes priority
            if(g_messLevel == 1) {
                temp = processPrint(messSpank1);
            }
            else if(g_messLevel >= 2) {
                temp = processPrint(messSpank2);
            }
        }
        else {
            if(g_wetLevel == 0) {
                temp = processPrint(cleanSpank);
            }
            else if(g_wetLevel == 1 || g_wetLevel == 2) {
                temp = processPrint(wetSpank1to2);
            }
            else if(g_wetLevel == 3 || g_wetLevel == 4) {
                temp = processPrint(wetSpank3to4);
            }
            else if(g_wetLevel >= 5) {
                temp = processPrint(wetSpank5to6);
            }
        }
    }
    else if(g_useType == "Force Wet") {
        if(g_forcedWet == FALSE) {
            g_forcedWet = TRUE;
            temp = processPrint(carer_forceWet1);
        }
        else { //2nd+ Time
            temp = processPrint(carer_forceWet2);
        }
    }
    else if(g_useType == "Force Mess") {
        if(g_forcedMess == FALSE) {
            g_forcedMess = TRUE;
            temp = processPrint(carer_forceMess1);
        }
        else { //2nd+ Time
            temp = processPrint(carer_forceMess2);
        }
    }
    else if(g_useType == "Wedgie")
    {
        if(g_messLevel > 0) // Messy Takes priority
        {
            if(g_messLevel == 1)
            {

                temp = processPrint(messWedgie1);
            }
            else if(g_messLevel >= 2)
            {
                temp = processPrint(messWedgie2);
            }
        }
        else
        {
            //wetWedgie1to2 is a clean wedgie
            if(g_wetLevel >= 0 && g_wetLevel <= 2) {
                temp = processPrint(wetWedgie1to2); 
            }
            else if(g_wetLevel == 3 || g_wetLevel == 4) {
                temp = processPrint(wetWedgie3to4);
            }
            else if(g_wetLevel >= 5) {
                temp = processPrint(wetWedgie5to6);
            }
        }
    }
    else if(g_useType == "CarerPotty") {
        temp = processPrint(carer_forcePotty);
    }
    else if(g_useType == "havetoPee") {
        temp = processPrint(havetoPee);
    }
    else if(g_useType == "havetoPoo") {
        temp = processPrint(havetoPoo);
    }
    else if(g_useType == "noPotty_W") {
        temp = processPrint(noPotty_W);
    }
    else if(g_useType == "noPotty_M") {
        temp = processPrint(noPotty_M);
    }
    else if(g_useType == "Forbitten") {
        temp = processPrint(forbitten);
    }
    if(temp) { //Allow for empty notecards to silence printouts
        index = llSubStringIndex(temp, " ");
        llSetObjectName(llGetSubString(temp, 0, index - 1));
        temp = llDeleteSubString(temp, 0, index);
        //determine chatter reach
        if(g_chatter > 1) {
            llSay(0, "/me " + temp);
        }
        else if(g_chatter == 1) {
            llWhisper(0, "/me "+temp);
        }
        else {
            llOwnerSay("/me "+temp);
            if(g_toucherKey != llGetOwner()) {
                llRegionSayTo(g_toucherKey, 0, "/me "+temp);
            }
        }
    }
    llSetObjectName(name); // Restore the name of the diaper.
}

default
{
    state_entry()
    {
        loadCustomPrints();   
    }
    //1. Query a line of the notecard
    //2. Check in dataserver to see if query_id matches g_lineQuery
    //3. If 2 is true, pull the data apart(Accounting for |)and store the information in the proper variable
    //3a.If 2 if false, return.
    //4. Goto 1
   dataserver(key query_id, string data)
   {
        if(g_lineQuery == query_id)
        {
            if(data != EOF)
            {
                ++g_lineNum; //Next Line
                
                integer index = llSubStringIndex(data, ":");
                if(index == -1) // This line is not the start of a printout
                {
                    index = llSubStringIndex(data, "|"); //Is it a 'next line' for a printout?
                    if(index == -1) // Garbage, discard it.
                    {
                        g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
                        
                        return;
                    }
                    else // Next line!
                    {
                        data = llGetSubString(data, index+1, llStringLength(data)); // Get rid of the pesky |
                        constructPrint(data, TRUE, g_printoutType);
                    }
                }
                else // New line, let's take care of it!
                {                
                    g_printoutType = llGetSubString(data, 0, index-1);
                    data = llGetSubString(data, index+1, llStringLength(data)); // Get rid of the type-header
                    
                    constructPrint(data, FALSE, g_printoutType);
                }
                
                // Get the next line based on notecard!
                g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
            }
            else
            {
                if(isDebug < 2) {
                    llOwnerSay("Printout2: Done reading your notecard! :3");
                }
                if(isDebug == TRUE) {
                    llOwnerSay("Printout2 Script Memory Used: " + (string) llGetUsedMemory() + " Bytes");
                    llOwnerSay("Printout2 Script Memory Remaining: " + (string) llGetFreeMemory() + " Bytes");
                }
            }
        }
    }
    
    //Messages for this will either come from Incont or Main, undecided.
    //Case 1: xxxxx, -4, g_gender:g_useLevel:g_useType:g_toucherName, xxxxx | xxxxx = Not used
    //Case 2: xxxxx, -4, g_gender:Update,               xxxxx | Used to swap out printout set
    link_message(integer sender_num, integer num, string msg, key id) {
        if(num != -4) {//the message isn't intended for us.
            return;
        }
        else {
            integer index = llSubStringIndex(msg, ":"); //Pull out the gender *Always first in list
            g_gender = (integer) llGetSubString(msg, 0, index-1);
            msg = llGetSubString(msg, index+1, -1); //Cut msg down to reflect change and move on
            if(llGetSubString(msg,0,5) == "Update") {//new notecard selected!
                g_PrintoutCard = llGetSubString(msg,7,-1);
                clearCustomPrints();
                loadCustomPrints(); //Load new printouts
            }
            else if (msg == "Gender") {//We actually don't need to do anything!
                return;
            }
            else if(msg == "Change") {// Diaper was changed by the carer.
                g_forcedMess = FALSE;
                g_forcedWet = FALSE;    
            }
            else if (msg == "Silent") {
                g_chatter = 0;
            }
            else if (msg == "High") {//llSay, 20 meters
                g_chatter = 2;
            }
            else if (msg == "Low") {//llWhisper, 10 meters
                g_chatter = 1;
            }
            else { // We got a message from main, let's print it!
                g_toucherKey = id;
                parseLinkedMessage(msg);
                displayPrintout();
            }
        }
    }
}
