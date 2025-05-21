script "Global | DepScript | Hkeys | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | DepScript | Hkeys | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | DepScript | Hkeys | Menu
-
on menu_GraphHkeyArray sObject, graphStyle
   put _dView() into dView
   put the hkey_Array of dView into hkeyArray
   
   # Draw and Display Graph
   displayGraph_HkeyArray hkeyArray, sObject, graphStyle
end menu_GraphHkeyArray

getprop graphHkeyArray_Params
   return dot_ListGraphStyles()
end graphHkeyArray_Params

private on _
end _

on menu_CollectDisplayed sObject
   put _DisplayedData() into hKeys
   put script_CollectFromObjects (hKeys, true) into depScript
   --
   _DisplayDepScript depScript, sObject
end menu_CollectDisplayed

on menu_CreateDepScriptStack sObject
   put _dView() into dView
   -- put the module_BehaviorDepScript of sObject into depScript
   put the hkey_Array of dView into hkeyArray
   put module_GetDepScript (hkeyArray, sObject) into depScript
   
   module_CreateBehaviorDepStack sObject, depScript
   --
   put the result into depStackName
   edit the script of stack depStackName
   return depHkeyArray
end menu_CreateDepScriptStack

on menu_SortDisplayedHkeys sObject
   put _dView() into dView
   put the displayed_Lines of dView into hKeys
   
   put hkeyIndex_ConstructDepScriptArray (hKeys) into depScriptArray
   display_Data depScriptArray, sObject, "depScriptArray"
   
   # Sort
   hkey_SortIndex hKeys
   
   # Extract privateHkeys
   filter hKeys with "P*" into privateHkeys
   filter hKeys without "P*"
   
   # Extract privateHkeys
   put "^(G|S) .+" into wildcardPattern
   filter hKeys with regex pattern wildcardPattern into propHandlers
   filter hKeys without regex pattern wildcardPattern
   sort lines of propHandlers by word 2 of each
   
   put propHandlers & CR & hKeys & CR & privateHkeys into sortedHkeys
   
   # To Display custom sort we need an index field display
   set the displayed_Lines of dView to sortedHkeys
end menu_SortDisplayedHkeys

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | DepScript | Hkeys | Menu")
end submenu_Dev
