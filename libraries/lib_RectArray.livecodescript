script "lib_RectArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_RectArray
type: library
version: 0.1

/*
*/

--> Working on
-
setprop rectArray_AnimateScaled [pScaleProportionally] indexOrName
   put the long id of the target into arrayObject
   --
   put the rect of arrayObject into tFrameRect
   put the rect_Data of arrayObject into rectData
   --
   put _GetRectArray (indexOrName, rectData) into rectArray
   set the uRIP["displayed_RectDataNum"] of arrayObject to indexOrName
   --
   put rectArray ["target"]["rect"] into oCardRect
   put rectArray_ListObjects (rectArray) into objectIndex
   --
   put "animationEngine" is among the lines of the stacksinuse into aeOn
   repeat for each line tObject in objectIndex
      -- bit of a crap way of doing things
      -- see 
      if exists (tObject) is false then next repeat
      --
      put the rectArray_Rects of tObject into rectIndex
      put line indexOrName of rectIndex into oRect
      --
      put rect_TransformFromOrigin (oRect, oCardRect, tFrameRect, pScaleProportionally) into sRect
      rect_Normalise sRect -- for animationEngine
      --
      if aeOn is true then
         aeChangeRect tObject, sRect, 1000, "inOut"
      else
         set the rect of tObject to sRect
      end if
   end repeat
   --
   return true
end rectArray_AnimateScaled


--> Working on | Extents
-
private command _RestoreRects objectArray
   put the keys of objectArray into layerNums
   sort numeric layerNums
   repeat for each line itemNum in layerNums
      -- repeat with itemNum = 1 to item 2 of the extents of objectArray -- layers may skip
      put objectArray [itemNum]["control"] into sObject
      if exists (sObject) is false then
         -- allows deleting of ordered items without having to reindex rectArray
         next repeat
      end if
      --
      put objectArray [itemNum]["rect"] into sRect
      if sRect is a rect then -- should not be necessary
         set the rect of sObject to sRect
      end if
   end repeat
end _RestoreRects

private function _ListObjects cArray
   put the keys of cArray into layerNums
   sort numeric layerNums
   repeat for each line itemNum in layerNums
      -- repeat with itemNum = 1 to item 2 of the extents of cArray
      put cArray [itemNum] into objectArray
      put objectArray ["control"] into sObject
      if sObject is not empty then
         put sObject & CR after objectIndex
      end if
   end repeat
   delete char -1 of objectIndex
   return objectIndex
end _ListObjects

private function _ListViewControlNames cArray
   put the keys of cArray into layerNums
   sort numeric layerNums
   repeat for each line itemNum in layerNums
      -- repeat with itemNum = 1 to item 2 of the extents of cArray
      put cArray [itemNum]["name"] into cName
      if cName is empty then next repeat
      --
      if cName is among the lines of cNames then
         put viewArray [itemNum]["control"] into rObject
         put word 1 to 3 of rObject into cName
      end if
      --
      put cName & CR after cNames
   end repeat
   delete char -1 of cNames
   return cNames
end _ListViewControlNames

function rectArray_FindObjectArray rectArray, tObject
   -- an object should only be listed in one section
   -- not searching target?
   
   put revRuggedId (tObject) into rObject
   repeat for each item oType in "views,controls"
      put rectArray [oType] into cArray
      --
      put the keys of cArray into layerNums
      sort numeric layerNums
      repeat for each line itemNum in layerNums
         -- repeat with itemNum = 1 to item 2 of the extents of cArray
         put cArray [itemNum] into objectArray
         put objectArray ["control"] into testObject
         if testObject = rObject then
            return objectArray
         end if
      end repeat
   end repeat
   return empty
end rectArray_FindObjectArray


--> Animated
-
function rectData_FindTitle sTitle, rectData
   repeat with itemNum = 1 to item 2 of the extents of rectData
      put rectData [itemNum]["meta"]["title"] into tName
      if tName = sTitle then
         return itemNum
      end if
   end repeat
   return 0
