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

//DrizzleHUD: contains memory core and interactive diaper statistics
//This represents a fundamental shift in how DrizzleScript stores its information.
//todo:
//-prevent spoofing by other people's objects; a user or worn objects may be able to communicate but outside objects should need permissions first
//-document API on how to communicate with diaper or HUD
integer g_confirmHandle;
integer g_listenerHandle;
integer g_uniqueChan;
string g_commandHandle;
integer userConfirmed;
integer g_wetLevel;
integer g_messLevel;
integer g_totalCarers;

//used to remember the linked prim set for the on-HUD indicators, if found
integer g_wetBar;
integer g_messBar;

integer generateChan(key id) {
    string channel = "0xE" +  llGetSubString((string)id, 0, 6);
    return (integer) channel;
}

string constructHandle() {
    string temp = llKey2Name(llGetOwner());
    integer space = llSubStringIndex(temp," ");
    temp = llGetSubString(temp,0,0) + llGetSubString(temp,space+1,space+1);
    return llToLower(temp) + "diaper";
}

//imported from main so that we have access to linked prims
loadCarers() {
    llMessageLinked(LINK_ALL_CHILDREN, 1, "SEND", NULL_KEY); // Tells the memory core to send us its data!
}

wipeCarers() {
    llMessageLinked(LINK_ALL_CHILDREN, 1, "WIPE", NULL_KEY);
}

loadSettings() {
    llMessageLinked(LINK_ALL_CHILDREN, 6, "SEND", NULL_KEY);
}

saveSettings(string csv) {
    //todo: expose the wet and mess information to linked prims to the HUD so we can see them visually
    llMessageLinked(LINK_ALL_CHILDREN, 6, csv, NULL_KEY);
}

addCarer(string name) {
    llMessageLinked(LINK_ALL_CHILDREN, 1, name, NULL_KEY); //Null key sent flags "Add Carer" as the action for the memory core.
}

removeCarer(string name) {
    llMessageLinked(LINK_ALL_CHILDREN, 1, name, llGetOwner()); //Valid key sent flags "Delete Carer" as the action for the memory core.
}

findPrims() {
    g_wetBar = 0;
    g_messBar = 0;
    integer i; // Used to loop through the linked objects
    integer primCount = llGetNumberOfPrims(); //should be attached, not sat on
    for(i = 0; i <= primCount; i++) { 
        string primName = (string) llGetLinkPrimitiveParams(i, [PRIM_NAME]); // Get the name of linked object i
        if(primName == "WetBar") {
            g_wetBar = i;
        }
        else if(primName == "MessBar") {
            g_messBar = i;
        }
    }
}

updateBars(string csv) {
    integer index; // Used to hold the location of a comma in the CSV
    
    index = llSubStringIndex(csv, ",");
    g_wetLevel = (integer) llGetSubString(csv, 0, index-1);
    csv = llGetSubString(csv, index+1, -1); // Remove the used data.
    
    index = llSubStringIndex(csv, ",");
    g_messLevel = (integer) llGetSubString(csv, 0, index-1);

    if(g_wetBar) {
        llSetLinkPrimitiveParamsFast(g_wetBar,[PRIM_SLICE, <0.0, g_wetLevel / 5.0, 0.0>, PRIM_COLOR, ALL_SIDES, <0.8, 0.765, 0.2>, (g_wetLevel > 0) * 1.0]);
    }
    if(g_messBar) {
        llSetLinkPrimitiveParamsFast(g_messBar,[PRIM_SLICE, <0.0, g_messLevel / 3.0, 0.0>, PRIM_COLOR, ALL_SIDES, <0.357, 0.239, 0.145>, (g_messLevel > 0) * 1.0]);
    }
    xyzzyText(1,"Wetness: "+(string)g_wetLevel+"/5");
    xyzzyText(2,"Messiness: "+(string)g_messLevel+"/3");
}

integer countCarers(string msg) {
    if(msg == "" || msg == "I'm sorry! There is no more room for carers, please delete one.") {
        return 0;
    }
    integer index = llSubStringIndex(msg, ",");
    if(~index) {
        return 2;
    }
    else {
        return 1;
    }
}

xyzzyText(integer row, string msg) {
    llMessageLinked(LINK_THIS,204000,msg,(string)row);
}

