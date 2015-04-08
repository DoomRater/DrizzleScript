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

/* 
*  5 instances of Node.lsl in separate prims are used to store carer
*  names. The prims containing these scripts must be linked
*  to the object with Menu.lsl in it. 
*/

integer myNum = 1; //Remember myNum needs to be custom set to the appropriate number when deployed. 1 to 5.

integer getListSize() {
    if(llGetObjectDesc() == "") {// Empty
        llSetColor(<0,255,0>, ALL_SIDES);
        return 0;
    }
    else {// One item or more saved already
        list temp = llCSV2List(llGetObjectDesc());
        integer size = (temp != []);
        if(size < 4) {
            llSetColor(<0,255,0>, ALL_SIDES);
        }
        else if(size >= 4 && size <= 6) {
            llSetColor(<0,0,255>, ALL_SIDES);   
        }
        else if(size > 6) {
            llSetColor(<255,0,0>, ALL_SIDES);   
        }
        return size;
    }
}
integer isFull() {
    if(getListSize() >= 8) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}

integer isCarer(string msg) {
    list temp = llCSV2List(llGetObjectDesc());
    if(~llListFindList(temp, [msg])) {
        return TRUE;
    }
    else {
        return FALSE;   
    }
}

removeInfo(string msg, key id) {
    list temp = llCSV2List(llGetObjectDesc());
    integer i = llListFindList(temp, [msg]);
    
    if(~i) {//Found
        llSetObjectDesc(llList2CSV(llDeleteSubList(temp, i, i)));
        return;
    }
    else {// Forward
        if(myNum != 5) {
            llMessageLinked(LINK_ALL_CHILDREN, myNum+1, msg, id);
            return;
        }
    }
}

saveInfo(string msg) {
    string temp = llGetObjectDesc();
    if(getListSize() == 0) {// Empty
        temp += msg;
        llSetObjectDesc(temp);
    }
    else if(getListSize() < 8) {//1, 2, 3
        temp += "," + msg;
        llSetObjectDesc(temp);
    }
    getListSize(); // Updates colors (Take this out when done debugging.)
}

forwardMessage(string msg) {
    llMessageLinked(LINK_ALL_CHILDREN, myNum+1, msg, NULL_KEY);
}

sendList() {
    //Safe for 1 -> 11, their numbers will tell main what to do.
    
    llMessageLinked(LINK_ROOT, myNum, llGetObjectDesc(), NULL_KEY); // Send main this object's list
    llMessageLinked(LINK_ALL_CHILDREN, myNum+1, "SEND", NULL_KEY); // Pass the message on to the next object
}

default {
    link_message(integer sender_num, integer num, string msg, key id) {
        if(msg == "SEND") {
            if(num == myNum) {
                sendList();
                return;
            }
            return;   
        }
        else if(id) { // Valid key in message is used to delete
            if(num == myNum) {
                removeInfo(msg, id);
                return;
            }
        }
        else {
            if(num == myNum) {
                if(!isFull()) {
                    saveInfo(msg);
                    return;
                }
                else {
                    if(myNum != 5) {
                        forwardMessage(msg);
                        return;
                    }
                    else {
                        llMessageLinked(LINK_ROOT, 5, "I'm sorry! There is no more room for carers, please delete one.", NULL_KEY);
                        return;
                    }
                }
            } 
        }
    }
}
