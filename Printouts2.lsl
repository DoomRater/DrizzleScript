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
* Local Variables used by Prinouts2.lsl to handle loading/displaying printouts.
*/

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

/*
* Variables which hold all printouts in memory for speed.
*/

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
string carer_checkWetMess1; //
string carer_checkWetMess2; // OUTDATED, update from Printouts to get the right ranges vvvv
string carer_checkWetMess3; //1 to 2 Wet + 1 Mess, 3 to 4 Wet + 2 Mess, 5 to 6 Wet + 2 Mess 
string carer_checkWetMess4;
string carer_checkWetMess5;
string carer_checkWetMess6;
string carer_forceWet1;     //Prints for carer 'Force' options
string carer_forceWet2;
string carer_forceMess1; 
string carer_forceMess2;

//Gaps filled 12/10/13
string carer_checkWet5to6Mess2;
string carer_checkWet1to2Mess3;
string carer_checkWet3to4Mess3;

//Other Check in Printouts1 (16)

//Self Check in Printouts1 (16)

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
string wetSpank1;
string wetSpank2;
string wetSpank3;
string messSpank1;
string messSpank2;

//Poke Prints Handled in Printouts1 (4)

//Wedgies
string cleanWedgie;
string wetWedgie1;
string wetWedgie2;
string wetWedgie3;
string messWedgie1;
string messWedgie2;

//Raspberry in Printouts1 (1)

//Tease in Prinouts1 (4)

clearCustomPrints()
{
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
    carer_checkWetMess1="";
    carer_checkWetMess2="";
    carer_checkWetMess3="";
    carer_checkWetMess4="";
    carer_checkWetMess5="";
    carer_checkWet5to6Mess2="";
    carer_checkWet1to2Mess3="";
    carer_checkWet3to4Mess3="";
    carer_checkWetMess6="";
    carer_forceWet1="";
    carer_forceWet2="";
    carer_forceMess1=""; 
    carer_forceMess2="";

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
    wetSpank1="";
    wetSpank2="";
    wetSpank3="";
    messSpank1="";
    messSpank2="";

    cleanWedgie="";
    wetWedgie1="";
    wetWedgie2="";
    wetWedgie3="";
    messWedgie1="";
    messWedgie2="";
}

