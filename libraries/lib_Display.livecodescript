script "lib_Display"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Display
type: library
version: 0.6

/*
Here we gather handlers that display things.

Displaying stuff, that is taking data from a model, processing it (with a controller),
and then laying it out in a display (view) is not the job of a library,
but while creating libraries we often find the need to do some generic display code,
either for testing, or because it is useful.

We use this library to pull out any display code from other libraries into one place,
so that there is no view oriented code in the other libraries.

You can "view" this library as contaminated :)
*/

local LocalArray


--> Move
-

--> Module | DepScript
-
getprop module_DepStackName
   put the stack_name of the target into sName
   put sName & "Deps" into depStackName
   return depStackName
end module_DepStackName

function scriptDeps_Collect hKeys, stackName 
   # Scripts Metadata
   put metadata_ConstructScriptHeader (stackName, "Deps") into depScript
   put CR&CR & hkeyIndex_CollectScript (hKeys) after depScript
   return depScript
end scriptDeps_Collect

command module_CreateBehaviorDepStack sObject, pDepScript
   if exists (sObject) is false then
      return "Error, object does not exist:" && sObject
   end if
   
   put the module_DepStackName of sObject into depStackName
   switch
      case depStackName is empty
         return "Error, the module_DepStackName is empty" -- getprop is missing?
      case exists (stack depStackName) is true
         return "Error, stack already exists:" && depStackName
      default
         # Create behavior stack (don't save)
         create stack depStackName
         --
         put the module_BahaviorFolder of sObject into bFolder
         put bFolder & depStackName & ".livecodescript" into bPath
         set the filename of stack depStackName to bPath
         set the destroyStack of stack depStackName to true
         set the destroyWindow of stack depStackName to true
         --
         go to stack depStackName
         
         # Collect depscript if not specified
         if pDepScript is empty then
            put the module_BehaviorDepScript of sObject into pDepScript
         end if
         
         # Add handlers to behavior created stack (don't save)
         set the script of stack depStackName to pDepScript
         return depStackName
   end switch 
end module_CreateBehaviorDepStack

getprop module_BehaviorDepScript [fromFolder]
   put the module_ExternalHkeys [fromFolder] of the target into hkeyDeps
   
   # Collect Depscript
   -- put script_CollectFromObjects (hkeyDeps, true) into depScript
   put the module_DepStackName of the target into stackName
   put scriptDeps_Collect (hkeyDeps, stackName) into depScript
   --
   return depScript
end module_BehaviorDepScript

getprop module_ExternalHkeys [fromFolder]
   put the long id of the target into sObject
   put the module_BehaviorDepHkeyArray [fromFolder] of sObject into hkeyArray
   put module_ListExternalHkeys (hkeyArray, sObject) into hKeys
   return hKeys
end module_ExternalHkeys

function module_GetDepScript hkeyArray, sObject
   put the module_DepStackName of sObject into stackName
   --
   put module_ListExternalHkeys (hkeyArray, sObject) into hkeyDeps
   put scriptDeps_Collect (hkeyDeps, stackName) into depScript
   return depScript
end module_GetDepScript

function module_ListExternalHkeys hkeyArray, sObject
   put the module_Hierarchy [true] of sObject into hObjects
   --
   put array_ListKeys (hkeyArray) into hKeys
   repeat for each line hObject in hObjects
      put revRuggedID (hObject) into rObject
      filter hKeys without ("*" && rObject)
   end repeat
   hkey_SortIndex hKeys
   return hKeys
end module_ListExternalHkeys

getprop module_Hierarchy [fromFolder]
   local oHierarchy, bHierarchy
   --
   put the module_Name of the target into moduleName
   if moduleName is empty then return empty
   put view_GetTemplateObject (moduleName) into mObject
   
   # Behaviors and object hieararchy
   if fromFolder is not false then
      put the module_Behaviors of mObject into oHierarchy
   else
      put the behavior_Objects of mObject into oHierarchy
   end if
   
   put word 1 to -1 of oHierarchy into oHierarchy
   
   # Rest of object hierarchy
   hierachy_AddStackObjects bHierarchy, mObject
   put oHierarchy & CR & word 1 to -1 of bHierarchy into moduleHierarchy
   --
   return moduleHierarchy
end module_Hierarchy


