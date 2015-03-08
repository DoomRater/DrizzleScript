/*==========================================================
DrizzleScript
Created By: Ryhn Teardrop
Original Date: Dec 3rd, 2011

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.


*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

/*
* Local Variables used by Prinouts.lsl to handle loading/displaying printouts.
*/

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

//Mess Prints
string mess1;
string mess2;
string mess3;

//Diaper Checks from Carers in Printouts2 (20)

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
string other_checkWetMess1; //
string other_checkWetMess2; // OUTDATED, update from Printouts to get the right ranges vvvv
string other_checkWetMess3; //1 to 2 Wet + 1 Mess, 3 to 4 Wet + 2 Mess, 5 to 6 Wet + 2 Mess 
string other_checkWetMess4;
string other_checkWetMess5;
string other_checkWetMess6;

// Gaps Filled in 6/30/2013
string other_checkWet5To6Mess2;
string other_checkWet1To2Mess3;
string other_checkWet3To4Mess3;

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
string self_checkWetMess1; //
string self_checkWetMess2; // OUTDATED, update from Printouts to get the right ranges vvvv
string self_checkWetMess3; //1 to 2 Wet + 1 Mess, 3 to 4 Wet + 2 Mess, 5 to 6 Wet + 2 Mess 
string self_checkWetMess4;
string self_checkWetMess5;
string self_checkWetMess6;

// Gaps Filled in 6/30/2013
string self_checkWet5To6Mess2;
string self_checkWet1To2Mess3;
string self_checkWet3To4Mess3;

//Special Print for Super-Flooding in Printouts2 (1)

//Rubbing and Tickles in Printouts2 (11)

//Change printouts
string self_change;
string carer_change;
string other_change;

//Spanking Prints in Printouts2 (5 w/ 2 potentially un-needed)

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

