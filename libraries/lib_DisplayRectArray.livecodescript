script "lib_DisplayRectArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayRectArray
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Display
-
command display_CardNames stackName
   put the cardnames of stack stackName into cNames
   --
   display_Index cNames
   put the result into dView
end display_CardNames


--> Display | RectArray
-
command display_RectData tObject, pRectData
   if pRectData is not an array then
      put the rect_Data of tObject into pRectData
   end if
   --
   display_Data pRectData, the name of tObject, "rect_Data"
   put the result into dView
   --
   display_SetInteractions dView, "Display | RectData"
   --
   put the rugged_ID of tObject into rObject
   set the displayed_Object of dView to rObject
   return dView
end display_RectData


--> Display | RectArray
-
command display_RectArray rectArray, sTitle
   display_Data rectArray, sTitle, "rect_Array"
   put the result into dView
   --
   display_SetInteractions dView, "Display | RectArray"
   --
   put rectArray ["target"]["control"] into tObject
   -- put rectArray ["target"]["name"] into tName
   set the displayed_Object of dView to tObject
   return dView
end display_RectArray
