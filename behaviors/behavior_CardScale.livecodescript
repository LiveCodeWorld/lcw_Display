script "behavior_CardScale"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_CardScale
type: behavior
version: 0.1

/*
-- set the rect_Test ["blue"] of the card_Object of me to bbRect
Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.
*/


--> Variable
-
local LocalArray


--> Working on
-
command LayoutCard
   put the long id of me into cardObject
   transform_CardScaled cardObject
end LayoutCard


--> Margins
-
getprop card_InnerRect [pRect]
   if pRect is empty then put the rect of me into pRect
   --
   put the card_Margin of me into cardMargin
   rect_SubtractMargins pRect, cardMargin
   return pRect
end card_InnerRect

getprop card_Margin
   put the card_Margin of me into cardMargin
   if cardMargin is empty then put 24 into cardMargin
   return cardMargin
end card_Margin

setprop card_Margin cardMargin
   set the card_Margin of me to cardMargin
   LayoutControl
end card_Margin

getprop scale_Proportional
   return LocalArray ["scale_Proportional"]
end scale_Proportional

setprop scale_Proportional sBoolean
   put sBoolean is true into LocalArray ["scale_Proportional"]
   LayoutCard
end scale_Proportional


--> Events
-
on preOpenCard
   LayoutCard
   pass preOpenCard
end preOpenCard

on mouseDown pButtonNumber
   switch pButtonNumber
      case 3
         put "Global | Card | Menu" into mTitle
         --
         put the long id of the target into tObject
         put the menu_Button of tObject into mButton
         mArray_MouseDown mTitle, mButton, tObject
         popup mButton
         break
      default
         pass mouseDown
   end switch
end mouseDown

on resizeStack
   LayoutCard
end resizeStack
