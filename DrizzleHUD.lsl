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

default {
    state_entry() {
        //todo: unsure
        g_uniqueChan = generateChan(llGetOwner());
        g_commandHandle = constructHandle();
    }
    
    listen(integer c, string n, key id, string m) {
        //todo: listen to user's personal channel and parse info to be sent to memory core
        //we can do this here without rewriting the memory core!
        //once information is verified and/or parsed, send it to the memory core with llMessageLinked
        //Additionally, if we add wet and mess indicators to the HUD users can see that without checking themselves
    }
    
    touch_end(integer t) {
        //todo:redirect the touch to DrizzleScript in the main diaper
        if(llDetectedKey(0) != llGetOwner()) {
            return;
        }
        llSay(1, g_commandHandle);
    }
}
