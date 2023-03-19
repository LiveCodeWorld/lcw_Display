script "Global | Card | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Card | Menu
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
   put the display_View of tObject into displayView
   put the stack_Name of tObject into stackName
   switch
      case word 1 of stackName = "revNewScriptEditor"
         put scriptEditor_Object() into sObject
         return sObject
      case exists (the displayed_Object of displayView)
         put the displayed_Object of displayView into sObject
         return sObject
      case exists (displayView)
         breakpoint
         return displayView
      default
         put the card_Object of tObject into cardObject
         get the name of cardObject
         return cardObject
   end switch
end menu_Target

on ChangeCardBehavior cardObject, bName
   -- sent by "menu_SetCardBehavior" so can change teh script of an executing script
   put the name of stack bName into bObject -- "behavior_CardMargin"
   set the behavior of cardObject to bObject
   --
   edit the script of bObject
end ChangeCardBehavior
   
getprop disabled_EditCardBehavior [cardObject]
   put the behavior of cardObject into bObject
   if exists (bObject) then
      return false
   else
      return true
   end if
end disabled_EditCardBehavior

getprop setCardBehavior_Param [cardObject]
   put the behavior of cardObject into bObject
   if exists (bObject) is false then return empty
   put the short name of bObject into bName
   return bName
end setCardBehavior_Param

getprop setCardBehavior_Params
   return card_ListBehaviorNames()
end setCardBehavior_Params


--> Global | Card | Menu
-
on submenu_RectArray
   return "Global | RectArray | Menu"
end submenu_RectArray

on submenu_Frame
   return "Global | Frame | Menu"
end submenu_Frame

private command _
end _

on menu_SetCardBehavior cardObject, bName
   send "ChangeCardBehavior cardObject,bName" to me in 2 ticks
end menu_SetCardBehavior

on menu_EditCardBehavior cardObject
   put the behavior of cardObject into bObject
   edit the script of bObject
end menu_EditCardBehavior

on menu_CreateCardBehavior cardObject
   card_CreateBehavior
end menu_CreateCardBehavior

private command __
end __

on menu_CardMenuTitle cardObject
   put the menu_Title of cardObject into mTitle
   put lcw_Ask ("Set the menu_Title of this card", mTitle, "Card") into mTitle
   set the menu_Title of cardObject to mTitle
end menu_CardMenuTitle

on menu_CardMargin cardObject
   put the card_Margin of cardObject into cMargin
   put lcw_Ask ("Set the card_Margin of this card", cMargin, "Card") into cMargin
   set the card_Margin of cardObject to cMargin
end menu_CardMargin

private command ___
end ___

on menu_LayoutCard cardObject
   dispatch "LayoutCard" to cardObject
end menu_LayoutCard

on menu_InsertPlaceHolder cardObject
   view_InsertFromPath "Layout|Placeholder", cardObject, "mouse"
   put the result into fasd
end menu_InsertPlaceHolder

-- on submenu_Menu cardObject
-- on insert_Menu cardObject
-- messes up module view card menu (but otherwise powerful)
put the menu_Title of cardObject into mName
return mName
end submenu_Menu