clearCustomPrints()
{
    wet1="";
    wet2="";
    wet3="";
    wet4="";
    wet5="";
    wet6="";

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
    other_checkWetMess1=""; 
    other_checkWetMess2="";
    other_checkWetMess3="";
    other_checkWetMess4="";
    other_checkWetMess5="";
    other_checkWetMess6="";

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
    self_checkWetMess1=""; 
    self_checkWetMess2="";
    self_checkWetMess3="";
    self_checkWetMess4="";
    self_checkWetMess5="";
    self_checkWetMess6="";

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

loadCustomPrints()
{
    llOwnerSay("Printouts1: Loading your notecard, this may take a minute or two!");
    g_lineNum = 0;
    //todo:  change this to load a specified printout notecard instead of by gender
    if(llGetInventoryType("PRINT:" + g_PrintoutCard) != -1)
    {
        g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
    }
    else
    {
        llOwnerSay("No Notecard Found!\n Please drag this notecard into your model: PRINT:" + g_PrintoutCard);
    }
}

// This function takes a message (presumably sent by the main menu)
// and pulls it apart, gathering values for the global values:
// g_useLevel, g_useType, and g_toucherName
// @msg = Example - "1:g_wetLevel:Ryhn Teardrop"
parseLinkedMessage(string msg)
{
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
constructPrint(string data, integer append, string printoutType)
{
    //TODO: Replace immediate tokens (User related tokens) on construction
    
    //llSay(0, "Printout Script: [Memory Used] " + (string) llGetUsedMemory() + " Bytes.");
    //llSay(0, "=== Processing: " + data + " ===");
    //llSay(0, "Printout Script: [Memory Remaining] " + (string) llGetFreeMemory() + " Bytes.");
    //llOwnerSay("Constructing print. . .");
    if(append == TRUE)
    {
        if(printoutType == "@Wet1")
        {
            wet1 += data;
            return; 
        }
        else if(printoutType == "@Wet2")
        {
            wet2 += data;
            return;
        }
        else if(printoutType == "@Wet3")
        {
            wet3 += data;
            return;   
        }
        else if(printoutType == "@Wet4")
        {
            wet4 += data;
            return;
        }
        else if(printoutType == "@Wet5")
        {
            wet5 += data;
            return;
        }
        else if(printoutType == "@Wet6")
        {
            wet6 += data;
            return;
        }// End of wetting printouts
        else if(printoutType == "@Mess1")
        {
            mess1 += data;
            return;   
        }
        else if(printoutType == "@Mess2")
        {
            mess2 += data;
            return;   
        }
        else if(printoutType == "@Mess3")
        {
            mess3 += data;
            return;   
        }// End of messing printouts
        else if(printoutType == "@uChange") // Messages starting with the "u" prefix are self-oriented prints. Self Change, etc.
        {
            self_change += data;
            return;   
        }
        else if(printoutType == "@uCheckClean")
        {
            self_checkClean += data;
            return;
        }
        else if(printoutType == "@uCheckWet1")
        {
            self_checkWet1 += data;
            return;
        }
        else if(printoutType == "@uCheckWet2")
        {
            self_checkWet2 += data;
            return;
        }
        else if(printoutType == "@uCheckWet3")
        {
            self_checkWet3 += data;
            return;
        }
        else if(printoutType == "@uCheckWet4")
        {
            self_checkWet4 += data;
            return;
        }
        else if(printoutType == "@uCheckWet5")
        {
            self_checkWet5 += data;
            return;
        }
        else if(printoutType == "@uCheckWet6")
        {
            self_checkWet6 += data;
            return;
        }
        else if(printoutType == "@uCheckMess1")
        {
            self_checkMess1 += data;
            return;
        }
        else if(printoutType == "@uCheckMess2")
        {
            self_checkMess2 += data;
            return;
        }
        else if(printoutType == "@uCheckMess3")
        {
            self_checkMess3 += data;
            return;
        }
        else if(printoutType == "@uCheckWet1-2Mess1")
        {
            self_checkWetMess1 += data;
            return;
        }
        else if(printoutType == "@uCheckWet3-4Mess1")
        {
            self_checkWetMess2 += data;
            return;
        }
        else if(printoutType == "@uCheckWet5-6Mess1")
        {
            self_checkWetMess3 += data;
            return;
        }
        else if(printoutType == "@uCheckWet1-2Mess2")
        {
            self_checkWetMess4 += data;
            return;
        }
        else if(printoutType == "@uCheckWet3-4Mess2")
        {
            self_checkWetMess5 += data;
            return;
        }
        else if(printoutType == "@uCheckWet5-6Mess2")
        {
            self_checkWet5To6Mess2 += data;   
        }
        else if(printoutType == "@uCheckWet1-2Mess3")
        {
            // Gap 6/30/2013
            self_checkWet1To2Mess3 += data;
        }
        else if(printoutType == "@uCheckWet3-4Mess3")
        {
            // ^^^^
            self_checkWet3To4Mess3 += data;
        }
        else if(printoutType == "@uCheckWet5-6Mess3")
        {
            self_checkWetMess6 += data;
            return;
        }
        else if(printoutType == "@oChange") // Messages beginning with the "o" prefix involve others interacting with the diaper.
        {
            other_change += data;
            return;   
        }
        else if(printoutType == "@oCheckClean")
        {
            other_checkClean += data;
            return;   
        }
        else if(printoutType == "@oCheckWet1")
        {
            other_checkWet1 += data;
            return;   
        }
        else if(printoutType == "@oCheckWet2")
        {
            other_checkWet2 += data;
            return;    
        }
        else if(printoutType == "@oCheckWet3")
        {
            other_checkWet3 += data;
            return;    
        }
        else if(printoutType == "@oCheckWet4")
        {
            other_checkWet4 += data;
            return;    
        }
        else if(printoutType == "@oCheckWet5")
        {
            other_checkWet5 += data;
            return;    
        }
        else if(printoutType == "@oCheckWet6")
        {
            other_checkWet6 += data;
            return;    
        }
        else if(printoutType == "@oCheckMess1")
        {
            other_checkMess1 += data;
            return;    
        }
        else if(printoutType == "@oCheckMess2")
        {
            other_checkMess2 += data;
            return;    
        }
        else if(printoutType == "@oCheckMess3")
        {
            other_checkMess3 += data;
            return; 
        }
        else if(printoutType == "@oCheckWet1-2Mess1")
        {
            other_checkWetMess1 += data;
            return;
        }
        else if(printoutType == "@oCheckWet3-4Mess1")
        {
            other_checkWetMess2 += data;
            return;
        }
        else if(printoutType == "@oCheckWet5-6Mess1")
        {
            other_checkWetMess3 += data;
            return;    
        }
        else if(printoutType == "@oCheckWet1-2Mess2")
        {
            other_checkWetMess4 += data;
            return;   
        }
        else if(printoutType == "@oCheckWet3-4Mess2")
        {
            other_checkWetMess5 += data;
            return;   
        }
        else if(printoutType == "@oCheckWet5-6Mess2")
        {
            other_checkWet5To6Mess2 += data;
            return;   
        }
        else if(printoutType == "@oCheckWet1-2Mess3")
        {
            // Gap 6/30/2013
            other_checkWet1To2Mess3 += data;
            return; 
        }
        else if(printoutType == "@oCheckWet3-4Mess3")
        {
            // ^^^^
            other_checkWet3To4Mess3 += data;
            return; 
        }
        else if(printoutType == "@oCheckWet5-6Mess3")
        {
            other_checkWetMess6 += data;
            return;
        }
        else if(printoutType == "@oPoke")
        {
            other_pokeClean += data;
            return;
        }
        else if(printoutType == "@oPokeWet")
        {
            other_pokeWet += data;
            return;
        }
        else if(printoutType == "@oPokeMess")
        {
            other_pokeMess += data;
            return;
        }
        else if(printoutType == "@oPokeWetMess")
        {
            other_pokeWetMess += data;
            return;
        }
        else if(printoutType == "@oRaspberry")
        {
            other_raspberry += data;
            return;
        }
        else if(printoutType == "@oTease")
        {
            cleanTease += data;
            return;
        }
        else if(printoutType == "@oWetTease1")
        {
            wetTease += data;
            return;
        }
        else if(printoutType == "@oMessTease1")
        {
            messTease += data;
            return;
        }
        else if(printoutType == "@oWetMessTease1")
        {
            wetMessTease += data;
            return;
        }
        else if(printoutType == "@CareChange")
        {
            carer_change += data;
            return; 
        }
        //Etc. . .
    }
    else // Not appending, initialize/replace the printout!
    {
        if(printoutType == "@Wet1")
        {
            wet1 = data;
            return; 
        }
        else if(printoutType == "@Wet2")
        {
            wet2 = data;
            return;
        }
        else if(printoutType == "@Wet3")
        {
            wet3 = data;
            return;   
        }
        else if(printoutType == "@Wet4")
        {
            wet4 = data;
            return;
        }
        else if(printoutType == "@Wet5")
        {
            wet5 = data;
            return;
        }
        else if(printoutType == "@Wet6")
        {
            wet6 = data;
            return;
        }// End of wetting printouts
        else if(printoutType == "@Mess1")
        {
            mess1 = data;
            return;   
        }
        else if(printoutType == "@Mess2")
        {
            mess2 = data;
            return;   
        }
        else if(printoutType == "@Mess3")
        {
            mess3 = data;
            return;   
        }
        else if(printoutType == "@uChange")
        {
            self_change = data;
            return;   
        }
        else if(printoutType == "@uCheckClean")
        {
            self_checkClean = data;
            return;
        }
        else if(printoutType == "@uCheckWet1")
        {
            self_checkWet1 = data;
            return;
        }
        else if(printoutType == "@uCheckWet2")
        {
            self_checkWet2 = data;
            return;
        }
        else if(printoutType == "@uCheckWet3")
        {
            self_checkWet3 = data;
            return;
        }
        else if(printoutType == "@uCheckWet4")
        {
            self_checkWet4 = data;
            return;
        }
        else if(printoutType == "@uCheckWet5")
        {
            self_checkWet5 = data;
            return;
        }
        else if(printoutType == "@uCheckWet6")
        {
            self_checkWet6 = data;
            return;
        }
        else if(printoutType == "@uCheckMess1")
        {
            self_checkMess1 = data;
            return;
        }
        else if(printoutType == "@uCheckMess2")
        {
            self_checkMess2 = data;
            return;
        }
        else if(printoutType == "@uCheckMess3")
        {
            self_checkMess3 = data;
            return;
        }
        else if(printoutType == "@uCheckWet1-2Mess1")
        {
            self_checkWetMess1 = data;
            return;
        }
        else if(printoutType == "@uCheckWet3-4Mess1")
        {
            self_checkWetMess2 = data;
            return;
        }
        else if(printoutType == "@uCheckWet5-6Mess1")
        {
            self_checkWetMess3 = data;
            return;
        }
        else if(printoutType == "@uCheckWet1-2Mess2")
        {
            self_checkWetMess4 = data;
            return;
        }
        else if(printoutType == "@uCheckWet3-4Mess2")
        {
            self_checkWetMess5 = data;
            return;
        }
        else if(printoutType == "@uCheckWet5-6Mess2")
        {
            self_checkWet5To6Mess2 = data;
            return;
        }
        else if(printoutType == "@uCheckWet1-2Mess3")
        {
            // Gap 6/30/2013
            self_checkWet1To2Mess3 = data;
            return;
        }
        else if(printoutType == "@uCheckWet3-4Mess3")
        {
            // ^^^^
            self_checkWet3To4Mess3 = data;
            return;
        }
        else if(printoutType == "@uCheckWet5-6Mess3")
        {
            self_checkWetMess6 = data;
            return;
        }
        else if(printoutType == "@oChange")
        {
            other_change = data;
            return;   
        }
        else if(printoutType == "@oCheckClean")
        {
            other_checkClean = data;
            return;   
        }
        else if(printoutType == "@oCheckWet1")
        {
            other_checkWet1 = data;
            return;   
        }
        else if(printoutType == "@oCheckWet2")
        {
            other_checkWet2 = data;
            return;    
        }
        else if(printoutType == "@oCheckWet3")
        {
            other_checkWet3 = data;
            return;    
        }
        else if(printoutType == "@oCheckWet4")
        {
            other_checkWet4 = data;
            return;    
        }
        else if(printoutType == "@oCheckWet5")
        {
            other_checkWet5 = data;
            return;    
        }
        else if(printoutType == "@oCheckWet6")
        {
            other_checkWet6 = data;
            return;    
        }
        else if(printoutType == "@oCheckMess1")
        {
            other_checkMess1 = data;
            return;    
        }
        else if(printoutType == "@oCheckMess2")
        {
            other_checkMess2 = data;
            return;    
        }
        else if(printoutType == "@oCheckMess3")
        {
            other_checkMess3 = data;
            return; 
        }
        else if(printoutType == "@oCheckWet1-2Mess1")
        {
            other_checkWetMess1 = data;
            return;
        }
        else if(printoutType == "@oCheckWet3-4Mess1")
        {
            other_checkWetMess2 = data;
            return;
        }
        else if(printoutType == "@oCheckWet5-6Mess1")
        {
            other_checkWetMess3 = data;
            return;    
        }
        else if(printoutType == "@oCheckWet1-2Mess2")
        {
            other_checkWetMess4 = data;
            return;   
        }
        else if(printoutType == "@oCheckWet3-4Mess2")
        {
            other_checkWetMess5 = data;
            return;   
        }
        else if(printoutType == "@oCheckWet5-6Mess2")
        {
            other_checkWet5To6Mess2 = data;
            return;
        }
        else if(printoutType == "@oCheckWet1-2Mess3")
        {
            // Gap 6/30/2013
            other_checkWet1To2Mess3 = data;
            return;
        }
        else if(printoutType == "@oCheckWet3-4Mess3")
        {
            // ^^^^
            other_checkWet3To4Mess3 = data;
            return;
        }
        else if(printoutType == "@oCheckWet5-6Mess3")
        {
            other_checkWetMess6 = data;
            return;
        }
        else if(printoutType == "@oPoke")
        {
            other_pokeClean = data;
            return;
        }
        else if(printoutType == "@oPokeWet")
        {
            other_pokeWet = data;
            return;
        }
        else if(printoutType == "@oPokeMess")
        {
            other_pokeMess = data;
            return;
        }
        else if(printoutType == "@oPokeWetMess")
        {
            other_pokeWetMess = data;
            return;
        }
        else if(printoutType == "@oRaspberry")
        {
            other_raspberry = data;
            return;
        }
        else if(printoutType == "@oTease")
        {
            cleanTease = data;
            return;
        }
        else if(printoutType == "@oWetTease")
        {
            wetTease = data;
            return;
        }
        else if(printoutType == "@oMessTease")
        {
            messTease = data;
            return;
        }
        else if(printoutType == "@oWetMessTease")
        {
            wetMessTease = data;
            return;
        }
        else if(printoutType == "@CareChange")
        {
            carer_change = data;
            return; 
        }
    }
}

//This function is passed a (potentially) tokenized (*first, *oFullName, etc) string,
//it's job is to remove the tokens if they exist, and replace them with the proper information (First name, Full name, etc.)
//@printout = A potentially tokenized string in need of processing.
//todo: Allow private printouts and printouts to caretakers interacting with the diaper!
string processPrint(string printout)
{
    string temp = printout; // Preserves the original data
    string fName; // First name of the User/Carer/Outsider, re-used.
    integer spaceLocation; // Holds the location of the space in a user name. I use this to cut out the first name.
    
    integer index = llSubStringIndex(temp, "*first"); //Search for *first in the printout
    
    while(~index) // Keep going while there's more tokens to replace!
    {
        temp = llDeleteSubString(temp, index, index+5); //Delete * to t from *first -- I'm deleting the *first token.
        
        fName = llKey2Name(llGetOwner()); // At first, fName is the full name of the user.
        spaceLocation = llSubStringIndex(fName, " "); // I find the space. . .
        fName = llDeleteSubString(fName, spaceLocation, -1); // . . . And only keep the first name!
        
        temp = llInsertString(temp, index, fName); // Name replacement!
        
        index = llSubStringIndex(temp, "*first"); // There could be more than one *first to replace in a printout!
    }
    
    index = llSubStringIndex(temp, "*fullName"); // Search for *fullName in the printout
    
    while(~index) // Don't stop replacing until we get all the tokens of this type!
    {
        temp = llDeleteSubString(temp, index, index+8); //Delete * to e from *fullName -- I'm deleting the *fullName token.
        temp = llInsertString(temp, index, llKey2Name(llGetOwner())); //Name replacement
        
        index = llSubStringIndex(temp, "*fullName"); // Any more to replace?
    }
    
    index = llSubStringIndex(temp, "*oFirstName"); // Search for *oFirstName" in the printout
    
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+10); // Delete * to e from *oFirstName -- I'm deleting the *oFirstName token.
        
        fName = g_toucherName; // Name of the outsider
        spaceLocation = llSubStringIndex(fName, " "); // Find the space in their name
        fName = llDeleteSubString(fName, spaceLocation, -1); // Only save the first name.
        
        temp = llInsertString(temp, index, fName); // Name replacement
        
        index = llSubStringIndex(temp, "*oFirstName");   
    }
    
    index = llSubStringIndex(temp, "*oFullName");
    
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+9); // Delete * to e from *oFullName
        temp = llInsertString(temp, index, g_toucherName); // Name replacement
        index = llSubStringIndex(temp, "*oFullName");  
    }
    //todo: process pronouns and persons

    index = llSubStringIndex(temp, "*Sub");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to b
        temp = llInsertString(temp, index, llList2String(["He","She"],g_gender)); //Capital subject replacement
        index = llSubStringIndex(temp, "*Sub");  
    }

    index = llSubStringIndex(temp, "*sub");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to b
        temp = llInsertString(temp, index, llList2String(["he","she"],g_gender)); //lowercase subject replacement
        index = llSubStringIndex(temp, "*sub");  
    }

    index = llSubStringIndex(temp, "*Obj");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to j
        temp = llInsertString(temp, index, llList2String(["Him","Her"],g_gender)); //Capital object replacement
        index = llSubStringIndex(temp, "*Obj");  
    }
    
    index = llSubStringIndex(temp, "*obj");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to j
        temp = llInsertString(temp, index, llList2String(["him","her"],g_gender)); //lowercase object replacement
        index = llSubStringIndex(temp, "*obj");  
    }
    
    index = llSubStringIndex(temp, "*Con");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to n
        temp = llInsertString(temp, index, llList2String(["He's","She's"],g_gender)); //Capital contraction replacement
        index = llSubStringIndex(temp, "*Con");  
    }
    
    index = llSubStringIndex(temp, "*con");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to n
        temp = llInsertString(temp, index, llList2String(["he's","she's"],g_gender)); //lowercase contraction replacement
        index = llSubStringIndex(temp, "*con");  
    }
    
    index = llSubStringIndex(temp, "*Ref");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to f
        temp = llInsertString(temp, index, llList2String(["Himself","Herself"],g_gender)); //Capital reflexive replacement
        index = llSubStringIndex(temp, "*Ref");  
    }
    
    index = llSubStringIndex(temp, "*ref");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to f
        temp = llInsertString(temp, index, llList2String(["himself","herself"],g_gender)); //lowercase reflexive replacement
        index = llSubStringIndex(temp, "*ref");  
    }

    index = llSubStringIndex(temp, "*Pos1");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+4); // Delete * to 1
        temp = llInsertString(temp, index, llList2String(["His","Her"],g_gender)); //Capital possessive replacement
        index = llSubStringIndex(temp, "*Pos1");  
    }
    
    index = llSubStringIndex(temp, "*pos1");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+4); // Delete * to 1
        temp = llInsertString(temp, index, llList2String(["his","her"],g_gender)); //lowercase object replacement
        index = llSubStringIndex(temp, "*pos1");  
    }

    index = llSubStringIndex(temp, "*Pos2");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+4); // Delete * to 2
        temp = llInsertString(temp, index, llList2String(["His","Hers"],g_gender)); //Capital object replacement
        index = llSubStringIndex(temp, "*Pos2");  
    }
    
    index = llSubStringIndex(temp, "*pos2");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+4); // Delete * to 2
        temp = llInsertString(temp, index, llList2String(["his","hers"],g_gender)); //lowercase object replacement
        index = llSubStringIndex(temp, "*pos2");  
    }

    index = llSubStringIndex(temp, "*Per");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to 1
        temp = llInsertString(temp, index, llList2String(["Boy","Girl"],g_gender)); //Capital object replacement
        index = llSubStringIndex(temp, "*Per");  
    }
    
    index = llSubStringIndex(temp, "*per");
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+3); // Delete * to 1
        temp = llInsertString(temp, index, llList2String(["boy","girl"],g_gender)); //lowercase object replacement
        index = llSubStringIndex(temp, "*per");  
    }
    //whew!  It's kinda slow though.

    temp = llStringTrim(temp, STRING_TRIM); // Remove any spaces that could potentially be hanging at the start or end of my string.
    
    return temp; // Send back the fully modified string
}

