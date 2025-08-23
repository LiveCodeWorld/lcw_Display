script "Global | Miro | Authorization | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Miro | Authorization | Menu
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

getprop menu_IsSimple
   return true
end menu_IsSimple


--> Global | Miro | Authorization | Menu
-
on menu_DisplayTeam displayView
   put the displayed_Array of displayView into authData
   put authData ["team"]["id"] into teamID
   --
   -- put miro_GetTeam (teamID) into rArray
   -- display_Data rArray, "Team", "Miro"
   --
   put miro_GetCurrentUserBoards (teamID) into rArray
   display_Data rArray, "Team Boards", "Miro"
end menu_DisplayTeam

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Miro | Authorization | Menu"
end menu_MenuEdit

on submenu_Dev
   return menu_DevTitle ("Global | Miro | Authorization | Menu")
end submenu_Dev
