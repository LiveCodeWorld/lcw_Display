script "Global | RectArray | Test | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | RectArray | Test | Menu
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

getprop storeRectArrayData_Params
   return LocalArray ["rectArrayNames"]
end storeRectArrayData_Params

getprop animateView_Param [cardObject]
   return LocalArray ["dRectDataNum"]
end animateView_Param

getprop animateView_Params
   return LocalArray ["viewNames"]
end animateView_Params

getprop animateAll_Params
   return "1,2,3"
end animateAll_Params

getprop testMove_Params [cardObject]
   return LocalArray ["objectNames"] & ",-,all"
end testMove_Params

getprop displayRectArray_Params [cardObject]
   return the rectArray_Names of cardObject
end displayRectArray_Params


--> Global | RectArray | Test | Menu
-

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

private on _____
end _____

on menu_DisplayRectArray cardObject, arrayName
   put the rect_Data [arrayName] of cardObject into rectArray
   --
   display_RectArray rectArray, arrayName
end menu_DisplayRectArray

on menu_DisplayRectData cardObject
   display_RectData cardObject
end menu_DisplayRectData

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

private on _
end _

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

on menu_FixIds cardObject
   put the rect_Data of cardObject into rectData
   display_Data rectData, "Current", "rectData"
   --
   repeat with itemNum = 1 to item 2 of the extents of rectData
      get rectData [itemNum]["Controls"]
      _FixArray it
      put it into rectData [itemNum]["Controls"]
      --
      get rectData [itemNum]["Views"]
      _FixArray it
      put it into rectData [itemNum]["Views"]
   end repeat
   --
   display_Data rectData, "Fixed", "rectData"
end menu_FixIds

private command _FixArray @it
   repeat for each key cNum in it
      put it [cNum]["control"] into sControl
      put it [cNum]["name"] into sName
      if word 1 to 2 of sName = "control id" then
         put empty into sName
      end if
      if exists (control sName of cardObject) is false then next repeat
      --
      put the rugged_ID of control sName of cardObject into newControl
      if newControl is not sControl then
         put newControl into rectData [itemNum]["Controls"][cNum]["name"]
      end if
   end repeat 
end _FixArray
