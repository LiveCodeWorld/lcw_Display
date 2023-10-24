script "Global | RectArray | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | RectArray | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put display_MenuTarget (tObject) into mTarget
   if mTarget is empty then return empty
   --
   get the hkey_CaseConditions ["S rectArray_Restore"] of stack "lib_RectArray"
   put it into LocalArray ["restoreHows"]
   --
   if word 1 of mTarget = "card" then
      put mTarget into arrayObject
   else
      put the view_Object of mTarget into arrayObject
   end if 
   --
   put the rectArray_Names of arrayObject into aNames
   put aNames into LocalArray ["rectArrayNames"]
   --
   put the rectArray_ListControlNames of arrayObject into vNames
   put vNames into LocalArray ["viewNames"]
   --
   put the displayed_RectDataNum [true] of arrayObject into LocalArray ["dRectDataNum"]
   put the displayed_ObjectNames of arrayObject into LocalArray ["objectNames"]
   --
   return arrayObject
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

getprop checked_ScaleProportional [cardObject]
   put the scale_Proportional of cardObject into sBoolean
   return sBoolean
end checked_ScaleProportional

getprop setGeometryTitle_Param [cardObject]
   return LocalArray ["dRectDataNum"]
end setGeometryTitle_Param

getprop setGeometryTitle_Params
   return LocalArray ["rectArrayNames"]
end setGeometryTitle_Params

getprop storeGeometry_Param [cardObject]
   return LocalArray ["dRectDataNum"]
end storeGeometry_Param

getprop storeGeometry_Params
   get LocalArray ["rectArrayNames"]
   if it is empty then
      return "add"
   else
      return it & ",-,add"
   end if
end storeGeometry_Params

getprop restoreGeometry_Param [cardObject]
   return LocalArray ["dRectDataNum"]
end restoreGeometry_Param

getprop restoreGeometry_Params
   return LocalArray ["rectArrayNames"]
end restoreGeometry_Params

getprop deleteGeometry_Param [cardObject]
   return LocalArray ["dRectDataNum"]
end deleteGeometry_Param

getprop deleteGeometry_Params
   -- return LocalArray ["rectArrayNames"]
   return LocalArray ["rectArrayNames"] & ",-,all"
end deleteGeometry_Params

getprop animateAllScaled_Param [cardObject]
   return LocalArray ["dRectDataNum"]
end animateAllScaled_Param

getprop animateAllScaled_Params
   return LocalArray ["rectArrayNames"]
end animateAllScaled_Params


--> Global | RectArray | Menu
-
on menu_ScaleProportional cardObject
   put the scale_Proportional of cardObject into sBoolean
   set the scale_Proportional of cardObject to (sBoolean is false)
end menu_ScaleProportional

on menu_AnimateAllScaled cardObject, indexNum
   set the rectArray_AnimateScaled of cardObject to indexNum
end menu_AnimateAllScaled

private on _
end _

on menu_RestoreGeometry cardObject, itemNum
   set the displayed_RectDataNum of cardObject to itemNum
   put the result into rectArray
end menu_RestoreGeometry

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

private on __
end __

on menu_SetGeometryTitle cardObject, itemNum
   put the rectData_Title [itemNum] of cardObject into sTitle
   put lcw_Ask ("Give this rectArray a title...", sTitle) into sTitle
   set the rectData_Title [itemNum] of cardObject to sTitle
   --
   display_RectData cardObject
end menu_SetGeometryTitle

private on ___
end ___

on submenu_Test
   return "Global | RectArray | Test | Menu"
end submenu_Test