end rectData_FindTitle


--> Model | RectArray
-
getprop rect_Array [idList]
   put the long id of the target into tObject
   --
   _AddTargetMeta rectArray, tObject
   _AddStackMeta rectArray
   
   if idList is empty then
      # Use topviews to not index elements inside
      _AddTopViews rectArray
      put the result into viewArrray
      _AddControls rectArray
   else
      repeat for each item cID in idList
         if exists (control id cID of tObject) is false then
            breakpoint
            next repeat
         end if
         --
         put the rugged_ID of control id cID of tObject into rObject
         put the layer of rObject into layerNum
         put the view_Name of rObject into vName
         --
         if vName is empty then
            _SetRectArray rectArray, "controls", layerNum, rObject    
         else
            put vName into rectArray ["views"][layerNum]["view"]
            _SetRectArray rectArray, "views", layerNum, rObject
         end if         
      end repeat
   end if
   --
   return rectArray
end rect_Array


--> Model | RectData
-
getprop rect_MetaArray [indexOrName]
   put the rect_Data [indexOrName] of the target into rectArray
   return rectArray ["meta"]
end rect_MetaArray

setprop rect_MetaArray [indexOrName] mArray
   put the rect_Data [indexOrName] of the target into rectArray
   put mArray into rectArray ["meta"]
   return rectArray
end rect_MetaArray

getprop rect_Data [indexOrName]
   put the rectArray_Data of the target into rectData
   return _GetRectArray (indexOrName, rectData)
end rect_Data

private function _GetRectArray @indexOrName, rectData
   switch
      case indexOrName is empty
         return rectData
      case indexOrName is a number
         return rectData [indexOrName]
      default
         put rectData_FindTitle (indexOrName, rectData) into itemNum
         put itemNum into indexOrName
         if itemNum = 0 then
            return empty
         else
            return rectData [itemNum]
         end if
   end switch
end _GetRectArray

setprop rect_Data [indexOrName] sArray
   switch
      case indexOrName is empty
         set the rectArray_Data of the target to sArray
         return rectData
      case indexOrName is a number
         put the rectArray_Data of the target into rectData
         if sArray is empty then
            delete variable rectData [indexOrName]
         else
            put sArray into rectData [indexOrName]
         end if
         set the rectArray_Data of the target to rectData
         return rectData
      default
         put the rectArray_Data of the target into rectData
         put rectData_FindTitle (indexOrName, rectData) into itemNum
         if itemNum is not a number then
            return empty
         else
            if sArray is empty then
               delete variable rectData [itemNum]
            else
               put sArray into rectData [itemNum]
            end if
            set the rectArray_Data of the target to rectData_ListRects(rectData, tObject)
         end if
   end switch
end rect_Data

setprop rectData_Add [sTitle] sArray
   put sTitle into sArray ["meta"]["title"]
   --  
   put the rectArray_Data of the target into rectData
   --
   put rectData_FindTitle (sTitle, rectData) into itemNum
   if itemNum = 0 then
      # Add to the end
      put item 2 of the extents of rectData + 1 into itemNum
   end if
   --
   put sArray into rectData [itemNum]
   set the rect_Data of the target to rectData
   return itemNum
end rectData_Add


--> Transform
-
command transform_CardScaled cardObject, pScaleProportionally, pIndexNum
   -- set to scaled rect
   if pScaleProportionally is empty then put the scale_Proportional of cardObject into pScaleProportionally
   if pIndexNum is empty then put the displayed_RectDataNum of cardObject into pIndexNum
   if pIndexNum is not a number then put 1 into pIndexNum
   --
   put the rect_Data [pIndexNum] of cardObject into rectArray
   put rectArray_ListObjects (rectArray) into objectIndex
   --
   put the rect of cardObject into tFrameRect
   put rectArray ["target"]["rect"] into oCardRect
   
   repeat for each line tObject in objectIndex
      put the rectArray_Rects of tObject into rectIndex
      --
      put line pIndexNum of rectIndex into oRect
      put rect_TransformFromOrigin (oRect, oCardRect, tFrameRect, pScaleProportionally) into sRect
      --
      set the rect of tObject to sRect
   end repeat
   return rectArray