default {
    state_entry() {
        findPrims();
        g_uniqueChan = generateChan(llGetOwner());
        g_commandHandle = constructHandle();
        g_listenerHandle = llListen(g_uniqueChan, "", "", "");
        //attempt to send a sync of data right off the bat
        llSay(g_uniqueChan, "SYNC:OK");
    }
    
    listen(integer c, string n, key id, string msg) {
        //todo: add some form of verification to allow HUDs permission but not other objects
        //Make permsisions configurable so that users can choose how much protection against spoofing they want
        if(msg  == "SYNC") {
            llSay(g_uniqueChan, "SYNC:OK");
        }
        else if(msg == "SYNC:OK") { //This came from another HUD, let's confirm with the user
            //Todo: get the version from the original HUD and include that with the dialog message
            userConfirmed = FALSE;
            list otherHUD = llParseString2List(n,["-V"],["-V"]);
            string invVersion = llList2String(otherHUD,1);
            llListenRemove(g_confirmHandle);
            g_confirmHandle = llListen(g_uniqueChan + 1, "", llGetOwner(), "");
            llDialog(llGetOwner(), "Another HUD (V" + invVersion +") is requesting to sync with this one.  This will wipe your carers and settings, and replace them with new ones!",["Yuppers!","Pls no"], g_uniqueChan + 1);
        llSetTimerEvent(60.0);
        }
        else if(msg == "Yuppers!") {
            userConfirmed = TRUE;
            llSetTimerEvent(0.0);
            llListenRemove(g_confirmHandle);
            wipeCarers();
            g_totalCarers = 0;
            xyzzyText(3,"Total Carers: ??");
            llSay(g_uniqueChan, "CARERS:Load");
            llSay(g_uniqueChan, "SETTINGS:Load");
        }
        else if(msg == "Pls no") {
            llSetTimerEvent(0.0);
            llListenRemove(g_confirmHandle);
        }
        else {
            integer index = llSubStringIndex(msg, ":");
            if(~index) {
                string prefix = llGetSubString(msg, 0, index);
                string data = llGetSubString(msg, index + 1, -1);
                if(prefix == "CARERS:") {
                    //re-use of variables, messy, fix later
                    index = llSubStringIndex(data, ":");
                    prefix = llGetSubString(data, 0, index);
                    data = llGetSubString(data, index + 1, -1);
                    if(prefix == "Load") {
                        loadCarers();
                    }
                    else if(prefix == "Add:") {
                        addCarer(data);
                        g_totalCarers += countCarers(data);
                    }
                    else if(prefix == "Remove:") {
                        removeCarer(data);
                        g_totalCarers -= countCarers(data);
                    }
                    else if(prefix != "CARERS:" && userConfirmed == TRUE){ //A carer list was sent, and we have permissions
                        //if there are two carers being sent at the same time, separate them before sending
                        index = llSubStringIndex(data, ",");
                        g_totalCarers += countCarers(data);
                        if(~index) {
                            addCarer(llGetSubString(data, 0, index - 1));
                            addCarer(llGetSubString(data, index + 1, -1));
                        }
                        else {
                            addCarer(data);
                        }
                    }
                    xyzzyText(3,"Total Carers: "+(string)g_totalCarers);
                }
                else if(prefix == "SETTINGS:") {
                    if(data == "Load") {
                        loadSettings();
                    }
                    else {
                        saveSettings(data);
                        updateBars(data);
                    }
                }
            }
        }
    }
    
    touch_end(integer t) {
        //todo:redirect the touch to DrizzleScript in the main diaper
        if(llDetectedKey(0) != llGetOwner()) {
            return;
        }
        llSay(g_uniqueChan, g_commandHandle);
    }
    
    on_rez(integer start_param) {
        //changed event is fired AFTER on_rez, so we need to do this here
        llListenRemove(g_listenerHandle);
        g_uniqueChan = generateChan(llGetOwner());
        g_commandHandle = constructHandle();
        g_listenerHandle = llListen(g_uniqueChan, "", "", "");
        llSay(g_uniqueChan, "SYNC:OK");
    }
    
    changed(integer c) {
        if(c & CHANGED_LINK) {
            findPrims();
        }
    }
    
    link_message(integer sender_num, integer num, string msg, key id) {
        //todo: upon receiving the information back from the memory core, pass it back to the diaper
        if(num == 6) {
            llSay(g_uniqueChan, "SETTINGS:"+msg);
        }
        if(num >= 1 && num <=5) {
            //update the carer count
            llSay(g_uniqueChan, "CARERS:"+msg);
        }
    }
    
    timer() {
        llSetTimerEvent(0.0);
        llListenRemove(g_confirmHandle);
    }
}
