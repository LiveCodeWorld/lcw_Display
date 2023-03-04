script "Global | RectArray | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | RectArray | Menu
type: controller
version: 0.1

/*
on menu_RestoreRectArrayData cardObject, restoreHow
   put the rectArray_Data of cardObject into rectArray
   --
   -- put the shiftKey is "Down" into sBoolean
   -- set the rectArray_Restore [sBoolean] of cardObject to rectArray
   set the rectArray_Restore of cardObject to restoreHow
   --
   display_RectArray cardObject
end menu_RestoreRectArrayData

on menu_StoreCustom cardObject
   put lcw_Ask("Custom name to store", "ring_NumberOfPoints") into propName
   put lcw_Ask("Default custom prop value  to store", propValue) into propValue
   --
   rectArray_StoreCustom propName, propValue, cardObject
   --
   display_RectArray cardObject
end menu_StoreCustom
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put display_MenuTarget (tObject) into tObject
   --
   get the hkey_CaseConditions ["S rectArray_Restore"] of stack "lib_RectArray"
   put it into LocalArray ["restoreHows"]
   --
   put the card_Object of tObject into cardObject
   put the rectArray_Names of cardObject into aNames
   put aNames into LocalArray ["rectArrayNames"]
   --
   put the rectArray_ListControlNames of cardObject into vNames
   put vNames into LocalArray ["viewNames"]
   --
   put the displayed_ObjectNames of cardObject into LocalArray ["objectNames"]
   --
   return cardObject
end menu_Target

private function _ObjectFromName cName, cardObject
   if word 1 to 2 of cName is among the items of "control id,group id" then
      put word 3 of cName into cID
      put the long id of control id cID of cardObject into tObject
   else
      put the long id of control cName of cardObject into tObject
   end if
   return tObject
end _ObjectFromName

getprop setGeometryTitle_Params
   return LocalArray ["rectArrayNames"]
   return "1,2,3"
end setGeometryTitle_Params

getprop storeGeometry_Params
   return "1,2,3,-,add"
end storeGeometry_Params

getprop restoreGeometry_Param [cardObject]
   put rectData [itemNum]["meta"]["title"] into sTitle
   if sTitle is empty then put itemNum into sTitle
   
   get the displayed_RectDataNum [true] of cardObject
   return it
end restoreGeometry_Param

getprop restoreGeometry_Params
   return LocalArray ["rectArrayNames"]
   return "1,2,3"
   return LocalArray ["restoreHows"]
end restoreGeometry_Params

getprop deleteGeometry_Params
   return "1,2,3,-,all"
end deleteGeometry_Params

getprop storeRectArrayData_Params
   return "1,2,3"
end storeRectArrayData_Params

getprop displayRectArray_Params [cardObject]
   return the rectArray_Names of cardObject
end displayRectArray_Params

getprop animateView_Params
   -- return "1,2,3"
   return LocalArray ["viewNames"]
end animateView_Params

getprop animateAll_Params
   return "1,2,3"
end animateAll_Params
   
getprop testMove_Params [cardObject]
   return LocalArray ["objectNames"] & ",-,all"
end testMove_Params

getprop checked_ScaleProportional [cardObject]
   put the scale_Proportional of cardObject into sBoolean
   return sBoolean
end checked_ScaleProportional


--> Global | RectArray | Menu
-
on menu_ScaleProportional cardObject
   put the scale_Proportional of cardObject into sBoolean
   set the scale_Proportional of cardObject to (sBoolean is false)
end menu_ScaleProportional

private command _____
end _____

on menu_AnimateAll cardObject, indexNum
   set the rectArray_Animate of cardObject to indexNum
end menu_AnimateAll

on menu_AnimateView cardObject, cName
   put _ObjectFromName (cName, cardObject) into tObject
   put the rectArray_Rects of tObject into rectIndex
   
   set the rect of tObject to line 1 of rectIndex
   put line 2 of rectIndex into newRect
   aeChangeRect tObject, newRect, 2000, "inOut"
end menu_AnimateView

private command _
end _

on menu_TestMove cardObject, cName
   put "100,100,500,500" into targetFrameRect
   put the scale_Proportional of cardObject into scaleProportionally
   --
   if cName = "all" then
      transform_Card cardObject, targetFrameRect, true, scaleProportionally
   else
      put _ObjectFromName (cName, cardObject) into tObject
      transform_MoveObject tObject, targetFrameRect, scaleProportionally
   end if
end menu_TestMove

on menu_RestoreGeometry cardObject, itemNum
   set the displayed_RectDataNum of cardObject to itemNum
   put the result into rectArray
   --
   -- display_RectArray rectArray, indexNum
end menu_RestoreGeometry

private command __
end __

on menu_StoreGeometry cardObject, indexNum
   put the rect_Array of cardObject into rectArray
   if indexNum = "add" then
      put lcw_Ask ("What title would you like to give this geometry?") into sTitle
      set the rectData_Add [sTitle] of cardObject to rectArray
      put the result into itemNum
      set the rectData_Title [itemNum] of cardObject to sTitle
   else
      put the rect_MetaArray [indexNum] of cardObject into mArray
      put mArray into rectArray ["meta"]
      --
      set the rect_Data [indexNum] of cardObject to rectArray
   end if
   --
   display_RectData cardObject
end menu_StoreGeometry

on menu_DeleteGeometry cardObject, itemNum
   if itemNum = "all" then
      set the rect_Data of cardObject to empty
   else
      set the rect_Data [itemNum] of cardObject to empty
   end if
   --
   display_RectData cardObject
end menu_DeleteGeometry

private command ___
end ___

on menu_LayoutCard cardObject
   dispatch "LayoutCard" to cardObject
end menu_LayoutCard

on menu_LayoutViews cardObject
   put the displayed_Views of cardObject into viewIndex
   repeat for each line someView in viewIndex
      get the name of someView
      dispatch "LayoutControl" to someView
   end repeat
end menu_LayoutViews

on menu_SetGeometryTitle cardObject, itemNum
   put the rectData_Title [itemNum] of cardObject into sTitle
   put lcw_Ask ("Give this rectArray a title...", sTitle) into sTitle
   set the rectData_Title [itemNum] of cardObject to sTitle
   --
   display_RectData cardObject
end menu_SetGeometryTitle

private command ____
end ____

on menu_DisplayRectArray cardObject, arrayName
   put the rect_Data [arrayName] of cardObject into rectArray
   --
   display_RectArray rectArray, arrayName
end menu_DisplayRectArray

on menu_DisplayRectData cardObject
   display_RectData cardObject
end menu_DisplayRectData
