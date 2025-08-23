script "Global | Display | RectArray | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Display | RectArray | Menu
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


--> Global | Display | RectArray | Menu
-
on menu_SaveRectArray dView
   put the displayed_Object of dView into tObject
   put the displayed_Array of dView into rectArray
   --
   put the title_Text of dView into sTitle
   breakpoint
   set the rect_Data [sTitle] of tObject to rectArray
end menu_SaveRectArray

-- on menu_ReloadRectArray dView
   put the displayed_Object of dView into tObject
   --
   display_RectArray tObject
end menu_ReloadRectArray

on _
end _

on submenu_Rect
   return "Global | RectArray | Menu"
end submenu_Rect