end transform_CardScaled

setprop rectArray_Animate indexNum
   -- animate to stored rect
   put the rect_Data [indexNum] of the target into rectArray
   put rectArray_ListObjects (rectArray) into objectIndex
   
   -- aeLockMoves
   repeat for each line tObject in objectIndex
      put the rectArray_Rects of tObject into rectIndex
      --
      put line indexNum of rectIndex into sRect
      aeChangeRect tObject, sRect, 1000, "inOut"
   end repeat
   return rectArray
end rectArray_Animate

getprop displayed_RectDataNum [pUseTitle]
   -- put the card_Object of the target into arrayObject
   put the long id of the target into arrayObject
   --
   put the uRIP["displayed_RectDataNum"] of arrayObject into indexNum
   --
   if pUseTitle is true then
      put the rect_Data of arrayObject into rectData
      put rectData [indexNum]["meta"]["title"] into sTitle
      if sTitle is not empty then
         return sTitle
      end if
   end if
   return indexNum
end displayed_RectDataNum

setprop displayed_RectDataNum [restoreStack] indexOrName
   -- put the card_Object of the target into arrayObject
   put the long id of the target into arrayObject
   --
   put the rect_Data of arrayObject into rectData
   switch
      case indexOrName is a number
         put indexOrName into indexNum
         break
      default
         put rectData_FindTitle (indexOrName, rectData) into indexNum
         if indexNum = 0 then
            return empty
         end if
   end switch
   --
   put rectData [indexNum] into rectArray
   set the rectArray_RestoreAll [false] of arrayObject to rectArray
   set the uRIP["displayed_RectDataNum"] of arrayObject to indexNum
   --
   return rectArray
end displayed_RectDataNum


--> Transform
-
getprop transformed_Rect [targetFrameRect]
   local pScaleProportionally
   --
   put the long id of the target into tObject
   put the card_Object of tObject into cardObject
   --
   put the displayed_RectArray of cardObject into rectArray 
   put transform_RectFromOrigin (rectArray, tObject, targetFrameRect, pScaleProportionally) into transformedRect
   return transformedRect
end transformed_Rect

setprop transformed_BoundingRect [pScaleProportionally] targetFrameRect
   put the long id of the target into tObject
   --
   put the card_Object of tObject into cardObject
   put the displayed_RectArray of cardObject into pRectArray
   --
   put transform_RectFromOrigin (pRectArray, tObject, targetFrameRect, pScaleProportionally) into transformedRect
   --
   set the rect of tObject to transformedRect
   return objectArray
end transformed_BoundingRect

function transform_RectFromOrigin rectArray, tObject, targetFrameRect, pScaleProportionally
   -- Transformed means "scaled and translated"
   -- We assume "target" "rect" is a card so has 0,0 topleft
   
   # No need to Translate
   put rectArray ["target"]["rect"] into oCardRect
   put rectArray_FindObjectArray (rectArray, tObject) into objectArray
   put objectArray ["rect"] into oRect -- original object rect
   
   put rect_TransformFromOrigin (oRect, oCardRect, targetFrameRect, pScaleProportionally) into transformedRect
   rect_Normalise transformedRect -- for animationEngine
   return transformedRect
end transform_RectFromOrigin

function rect_TransformFromOrigin oRect, oFrameRect, targetFrameRect, pScaleProportionally
   # Get translation vectors
   -- using topleft positions scaled graph in topleft of targetFrameRect
   put item 1 to 2 of oFrameRect into fromPoint -- will be 0,0 for now
   put item 1 to 2 of targetFrameRect into toPoint
   
   loc_SetTranslationVector fromPoint, toPoint, xVector, yVector
   
   # Get scaleX, scaleY
   rect_SetScaleVectors oFrameRect, targetFrameRect, scaleX, scaleY, pScaleProportionally
   
   # Scale before translating
   put rect_ScaleByVectors (oRect, scaleX, scaleY) into transformedRect   
   
   # Translate
   rect_Translate transformedRect, xVector, yVector
   --
   return transformedRect