--> Working on
-
function scriptSuite_ConstructSection suiteTitle, hKeys
   local suiteSectionScript
   
   scriptSuite_Construct suiteSectionScript, suiteTitle, hKeys
   put the result into missingHkeys
   return suiteSectionScript
end scriptSuite_ConstructSection

command scriptSuite_Construct @suiteSectionScript, suiteTitle, hKeys
   put script_ConstructSuiteHeader (suiteTitle) & CR after suiteSectionScript
   repeat for each line hKey in hKeys
      put handler_Get (hKey) into someHandler
      --
      if someHandler is empty then
         put hKey & CR after missingHkeys
      else
         put someHandler & CR&CR after suiteSectionScript
         -- text_AddParagraph someHandler, suiteSectionScript
      end if
   end repeat
   delete char -2 to -1 of suiteSectionScript
   delete char -1 of missingHkeys
   return missingHkeys
end scriptSuite_Construct

function hkeyIndex_CollectScript hKeys
   local depScript
   
   hkeyIndex_Split hKeys, sortedHKeys, propHandlers, privateHkeys
   --
   -- put scriptSuite_ConstructSection ("Props", propHandlers) after depScript
   if propHandlers is not empty then
      scriptSuite_Construct depScript, "Props", propHandlers
      put the result into missingHkeys
   end if
   
   -- put CR & scriptSuite_ConstructSection ("Hkeys", sortedHKeys) after depScript 
   if sortedHKeys is not empty then
      put CR&CR&CR after depScript
      scriptSuite_Construct depScript, "Hkeys", sortedHKeys
      line_Add the result, missingHkeys
      put CR&CR&CR after depScript
   end if
   
   -- put CR&CR&CR & scriptSuite_ConstructSection ("Private", privateHkeys) after depScript 
   if privateHkeys is not empty then
      put CR&CR&CR after depScript
      scriptSuite_Construct depScript, "Private", privateHkeys
      line_Add the result, missingHkeys
   end if
   
   if missingHkeys is not empty then
      put script_ConstructSuiteHeader ("Variables") & CR into varSuite
      put "local LocalArray" & CR&CR&CR after varSuite
      --
      put scriptDeps_ConstuctMissingGetprop (missingHkeys) into missingGetprop
      --
      put missingGetprop & CR&CR after varSuite
      put varSuite before depScript
   end if
   
   return depScript
end hkeyIndex_CollectScript

function scriptDeps_ConstuctMissingGetprop missingHkeys
   replace quote with "'" in missingHkeys
   
   # Construct hBody
   repeat for each line unQuotedHkey in missingHkeys
      put "put" && kwote (unQuotedHkey) && "after missingHkeys" & CR after hBody
   end repeat
   put "--" & CR after hBody
   put "replace" && kwote("'") && "with quote in missingHkeys" & CR after hBody
   put "return missingHkeys" after hBody
   --
   put handler_Construct ("getprop", "missing_Hkeys", hBody, false) into missingGetprop
   return missingGetprop
end scriptDeps_ConstuctMissingGetprop

command hkeyIndex_Split hKeys, @sortedHKeys, @propHandlers, @privateHkeys
   # Sort sortedHKeys
   put hKeys into sortedHKeys
   hkey_SortIndex sortedHKeys
   
   # Extract propHandlers
   put "^(G|S) .+" into wildcardPattern
   filter sortedHKeys with regex pattern wildcardPattern into propHandlers
   filter sortedHKeys without regex pattern wildcardPattern
   sort lines of propHandlers by word 2 of each
   
   # Extract privateHkeys
   filter sortedHKeys with "P*" into privateHkeys
   filter sortedHKeys without "P*"
end hkeyIndex_Split

function hkeyIndex_ConstructDepScriptArray hKeys
   hkeyIndex_Split hKeys, sortedHKeys, propHandlers, privateHkeys
   
   put array_EmptyIndex (propHandlers) into depScriptArray ["propHandlers"]
   put array_EmptyIndex (sortedHKeys) into depScriptArray ["hKeys"]
   put array_EmptyIndex (privateHkeys) into depScriptArray ["privateHkeys"]
   --
   return depScriptArray
end hkeyIndex_ConstructDepScriptArray

