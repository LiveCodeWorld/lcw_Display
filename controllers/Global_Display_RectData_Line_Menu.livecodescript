script "Global | Display | RectData | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Display | RectData | Line | Menu
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


--> Global | Display | RectData | Line | Menu
-
on insert_Menu
   return "Global | Display | RectArray | Line | Menu"
end insert_Menu

on _
end _

on menu_ListViews displayView
   put the top_Array of displayView into rectArray
   put rectArray_ListViews (rectArray)
end menu_ListViews

on menu_ListControls displayView
   put the top_Array of displayView into rectArray
   put rectArray_ListControls (rectArray)
end menu_ListControls

on menu_ListObjects displayView
   put the top_Array of displayView into rectArray
   put rectArray_ListObjects (rectArray)
end menu_ListObjects

on __
end __

on menu_DisplayRectArray displayView
   put the top_Array of displayView into rectArray
   put rectArray ["meta"]["title"] into sTitle
   if sTitle is empty then
      put the top_Key of displayView into sTitle 
   end if
   --
   display_RectArray rectArray, sTitle
end menu_DisplayRectArray
