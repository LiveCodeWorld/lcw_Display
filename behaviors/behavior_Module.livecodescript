script "behavior_Module"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_Module
type: behavior
version: 0.2

/*
Careful: this behavior was empty and restored form script export.
*/


--> Working on
-

private function _ViewObject
   put the card_View of me into cView
   if exists (cView) then return cView
   
   if exists (control 1 of me) then
      return the long id of control 1 of me
   else
      return empty
   end if
end _ViewObject


--> Events
-
on preOpenStack
   choose browse tool
   --
   put _ViewObject() into vObject
   if exists (vObject) then
      put the uOPN ["behavior_IndexArray"] of vObject into bArray
      set the object_Behaviors of vObject to bArray
   end if
   --
   pass preOpenStack
end preOpenStack

on openStack
   use_AndLoad  
   pass openStack
end openStack

on resizeStack
   put _ViewObject() into vObject
   if exists (vObject) then
      put the card_InnerRect of this cd into cRect
      -- dispatch "LayoutControl" to vObject with cRect
      set the rect of vObject to cRect
   end if
end resizeStack


--> Props | Geometry
-
getprop card_InnerRect
   put the card_Margin of this cd into cMargin
   put the rect of this cd into cRect
   --
   if cMargin is a number then
      add cMargin to item 1 of cRect
      add cMargin to item 2 of cRect
      --
      subtract cMargin from item 3 of cRect
      subtract cMargin from item 4 of cRect
   end if
   return cRect
end card_InnerRect

getprop card_Margin
   return the uOPN ["card_Margin"] of this cd
end card_Margin

setprop card_Margin cMargin
   put _DataView() into vObject
   set the uOPN ["card_Margin"] of me to cMargin
   --
   put the card_InnerRect of this cd into cRect
   dispatch "LayoutControl" to vObject with cRect
end card_Margin


--> Props | Dep
- 
/* Could be at card level or stored with module */

getprop dep_UsedNames
   put the dep_Array of me into depArray
   get depArray ["dep_UsedNames"]
   return keys (it)
end dep_UsedNames

getprop dep_UsedPaths
   put the dep_Array of me into depArray
   get depArray ["dep_UsedPaths"]
   return keys (it)
end dep_UsedPaths

getprop dep_Array
   put the uOPN ["dep_Array"] of me into dArray
   return dArray
end dep_Array

setprop dep_Array dArray
   if dArray = "default" then
      put the stackFile_DepArray of me into dArray
   end if
   set the uOPN ["dep_Array"] of me to dArray
   return dArray
end dep_Array


--> Load
-
command use_AndLoad
   -- Order matters
   if the platform is "web" then
      use_Wasm
      load_FrameContext
      load_MatchData
   else
      put the dep_UsedPaths of me into sPaths
      use_StackPaths sPaths
   end if
end use_AndLoad

command use_Wasm
   put "/boot/standalone/lib_Wasm.livecodescript" into stackPath
   dispatch "wasm_UseLibs" to stack stackPath
end use_Wasm

command load_FrameContext
   -- After use_Wasm
   put wikiFrame_GetContextData() into contextData
   set the context_Data of me to contextData
end load_FrameContext

command load_MatchData pPort
   -- After use_Wasm and load_FrameContext
   set the match_Data of me to empty
   
   put the origin_Protocol of me into pProtocol
   put controller_FetchMatchData (pProtocol, pPort) into matchData
   set the match_Data of me to matchData
end load_MatchData

command use_StackPaths stackPaths, pBoolean
   put the stacksInUse into usedNames
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the short name of stack stackPath into sName
      --
      if pBoolean is false then
         stop using stack stackPath
      else if sName is not among the lines of usedNames then
         start using stack stackPath
      end if
   end repeat
end use_StackPaths
