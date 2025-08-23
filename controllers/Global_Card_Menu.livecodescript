script "Global | Card | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Card | Menu
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
   put the display_View of tObject into displayView
   put the stack_Name of tObject into stackName
   switch
      case word 1 of stackName = "revNewScriptEditor"
         put scriptEditor_Object() into sObject
         put the card_Object of sObject into cardObject
         return cardObject
      case exists (the displayed_Object of displayView)
         put the displayed_Object of displayView into sObject
         put the card_Object of sObject into cardObject
         return cardObject
      case exists (displayView)
         return empty
      default
         put the card_Object of tObject into cardObject
         return cardObject
   end switch
end menu_Target

on ChangeCardBehavior cardObject, bName
   -- sent by "menu_SetCardBehavior" so can change the script of an executing script
   if bName is empty then
      set the behavior of cardObject to empty
   else
      if exists (stack bName) is false then breakpoint
      --
      put the name of stack bName into bObject -- "behavior_CardMargin"
      set the behavior of cardObject to bObject
      --
      if the shiftKey is "Down" then
         edit the script of bObject
      end if
   end if
end ChangeCardBehavior

private function _bNameMenu
   get card_ListBehaviorNames()
   if it is empty then
      return "behavior_ViewTemplateCard"
   else
      return it & ",-,behavior_ViewTemplateCard,behavior_WikiBrowserCard,behavior_CardModule"
   end if
end _bNameMenu


--> Global | Card | Menu
-
on menu_ThisCardBehavior cardObject
   put the behavior of cardObject into bObject
   edit the script of bObject
end menu_ThisCardBehavior

getprop disabled_ThisCardBehavior [cardObject]
   put the behavior of cardObject into bObject
   if exists (bObject) then
      return false
   else
      return true
   end if
end disabled_ThisCardBehavior

on menu_EditCardBehavior  cardObject, bName
   put behavior_GetObject(bName) into bObject
   put the name of stack bName into bObject -- "behavior_CardMargin"
   --
   edit the script of bObject
end menu_EditCardBehavior

getprop editCardBehavior_Params
   return _bNameMenu()
end editCardBehavior_Params

on menu_SetCardBehavior cardObject, bName
   put the name of cardObject into namedCardObject
   --
   put the behavior of cardObject into bObject
   if exists (bObject) is true then
      send "ChangeCardBehavior cardObject" to me in 2 ticks
      lcw_Notify "Removed card behavior for [[var]].", "Card Behavior", namedCardObject
   else
      send "ChangeCardBehavior cardObject,bName" to me in 2 ticks
      --
      lcw_Notify "Set card behavior to [[var]].", namedCardObject, bName
   end if
end menu_SetCardBehavior

getprop setCardBehavior_Param [cardObject]
   put the behavior of cardObject into bObject
   if exists (bObject) is false then return empty
   put the short name of bObject into bName
   return bName
end setCardBehavior_Param

getprop setCardBehavior_Params
   return _bNameMenu()
end setCardBehavior_Params

on menu_CreateCardBehavior cardObject
   card_CreateBehavior
end menu_CreateCardBehavior

private on _
end _

on submenu_RectArray
   return "Global | RectArray | Menu"
end submenu_RectArray

on submenu_Frame
   return "Global | Frame | Menu"
end submenu_Frame

private on __
end __

on menu_CardMargin cardObject
   put the card_Margin of cardObject into cMargin
   put lcw_Ask ("Set the card_Margin of this card", cMargin, "Card") into cMargin
   set the card_Margin of cardObject to cMargin
end menu_CardMargin

on menu_CardInspector cardObject
   display_ObjectProperties cardObject
end menu_CardInspector

private on ___
end ___

on menu_InsertPlaceHolder cardObject
   view_InsertFromPath "Layout|Placeholder", cardObject, "mouse"
   put the result into fasd
end menu_InsertPlaceHolder

on menu_InsertLayout cardObject
   put the card_InnerRect of cardObject into cRect
   view_InsertFromPath "Layout|Horizontal|Two", cardObject, cRect
end menu_InsertLayout

private on ____
end ____

on menu_LayoutCard cardObject
   dispatch "LayoutCard" to cardObject
end menu_LayoutCard

on menu_LayoutTopViews cardObject
   put the top_Views of cardObject into tViews
   lock screen
   repeat for each line tView in tViews
      dispatch "LayoutControl" to tView
   end repeat
   unlock screen
end menu_LayoutTopViews

-- on menu_CardMenuTitle cardObject
put the menu_Title of cardObject into mTitle
put lcw_Ask ("Set the menu_Title of this card", mTitle, "Card") into mTitle
set the menu_Title of cardObject to mTitle
end menu_CardMenuTitle