command display_HkeyArrayLines hkeyArray, sObject, pDisplayView
   local mTitle, mLineTitle, mUp
   --
   put the module_ExternalHkeys [hKeyArray] of sObject into hKeys
   put the short name of sObject into pTitle
   put hkeyIndex_ConstructDepScriptArray (hKeys) into depScriptArray
   
   put the project_Name of me into projectName
   -- display_Tool hKeys, pTitle, "DepScript Hkeys", projectName, "Hkey | Lines" -- crashes when resized
   display_Tool depScriptArray, pTitle, "DepScript Hkeys"
   put the result into dView
   --
   set the displayed_Object of dView to sObject
   set the hkey_Array of dView to hkeyArray
   --
   return dView
end display_HkeyArrayLines

command display_HkeyLines hkeyLines, pTitle, pDisplayView
   local mTitle, mLineTitle, mUp
   --
   put the project_Name of me into projectName
   display_Tool hkeyLines, pTitle, "DepScript Hkeys", projectName, "Hkey | Lines"
   put the result into dView
   --
   return dView
end display_HkeyLines

on mDoubleUp_HkeyLines displayView, hKeyLine
   hkey_Edit hKeyLine
end mDoubleUp_HkeyLines

command display_Index someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette, pTopLeft
   -- phase out and use "display_Lines" instead
   put empty into oRect
   --
   display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put the result into displayView 
   put token -1 of displayView into cloneStackName
   --
   put the view_StackRect [oRect] of displayView into newRect
   stack_Position cloneStackName, newRect
   --
   send "stack_Show displayView" to displayView in 2 ticks -- stops flickr
   return displayView
end display_Index

getprop display_View
   -- a lazy default
   put the displayed_Object of the target into dObject
   return dObject
end display_View

function display_View
   -- a default
   -- works with display_MenuTarget
   -- use carefully (should integrate with mArray menus)
   return LocalArray ["display_View"]
end display_View

function display_MenuTarget tObject
   -- a utility function to allow for direct of display view menus
   if exists (tObject) is false then return empty
   put the display_View of tObject into dView
   put dView into LocalArray ["display_View"]
   --
   if exists (dView) then
      put the displayed_Object of dView into linkedView
      return linkedView
   else
      return tObject
   end if
end display_MenuTarget

command display_Lines someIndex, pTitle, pDoubleUp, pStackLabel, pPalette, pTopLeft
   -- does not sort
   local pTitleMenu, pLineMenu, pMouseUp, pDragCommand
   
   if pStackLabel is empty then
      put space into pStackLabel
   else
      put comma & pStackLabel after pTitle
   end if
   --
   display_Index someIndex, pTitle, pTitleMenu, pLineMenu, pMouseUp, pDoubleUp, pDragCommand, pPalette, pTopLeft
   put the result into indexView
   --
   set the field_Style of indexView to "click"
   return indexView
end display_Lines


--> Display | Model
-
on mDoubleUp_LcwModel dView, shortModelFile
   put lcw_FetchArray (shortModelFile) into modelArray
   display_Data modelArray, shortModelFile, "LCW Model Data"
end mDoubleUp_LcwModel

command display_LcwModels
   put lcw_ListModelNames() into shortFiles
   
   display_Data shortFiles, "Lcw Models"
   put the result into displayView
   -- set the tool_MenuBit of displayView to "Lcw | Model"
   set the mouse_DoubleUp of displayView to "mDoubleUp_LcwModel"
   return displayView
end display_LcwModels

on display_LibraryData projectName
   put library_FetchProjectData() into libraryData
   
   display_Data libraryData, "libraryData", "Lcw Library"
   put the result into displayView
   --
   -- set the tool_MenuBit of displayView to "Lcw | Model"
   -- set the mouse_DoubleUp of displayView to "mDoubleUp_LcwModel"
   return displayView
end display_LibraryData


--> Props
-
getprop stack_IsDisplay
   put the stack_Name of the target into stackName
   switch
      case word 1 to 2 of stackName is not among the items of "Display Index,Display Array"
      case exists (control 1 of card 1 of stack stackName) is false
         return false
      default
         -- put the view_Name of control 1 of card 1 of stack stackName into viewName
         put the uRIP ["name"] of control 1 of card 1 of stack stackName into viewName
         --
         put "View|Tree|Widget with Title,View|Index|Simple" into displayViewNames
         if viewName is among the items of displayViewNames then
            return true
         else
            return false
         end if
   end switch