end rect_TransformFromOrigin

command transform_Card cardObject, targetFrameRect, pMove, pScaleProportionally
   put the displayed_Objects of cardObject into objectIndex
   repeat for each line tObject in objectIndex
      if pMove is true then
         transform_MoveObject tObject, targetFrameRect, pScaleProportionally
      else
         set the transformed_BoundingRect [pScaleProportionally] of tObject to targetFrameRect
      end if
   end repeat
end transform_Card

command transform_Object tObject, targetFrameRect, pScaleProportionally
   set the transformed_BoundingRect [pScaleProportionally] of tObject to targetFrameRect
   put the result into objectArray
   return objectArray
end transform_Object

command transform_MoveObject tObject, targetFrameRect, pScaleProportionally, pDuration, pMethod
   if pDuration is empty then put 1000 into pDuration
   if pMethod is empty then put "inOut" into pMethod
   --
   put the displayed_RectArray of tObject into rectArray 
   put transform_RectFromOrigin (rectArray, tObject, targetFrameRect, pScaleProportionally) into transformedRect
   --
   rect_Normalise transformedRect
   aeChangeRect tObject, transformedRect, pDuration, pMethod
   return transformedRect
end transform_MoveObject


--> Displayed
-
getprop displayed_Objects
   put the displayed_RectArray of the target into rectArray
   put rectArray_ListObjects (rectArray) into objectIndex
   return objectIndex
end displayed_Objects

getprop displayed_Views
   put the displayed_RectArray of the target into rectArray
   put rectArray_ListViews (rectArray) into objectIndex
   return objectIndex
end displayed_Views

getprop displayed_ObjectNames
   put the displayed_RectArray of the target into rectArray
   --
   switch whichControls
      case "Controls"
         return rectArray_ListControlNames (rectArray)
      case "views"
         return rectArray_ListViewControlNames (rectArray)
      default
         return rectArray_ListObjectNames (rectArray)
   end switch
end displayed_ObjectNames

getprop displayed_RectArray
   put the card_Object of the target into cardObject
   put the uRIP["displayed_RectDataNum"] of cardObject into indexNum
   if indexNum is empty then put 1 into indexNum -- defaults to 1
   return the rect_Data [indexNum] of cardObject
end displayed_RectArray


--> Props | RectData
-
getprop rectData_ItemNum [itemNum]
   put the rect_Data of the target into rectData
   return rectData [itemNum]["meta"]["title"]
end rectData_ItemNum

setprop rectData_ItemNum [itemNum] sTitle
   if itemNum is not a number then return empty
   --
   put the rect_Data of the target into rectData
   put sTitle into rectData [itemNum]["meta"]["title"]
   set the rectArray_Data of the target to rectData
   return rectData
end rectData_ItemNum

getprop rectData_CardRect [itemNum]
   -- assummes target was a card
   if itemNum is not a number then return empty
   --
   put the rect_Data of the target into rectData
   return rectData [itemNum]["target"]["rect"]
end rectData_CardRect

getprop rectData_Title [itemNum]
   if itemNum is not a number then return empty
   --
   put the rect_Data of the target into rectData
   return rectData [itemNum]["meta"]["title"]
end rectData_Title

setprop rectData_Title [itemNum] sTitle
   if itemNum is not a number then return empty
   --
   put the rect_Data of the target into rectData
   put sTitle into rectData [itemNum]["meta"]["title"]
   set the rectArray_Data of the target to rectData
   return rectData
end rectData_Title


