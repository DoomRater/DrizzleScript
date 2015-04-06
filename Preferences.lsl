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

/* Script used to offer and manage setting-changing menu options */

integer g_printTextueLength;
integer g_printCardLength;
integer g_uniqueChan;
integer g_mainListen; //needed to keep track of the listens
key g_queueid = NULL_KEY; //keep track of people who are waiting in line to use the item
key g_currentid = NULL_KEY;
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
list g_plasticPantsMenu = ["<--BACK","Put❤On","Take❤Off"];
list g_appearanceMenu = ["<--BACK","Help", "*","Diaper❤Print","Tapes"];
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
integer g_plasticPantsPrim;
string g_plasticPantsName = "Plastic Pants";
//various diapers have different texture settings
//ABAR Sculpted diaper bases uses repeat 1.0, 1.0 and offset .03, -.5
string g_diaperType = "Fluffems";
string g_resizerScriptName = ""; //change this to a resizer script name, if provided
integer isDebug = FALSE;

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
integer g_PlasticPants;

//Old variables used in an prim-sculptie based system.
//list g_TrainingMenu = ["<--BACK", "★", "★", "Infant", "Toddler", "Adult"];

init()
{
    llListenRemove(g_mainListen);
    g_uniqueChan = generateChan(llGetOwner()) + 1; // Remove collision with Menu listen handler via +1
    loadInventoryList();
    findPrims();
    if(g_plasticPantsPrim) {
        g_settingsMenu = llListReplaceList(g_settingsMenu, ["Plastic❤Pants"], 1, 1);
    }
    if(g_diaperType == "") {
        detectDiaperType();
    }
    scanForResizerScript();
    if(isDebug==TRUE && llListFindList(g_settingsMenu, ["DEBUG"]) == -1) {
        g_settingsMenu += ["DEBUG"];
    }
    if(g_diaperType == "Kawaii") {
        g_appearanceMenu = ["<--BACK","Help", "*","Diaper❤Print","Tapes","Back❤Face","Panel","Cutie*Mark"];
    }
}