loadCustomPrints()
{
    llOwnerSay("Printouts2: Loading your notecard, this may take a minute or two!");
    g_lineNum = 0;
    
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
constructPrint(string data, integer append, string printoutType)
{
    //TODO: Replace immediate tokens (User related tokens) on construction
    
    //llSay(0, "Printout Script: [Memory Used] " + (string) llGetUsedMemory() + " Bytes.");
    //llSay(0, "=== Processing: " + data + " ===");
    //llSay(0, "Printout Script: [Memory Remaining] " + (string) llGetFreeMemory() + " Bytes.");
    //llOwnerSay("Constructing print. . .");
    if(append == TRUE)
    {
        if(printoutType == "@CareCheckClean")
        {
            carer_checkClean += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1")
        {
            carer_checkWet1 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet2")
        {
            carer_checkWet2 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3")
        {
            carer_checkWet3 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet4")
        {
            carer_checkWet4 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet5")
        {
            carer_checkWet5 += data;
            return;
        }
        else if(printoutType == "@CareCheckWet6")
        {
            carer_checkWet6 += data;
            return;
        }
        else if(printoutType == "@CareCheckMess1")
        {
            carer_checkMess1 += data;
            return;    
        }
        else if(printoutType == "@CareCheckMess2")
        {
            carer_checkMess2 += data;
            return;    
        }
        else if(printoutType == "@CareCheckMess3")
        {
            carer_checkMess3 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1-2Mess1")
        {
            carer_checkWetMess1 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3-4Mess1")
        {
            carer_checkWetMess2 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet5-6Mess1")
        {
            carer_checkWetMess3 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1-2Mess2")
        {
            carer_checkWetMess4 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3-4Mess2")
        {
            carer_checkWetMess5 += data;
            return;    
        }
        //Gaps filled 12/10/13
        else if(printoutType == "@CareCheckWet5-6Mess2")
        {
            carer_checkWet5to6Mess2 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1-2Mess3")
        {
            carer_checkWet1to2Mess3 += data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3-4Mess3")
        {
            carer_checkWet3to4Mess3 += data;
            return;    
        }
        
        else if(printoutType == "@CareCheckWet5-6Mess3")
        {
            carer_checkWetMess6 += data;
            return;    
        }
        else if(printoutType == "@CareForceWet1")
        {
            carer_forceWet1 += data;
            return;    
        }
        else if(printoutType == "@CareForceWet2")
        {
            carer_forceWet2 += data;
            return;    
        }
        else if(printoutType == "@CareForceMess1")
        {
            carer_forceMess1 += data;
            return;    
        }
        else if(printoutType == "@CareForceMess2")
        {
            carer_forceMess2 += data;
            return;    
        }
        else if(printoutType == "@uInstantFlood")
        {
            instantFlood += data;
            return;
        }
        else if(printoutType == "@oSpank")
        {
            cleanSpank += data;
            return;    
        }
        else if(printoutType == "@oSpankWet1-2")
        {
            wetSpank1 += data;
            return;
        }
        else if(printoutType == "@oSpankWet3-4")
        {
            wetSpank2 += data;
            return;   
        }
        else if(printoutType == "@oSpankWet5-6")
        {
            wetSpank3 += data;
            return;
        }
        else if(printoutType == "@oSpankMess1")
        {
            messSpank1 += data;
            return;
        }
        else if(printoutType == "@oSpankMess2")
        {
            messSpank2 += data;
            return;
        }
         else if(printoutType == "@oDefault_Tickle")
        {
            tickle_fail += data;
            return;
        }
        else if(printoutType == "@oTickle1")
        {
            tickle1 += data;
            return;
        }
        else if(printoutType == "@oTickle2")
        {
            tickle2 += data;
            return;
        }
        else if(printoutType == "@oTickle3")
        {
            tickle3 += data;
            return;
        }
        else if(printoutType == "@oTickle4")
        {
            tickle4 += data;
            return;
        }
        else if(printoutType == "@oTickle5")
        {
            tickle5 += data;
            return;
        }
        else if(printoutType == "@oTickle6")
        {
            tickle6 += data;
            return;
        }
        else if(printoutType == "@oDefault_TummyRub")
        {
            tummyRub_fail += data;
            return;
        }
        else if(printoutType == "@oTummyRub1")
        {
            tummyRub1 += data;
            return;
        }
        else if(printoutType == "@oTummyRub2")
        {
            tummyRub2 += data;
            return;
        }
        else if(printoutType == "@oWedgieWet1-2")
        {
            wetWedgie1 += data;
            return;
        }
        else if(printoutType == "@oWedgieWet3-4")
        {
            wetWedgie2 += data;
            return;
        }
        else if(printoutType == "@oWedgieWet5-6")
        {
            wetWedgie3 += data;
            return;
        }
        else if(printoutType == "@oWedgieMess1")
        {
            messWedgie1 += data;
            return;
        }
        else if(printoutType == "@oWedgieMess2")
        {
            messWedgie2 += data;
            return;
        }
    }
    else // Not appending, replace the printout!
    {
        if(printoutType == "@CareCheckClean")
        {
            carer_checkClean = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1")
        {
            carer_checkWet1 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet2")
        {
            carer_checkWet2 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3")
        {
            carer_checkWet3 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet4")
        {
            carer_checkWet4 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet5")
        {
            carer_checkWet5 = data;
            return;
        }
        else if(printoutType == "@CareCheckWet6")
        {
            carer_checkWet6 = data;
            return;
        }
        else if(printoutType == "@CareCheckMess1")
        {
            carer_checkMess1 = data;
            return;    
        }
        else if(printoutType == "@CareCheckMess2")
        {
            carer_checkMess2 = data;
            return;    
        }
        else if(printoutType == "@CareCheckMess3")
        {
            carer_checkMess3 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1-2Mess1")
        {
            carer_checkWetMess1 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3-4Mess1")
        {
            carer_checkWetMess2 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet5-6Mess1")
        {
            carer_checkWetMess3 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1-2Mess2")
        {
            carer_checkWetMess4 = data;
            return;
        }
        else if(printoutType == "@CareCheckWet3-4Mess2")
        {
            carer_checkWetMess5 = data;
            return; 
        }
        //gaps filled 12/10/13
        else if(printoutType == "@CareCheckWet5-6Mess2")
        {
            carer_checkWet5to6Mess2 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet1-2Mess3")
        {
            carer_checkWet1to2Mess3 = data;
            return;    
        }
        else if(printoutType == "@CareCheckWet3-4Mess3")
        {
            carer_checkWet3to4Mess3 = data;
            return;    
        }
        
        else if(printoutType == "@CareCheckWet5-6Mess3")
        {
            carer_checkWetMess6 = data;
            return;    
        }
        else if(printoutType == "@CareForceWet1")
        {
            carer_forceWet1 = data;
            return;    
        }
        else if(printoutType == "@CareForceWet2")
        {
            carer_forceWet2 = data;
            return;    
        }
        else if(printoutType == "@CareForceMess1")
        {
            carer_forceMess1 = data;
            return;    
        }
        else if(printoutType == "@CareForceMess2")
        {
            carer_forceMess2 = data;
            return;    
        }
        else if(printoutType == "@uInstantFlood")
        {
            instantFlood = data;
            return;
        }
        else if(printoutType == "@oSpank")
        {
            cleanSpank = data;
            return;    
        }
        else if(printoutType == "@oSpankWet1-2")
        {
            wetSpank1 = data;
            return;
        }
        else if(printoutType == "@oSpankWet3-4")
        {
            wetSpank2 = data;
            return;   
        }
        else if(printoutType == "@oSpankWet5-6")
        {
            wetSpank3 = data;
            return;
        }
        else if(printoutType == "@oSpankMess1")
        {
            messSpank1 = data;
            return;
        }
        else if(printoutType == "@oSpankMess2")
        {
            messSpank2 = data;
            return;
        }
        else if(printoutType == "@oDefault_Tickle")
        {
            tickle_fail = data;
            return;
        }
        else if(printoutType == "@oTickle1")
        {
            tickle1 = data;
            return;
        }
        else if(printoutType == "@oTickle2")
        {
            tickle2 = data;
            return;
        }
        else if(printoutType == "@oTickle3")
        {
            tickle3 = data;
            return;
        }
        else if(printoutType == "@oTickle4")
        {
            tickle4 = data;
            return;
        }
        else if(printoutType == "@oTickle5")
        {
            tickle5 = data;
            return;
        }
        else if(printoutType == "@oTickle6")
        {
            tickle6 = data;
            return;
        }
        else if(printoutType == "@oDefault_TummyRub")
        {
            tummyRub_fail = data;
            return;
        }
        else if(printoutType == "@oTummyRub1")
        {
            tummyRub1 = data;
            return;
        }
        else if(printoutType == "@oTummyRub2")
        {
            tummyRub2 = data;
            return;
        }
        else if(printoutType == "@oWedgieWet1-2")
        {
            wetWedgie1 = data;
            return;
        }
        else if(printoutType == "@oWedgieWet3-4")
        {
            wetWedgie2 = data;
            return;
        }
        else if(printoutType == "@oWedgieWet5-6")
        {
            wetWedgie3 = data;
            return;
        }
        else if(printoutType == "@oWedgieMess1")
        {
            messWedgie1 = data;
            return;
        }
        else if(printoutType == "@oWedgieMess2")
        {
            messWedgie2 = data;
            return;
        }
        
        
    }
}

//This function is passed a (potentially) tokenized (*first, *oFullName, etc) string,
//it's job is to remove the tokens if they exist, and replace them with the proper information (First name, Full name, etc.)
//@printout = A potentially tokenized string in need of processing.
string processPrint(string printout)
{
    string temp = printout;
    string fName;
    integer spaceLocation;
    
    integer index = llSubStringIndex(temp, "*first"); //Search for *first in the printout
    
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+5); //Delete * to t from *first
        
        fName = llKey2Name(llGetOwner());
        spaceLocation = llSubStringIndex(fName, " ");
        fName = llDeleteSubString(fName, spaceLocation, -1);
        
        temp = llInsertString(temp, index, fName); //Name replacement!
        
        index = llSubStringIndex(temp, "*first");
    }
    
    index = llSubStringIndex(temp, "*fullName"); // Search for *fullName in the printout
    
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+8); //Delete * to e from *fullName
        temp = llInsertString(temp, index, llKey2Name(llGetOwner())); //Name replacement
        
        index = llSubStringIndex(temp, "*fullName");
    }
    
    index = llSubStringIndex(temp, "*oFirstName"); // Search for *oFirstName" in the printout
    
    while(~index)
    {
        temp = llDeleteSubString(temp, index, index+10); // Delete * to e from *oFirstName
        
        fName = g_toucherName;
        spaceLocation = llSubStringIndex(fName, " ");
        fName = llDeleteSubString(fName, spaceLocation, -1);
        
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
    //whew!

    
    temp = llStringTrim(temp, STRING_TRIM);
    return temp; // Send back the fully modified string
}

// Displays the appropriate printout given a usage type
// @msg = g_useType
displayPrintout()
{
    string temp; // Used to prevent the original printouts from being altered.
    string name;
    integer index;
    
    name = llGetObjectName(); // Preserve the name of the Diaper
    
    if(g_useType == "Carer Check") // Carer change printouts
    {
        if(g_wetLevel == 0 && g_messLevel == 0)
        {
            temp = processPrint(carer_checkClean);
        }
        else if(g_wetLevel == 1 && g_messLevel == 0) // Wet Once
        {
            temp = processPrint(carer_checkWet1);
        }
        else if(g_wetLevel == 2 && g_messLevel == 0) // Wet Twice
        {
            temp = processPrint(carer_checkWet2);
        }
        else if(g_wetLevel == 3 && g_messLevel == 0) // Wet Three Times
        {
            temp = processPrint(carer_checkWet3);
        }
        else if(g_wetLevel == 4 && g_messLevel == 0) // Wet Four Times
        {
            temp = processPrint(carer_checkWet4);
        }
        else if(g_wetLevel == 5 && g_messLevel == 0) // Wet Five Times
        {
            temp = processPrint(carer_checkWet5);
        }
        else if(g_wetLevel >= 6 && g_messLevel == 0) // Catch all for very soggy diapers.
        {
            temp = processPrint(carer_checkWet6);
        }
        else if(g_wetLevel == 0 && g_messLevel == 1)
        {
            temp = processPrint(carer_checkMess1);
        }
        else if(g_wetLevel == 0 && g_messLevel == 2)
        {
            temp = processPrint(carer_checkMess2);
        }
        else if(g_wetLevel == 0 && g_messLevel >= 3) // Catch all for very stinky diapers.
        {
            temp = processPrint(carer_checkMess3);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 1) // Wet 1 or 2 Times, Messed Once.
        {
            temp = processPrint(carer_checkWetMess1);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 1) // Wet 3 or 4 Times, Messed Once.
        {
            temp = processPrint(carer_checkWetMess2);
        }
        else if((g_wetLevel == 5 || g_wetLevel == 6) && g_messLevel == 1)
        {
            temp = processPrint(carer_checkWetMess3);
        }
        else if((g_wetLevel == 1 || g_wetLevel == 2) && g_messLevel == 2)
        {
            temp = processPrint(carer_checkWetMess4);
        }
        else if((g_wetLevel == 3 || g_wetLevel == 4) && g_messLevel == 2)
        {
            temp = processPrint(carer_checkWetMess5);
        }
        //todo: fill gap
        else if((g_wetLevel >= 5 || g_wetLevel >= 6) && g_messLevel >= 3) // Catch all for very used diapers.
        {
            temp = processPrint(carer_checkWetMess6);
        }
    }
    else if(g_useType == "Self Flood") // Flood Printout!
    {
        temp = processPrint(instantFlood);
    }
    else if(g_useType == "Tickle Fail")   // Default Tickle.
    {
        temp = processPrint(tickle_fail);
    }
    else if(g_useType == "Tickle Success") // Vary printout based on g_wetlevel
    {
        if(g_wetLevel == 1) // First Wet!
        {
            temp = processPrint(tickle1);
        }
        else if(g_wetLevel == 2) // Second Wet!
        {
            temp = processPrint(tickle2);
        }
        else if(g_wetLevel == 3) // Third Wet!
        {
            temp = processPrint(tickle3);
        }
        else if(g_wetLevel == 4) // Fourth Wet!
        {
            temp = processPrint(tickle4);
        }
        else if(g_wetLevel == 5) // Fifth Wet!
        {
            temp = processPrint(tickle5);
        }
        else if(g_wetLevel > 5) // Sixth Wet!
        {
            temp = processPrint(tickle6);
        }
    }
    else if(g_useType == "Rub Fail")
    {
        temp = processPrint(tummyRub_fail);
    }
    else if(g_useType == "Rub Success")
    {
        if(g_messLevel == 1) // First mess!
        {
            temp = processPrint(tummyRub1);
        }
        else if(g_messLevel >= 2)
        {
            temp = processPrint(tummyRub2);
        }
    }
    else if(g_useType == "Spank")
    {
        if(g_messLevel > 0) // Messy Takes priority
        {
            if(g_messLevel == 1)
            {

                temp = processPrint(messSpank1);
            }
            else if(g_messLevel >= 2)
            {
                temp = processPrint(messSpank2);
            }
        }
        else
        {
            if(g_wetLevel == 0)
            {
                temp = processPrint(cleanSpank);
            }
            else if(g_wetLevel == 1)
            {
                temp = processPrint(wetSpank1);
            }
            else if(g_wetLevel == 2)
            {
                temp = processPrint(wetSpank2);
            }
            else if(g_wetLevel >= 3)
            {
                temp = processPrint(wetSpank3);
            }
        }
    }
    else if(g_useType == "Force Wet")
    {
        if(g_forcedWet == FALSE)
        {
            g_forcedWet = TRUE;
            
            temp = processPrint(carer_forceWet1);
        }
        else //2nd+ Time
        {
            temp = processPrint(carer_forceWet2);
        }
    }
    else if(g_useType == "Force Mess")
    {
        if(g_forcedMess == FALSE)
        {
            g_forcedMess = TRUE;
            
            temp = processPrint(carer_forceMess1);
        }
        else //2nd+ Time
        {
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
            if(g_wetLevel == 0)
            {
                temp = processPrint(wetWedgie1); //wetWedgie1 is a clean wedgie, printouts dont vary until 2+ wet, or 1 mess.
            }
            else if(g_wetLevel == 1)
            {
                temp = processPrint(wetWedgie1);
            }
            else if(g_wetLevel == 2)
            {
                temp = processPrint(wetWedgie2);
            }
            else if(g_wetLevel >= 3)
            {
                temp = processPrint(wetWedgie3);
            }
        }
    }
    if(temp) //Allow for empty notecards to silence printouts
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
            llOwnerSay("/me "+temp);
            if(g_toucherKey != llGetOwner())
            {
                llInstantMessage(g_toucherKey,"/me "+temp);
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
                llOwnerSay("Done reading your notecard! :3");
                llOwnerSay("Printout2 Script Memory Used: " + (string) llGetUsedMemory() + " Bytes");
                llOwnerSay("Printout2 Script Memory Remaining: " + (string) llGetFreeMemory() + " Bytes");
            }
        }
    }
    
    //Messages for this will either come from Incont or Main, undecided.
    //Case 1: xxxxx, -4, g_gender:g_useLevel:g_useType:g_toucherName, xxxxx | xxxxx = Not used
    //Case 2: xxxxx, -4, g_gender:Update,               xxxxx | Used to swap out printout set
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num != -4) //If the num is not -4, exit immediately, the message wasn't intended for us.
            return; 
        else 
        {
            integer index = llSubStringIndex(msg, ":"); //Pull out the gender *Always first in list
            g_gender = (integer) llGetSubString(msg, 0, index-1);
            msg = llGetSubString(msg, index+1, llStringLength(msg)); //Cut msg down to reflect change and move on
            
            if(llGetSubString(msg,0,5) == "Update") //new notecard selected!
            {
                g_PrintoutCard = llGetSubString(msg,7,-1);
                clearCustomPrints();
                loadCustomPrints(); //Load new printouts
            }
            else if (msg == "Gender") //We actually don't need to do anything!
                return;
            else if(msg == "Change") // Diaper was changed by the carer.
            {
                g_forcedMess = FALSE;
                g_forcedWet = FALSE;    
            }
            else if (msg == "Silent")
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
                parseLinkedMessage(msg);
                displayPrintout();
            }
        }
    }
}
