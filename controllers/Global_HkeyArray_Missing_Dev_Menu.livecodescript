script "Global | HkeyArray | Missing | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Missing | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the data_View of tObject
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

getprop checked_MissingFoundKeys [dView]
   put the missing_FoundArray of dView into foundArray -- fine
   return the keys of foundArray is not empty
end checked_MissingFoundKeys


--> Global | HkeyArray | Missing | Dev | Menu
-
on menu_MissingFoundKeys dView
   put the missing_FoundArray of dView into foundArray -- fine
   --
   _DisplayMissing "Already in Index", foundArray, dView
end menu_MissingFoundKeys

on menu_MissingModuleKeys dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   --
   
   put "Deps" && the number of lines of hKeys into sTitle
   put objectHkeyArray_FromKeys (hKeys) into objectHkeyArray
   set the displayed_Array of dView to objectHkeyArray
   
   if hKeys is not empty then
      put the name of sObject into sTitle
      put script_CollectFromObjects (hKeys, true) into newDepScript
      display_Text newDepScript, sTitle, "Module Dependency Script"
   end if
end menu_MissingModuleKeys

on menu_DisplayHkeyIndex dView
   put the displayed_HkeyArray of dView into hkeyArray
   put array_List (hkeyArray) into hKeys
   
   # Title
   put the number of lines of hKeys into keyNum
   put "(" & keyNum && "Hkeys)" into keyNumBit
   --
   put the displayed_Hkey of dView into hKey
   put the displayed_Object of dView into sObject
   if sObject is empty then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put hObject into sObject
      put hKey into sTitle
   else
      put the name of sObject into sTitle
   end if
   
   put space & keyNumBit after sTitle
   -- set the title_Text of dView to sTitle
   set the displayed_Array of dView to hKeys
   --
   sort lines of hKeys
   return hKeys
end menu_DisplayHkeyIndex

on menu_FindMissing displayView
   put LocalArray ["missingArray"] into missingArray
   --
   put env_ScriptHierarchy (true) into searchObjects
   put scriptMissing_FindFromMissingArray (missingArray, searchObjects) into foundMissingObjectDepArray
   --
   set the displayed_Array of displayView to foundMissingObjectDepArray
end menu_FindMissing


private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | HkeyArray | Missing | Dev | Menu"
end menu_MenuEdit
