script "behavior_CardSplitHorizontal"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_CardSplitHorizontal
type: behavior
version: 0.1

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Variable
-
local LocalArray


--> Working On
-
getprop menu_Title
   put LocalArray ["mTitle"] into mTitle
   if mTitle is empty then
      return "Global | Card | Split | Horizontal | Menu"
   else
      return mTitle
   end if
end menu_Title

setprop menu_Title mTitle
   put mTitle into LocalArray ["mTitle"]
end menu_Title


--> Events
-
on preOpenCard
   LayoutCard
   pass preOpenCard
end preOpenCard

on mouseDown pButtonNumber
   switch pButtonNumber
      case 3
         put the menu_Title of me into mTitle
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


--> Objects
-
getprop displayed_Object
   return the right_View of me
end displayed_Object

getprop left_View
   if exists (control "Left Card View" of me) is false then return empty
   --
   put the long id of control "Left Card View" of me into leftView
   return leftView
end left_View

getprop right_View
   if exists (control "Right Card View" of me) is false then return empty
   --
   put the long id of control "Right Card View" of me into rightView
   return rightView
end right_View


--> Layout
-
command LayoutCard
   put the long id of me into cardObject
   --
   put the the rect of cardObject into pRect
   put the card_InnerRect [pRect] of cardObject into innerRect
   --
   put the left_View of me into leftView
   put the right_View of me into rightView 
   put the horizontal_Spacing of me into viewSpacing
   
   ## left_View rect
   put the left_Width of me into leftViewWidth
   put _LeftRect (leftViewWidth, innerRect) into leftViewRect
   
   ## vertical_Divider Rect
   put _DividerRect (leftViewRect, viewSpacing, innerRect) into verticalDividerRect
   
   -- right_View rect
   put _RightRect (verticalDividerRect, innerRect) into rightViewRect
   
   -- Set Rects
   lock screen
   if exists (leftView) then
      set the rect of leftView to leftViewRect
   end if
   if exists (rightView) then
      if the scale_Proportionally of me is true then
         dispatch "LayoutControl" to rightView with rightViewRect
      else
         set the rect of rightView to rightViewRect
      end if
   end if
   
   unlock screen  
end LayoutCard

getprop scale_Proportionally
   return the scale_Proportionally of me is true
end scale_Proportionally

setprop scale_Proportionally sBoolean
   set the scale_Proportionally of me to sBoolean
   LayoutCard
end scale_Proportionally

command relayout_TopViews
   put the top_Views of cardObject into tViews
   lock screen
   repeat for each line tView in tViews
      dispatch "LayoutControl" to tView
   end repeat
   unlock screen
end relayout_TopViews

private function _LeftRect leftViewWidth, innerRect
   put item 1 of innerRect + leftViewWidth into leftViewRight
   put leftViewRight into item 3 of innerRect
   return innerRect
end _LeftRect

private function _RightRect verticalDividerRect, innerRect
   put item 3 of verticalDividerRect into rightViewLeft
   put rightViewLeft into item 1 of innerRect
   return innerRect
end _RightRect

private function _DividerRect leftViewRect, viewSpacing, innerRect
   put innerRect into verticalDividerRect
   put item 3 of leftViewRect into leftViewRight
   --
   put leftViewRight into item 1 of verticalDividerRect
   put leftViewRight + viewSpacing into rightViewLeft
   put rightViewLeft into item 3 of verticalDividerRect
   --
   return verticalDividerRect
end _DividerRect


--> Props | Geometry
-
getprop horizontal_Spacing
   put LocalArray ["horizontal_Spacing"] into someSpacing
   if someSpacing is empty then
      put the card_Margin of me into someSpacing
   end if
   return someSpacing
end horizontal_Spacing

setprop horizontal_Spacing [dontLayout] someSpacing
   put someSpacing into LocalArray ["horizontal_Spacing"]
   if dontLayout is not true then dispatch "LayoutControl" to me
end horizontal_Spacing

getprop left_Width
   return the width of the left_View of me
end left_Width

-- setprop left_Width someWidth
end left_Width

getprop right_Width
   return the width of the right_Width of me
end right_Width

-- setprop right_Width someWidth
end right_Width

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
