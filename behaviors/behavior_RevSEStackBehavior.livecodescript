script "behavior_RevSEStackBehavior"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_RevSEStackBehavior
type: behavior
version: 0.2

/*
This is the new way to handle intercepting the compile or apply behavior of the Script Editor.
Handling before and after handler events here gives us more flexibility.

-- put the script_Diff of scriptObject 
-- put revTargetStack (pObject)
*/


--> Working on
-
after actionCompile
   -- so this should be sent after you compile a script
   -- for instance when you press the Apply button in the ScriptEditor
   -- put the long id of target into compileButton
   -- put the params
   
   ## Get the control being edited in the ScriptEditor using built in revIDE handlers
   dispatch "revSEGetCurrentObject" to the target
   put the result into scriptObject -- being edited
   
   ## Export sctip and handlers to files, and update menu database if it is a controller
   script_ExportAndIndexMenus scriptObject
   
   ## Update Script Changes view if showing
   put display_FindView ("Script Changes") into dView
   if exists (dView) then
      put the name of scriptObject into sName
      set the deleted_Line of dView to sName
   end if
end actionCompile