end stack_IsDisplay

getprop view_StackRect [lastStackRect]
   put the long id of the target into newViewObject
   put the formatted_Rect of newViewObject into fRect
   put the screen_Rect of newViewObject into displayScreenRect
   --
   if lastStackRect is empty then
      put stack_GetLastRect() into lastStackRect
   end if
   --
   put display_GetNewStackRect (lastStackRect, fRect, displayScreenRect) into newRect
   return newRect
end view_StackRect

getprop display_BelowRect [fRect]
   put the long id of the target into tObject
   --
   if fRect is empty then
      put the formatted_Rect of tObject into fRect
   end if
   put the rect of tObject into oRect
   put the screen_Rect of tObject into displayScreenRect
   --
   put display_GetNewStackRect (oRect, fRect, displayScreenRect) into newStackRect
   return newStackRect
end display_BelowRect

getprop stack_BelowRect [fRect]
   put the long id of the target into tObject
   put the stack_Name of the target into stackName
   --
   put the rect of stack stackName into oRect
   put the screen_Rect of tObject into displayScreenRect
   --
   if fRect is empty then
      put the formatted_Rect of tObject into fRect
      if fRect is empty then put the rect of tObject into fRect
   end if
   --
   put display_GetNewStackRect (oRect, fRect, displayScreenRect) into newStackRect
   return newStackRect
end stack_BelowRect

function stack_GetLastRect
   put line -1 of display_ListIndexStackNames() into lastIndexStackName
   if lastIndexStackName is empty then
      put stack_GetTop (true) into stackName 
      if exists (stack stackName) is false then return empty
      put the rect of stack stackName into pRect
   else
      put the rect of stack lastIndexStackName into pRect
   end if
   return pRect   
end stack_GetLastRect

function stack_GetTop pWithoutDisplay
   put the openstacks into stackList
   --
   if pWithoutDisplay is not false then
      filter stackList without "Display*"
   end if
   --
   filter stackList without "rev*"
   filter stackList without "Message Box"
   filter stackList without "com.*"
   filter stackList without "Global |*"
   sort stackList
   put line 1 of stackList into stackName
   return stackName
end stack_GetTop


--> Display | Events
-
/*
These handlers handle events from display views that are created from the code in this library.
They do not have to be here, as you can change their location by setting the "mouse_Target" property of the display_View.
*/

on mouse_EditObjectScript treeView, scriptObject
   if the optionKey is "Down" then breakpoint
   if exists (scriptObject) then
      edit the script of scriptObject
      --
      display_ScriptIsDifferent scriptObject
   end if
end mouse_EditObjectScript

on mDoubleUp_LocateDisplayView treeWidget, displayView, pathItems
   object_GoTo displayView, true
   --
   put the clickloc into sLoc
   put the globalLoc of sLoc into gLoc
   put the stack_Name of displayView into stackName
   --
   set the topleft of stack stackName to gLoc
end mDoubleUp_LocateDisplayView

command mDoubleUp_EditOldMenuScript targetObject, globalMenuCardName
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   edit the script of card globalMenuCardName of stack longStackFile
end mDoubleUp_EditOldMenuScript

on mDouble_EditStack displayView, stackName
   edit the script of stack stackName
end mDouble_EditStack

command display_SetMouseAndMenu displayView, menuBit, pLibName
   put replaceText (menuBit, " |\|", empty) into mDoubleup
   put "mDoubleUp_" before mDoubleup
   --
   display_SetInteractions displayView, menuBit, mDoubleup, pLibName
   return displayView
end display_SetMouseAndMenu


--> Display | Handler | Exports
-
command display_RecentExports pSinceMin, pIndexView, pDontFilter
   if pSinceMin is empty then
      put 60*60 into someMin
   else
      put word 1 of pSinceMin into someMin
   end if
   --
   put merge ("In last [[someMin]] minutes") into someTitle
   --
   put 60 * someMin into someSec
   put spotlight_ListRecentlyExportedObjects (someSec) into scriptObjects
   if pDontFilter is not true then
      put "Unsaved in" into word 1 of someTitle
      put script_FilterChangedIndex (scriptObjects) into scriptObjects
   else
      put "Modified in" into word 1 of someTitle
   end if
   
   display_Data scriptObjects, "Script Changes", "Script Changes"
   put the result into displayView
   display_SetInteractions displayView, "Script | Changes", "mouse_EditObjectScript"
   return displayView