--> RectArray | List | Names
-
getprop rectArray_ListControlNames [indexOrName]
   if indexOrName is empty then put 1 into indexOrName
   put the rect_Data [indexOrName] of the target into rectArray
   --
   return rectArray_ListObjectNames (rectArray)
end rectArray_ListControlNames

function rectArray_ListObjectNames rectArray
   put rectArray ["controls"] into cArray
   put rectArray ["views"] into vArray
   union cArray with vArray
   return _ListViewControlNames (cArray)
end rectArray_ListObjectNames

function rectArray_ListControlNames rectArray
   put rectArray ["controls"] into cArray
   return _ListViewControlNames (cArray)
end rectArray_ListControlNames

function rectArray_ListViewControlNames rectArray
   put rectArray ["views"] into cArray
   return _ListViewControlNames (cArray)
end rectArray_ListViewControlNames


--> RectArray | List | Objects
-
function rectArray_ListObjects rectArray
   put rectArray ["controls"] into oArray
   put rectArray ["views"] into vArray
   union oArray with vArray
   --
   put _ListObjects (oArray) into objectIndex
   return objectIndex
end rectArray_ListObjects

function rectArray_ListViews rectArray
   put rectArray ["views"] into cArray
   put _ListObjects (cArray) into viewIndex
   return viewIndex
end rectArray_ListViews

function rectArray_ListControls rectArray
   put rectArray ["controls"] into cArray
   put _ListObjects (cArray) into viewIndex
   return viewIndex
end rectArray_ListControls


--> RectArray
-
getprop rectArray_Rects [rectData]
   put the long id of the target into tObject
   if rectData is not an array then
      -- assumes stored on the card
      put the card_Object of tObject into cardObject
      put the rect_Data of cardObject into rectData
   end if
   put rectData_ListRects (rectData, tObject) into rectIndex
   return rectIndex
end rectArray_Rects

function rectData_ListRects rectData, tObject
   repeat with lineNum = 1 to item 2 of the extents of rectData
      put rectData [lineNum] into rectArray
      put rectArray_FindObjectArray (rectArray, tObject) into objectArray
      if objectArray is empty then next repeat
      --
      put objectArray ["rect"] into oRect
      put oRect & CR after rectIndex
   end repeat
   return rectIndex
end rectData_ListRects

getprop rectArray_Names
   put the rect_Data of the target into rectData
   repeat with itemNum = 1 to item 2 of the extents of rectData
      put rectData [itemNum]["meta"]["title"] into sTitle
      if sTitle is empty then put itemNum into sTitle
      put sTitle & CR after rectArrayNames
   end repeat
   delete char -1 of rectArrayNames
   return rectArrayNames
end rectArray_Names


--> RectArray
-
function rectArray_WithinView rObject, rectArray
   put the long name of rObject into sObject
   --
   put rectArray ["views"] into viewArray
   repeat for each key lineNum in viewArray
      put viewArray [lineNum]["control"] into rView
      put the long name of rView into sView
      if word 1 of sView is not "group" then next repeat
      --
      if sObject ends with sView then
         return true
      end if
   end repeat
   return false
end rectArray_WithinView

private command _AddControls @rectArray
   -- won't index controls within views
   put rectArray ["target"]["control"] into tObject
   
   put the controlids of tObject into cIDS -- could use the top_ControlIDs
   repeat with lineNum = 1 to the number of lines of cIDS
      put line lineNum of cIDS into cID
      put the rugged_ID of control id cID of tObject into rObject
      
      # Skip if a view
      -- put the object_IsView of rObject into isView
      put the view_Name of rObject is not empty into isView
      if isView is true then next repeat
      
      # Add if not within
      if rectArray_WithinView (rObject, rectArray) is false then
         _SetRectArray rectArray, "controls", lineNum, rObject
      end if
   end repeat
   return cIDS
end _AddControls @rectArray


--> RectArray | Restore
-
setprop rectArray_RestoreAll [restoreStack] rectArray
   put the long id of the target into tObject
   --
   set lockmessages to true
   lock screen
   --
   if restoreStack is true then _RestoreStack rectArray
   _RestoreTarget rectArray
   _RestoreViews rectArray
   _RestoreControls rectArray
   --
   unlock screen
   set lockmessages to false
   return rectArray
