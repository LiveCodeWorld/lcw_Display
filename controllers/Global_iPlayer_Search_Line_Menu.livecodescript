script "Global | iPlayer | Search | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | iPlayer | Search | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

private function _SelectedProgramID displayView
   _SelectedInfo displayView, programID, indexNum, sTitle
   return programID
end _SelectedProgramID

private command _SelectedInfo displayView, @programID, @indexNum, @sTitle
   put the selected_Line of displayView into someLine
   set the cursor to watch
   --
   put word 1 of item -1 of someLine into programID
   delete item -1 of someLine
   set the itemdelimiter to ":"
   put item 1 of someLine into indexNum
   put item 2 to -1 of someLine into sTitle
   --
   return someLine
end _SelectedInfo


--> Global | iPlayer | Search | Line | Menu
-
on menu_Download displayView
   put _SelectedProgramID (displayView) into programID
   --
   iplayer_Download programID, true
   put the result into shellResult
   put iplayer_EpisodesFromResult (shellResult)
   --
   put iplayer_GetInfo (programID) into infoArray
   display_Data infoArray, "infoArray"
end menu_Download

on menu_GetInfo displayView
   _SelectedInfo displayView, programID, indexNum, sTitle
   --
   put iplayer_GetInfo (programID) into infoArray
   put infoArray ["desclong"] into desclong
   --
   put desclong
   display_Data infoArray, sTitle, "iPlayer"
end menu_GetInfo

private on _
end _

on menu_RevealFile displayView
   _SelectedInfo displayView, programID, indexNum, sTitle
   --
   put iplayer_GetInfo (programID) into infoArray
   put infoArray ["filename"] into sFile
   --
   if there is a file sFile then
      finder_Reveal sFile
   else
      display_Data infoArray, "infoArray", "iPlayer"
   end if
end menu_RevealFile

on submenu_Dev
   return menu_DevTitle ("Global | iPlayer | Search | Line | Menu")
end submenu_Dev
