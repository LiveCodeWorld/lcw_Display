script "Global | Behavior | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Behavior | Line | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Display | Events
-
on mDoubleUp_Behavior dView, bStackName
   put the displayed_Object of dView into viewObject
   --
   edit the script of stack bStackName
end mDoubleUp_Behavior


--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Behavior | Line | Menu
-
on menu_AddBehavior
   put the selected_Line of dView into bObject
   put the displayed_Object of dView into sliceView
   breakpoint
end menu_AddBehavior

on menu_RemoveBehavior dView
   put the selected_Line of dView into bObject
   put the displayed_Object of dView into sliceView
   --
   breakpoint
   put the ix_View of sliceView into ixView
   put the behavior_Objects of ixView into bObjects
   --
   line_Delete bObject, bObjects
   set the behavior_Objects of ixView to bObjects
   set the displayed_Array of dView to bObjects
end menu_RemoveBehavior

private on _
end _

on menu_PropertyInspector dView
   put the selected_Line of dView into bObject
   --
   display_ObjectProperties bObject
end menu_PropertyInspector

on submenu_Dev
   return menu_DevTitle ("Global | Behavior | Line | Menu")
end submenu_Dev
