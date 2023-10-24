script "Global | Card | Split | Horizontal | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Card | Split | Horizontal | Menu
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

private command _Exit tObject
   if exists (tObject) is false then 
      breakpoint
      exit to top
   end if
end _Exit

getprop disabled_ScaleProportionally [cardObject]
   put the right_View of cardObject into rightView
   if exists (rightView) then
      return false
   else
      return true
   end if
end disabled_ScaleProportionally

getprop checked_ScaleProportionally [cardObject]
   put the right_View of cardObject into rightView
   put the scale_Proportionally of rightView into sBoolean
   return sBoolean
end checked_ScaleProportionally

getprop treeLeft_Param [cardObject]
   put the left_View of cardObject into leftView
   if the tree_View of leftView is empty then
      return "Index"
   else
      return "Tree"
   end if
end treeLeft_Param

getprop treeLeft_Params
   return "Tree,Index"
end treeLeft_Params


--> Global | Card | Split | Horizontal | Menu
-
on menu_TreeLeft cardObject, vBit
   put the left_View of cardObject into leftView
   _Exit leftView
   switch vBit
      case "Tree"
         put view_GetTemplateObject ("View|Tree|Widget with Title") into tObject
         break
      default
         put view_GetTemplateObject ("View|Index|Simple") into tObject
   end switch
   _Exit tObject
   
   set the view_Replacement of leftView to tObject
   put the result into leftView
   --
   display_TrelloOrganisations leftView
end menu_TreeLeft

on menu_ImageRight cardObject
   put the right_View of cardObject into rightView
   _Exit rightView
   put view_GetTemplateObject ("View|Image") into tObject
   _Exit tObject
   
   set the view_Replacement of rightView to tObject
   put the result into rightView
   --
   put the left_View of cardObject into leftView
   _Exit leftView
   display_TrelloOrganisations leftView
end menu_ImageRight
   
private on _
end _

on menu_ScaleProportionally cardObject
   put the right_View of cardObject into rightView
   _Exit rightView
   --
   put the scale_Proportionally of rightView into sBoolean
   set the scale_Proportionally of rightView to (sBoolean is false)
end menu_ScaleProportionally

on submenu_Card
   return "Global | Card | Menu"
end submenu_Card

