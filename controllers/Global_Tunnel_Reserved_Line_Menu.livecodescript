﻿script "Global | Tunnel | Reserved | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Tunnel | Reserved | Line | Menu
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

getprop menu_CheckTarget [cameraView]
   return exists (cameraView)
end menu_CheckTarget


--> Global | Tunnel | Reserved | Line | Menu
-
on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Tunnel | Reserved | Line | Menu"
end menu_MenuEdit

on submenu_Dev
   return menu_DevTitle ("Global | Tunnel | Reserved | Line | Menu")
end submenu_Dev

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Tunnel | Reserved | Line | Menu")
end submenu_Dev
