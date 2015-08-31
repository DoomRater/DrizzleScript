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
//-change memory communication
//-prevent spoofing by other people's objects; a user or worn objects may be able to communicate but outside objects should need permissions first
//-document API on how to communicate with diaper or HUD
integer g_listenerHandle;
integer g_uniqueChan;
string g_commandHandle;

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

default {
    state_entry() {
        g_uniqueChan = generateChan(llGetOwner());
        g_commandHandle = constructHandle();
        g_listenerHandle = llListen(g_uniqueChan, "", "", "");
        //attempt to send a sync of data right off the bat
        loadSettings();
        loadCarers();
    }
    
    listen(integer c, string n, key id, string msg) {
        //todo: listen to user's personal channel and parse info to be sent to memory core
        //we can do this here without rewriting the memory core!
        if(msg  == "SYNC") {
            loadCarers();
            loadSettings();
        }
        else {
            integer index = llSubStringIndex(msg, ":");
            if(~index) {
                string prefix = llGetSubString(msg, 0, index);
                string data = llGetSubString(msg, index + 1, -1);
                if(prefix == "CARERS:") {
                    //re-use of variables, messy, fix later
                    index = llSubStringIndex(msg, ":");
                    prefix = llGetSubString(data, 0, index);
                    data = llGetSubString(msg, index + 1, -1);
                    if(prefix == "Load") {
                        loadCarers();
                    }
                    else if(prefix == "Add:") {
                        addCarer(data);
                    }
                    else if(prefix == "Remove:") {
                        removeCarer(data);
                    }
                }
                else if(prefix == "SETTINGS:") {
                    saveSettings(data);
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
    
    changed(integer change) {
        if(change & CHANGED_OWNER) {
            llListenRemove(g_listenerHandle);
            g_uniqueChan = generateChan(llGetOwner());
            g_commandHandle = constructHandle();
            g_listenerHandle = llListen(g_uniqueChan, "", "", "");
        }
    }
    
    on_rez(integer start_param) {
        loadSettings();
        loadCarers();
    }
    
    link_message(integer sender_num, integer num, string msg, key id) {
        //todo: upon receiving the information back from the memory core, pass it back to the diaper
        if(num == 6) {
            llSay(g_uniqueChan, "SETTINGS:"+msg);
        }
        if(num >= 1 && num <=5) {
            llSay(g_uniqueChan, "CARERS:"+msg);
        }
    }
}
