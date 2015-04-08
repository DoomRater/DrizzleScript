/*==========================================================
DrizzleScript v1.00
Created By: Ryhn Teardrop
Date: Dec 3rd, 2011

Programming Contributors: Ryhn Teardrop
Resource Contributors: Murreki Fasching

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.


*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

/* Simple script used in a 6th separate prim to save settings 
*  The prim containing this must be linked to the prim
*  with Menu.lsl in it.
*/

integer myNum = 6;

saveInfo(string msg) {
    llSetObjectDesc(msg);
}

default {
    changed(integer c) {
        if(c & CHANGED_OWNER) {
            llSetObjectDesc(""); //wipe settings on new owner
        }
    }
    
    link_message(integer sender_num, integer num, string msg, key id) {
        if(num == myNum) {
            if(msg == "SEND") {
                llMessageLinked(LINK_ROOT, myNum, llGetObjectDesc(), NULL_KEY);   
            }
            else {
                saveInfo(msg);
            }
        }
    }
}
