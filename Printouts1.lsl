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

// Local Variables used by Prinouts.lsl to handle loading/displaying printouts.

integer g_wetLevel; // 0, 1, 2, . . .
integer g_messLevel;
integer g_gender = 1; // 0, 1 this one made for a girl
integer g_chatter = 2; //0, 1, 2 affects loudNESS
integer g_lineNum;
key g_lineQuery;
string g_printoutType; // Used in coupling with nextLineTest when a multi-liner is encountered!
string g_toucherName; // "Self" or "Tickle" or "Forced"
key g_toucherKey; //in case we need to print to someone else quietly!
string g_useType; // "Wet" "Mess"
string g_PrintoutCard = "Default";
integer isDebug = FALSE;
//set isDebug to 1 (TRUE) to enable all debug messages, and to 2 to disable info messages

// Variables which hold all printouts in memory for speed.

//Wet Prints
string wet1;
string wet2;
string wet3;
string wet4;
string wet5;
string wet6;

//wet holding events
//string holdwetstage0;
//string holdwetstage1;
//string holdwetstage2;
//string holdwetstage3;
//string holdwetstage4;
//string holdwetstage5;
//string holdwetstage6;
//string holdwetstage7;
//string holdwetstage8;
//string holdwetstage9;
//string holdunsuccessful;

// holding
string holtwTimer;
string holtmTimer;
string holtwButton;
string holtmButton;

string PottyW;
string PottyM;

//Mess Prints
string mess1;
string mess2;
string mess3;

//Diaper Checks from Carers in Printouts2 (22)

//Diaper Checks from Others
string other_checkClean;
string other_checkWet1;
string other_checkWet2;
string other_checkWet3;
string other_checkWet4; 
string other_checkWet5;
string other_checkWet6;
string other_checkMess1;
string other_checkMess2;
string other_checkMess3;
string other_checkWet1to2Mess1;
string other_checkWet3to4Mess1;
string other_checkWet5to6Mess1;
string other_checkWet1to2Mess2;
string other_checkWet3to4Mess2;
string other_checkWet5To6Mess2;
string other_checkWet1To2Mess3;
string other_checkWet3To4Mess3;
string other_checkWet5to6Mess3;

//Self Diaper Checks
string self_checkClean;
string self_checkWet1;
string self_checkWet2;
string self_checkWet3;
string self_checkWet4;
string self_checkWet5;
string self_checkWet6;
string self_checkMess1;
string self_checkMess2;
string self_checkMess3;
string self_checkWet1to2Mess1;
string self_checkWet3to4Mess1;
string self_checkWet5to6Mess1;
string self_checkWet1to2Mess2;
string self_checkWet3to4Mess2;
string self_checkWet5To6Mess2;
string self_checkWet1To2Mess3;
string self_checkWet3To4Mess3;
string self_checkWet5to6Mess3;

//Special Print for Super-Flooding in Printouts2 (1)

//Rubbing and Tickles in Printouts2 (11)

//Change printouts
string self_change;
string carer_change;
string other_change;

//Spanking Prints in Printouts2 (6)

//Poke Prints
string other_pokeClean;
string other_pokeWet;
string other_pokeMess;
string other_pokeWetMess;

//Wedgies in Printouts2 (6)

//Raspberry
string other_raspberry;

//Tease Prinouts
string cleanTease;
string wetTease;
string messTease;
string wetMessTease;

clearCustomPrints() {
    wet1="";
    wet2="";
    wet3="";
    wet4="";
    wet5="";
    wet6="";

    holtwTimer="";
    holtmTimer="";
    holtwButton="";
    holtmButton="";
    PottyW="";
    PottyM="";
    mess1="";
    mess2="";
    mess3="";

    other_checkClean="";
    other_checkWet1="";
    other_checkWet2="";
    other_checkWet3="";
    other_checkWet4="";
    other_checkWet5="";
    other_checkWet6="";
    other_checkMess1="";
    other_checkMess2="";
    other_checkMess3="";
    other_checkWet1to2Mess1=""; 
    other_checkWet3to4Mess1="";
    other_checkWet5to6Mess1="";
    other_checkWet1to2Mess2="";
    other_checkWet3to4Mess2="";
    other_checkWet5to6Mess3="";

    other_checkWet5To6Mess2="";
    other_checkWet1To2Mess3="";
    other_checkWet3To4Mess3="";

    self_checkClean="";
    self_checkWet1="";
    self_checkWet2="";
    self_checkWet3="";
    self_checkWet4="";
    self_checkWet5="";
    self_checkWet6="";
    self_checkMess1="";
    self_checkMess2="";
    self_checkMess3="";
    self_checkWet1to2Mess1=""; 
    self_checkWet3to4Mess1="";
    self_checkWet5to6Mess1="";
    self_checkWet1to2Mess2="";
    self_checkWet3to4Mess2="";
    self_checkWet5to6Mess3="";

    self_checkWet5To6Mess2="";
    self_checkWet1To2Mess3="";
    self_checkWet3To4Mess3="";

    self_change="";
    carer_change="";
    other_change="";

    other_pokeClean="";
    other_pokeWet="";
    other_pokeMess="";
    other_pokeWetMess="";

    other_raspberry="";

    cleanTease="";
    wetTease="";
    messTease="";
    wetMessTease="";
}

