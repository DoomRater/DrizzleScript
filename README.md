DrizzleScript
=============

an open source LSL diaper script
These scripts are provided under the Reciprocal Public License 1.5. See LISCENCE for more details.

Changes by Brache Spyker:
-updated the Frand calls to truly generate numbers from 1-100 (were previously only reaching 1-99)
-added calls to sounds and llRequestControls() so we can tell when the user is crinkling
-Added option to silence diaper chatter or make it whisper instead of going all over the place
-Notecards can now be gender inspecific- two example notecards are included
-Now as many different notecards can be added as memory allows, just like diaper textures
-crinkle sounds and wetting sounds added (not configurable yet)
-BUGFIX: tummy rub messings always displaying as if previously messy
-BUGFIX: when others checked a diaper it didn't check for dry messy messages
-heavily updated notecards
-Added lots more security checks to the listens; people can't just spoof carer actions if they know the listen channel now
Default gender is girl in this script
-timesheldWet is reset properly when you wet, regardless of HOW you wet- before it only reset on timer
-BUGFIX: once you started flooding, you didn't stop flooding
-timesheldMess now resets under any messing not just timer
-nearby avatars could flood the lists and cause memory crashes, so now we're flushing those lists and storing a max of 12.
BUGFIX: parseSettings was not interpreting the volume settings as floats and thus failed to load the correct values

todo list:
-add RP name option to printouts
-allow others to interact with diaper but not check or change
-allow toggling of carer access to diaper options menu
-add additional support for wet & mess prims/document how wetting and messing is handled
-add chat commands so that gestures can be created
-additional rezzable objects with system to organize