findPrims() {
    integer i; // Used to loop through the linked objects
    integer primCount = llGetNumberOfPrims(); //should be attached, not sat on
    for(i = 1; i <= primCount; i++) {
        string primName = (string) llGetLinkPrimitiveParams(i, [PRIM_NAME]); // Get the name of linked object i
        if(g_mainPrimName == primName) { // Is this the prim?
            g_mainPrim = i;
        }
        else if(g_plasticPantsName == primName) {
            g_plasticPantsPrim = i;
        }
            //add additional prims to seek here
    }
    if(g_mainPrimName == "") { // No specified prim. Look for root.
        g_mainPrim = 1;
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

//quick and dirty resizer check
scanForResizerScript() {
    if(llGetInventoryType(g_resizerScriptName) == INVENTORY_SCRIPT) {
        if(llListFindList(g_settingsMenu,["Resize"])==-1) {
            g_settingsMenu += ["Resize"];
        }
    }
}

//Created by Ugleh Ulrik
//Edited by Taff Nouvelle to put the buttons in correct order.

list order_buttons(list buttons) {
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
        llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
 
DialogPlus(string msg, list buttons, integer CurMenu, key id) {
    if (11 < llGetListLength(buttons)) {
        list lbut = buttons;
        list Nbuttons = [];
        if(CurMenu == -1) {
            CurMenu = 0;
            g_currCount = 0;
        }
 
        if((Nbuttons = (llList2List(buttons, (CurMenu * 9), ((CurMenu * 9) + 8)) + ["<--BACK", "<--PREV", "NEXT-->"])) == ["<--BACK", "<--PREV", "NEXT-->"]) {
            DialogPlus(msg, lbut, g_currCount = 0, id);
        }
        else {
            offerMenu(id, msg,  order_buttons(Nbuttons));
        }
    }
    else {
        offerMenu(id, msg,  ["<--BACK"] + order_buttons(buttons));
    }
}

//@id = The key used to send the menu out.
//This function determines which page needs to be generated
handlePrev(key id) {
    if(g_currMenu == "Skins") {
         DialogPlus(m_skinMenu(), g_Skins, --g_currCount, id);
    }
    else if(g_currMenu == "Printouts") {
        DialogPlus(m_printMenu(),g_Printouts, --g_currCount, id);
    }
    //handling for Kawaii Diapers
    else if(g_currMenu == "Diaper❤Print") {
        DialogPlus(m_skinMenu(), g_Skins, --g_currCount, id);
    }
    else if(g_currMenu == "Tapes") {
        DialogPlus(m_tapesMenu(),g_Tapes, --g_currCount, id);
    }
    else if(g_currMenu == "Back❤Face") {
        DialogPlus(m_backFaceMenu(),g_BackFaces, --g_currCount, id);
    }
    else if(g_currMenu == "Panel") {
        DialogPlus(m_panelMenu(),g_Panels, --g_currCount, id);
    }
    else if(g_currMenu == "Cutie*Mark") {
        DialogPlus(m_cutieMenu(),g_Cuties, --g_currCount, id);
    }
}

//@id = The key used to send the menu out.
//This function determines which page needs to be generated
handleNext(key id) {
    if(g_currMenu == "Skins") {
         DialogPlus(m_skinMenu() ,g_Skins, ++g_currCount, id);
    }
    else if(g_currMenu == "Printouts") {
        DialogPlus(m_printMenu(), g_Printouts, ++g_currCount, id);
    }
    else if(g_currMenu == "Diaper❤Print") {
        DialogPlus(m_skinMenu(), g_Skins, ++g_currCount, id);
    }
    else if(g_currMenu == "Tapes") {
        DialogPlus(m_tapesMenu(), g_Tapes, ++g_currCount, id);
    }
    else if(g_currMenu == "Back❤Face") {
        DialogPlus(m_backFaceMenu(),g_BackFaces, ++g_currCount, id);
    }
    else if(g_currMenu == "Panel") {
        DialogPlus(m_panelMenu(),g_Panels, ++g_currCount, id);
    }
    else if(g_currMenu == "Cutie*Mark") {
        DialogPlus(m_cutieMenu(),g_Cuties, ++g_currCount, id);
    }
}

loadAllTextures(list l) {
    integer i;
    g_Skins = [];
    g_Tapes = [];
    g_BackFaces = [];
    g_Panels = [];
    g_Cuties = [];
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

//This function serves a new menu directly to the user, and 
//informs the person waiting in line that they'll need to try again
//This doesn't give the user ultimate control- carers and users are considered
//equal in this function.
offerMenu(key id, string dialogMessage, list buttons) {
    llSetTimerEvent(0.0);
    llListenRemove(g_mainListen);
    g_currMenuButtons = buttons;
    g_currMenuMessage = dialogMessage;
    if(g_queueid != NULL_KEY) {
        llRegionSayTo(g_queueid, 0, "I'm sorry, someone else is still using the menu! You'll need to try again after they're done.");
        g_queueid = NULL_KEY;
    }
    g_mainListen = llListen(g_uniqueChan, "", id, "");
    llSetTimerEvent(30.0);
    llDialog(id, dialogMessage, buttons, g_uniqueChan);
}

integer msgToNumber(string msg) {
    if(llGetSubString(msg, -1, -1) == "%") {
        msg = llGetSubString(msg, 0, -2);
    }
    return (integer) msg;
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
    
    if(g_diaperType == "Fluffems") {
        offset.x = 0.0;
        offset.y = 0.0;
    }
    else if(g_diaperType == "ABARSculpt") {
        offset.x = 0.03;
        offset.y = -.5;
    }
    
    radRotation = 0.0;
    //todo: apply to the correct face and prim according to the prefix
    if(g_diaperType == "Kawaii") {
        if(prefix == "SKIN:") {
            llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, 1, texture, repeats, offset, radRotation]);
        }
        else if(prefix == "TAPE:") {
            llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, 4, texture, repeats, offset, radRotation]);
        }
        else if(prefix == "PANEL:") {
            llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, 2, texture, repeats, offset, radRotation]);
        }
        else if(prefix == "CUTIE:") {
            llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, 5, texture, repeats, offset, radRotation]);
        }
        else if(prefix == "BACKFACE:") { //not sure if going to stay a backface or become mess face
            llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, 6, texture, repeats, offset, radRotation]);
        }
    }
    else if(g_diaperType == "Fluffems" || g_diaperType == "ABARSculpt") {
        if(prefix == "SKIN:") {
            llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, ALL_SIDES, texture, repeats, offset, radRotation]);
        }
    }
}

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
    (string) g_PlasticPants;
    llMessageLinked(LINK_THIS, -3, csv, NULL_KEY);
    llMessageLinked(LINK_ALL_OTHERS, 6, csv, NULL_KEY);
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
    
    g_PlasticPants = (integer) temp;
    
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
    return "How loud should the crinkling be?\nCurrent value: "+(string)g_crinkleVolume+"%";
}