loadCustomPrints() {
    if(isDebug < 2) {
        llOwnerSay("Printouts1: Loading "+g_PrintoutCard+" notecard, this may take a minute or two!");
    }
    g_lineNum = 0;
    //todo:  change this to load a specified printout notecard instead of by gender
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
    msg = llGetSubString(msg, index+1, llStringLength(msg));
    
    index = llSubStringIndex(msg, ":"); // Pull out mess level
    g_messLevel = (integer) llGetSubString(msg, 0, index - 1);
    msg = llGetSubString(msg, index+1, llStringLength(msg));
    
    index = llSubStringIndex(msg, ":"); //Pull the usage type out
    g_useType = llGetSubString(msg, 0, index - 1);
    msg = llGetSubString(msg, index+1, llStringLength(msg));
    
    index = llSubStringIndex(msg, ":"); //Pull the sent name out
    g_toucherName = llGetSubString(msg, 0, index);
    msg = llGetSubString(msg, index+1, llStringLength(msg));
}

//@data = Unprocessed line of text from printout
//@append = Flags True/False if this is an addition to a prior printout
//@printoutType = Information that identifies which variable should be updated
constructPrint(string data, integer append, string printoutType) {
    if(append == TRUE) {
        if(printoutType == "@Wet1") {
            wet1 += data;
        }
        else if(printoutType == "@Wet2") {
            wet2 += data;
        }
        else if(printoutType == "@Wet3") {
            wet3 += data;
        }
        else if(printoutType == "@Wet4") {
            wet4 += data;
        }
        else if(printoutType == "@Wet5") {
            wet5 += data;
        }
        else if(printoutType == "@Wet6") {
            wet6 += data;
        }// End of wetting printouts
        else if(printoutType == "@uHoldwTimer") {
            holtwTimer += data;
        }
        else if(printoutType == "@uHoldmTimer") {
            holtmTimer += data;
        }
        else if(printoutType == "@uHoldwButton") {
            holtwButton += data;
        }
        else if(printoutType == "@uHoldmButton") {
            holtmButton += data;
        }// End of holding printouts
        else if(printoutType == "@uPotty_W") {
            PottyW += data;
        }
        else if(printoutType == "@uPotty_M") {
            PottyM += data;
        }
        else if(printoutType == "@Mess1") {
            mess1 += data;
        }
        else if(printoutType == "@Mess2") {
            mess2 += data;
        }
        else if(printoutType == "@Mess3") {
            mess3 += data;
        }// End of messing printouts
        else if(printoutType == "@uChange") { // Messages starting with the "u" prefix are self-oriented prints. Self Change, etc.
            self_change += data;
        }
        else if(printoutType == "@uCheckClean") {
            self_checkClean += data;
        }
        else if(printoutType == "@uCheckWet1") {
            self_checkWet1 += data;
        }
        else if(printoutType == "@uCheckWet2") {
            self_checkWet2 += data;
        }
        else if(printoutType == "@uCheckWet3") {
            self_checkWet3 += data;
        }
        else if(printoutType == "@uCheckWet4") {
            self_checkWet4 += data;
        }
        else if(printoutType == "@uCheckWet5") {
            self_checkWet5 += data;
        }
        else if(printoutType == "@uCheckWet6") {
            self_checkWet6 += data;
        }
        else if(printoutType == "@uCheckMess1") {
            self_checkMess1 += data;
        }
        else if(printoutType == "@uCheckMess2") {
            self_checkMess2 += data;
        }
        else if(printoutType == "@uCheckMess3") {
            self_checkMess3 += data;
        }
        else if(printoutType == "@uCheckWet1-2Mess1") {
            self_checkWet1to2Mess1 += data;
        }
        else if(printoutType == "@uCheckWet3-4Mess1") {
            self_checkWet3to4Mess1 += data;
        }
        else if(printoutType == "@uCheckWet5-6Mess1") {
            self_checkWet5to6Mess1 += data;
        }
        else if(printoutType == "@uCheckWet1-2Mess2") {
            self_checkWet1to2Mess2 += data;
        }
        else if(printoutType == "@uCheckWet3-4Mess2") {
            self_checkWet3to4Mess2 += data;
        }
        else if(printoutType == "@uCheckWet5-6Mess2") {
            self_checkWet5To6Mess2 += data;   
        }
        else if(printoutType == "@uCheckWet1-2Mess3") {
            self_checkWet1To2Mess3 += data;
        }
        else if(printoutType == "@uCheckWet3-4Mess3") {
            self_checkWet3To4Mess3 += data;
        }
        else if(printoutType == "@uCheckWet5-6Mess3") {
            self_checkWet5to6Mess3 += data;
        }
        else if(printoutType == "@oChange") { // Messages beginning with the "o" prefix involve others interacting with the diaper.
            other_change += data;
        }
        else if(printoutType == "@oCheckClean") {
            other_checkClean += data;
        }
        else if(printoutType == "@oCheckWet1") {
            other_checkWet1 += data;
        }
        else if(printoutType == "@oCheckWet2") {
            other_checkWet2 += data;
        }
        else if(printoutType == "@oCheckWet3") {
            other_checkWet3 += data;
        }
        else if(printoutType == "@oCheckWet4") {
            other_checkWet4 += data;
        }
        else if(printoutType == "@oCheckWet5") {
            other_checkWet5 += data;
        }
        else if(printoutType == "@oCheckWet6") {
            other_checkWet6 += data;
        }
        else if(printoutType == "@oCheckMess1") {
            other_checkMess1 += data;
        }
        else if(printoutType == "@oCheckMess2") {
            other_checkMess2 += data;
        }
        else if(printoutType == "@oCheckMess3") {
            other_checkMess3 += data;
        }
        else if(printoutType == "@oCheckWet1-2Mess1") {
            other_checkWet1to2Mess1 += data;
        }
        else if(printoutType == "@oCheckWet3-4Mess1") {
            other_checkWet3to4Mess1 += data;
        }
        else if(printoutType == "@oCheckWet5-6Mess1") {
            other_checkWet5to6Mess1 += data;
        }
        else if(printoutType == "@oCheckWet1-2Mess2") {
            other_checkWet1to2Mess2 += data;
        }
        else if(printoutType == "@oCheckWet3-4Mess2") {
            other_checkWet3to4Mess2 += data;
        }
        else if(printoutType == "@oCheckWet5-6Mess2") {
            other_checkWet5To6Mess2 += data;
        }
        else if(printoutType == "@oCheckWet1-2Mess3") {
            other_checkWet1To2Mess3 += data;
        }
        else if(printoutType == "@oCheckWet3-4Mess3") {
            other_checkWet3To4Mess3 += data;
        }
        else if(printoutType == "@oCheckWet5-6Mess3") {
            other_checkWet5to6Mess3 += data;
        }
        else if(printoutType == "@oPoke") {
            other_pokeClean += data;
        }
        else if(printoutType == "@oPokeWet") {
            other_pokeWet += data;
        }
        else if(printoutType == "@oPokeMess") {
            other_pokeMess += data;
        }
        else if(printoutType == "@oPokeWetMess") {
            other_pokeWetMess += data;
        }
        else if(printoutType == "@oRaspberry") {
            other_raspberry += data;
        }
        else if(printoutType == "@oTease") {
            cleanTease += data;
        }
        else if(printoutType == "@oWetTease1") {
            wetTease += data;
        }
        else if(printoutType == "@oMessTease1") {
            messTease += data;
        }
        else if(printoutType == "@oWetMessTease1") {
            wetMessTease += data;
        }
        else if(printoutType == "@CareChange") {
            carer_change += data;
        }
    }
    else // Not appending, initialize/replace the printout!
    {
        if(printoutType == "@Wet1") {
            wet1 = data;
        }
        else if(printoutType == "@Wet2") {
            wet2 = data;
        }
        else if(printoutType == "@Wet3") {
            wet3 = data;
        }
        else if(printoutType == "@Wet4") {
            wet4 = data;
        }
        else if(printoutType == "@Wet5") {
            wet5 = data;
        }
        else if(printoutType == "@Wet6") {
            wet6 = data;
        }// End of wetting printouts
        else if(printoutType == "@uHoldwTimer") {
            holtwTimer = data;
        }
        else if(printoutType == "@uHoldmTimer") {
            holtmTimer = data;
        }
        else if(printoutType == "@uHoldwButton") {
            holtwButton = data;
        }
        else if(printoutType == "@uHoldmButton") {
            holtmButton = data;
        }// End of holding printouts
        else if(printoutType == "@uPotty_W") {
            PottyW = data;
        }
        else if(printoutType == "@uPotty_M") {
            PottyM = data;
        }
        else if(printoutType == "@Mess1") {
            mess1 = data;
        }
        else if(printoutType == "@Mess2") {
            mess2 = data;
        }
        else if(printoutType == "@Mess3") {
            mess3 = data;
        }
        else if(printoutType == "@uChange") {
            self_change = data;
        }
        else if(printoutType == "@uCheckClean") {
            self_checkClean = data;
        }
        else if(printoutType == "@uCheckWet1") {
            self_checkWet1 = data;
        }
        else if(printoutType == "@uCheckWet2") {
            self_checkWet2 = data;
        }
        else if(printoutType == "@uCheckWet3") {
            self_checkWet3 = data;
        }
        else if(printoutType == "@uCheckWet4") {
            self_checkWet4 = data;
        }
        else if(printoutType == "@uCheckWet5") {
            self_checkWet5 = data;
        }
        else if(printoutType == "@uCheckWet6") {
            self_checkWet6 = data;
        }
        else if(printoutType == "@uCheckMess1") {
            self_checkMess1 = data;
        }
        else if(printoutType == "@uCheckMess2") {
            self_checkMess2 = data;
        }
        else if(printoutType == "@uCheckMess3") {
            self_checkMess3 = data;
        }
        else if(printoutType == "@uCheckWet1-2Mess1") {
            self_checkWet1to2Mess1 = data;
        }
        else if(printoutType == "@uCheckWet3-4Mess1") {
            self_checkWet3to4Mess1 = data;
        }
        else if(printoutType == "@uCheckWet5-6Mess1") {
            self_checkWet5to6Mess1 = data;
        }
        else if(printoutType == "@uCheckWet1-2Mess2") {
            self_checkWet1to2Mess2 = data;
        }
        else if(printoutType == "@uCheckWet3-4Mess2") {
            self_checkWet3to4Mess2 = data;
        }
        else if(printoutType == "@uCheckWet5-6Mess2") {
            self_checkWet5To6Mess2 = data;
        }
        else if(printoutType == "@uCheckWet1-2Mess3") {
            self_checkWet1To2Mess3 = data;
        }
        else if(printoutType == "@uCheckWet3-4Mess3") {
            self_checkWet3To4Mess3 = data;
        }
        else if(printoutType == "@uCheckWet5-6Mess3") {
            self_checkWet5to6Mess3 = data;
        }
        else if(printoutType == "@oChange") {
            other_change = data;
        }
        else if(printoutType == "@oCheckClean") {
            other_checkClean = data;
        }
        else if(printoutType == "@oCheckWet1") {
            other_checkWet1 = data;
        }
        else if(printoutType == "@oCheckWet2") {
            other_checkWet2 = data;
        }
        else if(printoutType == "@oCheckWet3") {
            other_checkWet3 = data;
        }
        else if(printoutType == "@oCheckWet4") {
            other_checkWet4 = data;
        }
        else if(printoutType == "@oCheckWet5") {
            other_checkWet5 = data;
        }
        else if(printoutType == "@oCheckWet6") {
            other_checkWet6 = data;
        }
        else if(printoutType == "@oCheckMess1") {
            other_checkMess1 = data;
        }
        else if(printoutType == "@oCheckMess2") {
            other_checkMess2 = data;
        }
        else if(printoutType == "@oCheckMess3") {
            other_checkMess3 = data;
        }
        else if(printoutType == "@oCheckWet1-2Mess1") {
            other_checkWet1to2Mess1 = data;
        }
        else if(printoutType == "@oCheckWet3-4Mess1") {
            other_checkWet3to4Mess1 = data;
        }
        else if(printoutType == "@oCheckWet5-6Mess1") {
            other_checkWet5to6Mess1 = data;
        }
        else if(printoutType == "@oCheckWet1-2Mess2") {
            other_checkWet1to2Mess2 = data;
        }
        else if(printoutType == "@oCheckWet3-4Mess2") {
            other_checkWet3to4Mess2 = data;
        }
        else if(printoutType == "@oCheckWet5-6Mess2") {
            other_checkWet5To6Mess2 = data;
        }
        else if(printoutType == "@oCheckWet1-2Mess3") {
            other_checkWet1To2Mess3 = data;
        }
        else if(printoutType == "@oCheckWet3-4Mess3") {
            other_checkWet3To4Mess3 = data;
        }
        else if(printoutType == "@oCheckWet5-6Mess3") {
            other_checkWet5to6Mess3 = data;
        }
        else if(printoutType == "@oPoke") {
            other_pokeClean = data;
        }
        else if(printoutType == "@oPokeWet") {
            other_pokeWet = data;
        }
        else if(printoutType == "@oPokeMess") {
            other_pokeMess = data;
        }
        else if(printoutType == "@oPokeWetMess") {
            other_pokeWetMess = data;
        }
        else if(printoutType == "@oRaspberry") {
            other_raspberry = data;
        }
        else if(printoutType == "@oTease") {
            cleanTease = data;
        }
        else if(printoutType == "@oWetTease") {
            wetTease = data;
        }
        else if(printoutType == "@oMessTease") {
            messTease = data;
        }
        else if(printoutType == "@oWetMessTease") {
            wetMessTease = data;
        }
        else if(printoutType == "@CareChange") {
            carer_change = data;
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
// @g_useType - A global variable set when parsing printout messages from main.
// NOTE: Animations, when implemented, will go in the if-else chain.
displayPrintout() {
    string temp; // Used to prevent the original printouts from being altered.
    string name; // Holds the original name of the object.
    integer index;  // Used to locate the first space in any given printout. This lets me set the name of the object
                    // temporarily to the first word of any given printed message. Allows for RP prints.

    name = llGetObjectName(); // Preserve the name of the Diaper
    
    if(g_useType == "Carer Change") { // Diaper change commencing
        temp = processPrint(carer_change); 
    }
    else if(g_useType == "Normal Change") { // Changed by a random outsider.
        temp = processPrint(other_change);
    }
    else if(g_useType == "Self Change") { // User changed themselves!
        temp = processPrint(self_change);
    }
    else if(g_useType == "g_wetLevel") { // They've wet!
        if(g_wetLevel == 1) { // How wet are they?
            temp = processPrint(wet1);
        }
        else if(g_wetLevel == 2) {
            temp = processPrint(wet2);
        }
        else if(g_wetLevel == 3) {
            temp = processPrint(wet3);
        }
        else if(g_wetLevel == 4) {
            temp = processPrint(wet4);
        }
        else if(g_wetLevel == 5) {
            temp = processPrint(wet5);
        }
        else {
            temp = processPrint(wet6);
        }
    }
    else if(g_useType == "g_messLevel") { // The user messed!
        if(g_messLevel == 1) {
            temp = processPrint(mess1);
        }
        else if(g_messLevel == 2) {
            temp = processPrint(mess2);
        }
        else {
            temp = processPrint(mess3);
        }
    }
    else if(g_useType == "Self Check") {
        //There are different messages for when messy, when wet, and when both wet and messy
        //wet
        if(g_wetLevel == 0 && g_messLevel == 0) {
            temp = processPrint(self_checkClean);
        }
        else if(g_wetLevel == 1 && g_messLevel == 0) {
            temp = processPrint(self_checkWet1);
        }
        else if(g_wetLevel == 2 && g_messLevel == 0) {
            temp = processPrint(self_checkWet2);
        }
        else if(g_wetLevel == 3 && g_messLevel == 0) {
            temp = processPrint(self_checkWet3);
        }
        else if(g_wetLevel == 4 && g_messLevel == 0) {
            temp = processPrint(self_checkWet4);
        }
        else if(g_wetLevel == 5 && g_messLevel == 0) {
            temp = processPrint(self_checkWet5);
        }
        else if(g_wetLevel >= 6 && g_messLevel == 0) { //catch-all for very wet diapers.
            temp = processPrint(self_checkWet6);
        }
        //messy
        else if(g_wetLevel == 0 && g_messLevel == 1) {
            temp = processPrint(self_checkMess1);
        }
        else if(g_wetLevel == 0 && g_messLevel == 2) {
            temp = processPrint(self_checkMess2);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 3) { //Catch all for very stinky diapers.
            temp = processPrint(self_checkMess3);
        }
        //both wet and messy
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 1) {
            temp = processPrint(self_checkWet1to2Mess1);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 1) {
            temp = processPrint(self_checkWet3to4Mess1);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 1) { //catch-all for very wet diapers.
            temp = processPrint(self_checkWet5to6Mess1);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 2) {
            temp = processPrint(self_checkWet1to2Mess2);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 2) {
            temp = processPrint(self_checkWet3to4Mess2);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 2) { //catch-all for very wet diapers.
            temp = processPrint(self_checkWet5To6Mess2);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel >= 3) {
            temp = processPrint(self_checkWet1To2Mess3);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel >= 3) {
            temp = processPrint(self_checkWet3To4Mess3);
        }
        else if(g_wetLevel >= 5 && g_messLevel >= 3) {// Catch all for very stinky, and very wet diapers.
            temp = processPrint(self_checkWet5to6Mess3);
        }
    }
    else if(g_useType == "Other Check") {
    //wet
        if(g_wetLevel == 0 && g_messLevel == 0) {
            temp = processPrint(other_checkClean);
        }
        else if(g_wetLevel == 1 && g_messLevel == 0) {
            temp = processPrint(other_checkWet1);
        }
        else if(g_wetLevel == 2 && g_messLevel == 0) {
            temp = processPrint(other_checkWet2);
        }
        else if(g_wetLevel == 3 && g_messLevel == 0) {
            temp = processPrint(other_checkWet3);
        }
        else if(g_wetLevel == 4 && g_messLevel == 0) {
            temp = processPrint(other_checkWet4);
        }
        else if(g_wetLevel == 5 && g_messLevel == 0) {
            temp = processPrint(other_checkWet5);
        }
        else if(g_wetLevel >= 6 && g_messLevel == 0) {
            temp = processPrint(other_checkWet6);
        }
        //messy
        else if(g_wetLevel == 0 && g_messLevel == 1) {
            temp = processPrint(other_checkMess1);
        }
        else if(g_wetLevel == 0 && g_messLevel == 2) {
            temp = processPrint(other_checkMess2);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 3) {// Catch all for very stinky diapers.
            temp = processPrint(other_checkMess3);
        }
        //both wet and messy
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 1) {
            temp = processPrint(other_checkWet1to2Mess1);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 1) {
            temp = processPrint(other_checkWet3to4Mess1);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 1) { //Catch-all for very wet diapers.
            temp = processPrint(other_checkWet5to6Mess1);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 2) {
            temp = processPrint(other_checkWet1to2Mess2);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 2) {
            temp = processPrint(other_checkWet3to4Mess2);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 2) { //catch all for very wet diapers.
            temp = processPrint(other_checkWet5To6Mess2);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel >= 3) {
            temp = processPrint(other_checkWet1To2Mess3);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel >= 3) {
            temp = processPrint(other_checkWet3To4Mess3);
        }
        else if(g_wetLevel >= 5 && g_messLevel >= 3) {//Catch-all for very wet and messy diapers.
            temp = processPrint(other_checkWet5to6Mess3);
        }
    }
    else if(g_useType == "Poke") {
        if(g_wetLevel == 0 && g_messLevel == 0) {
            temp = processPrint(other_pokeClean);
        }
        else if(g_wetLevel >= 1 && g_messLevel == 0) {
            temp = processPrint(other_pokeWet);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 1) {
            temp = processPrint(other_pokeMess);
        }
        else if(g_wetLevel >= 1 && g_messLevel >= 1) {
            temp = processPrint(other_pokeWetMess);
        }
    }
    else if(g_useType == "Raspberry") {
        temp = processPrint(other_raspberry);
    }
    else if(g_useType == "Tease") {
        if(g_wetLevel == 0 && g_messLevel == 0) {
            temp = processPrint(cleanTease);
        }
        else if(g_wetLevel >= 1 && g_messLevel == 0) {
            temp = processPrint(wetTease);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 1) {
            temp = processPrint(messTease);
        }
        else if(g_wetLevel >= 1 && g_messLevel >= 1) {
            temp = processPrint(wetMessTease);
        }
    }
    // addet napysusy to do message vor holding
    else if(g_useType == "WHold_Button") {
        temp = processPrint(holtwButton);
    }
    else if(g_useType == "WHold_Timer") {
        temp = processPrint(holtwTimer);
    }
    else if(g_useType == "MHold_Button") {
        temp = processPrint(holtmButton);
    }
    else if(g_useType == "MHold_Timer") {
        temp = processPrint(holtmTimer);
    }
    else if(g_useType == "Potty_W") {
        temp = processPrint(PottyW);
    }
    else if(g_useType == "Potty_M") {
        temp = processPrint(PottyM);
    }
    if(temp) { //Don't chat at all if we didn't assign temp anything
        //Remove first word in sentence
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
    llSetObjectName(name); // Restore the original name of the diaper.
}

default {
    state_entry() {
        loadCustomPrints();   //load the default notecard on script reset
    }
    
    //1. Query a line of the notecard
    //2. Check in dataserver to see if query_id matches g_lineQuery
    //3. If 2 is true, pull the data apart(Accounting for |)and store the information in the proper variable
    //3a.If 2 if false, return.
    //4. Goto 1
    //
    // To fully understand this event, you need to look at the format of data in the notecards!
    dataserver(key query_id, string data) {
        if(g_lineQuery == query_id) {
            if(data != EOF) {
                ++g_lineNum; //Next Line
                integer index = llSubStringIndex(data, ":");
                if(index == -1) { // This line is not the start of a printout
                    index = llSubStringIndex(data, "|"); //Is it a 'next line' for a printout?
                    if(index == -1) { // Garbage, discard it.
                        g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
                        return;
                    }
                    else { // Next line!
                        data = llGetSubString(data, index+1, llStringLength(data)); // Get rid of the pesky |
                        constructPrint(data, TRUE, g_printoutType);
                    }
                }
                else { // New line, let's take care of it!
                    g_printoutType = llGetSubString(data, 0, index-1);
                    data = llGetSubString(data, index+1, llStringLength(data)); // Get rid of the type-header
                    constructPrint(data, FALSE, g_printoutType);
                }
                // Get the next line from the requested notecard!
                g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
            }
            else {
                if(isDebug < 2) {
                    llOwnerSay("Printout1: Done reading your notecard! :3");
                }
                if(isDebug == TRUE) {
                    llOwnerSay("Printout1 Script Memory Used: " + (string) llGetUsedMemory() + " Bytes");
                    llOwnerSay("Printout1 Script Memory Remaining: " + (string) llGetFreeMemory() + " Bytes");
                }
            }
        }
    }
    
    //Messages for this will either come from Incont or Main, undecided.
    //Case 1: xxxxx, -2, g_gender:g_useLevel:g_useType:g_toucherName, g_toucherKey | xxxxx = Not used
    //Case 2: xxxxx, -2, g_gender:Update:Notecard,               xxxxx | Used to swap out printout set
    //Case 3: xxxxx, -2, g_gender:Gender, xxxxx  | Just updating the gender
    //Case 4: XXXXX, -2, g_gender:Silent, xxxxx  | Diaper should only print out to self
    //case 5: xxxxx, -2, g_gender:High,xxxx   | High spammy diaper!
    //Case 6: xxxxx, -2, g_gender:Low, xxxx   | Low spammy diaper, whispers
    link_message(integer sender_num, integer num, string msg, key id) {
        if(num != -2) { //the message isn't intended for us.
            return;
        }
        else {
            integer index = llSubStringIndex(msg, ":"); //Pull out the gender *Always first in list
            g_gender = (integer) llGetSubString(msg, 0, index-1);
            msg = llGetSubString(msg, index+1, -1); //Cut msg down to reflect change and move on
            if(llGetSubString(msg,0,5) == "Update") {//new notecard selected!
                g_PrintoutCard = llGetSubString(msg,7,-1);
                clearCustomPrints();
                loadCustomPrints();
            }
            else if (msg == "Gender") { //We no longer need to do anything!
                return;
            }
            else if (msg == "Silent") { //only to self and potentially toucher
                g_chatter = 0;
            }
            else if (msg == "High") { //llSay, 20 meters
                g_chatter = 2;
            }
            else if (msg == "Low") { //llWhisper, 10 meters
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