end display_RecentExports


--> Display | Json
-
command display_JsonFile jsonFile, pTitle
   if pTitle is empty then put "JSON File" into pTitle
   --
   put url ("file:" & jsonFile) into sJSON
   put json_ToArray (sJSON) into sArray
   --
   _DisplayArrayOrJsonFile sArray, jsonFile, pTitle
   put the result into dView
   --
   return dView
end display_JsonFile

command display_ArrayFile sFile, pTitle
   if pTitle is empty then put "Array File" into pTitle
   --
   put array_Get (sFile) into sArray
   _DisplayArrayOrJsonFile sArray, sFile, pTitle
   put the result into dView
   --
   return dView
end display_ArrayFile


--> Display | Objects
-
function display_GetObject tObject
   -- a utility function to allow general listing of a script object
   -- whether directly from the script editor or an index or array dispayView
   
   put the display_View of tObject into displayView
   if exists (displayView) is false then return empty
   
   put the stack_Name of tObject into stackName
   switch
      case word 1 of stackName = "revNewScriptEditor"
         -- revNewScriptEditor 1
         put scriptEditor_Object() into sObject
         return sObject         
      default
         put the displayed_Object of displayView into sObject
         if exists (sObject) is false then return empty
         return sObject
   end switch
end display_GetObject

function display_GetLibObject pLibName, pLineNum
   put debug_CallingObject (2) into libObject
   if pLibName is empty then
   end if
   return libObject
end display_GetLibObject


--> Display | Specialised
-
command stack_Show displayView
   -- stops flickr
   if exists (displayView) is false then
      put the stack_Name of the target into stackName
   else
      put the the stack_Name of displayView into stackName
   end if
   show stack stackName
end stack_Show

command stack_Position stackName, pLocOrRect
   switch
      case pLocOrRect = "click"
      case pLocOrRect = "mouse"
         -- put globalLoc (the mouseloc) into mGlobalLoc
         put the screenmouseloc into mGlobalLoc
         set the topLeft of stack stackName to mGlobalLoc
         break
      case pLocOrRect is a point
         set the topLeft of stack stackName to pLocOrRect
         break
      case pLocOrRect is a rect
         set the rect of stack stackName to pLocOrRect
         break
      default
         revIDEEnsureOnscreen stackName
   end switch
end stack_Position

function display_GetNewStackRect oStackRect, fRect, displayScreenRect
   if oStackRect is not a rect then
      put 13 into oLeft
      put 41 into oBottom
   else
      put item 1 of oStackRect into oLeft
      put item 4 of oStackRect into oBottom
   end if
   
   put item 3 of fRect into newWidth
   put item 4 of fRect into newHeight
   
   put item 4 of displayScreenRect into screenBottom
   put item 3 of displayScreenRect - item 1 of displayScreenRect - 60 into maxScreenWidth
   put screenBottom - item 2 of displayScreenRect - 60 into maxScreenHeight
   
   put min (newWidth, maxScreenWidth) into newWidth
   put min (newHeight, maxScreenHeight) into newHeight
   
   put 20 into tileBarHeight
   put oLeft into newLeft
   put tileBarHeight + oBottom into newTop
   put newLeft + newWidth into newRight
   put newTop + newHeight into newBottom
   
   -- if newBottom > screenBottom then -- here we could tile it across the screen
   
   return newLeft,newTop,newRight,newBottom
end display_GetNewStackRect

function display_ConstructFoldState ePaths
   repeat for each item someKey in ePaths
      put false into foldedArray [someKey]["folded"]
   end repeat
   return foldedArray
end display_ConstructFoldState


--> Display | Edited
-
command display_EditedStacks
   put stack_ListEditedNames() into stackNames
   display_Data stackNames, "Stacks", "Edited"
   put the result into displayView
   display_SetInteractions displayView, "Edited | Tree", "mDouble_EditStack"
   return displayView
end display_EditedStacks


