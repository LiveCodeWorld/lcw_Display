script "behavior_CardMargin"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_CardMargin
type: behavior
version: 0.1

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Working on
-

--> Events
-
on preOpenCard
   LayoutControl
   pass preOpenCard
end preOpenCard

on mouseDown pButtonNumber
   switch pButtonNumber
      case 3
         menu_PopUp "Global | Card | Menu"
         break
      default
         pass mouseDown
   end switch
end mouseDown

on resizeStack
   put the rect of me into cRect
   LayoutControl cRect
end resizeStack

on resizeControl
   put the rect of me into cRect
   LayoutControl cRect
end resizeControl

command LayoutControl cRect
   if cRect is empty then put the rect of me into cRect
   put the card_Margin of me into cMargin
   --
   put _ViewObject() into vObject
   if vObject is empty then return empty
   --
   rect_SubtractMargins cRect, cMargin
   set the rect of vObject to cRect
   return vObject
end LayoutControl


--> Margins
-
getprop card_Margin
   put the card_Margin of me into cardMargin
   if cardMargin is empty then put 24 into cardMargin
   return cardMargin
end card_Margin

setprop card_Margin cardMargin
   set the card_Margin of me to cardMargin
   LayoutControl
end card_Margin


--> Deps
-
command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM
   put the result into nMargins
   --
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
   --
   return nMargins
end rect_SubtractMargins

command margin_Normalize someMargin, @leftM, @topM, @rightM, @bottomM
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   return leftM,topM,rightM,bottomM
end margin_Normalize


--> Objects
-
private function _ViewObject
   if exists (control 1 of me) is false then return empty
   --
   -- put the view_Object of control 1 of me into someView
   put the long id of control 1 of me into someView
   return someView
end _ViewObject

getprop view_Object
   return _ViewObject()
end view_Object