// Displays the appropriate printout given a usage type
// @g_useType - A global variable set when parsing printout messages from main.
// NOTE: Animations, when implemented, will go in the if-else chain.
// todo: make this able to play private messages too when that setting is made.
displayPrintout()
{
    string temp; // Used to prevent the original printouts from being altered.
    string name; // Holds the original name of the object.
    integer index;  // Used to locate the first space in any given printout. This lets me set the name of the object
                    // temporarily to the first word of any given printed message. Allows for RP prints.

    name = llGetObjectName(); // Preserve the name of the Diaper
    
    if(g_useType == "Carer Change") // Diaper change commencing
    {
        temp = processPrint(carer_change); // Send tokenized printout to be processed, we'll use the result.
    }
    else if(g_useType == "Normal Change") // Changed by a random outsider.
    {
        temp = processPrint(other_change);
    }
    else if(g_useType == "Self Change") // User changed themselves!
    {
        temp = processPrint(self_change);
    }
    else if(g_useType == "g_wetLevel") // They've wet!
    {
        if(g_wetLevel == 1) // How wet are they?
        {
            temp = processPrint(wet1);
             
            //Animation Goes Here! EX: playAnimation("myAnimation");
            //Should wetting sounds go here too?  Currently they are elsewhere.
        }
        else if(g_wetLevel == 2)
        {
            temp = processPrint(wet2);
            
            //Animation Goes Here! EX: playAnimation("myAnimation");
        }
        else if(g_wetLevel == 3)
        {
            temp = processPrint(wet3);
            
            //Animation Goes Here! EX: playAnimation("myAnimation");
        }
        else if(g_wetLevel == 4)
        {
            temp = processPrint(wet4);
            
            //Animation Goes Here! EX: playAnimation("myAnimation");
        }
        else if(g_wetLevel == 5)
        {
            temp = processPrint(wet5);
            
            //Animation Goes Here! EX: playAnimation("myAnimation");
        }
        else
        {
            temp = processPrint(wet6);
            
            //Animation Goes Here! EX: playAnimation("myAnimation");
        }
        
    }
    else if(g_useType == "g_messLevel") // The user messed!
    {
        if(g_messLevel == 1) // How messy are they?
        {
            temp = processPrint(mess1);
            
            //Animation Goes Here! EX: playAnimation("myAnimation");
        }
        else if(g_messLevel == 2)
        {
            temp = processPrint(mess2);
            
            //You get the idea on animations.
        }
        else
        {
            temp = processPrint(mess3);
        }
    }
    else if(g_useType == "Self Check")
    {
        if(g_wetLevel == 0 && g_messLevel == 0)
        {
            temp = processPrint(self_checkClean);
        }
        else if(g_wetLevel == 1 && g_messLevel == 0) // Wet Once
        {
            temp = processPrint(self_checkWet1);
        }
        else if(g_wetLevel == 2 && g_messLevel == 0) // Wet Twice
        {
            temp = processPrint(self_checkWet2);
        }
        else if(g_wetLevel == 3 && g_messLevel == 0) // Wet Three times
        {
            temp = processPrint(self_checkWet3);
        }
        else if(g_wetLevel == 4 && g_messLevel == 0) // Wet Four times
        {
            temp = processPrint(self_checkWet4);
        }
        else if(g_wetLevel == 5 && g_messLevel == 0) // . . .
        {
            temp = processPrint(self_checkWet5);
        }
        else if(g_wetLevel >= 6 && g_messLevel == 0) // Etc.
        {
            temp = processPrint(self_checkWet6);
        }
        else if(g_wetLevel == 0 && g_messLevel == 1)
        {
            temp = processPrint(self_checkMess1);
        }
        else if(g_wetLevel == 0 && g_messLevel == 2)
        {
            temp = processPrint(self_checkMess2);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 3) // Catch all for very stinky diapers.
        {
            temp = processPrint(self_checkMess3);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 1) // Wet 1 or 2 Times, Messed Once.
        {
            temp = processPrint(self_checkWetMess1);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 1) // Wet 3 or 4 Times, Messed Once.
        {
            temp = processPrint(self_checkWetMess2);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 1)
        {
            temp = processPrint(self_checkWetMess3);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 2)
        {
            temp = processPrint(self_checkWetMess4);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 2)
        {
            temp = processPrint(self_checkWetMess5);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 2) //fix
        {
            temp = processPrint(self_checkWet5To6Mess2);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel >= 3)
        {
            temp = processPrint(self_checkWet1To2Mess3);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel >= 3)
        {
            temp = processPrint(self_checkWet3To4Mess3);
        }
        else if(g_wetLevel >= 5 && g_messLevel >= 3) // Catch all for very stinky, and very wet diapers.
        {
            temp = processPrint(self_checkWetMess6);
        }
    }
    else if(g_useType == "Other Check")
    {
        if(g_wetLevel == 0 && g_messLevel == 0)
        {
            temp = processPrint(other_checkClean);
        }
        else if(g_wetLevel == 1 && g_messLevel == 0) // Wet Once
        {
            temp = processPrint(other_checkWet1);
        }
        else if(g_wetLevel == 2 && g_messLevel == 0) // Wet Twice
        {
            temp = processPrint(other_checkWet2);
        }
        else if(g_wetLevel == 3 && g_messLevel == 0) // . . .
        {
            temp = processPrint(other_checkWet3);
        }
        else if(g_wetLevel == 4 && g_messLevel == 0) // . . .
        {
            temp = processPrint(other_checkWet4);
        }
        else if(g_wetLevel == 5 && g_messLevel == 0) // . . .
        {
            temp = processPrint(other_checkWet5);
        }
        else if(g_wetLevel >= 6 && g_messLevel == 0) // . . .
        {
            temp = processPrint(other_checkWet6);
        }
        else if(g_wetLevel == 0 && g_messLevel == 1)
        {
            temp = processPrint(other_checkMess1);
        }
        else if(g_wetLevel == 0 && g_messLevel == 2)
        {
            temp = processPrint(other_checkMess2);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 3) // Catch all for very stinky diapers.
        {
            temp = processPrint(other_checkMess3);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 1) // Wet 1 or 2 Times, Messed Once.
        {
            temp = processPrint(other_checkWetMess1);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 1) // Wet 3 or 4 Times, Messed Once.
        {
            temp = processPrint(other_checkWetMess2);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 1)
        {
            temp = processPrint(other_checkWetMess3);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 2)
        {
            temp = processPrint(other_checkWetMess4);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 2)
        {
            temp = processPrint(other_checkWetMess5);
        }
        else if(g_wetLevel >= 5 && g_messLevel == 2)
        {
            temp = processPrint(other_checkWet5To6Mess2);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel >= 3) // Little wet, very messy
        {
            temp = processPrint(other_checkWet1To2Mess3);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel >= 3) // Sorta wet, very messy
        {
            temp = processPrint(other_checkWet3To4Mess3);
        }
        else if(g_wetLevel >= 5 && g_messLevel >= 3) // Very wet, very messy
        {
            temp = processPrint(other_checkWetMess6);
        }
    }
    else if(g_useType == "Poke")
    {
        if(g_wetLevel == 0 && g_messLevel == 0)
        {
            temp = processPrint(other_pokeClean);
        }
        else if(g_wetLevel >= 1 && g_messLevel == 0)
        {
            temp = processPrint(other_pokeWet);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 1)
        {
            temp = processPrint(other_pokeMess);
        }
        else if(g_wetLevel >= 1 && g_messLevel >= 1)
        {
            temp = processPrint(other_pokeWetMess);
        }
    }
    else if(g_useType == "Raspberry")
    {
        temp = processPrint(other_raspberry);
    }
    else if(g_useType == "Tease")
    {
        if(g_wetLevel == 0 && g_messLevel == 0)
        {
            temp = processPrint(cleanTease);
        }
        else if(g_wetLevel >= 1 && g_messLevel == 0)
        {
            temp = processPrint(wetTease);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 1)
        {
            temp = processPrint(messTease);
        }
        else if(g_wetLevel >= 1 && g_messLevel >= 1)
        {
            temp = processPrint(wetMessTease);
        }
    }
    if(temp) //Let's not bother saying anything if the message is empty...  allows for silent notecards!
    {
        index = llSubStringIndex(temp, " "); // First space in the sentence.
        llSetObjectName(llGetSubString(temp, 0, index - 1)); // Sets object name to first word in the sentence.
        temp = llDeleteSubString(temp, 0, index); // Removes first word in the sentence.

        if(g_chatter > 1)
        {
            llSay(0, "/me " + temp); //print well formatted output loudly!
        }
        else if(g_chatter == 1)
        {
            llWhisper(0, "/me "+temp); //little quieter
        }
        else
        {
        //todo: compare g_toucherKey to owner and also send formatted output to the toucher
            llOwnerSay("/me "+temp);
            if(g_toucherKey != llGetOwner())
            {
                llInstantMessage(g_toucherKey,"/me "+temp);
            }
        }
    }
    llSetObjectName(name); // Restore the original name of the diaper.
}