--> Display | Utilities
-
command display_Spin lineOrNum, pIndexView, pLineColour
   set the cursor to busy
   if exists (pIndexView) is false then
      set the cursor to busy
      return 0
   end if
   
   # Spin (works with index and array display views)
   lock screen
   if lineOrNum is a number then
      put lineOrNum into lineNum
      set the hilited_Line of pIndexView to lineNum
   else
      set the selected_Line of pIndexView to lineOrNum
      put the result into lineNum
   end if
   --
   switch pLineColour
      case "delete"
         set the deleted_Line of pIndexView to lineNum
         break
      case empty
         break
      default
         set the line_Colour [lineNum] of pIndexView to pLineColour
   end switch
   unlock screen
   return lineNum
end display_Spin


--> Display
-
command display_Files filePaths, pFolderToStrip, pMouseDoubleUpHandler, pTitleMenu, pTitle
   put empty into pPathFilter
   put file_ConstructFolderArray (filePaths, pPathFilter, pFolderToStrip) into pathArray
   if pathArray is not an array then
      answer "I cannot find this handler anywhere!"
      exit to top
   end if
   
   put debug_CallingObject (2) into pCommandObject
   display_Array pathArray, pTitle
   put the result into displayView
   
   set the title_Menu of displayView to pTitleMenu
   set the mouse_DoubleUp of displayView to pMouseDoubleUpHandler
   set the mouse_Target of displayView to pCommandObject
   --   
   set the search_Folder of displayView to pFolderToStrip
   return displayView
end display_Files

command display_TextFile someFile, pDisplayTitle, pMenuTitle, pStackName
   local pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand
   
   if pMenuTitle is empty then put "Global | Display | File | Menu" into pMenuTitle
   put "file:" & someFile into someUrl
   put url someUrl into someText
   
   put pDisplayTitle,pStackName into displayTitle
   display_Index someText, displayTitle, pMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, true
   put the result into displayView
   --
   put the stack_Name of displayView into stackName
   -- set the cantmodify of stack stackName to true
   --
   set the field_Style of displayView to "text"
   set the menu_Title of displayView to pMenuTitle
   set the displayed_File of displayView to someFile
   return displayView
end display_TextFile

command display_GlobalValue gName
   put global_GetValue (gName) into gValue
   if gValue is an array then
      put "Global:" && gName into someTitle
      display_Array gValue, someTitle, "Global | Pref | Menu"
   else
      put gValue
   end if
end display_GlobalValue

command display_JsonRPC rpcURL, pDisplayTitle, pMouseDoubleUpCommand
   -- put url rpcURL into jsonReply
   put jsonrpc_GET (rpcURL) into jsonReply 
   display_Json jsonReply, pDisplayTitle, pMouseDoubleUpCommand
   return the result
end display_JsonRPC

command display_Json jsonReply, pDisplayTitle, pMouseDoubleUpCommand
   put json_ToArray (jsonReply) into jsonArray
   switch
      case pDisplayTitle is "atom"
         atom_DisplayText jsonReply, "json"
         return empty
      case jsonArray is an array
         local pTreeMenuTitle, pLineMenuTitle, pInspectCommand, pCommandObject
         display_Array jsonArray, pDisplayTitle
         put the result into displayView
         --
         set the title_Menu of displayView to pTreeMenuTitle
         set the line_Menu of displayView to pLineMenuTitle
         set the mouse_DoubleUp of displayView to pMouseDoubleUpCommand
         set the mouse_Target of displayView to pCommandObject
         break
      default
         display_Lines jsonReply, pDisplayTitle
         break
   end switch
   put the result into displayView
   return displayView
end display_Json