end rectArray_RestoreAll

setprop rectArray_Restore restoreHow
   put the rectArray_Data of the target into rectArray
   switch restoreHow
      case "controls"
         _RestoreControls rectArray
         break
      case "views"
         _RestoreViews rectArray
         break 
      case "target"
         _RestoreTarget rectArray
         break
      case "stack"
         _RestoreStack rectArray
         break
      case "-"
      case "All"
      default
         set the rectArray_RestoreAll [true] of the target to rectArray
   end switch
end rectArray_Restore

setprop rectArray_RestoreViews rectArray
   _RestoreViews rectArray
   return the result
end rectArray_RestoreViews

setprop rectArray_RestoreControls rectArray
   _RestoreControls rectArray
   return the result
end rectArray_RestoreControls


--> RectArray | Model
-
command rectArray_StoreCustom propName, propValue, tObject
   put the rect_Array of tObject into rectArray
   --
   put rectArray ["view"][propName] into propValue
   put propValue into rectArray ["view"][propName]
   set the rect_Array of tObject to rectArray
   return rectArray
end rectArray_StoreCustom


--> RectArray | Store
-
private command _AddTargetMeta @rectArray, tObject
   put "target" into mKey
   put the rugged_ID of tObject into rObject
   put the short id of tObject into tID
   --
   put rObject into rectArray [mKey]["control"]
   put the rect of tObject into rectArray [mKey]["rect"]
   put the short name of tObject into rectArray [mKey]["name"]
   return rObject
end _AddTargetMeta

private command _AddStackMeta @rectArray
   put rectArray ["target"]["control"] into tObject
   --
   put the stack_Name of tObject into stackName
   put stackName into rectArray ["stack"]["name"]
   --
   put the name of stack stackName into stackObject
   put stackObject into rectArray ["stack"]["stackObject"]
   --
   put the effective filename of stack stackName into sFile
   put sFile into rectArray ["stack"]["file"]
   --
   put the rect of stack stackName into rectArray ["stack"]["rect"]
end _AddStackMeta

private command _AddTopViews @rectArray
   put rectArray ["target"]["control"] into tObject
   --
   put the top_Views of tObject into topViews
   repeat with lineNum = 1 to the number of lines of topViews
      put line lineNum of topViews into topView
      put revRuggedId (topView) into rObject
      put the layer of rObject into sLayer
      
      put the view_Name of rObject into vName
      put vName into rectArray ["views"][sLayer]["view"]
      --
      _SetRectArray rectArray, "views", sLayer, rObject
   end repeat
   return rectArray ["views"]
end _AddTopViews

private command _SetRectArray @rectArray, mKey, itemNum, rObject
   put rObject into rectArray [mKey][itemNum]["control"]
   put the rect of rObject into rectArray [mKey][itemNum]["rect"]
   put the short name of rObject into rectArray [mKey][itemNum]["name"]
end _SetRectArray


--> RectArray | Restore
-
private command _RestoreTarget rectArray
   put rectArray ["target"]["control"] into tObject
   if word 1 of tObject is among the items of "card,stack" then return empty
   --
   put rectArray ["target"]["rect"] into tRect
   set the rect of tObject to tRect
   return tRect
end _RestoreTarget

private command _RestoreStack rectArray
   put rectArray ["stack"]["rect"] into stackRect
   put rectArray ["stack"]["name"] into stackName
   --
   set the rect of stack stackName to stackRect
   return stackName
end _RestoreStack

private command _RestoreControls rectArray
   put rectArray ["controls"] into controlArray
   _RestoreRects controlArray
   return controlArray
end _RestoreControls

private command _RestoreViews rectArray
   put rectArray ["views"] into viewArray
   _RestoreRects viewArray
   return viewArray
end _RestoreViews
