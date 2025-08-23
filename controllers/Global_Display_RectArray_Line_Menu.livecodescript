script "Global | Display | RectArray | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Display | RectArray | Line | Menu
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
   return the display_View of tObject
end menu_Target


--> Global | Display | RectArray | Line | Menu
-
on menu_SetTitle dView
   put the selected_Path of dView into tPath
   put the top_Array of dView into rectArray
   --
   put lcw_Ask ("Give this rectArray a title...") into sTitle
   put sTitle into rectArray ["meta"]["title"]
   --
   set the top_Array of dView to rectArray
   lcw_Notify "Remeber to save rectArray!"
end menu_SetTitle

on menu_Delete dView
   -- put display_MenuTarget(tObject) into mTarget
   --
   put the selected_Path of dView into tPath
   set the deleted_Path of dView to tPath
end menu_Delete
