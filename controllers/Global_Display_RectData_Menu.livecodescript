script "Global | Display | RectData | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Display | RectData | Menu
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


--> Global | Display | RectData | Menu
-
on menu_SaveRectData dView
   put the displayed_Object of dView into tObject
   put the displayed_Array of dView into rectData
   --
   set the rect_Data of tObject to rectData
end menu_SaveRectData