string m_wetVolume() {
    return "How loud should the wetting sound be?\nCurrent value: "+(string)g_wetVolume+"%";
}

string m_messVolume() {
    return "How loud should the messing sound be?\nCurrent value: "+(string)g_messVolume+"%";
}

string m_appearanceMenu() {
    return "Change the diaper's appearance!";
}

string m_plasticPantsMenu() {
    return "What would you like do to with "+llKey2Name(llGetOwner())+"'s plastic pants?";
}

string m_skinMenu() {
    return "Choose a diaper print.\nPrefix is SKIN:";
}

string m_tapesMenu() {
    return "Choose a tape texture.\nPrefix is TAPE:";
}

string m_panelMenu() {
    return "Choose a panel print.\nPrefix is PANEL:";
}

string m_backFaceMenu() {
    return "Choose a butt print.\nPrefix is BACKFACE:";
}

string m_cutieMenu() {
    return "Yay cutie marks!\n\nChoose a cutie mark.\nPrefix is CUTIE:";
}

string m_printMenu() {
    return "Choose a Printout style.\nPrefix is PRINT:";
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
        if(change & (CHANGED_OWNER | CHANGED_INVENTORY)) {
            init();
        }
    }
    
    timer() {
        llSetTimerEvent(0.0);
        llListenRemove(g_mainListen);
        if(g_queueid != NULL_KEY) {
            g_currentid = g_queueid;
            g_queueid = NULL_KEY;
            g_currMenu = "";
            offerMenu(g_currentid, m_topMenu(), g_settingsMenu);
        }
        else {
            g_currentid = NULL_KEY;
        }
    }

    link_message(integer sender_num, integer num, string msg, key id) {
        if(num == -6) {
            parseSettings(msg);
        }
        else if(num == -1) {
            if(msg == "Options" && g_currentid == NULL_KEY || g_currentid == id) {
                g_currentid = id;
                g_currMenu = "";
                offerMenu(id, m_topMenu(), g_settingsMenu);
            }
            else if(msg == "Options" && g_queueid == NULL_KEY) {
                g_queueid = id;
                llRegionSayTo(id, 0, "Please wait a few seconds...");
                llSetTimerEvent(5.0); //five seconds should be enough time to wait in line
            }
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if(msg == "★") {// Someone misclicked in the menu!
            if(isDebug < 2) {
                llRegionSayTo(id, 0, "The stars are just there to look pretty! =p");
            }
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "<--BACK") {
            if(~llListFindList(g_pottyMenu, [g_currMenu])) {
                g_currMenu = "";
                offerMenu(id, m_pottyMenu(), g_pottyMenu);
            }
            else if(~llListFindList(g_volumeMenu, [g_currMenu])) {
                g_currMenu = "";
                offerMenu(id, m_volumeMenu(), g_volumeMenu);
            }
            else if(~llListFindList(g_appearanceMenu, [g_currMenu])) {
                g_currMenu = "";
                offerMenu(id, m_appearanceMenu(), g_appearanceMenu);
            }
            else {
                g_currMenu = "";
                offerMenu(id, m_topMenu(), g_settingsMenu);
            }
        }
        else if(msg=="DEBUG") {
            printDebugSettings();
        }
        else if(~llListFindList(g_Skins, [msg]) && g_currMenu == "Diaper❤Print") {
            applyTexture(msg, "SKIN:");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(~llListFindList(g_Panels, [msg]) && g_currMenu == "Panel") {
            applyTexture(msg, "PANEL:");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(~llListFindList(g_Tapes, [msg]) && g_currMenu == "Tapes") {
            applyTexture(msg, "TAPE:");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(~llListFindList(g_BackFaces, [msg]) && g_currMenu == "Back❤Face") {
            applyTexture(msg, "BACKFACE:");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(~llListFindList(g_Cuties, [msg]) && g_currMenu == "Cutie*Mark") {
            applyTexture(msg, "CUTIE:");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(~llListFindList(g_Printouts, [msg])  && g_currMenu == "Printouts") {// new printout notecard!
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "NEXT-->") {
            handleNext(id);
        }
        else if(msg == "<--PREV") {
            handlePrev(id);
        }
        else if(g_currMenu == "Crinkle❤Volume") {
            g_crinkleVolume = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_crinkleVolume(), g_currMenuButtons);
        }
        else if(g_currMenu == "Wet❤Volume") {
            g_wetVolume = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_wetVolume(), g_currMenuButtons);
        }
        else if(g_currMenu == "Mess❤Volume") {
            g_messVolume = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_messVolume(), g_currMenuButtons);
        }            
        else if(g_currMenu == "Mess%") {
            g_messChance = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_messChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Wet%") {
            g_wetChance = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_wetChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Mess❤Timer") {
            g_messTimer = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_messTimer(), g_currMenuButtons);
        }
        else if(g_currMenu == "Wet❤Timer") {
            g_wetTimer = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_wetTimer(), g_currMenuButtons);
        }
        else if(g_currMenu == "❤Tickle❤") {
            g_tickle = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_tickleChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Tummy❤Rub") {
            g_tummyRub = msgToNumber(msg);
            sendSettings();
            offerMenu(id, m_tummyRubChance(), g_currMenuButtons);
        }
        else if(g_currMenu == "Plastic❤Pants") {
            if(msg == "Put❤On") {
                g_PlasticPants = TRUE;
            }
            else if(msg == "Take❤Off") {
                g_PlasticPants = FALSE;
            }
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "Boy") {
            g_gender = 0;
            sendSettings();
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "Girl") {
            g_gender = 1;
            sendSettings();
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        //Security settings
        else if(msg == "Everyone") {
            g_interact = 1;
            sendSettings();
            offerMenu(id, m_interactions(), g_currMenuButtons);
        }
        else if(msg == "Carers❤&❤Me") {
            g_interact = 0;
            sendSettings();
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
        else if(msg == "Skins" || msg == "Diaper❤Print") {
            g_currMenu = msg;
            if(g_diaperType == "ABARSculpt" || msg == "Diaper❤Print") {
                DialogPlus(m_skinMenu(), g_Skins, g_currCount = 0, id);
            }
            else if(g_diaperType == "Fluffems" || g_diaperType == "Kawaii") {
                //this diaper can use tapes, panels, and the like, so show the skin menu instead
                offerMenu(id, m_appearanceMenu(), g_appearanceMenu);
            }
        }
        else if(msg == "Tapes") {
            g_currMenu = msg;
            DialogPlus(m_tapesMenu(), g_Tapes, g_currCount = 0, id);
        }
        else if(msg == "Panel") {
            g_currMenu = msg;
            DialogPlus(m_panelMenu(), g_Panels, g_currCount = 0, id);
        }
        else if(msg == "Back❤Face") {
            g_currMenu = msg;
            DialogPlus(m_backFaceMenu(), g_BackFaces, g_currCount = 0, id);
        }
        else if(msg == "Cutie*Mark") {
            g_currMenu = msg;
            DialogPlus(m_cutieMenu(), g_Cuties, g_currCount = 0, id);
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
            DialogPlus(m_printMenu(), g_Printouts, g_currCount = 0, id);
        }
        else if(msg == "Plastic❤Pants") {
            g_currMenu = msg;
            offerMenu(id, m_plasticPantsMenu(), g_plasticPantsMenu);
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
            llSetTimerEvent(.1); //queue up the next person in line
            llMessageLinked(LINK_THIS, 900, "MENU", NULL_KEY);
        }
        else if(msg == "<--TOP") {
            llSetTimerEvent(.1); //queue up the next person in line
            llMessageLinked(LINK_THIS, -3, "Cancel:"+(string)id, NULL_KEY);
        }
    }
}
