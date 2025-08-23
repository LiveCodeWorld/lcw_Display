script "Global | iPlayer | Search | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | iPlayer | Search | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | iPlayer | Search | Menu
-
on submenu_Iplayer
   return "Global | iPlayer | Menu"
end submenu_Iplayer

private on _
end _

on menu_Refresh displayView
   display_SearchIplayer empty, displayView
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | iPlayer | Search | Menu")
end submenu_Dev
