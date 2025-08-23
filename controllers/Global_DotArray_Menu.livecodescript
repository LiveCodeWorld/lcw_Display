script "Global | DotArray | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | DotArray | Menu
type: controller
version: 0.2

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

private function _GetDotText displayView
   put the displayed_Array of displayView into dotArray
   --
   if LocalArray ["BoundingBox"] then
      delete variable dotArray ["bb"]
   end if
   --
   put LocalArray ["StripPositions"] into removePos
   put dot_FromArray (dotArray, removePos) into dotText
   return dotText
end _GetDotText

getprop checked_StripPositions
   return LocalArray ["StripPositions"] is true
end checked_StripPositions

getprop checked_StripBoundingBox
   return LocalArray ["BoundingBox"] is true
end checked_StripBoundingBox


--> Global | DotArray | Menu
-
on menu_DotFromArray displayView
   put _GetDotText (displayView) into dotText
   put the dot_File of displayView into dotFile
   --
   display_DotText dotText
   put the result into dView
   set the dot_File of dView to dotFile
end menu_DotFromArray

on menu_DotFromFile displayView
   put the dot_File of displayView into dotFile
   --
   display_DotText dotFile
end menu_DotFromFile

private command _
end _

on menu_StripPositions displayView, sBoolean
   put LocalArray ["StripPositions"] is false into LocalArray ["StripPositions"]
end menu_StripPositions

on menu_StripBoundingBox displayView, sBoolean
   put LocalArray ["BoundingBox"] is false into LocalArray ["BoundingBox"]
end menu_StripBoundingBox

private command __
end __

on submenu_Dev
   return menu_DevTitle ("Global | DotArray | Menu")
end submenu_Dev