command display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put "View|Index|Simple" into viewName
   
   -- new feature for specifying widget and stack label titles using a comma
   _setTitles widgetDisplayTitle, displayStackLabel, pDisplayTitle, "Index"
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Index"
   put the result into cloneStackName
   
   -- don't rely on this. It works only for handlers at the level of "display_Index"
   -- best practice is to "set the mouse_Target of indexView to debug_CallingObject()" after you call the display handler you write
   put debug_CallingObject (3) into eventArray ["eventTarget"]
   
   -- set basic data  
   put pMouseUpCommand into eventArray ["mouseUp"]
   put pMouseDoubleUpCommand into eventArray ["mouseDoubleUp"]
   put pDragCommand into eventArray ["dragCommand"]
   
   put pTreeMenuTitle into menuArray ["title"]
   put pLineMenuTitle into menuArray ["line"]
   
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   --
   if someIndex is an array then
      set the displayed_Array of displayView to someIndex
   else
      set the view_Index of displayView to someIndex
   end if
   set the view_MenuArray of displayView to menuArray
   set the view_EventArray of displayView to eventArray
   
   -- set the geometry
   -- revIdeEnsureOnscreen cloneStackName -- we use our own version?
   
   -- set the display
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to "random"
   put the result into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   
   set the label of stack cloneStackName to displayStackLabel
   set the title_Text of displayView to widgetDisplayTitle
   set the multiple_Hilites of displayView to false -- the most common default
   --
   switch pPalette
      case "system"
         set the systemWindow of stack cloneStackName to true
         break
      case false
         break
         -- case empty
         -- case true
      default
         set the style of stack cloneStackName to "palette"
   end switch
   --
   return displayView
end display_InvisibleIndex


--> Deps
-
function colour_GetDarkOrLight someColour
   put colour_RgbToHSV (someColour) into someHSV
   put item 3 of someHSV into howDark
   if howDark > 66 then
      return "10,10,10"
   else
      return "204,204,204"
   end if
end colour_GetDarkOrLight

function colour_RgbToHSV rgbColour
   -- was "rgb_2HSV"
   if rgbColour is not a color then return empty
   
   local maxv, minv, diff, s, rc, gc, bc, h
   
   put item 1 of rgbColour into r
   put item 2 of rgbColour into g
   put item 3 of rgbColour into b
   
   set the numberformat to "0.###############"
   put r / 255 into r
   put g / 255 into g
   put b / 255 into b
   put max(r,g,b) into maxv
   put min(r,g,b) into minv
   put maxv - minv into diff
   if maxv <> 0 and diff <> 0 then
      put diff / maxv into s
      put (maxv - r) / diff into rc
      put (maxv - g) / diff into gc
      put (maxv - b) / diff into bc
      if r = maxv then put bc - gc into h
      else if g = maxv then put 2 + rc - bc into h
      else if b = maxv then put 4 + gc - rc into h
      multiply h by 60
      if h < 0 then
         add 360 to h
      end if
   else
      put 0 into s
      put 0 into h
   end if
   return round(h),round(s * 100),round(maxv * 100)
end colour_RgbToHSV


--> Private
-
private function script_FilterChangedIndex scriptObjects
   repeat for each line scriptObject in scriptObjects
      set the cursor to busy
      if the script_IsDifferent of scriptObject is true then
         put scriptObject & CR after changedScriptObjects
      end if
   end repeat
   delete char -1 of changedScriptObjects
   return changedScriptObjects
end script_FilterChangedIndex


--> Private
-
private command _DisplayArrayOrJsonFile sArray, sFile, pTitle
   set the itemdelimiter to slash
   put item -1 of sFile into shortFile
   --
   display_Data sArray, shortFile, pTitle
   put the result into dView
   set the displayed_File of dView to sFile
   --
   return dView
end _DisplayArrayOrJsonFile

private function debug_CallingObject pNum
   -- need to remove reliance on the executioncontexts
   if pNum is empty then put 2 into pNum
   put (pNum + 2) * -1 into lineNum
   get the executioncontexts
   put item 1 of line lineNum of it into callingObject
   return callingObject
end debug_CallingObject

private function _MakeStackNameArrayPretty displayViewArray
   repeat for each key dStackName in displayViewArray
      put displayViewArray [dStackName]["stackLabel"] into stackLabel
      if word 1 to -1 of stackLabel is empty then
         put "Space" into stackLabel
      end if
      put displayViewArray [dStackName]["displayView"] into displayView
      put displayViewArray [dStackName]["titleText"] into titleText
      --
      put displayView into prettyArray [stackLabel][titleText]
   end repeat
   return prettyArray
end _MakeStackNameArrayPretty

private command _setTitles @widgetDisplayTitle, @displayStackLabel, pDisplayTitle, pDefault
   if pDisplayTitle is empty then
      put pDefault into widgetDisplayTitle
      put empty into displayStackLabel
   else
      put word 1 to -1 of item 1 of pDisplayTitle into widgetDisplayTitle
      put word 1 to -1 of item 2 of pDisplayTitle into displayStackLabel
   end if
end _setTitles
