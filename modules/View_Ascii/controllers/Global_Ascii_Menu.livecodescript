script "Global | Ascii | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Ascii | Menu
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
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Ascii | Menu
-
on menu_Ascii dView
   put the params
end menu_Ascii

private on _
end _

on menu_InstallAsciinema dView
   display_Xterm "brew install asciinema"
end menu_InstallAsciinema

on menu_Documentation dView
   launch url "https://docs.asciinema.org/manual/cli/installation/"
end menu_Documentation

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Ascii | Menu")
end submenu_Dev
