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
   -- don't debug as debugger can't cope
   
   put _ScriptEditorScriptObject() into scriptObject
   if exists (scriptObject) is false then return false
   
   ## Export sctip and handlers to files, and update menu database if it is a controller 
   if the shiftKey is "Up" then
      script_ExportAndIndexMenus scriptObject
   end if
   
   ## Update Script Changes view if showing
   put display_FindView ("Script Changes") into dView
   if exists (dView) then
      put revRuggedID (scriptObject) into sName
      set the deleted_Line of dView to sName
   end if
end actionCompile

private function _ScriptEditorScriptObject
   ## Get the control being edited in the ScriptEditor using built in revIDE handlers
   dispatch "revSEGetCurrentObject" to the target
   put the result into scriptObject -- being edited
   return scriptObject
end _ScriptEditorScriptObject