default
{
    state_entry()
    {
        loadCustomPrints();   //load the default notecard on script reset
    }
    
    //1. Query a line of the notecard
    //2. Check in dataserver to see if query_id matches g_lineQuery
    //3. If 2 is true, pull the data apart(Accounting for |)and store the information in the proper variable
    //3a.If 2 if false, return.
    //4. Goto 1
    //
    // To fully understand this event, you need to look at the format of data in the notecards!
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
                
                // Get the next line based on gender!
                // Todo: make this based on the notecard picked, instead of assuming gender
                g_lineQuery = llGetNotecardLine("PRINT:" + g_PrintoutCard, g_lineNum);
            }
            else
            {
                llOwnerSay("Done reading your notecard! :3");
                llOwnerSay("Printout1 Script Memory Used: " + (string) llGetUsedMemory() + " Bytes");
                llOwnerSay("Printout1 Script Memory Remaining: " + (string) llGetFreeMemory() + " Bytes");
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
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num != -2) //If the num is not -2, exit immediately, the message wasn't intended for us.
            return; 
        else 
        {
            integer index = llSubStringIndex(msg, ":"); //Pull out the gender *Always first in list
            g_gender = (integer) llGetSubString(msg, 0, index-1);
            msg = llGetSubString(msg, index+1, -1); //Cut msg down to reflect change and move on
            if(llGetSubString(msg,0,5) == "Update") //new notecard selected!
            {
                g_PrintoutCard = llGetSubString(msg,7,-1);
                clearCustomPrints();
                loadCustomPrints(); //Load new printouts
            }
            else if (msg == "Gender") //We actually don't need to do anything!
                return;
            else if (msg == "Silent") //only to self, must add toucher to the list of printouts as well
            {
                g_chatter = 0;
            }
            else if (msg == "High") //llSay, 20 meters
            {
                g_chatter = 2;
            }
            else if (msg == "Low") //llWhisper, 10 meters
            {
                g_chatter = 1;
            }
            else
            {
                g_toucherKey = id;
                parseLinkedMessage(msg); // Pull apart the message and set the appropriate global variables
                displayPrintout(); // Make the correct llSay execute!
            }
        }
    }
}
