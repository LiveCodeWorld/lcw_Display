script "lib_DisplayFind"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayFind
type: library
version: 0.1

/*
A library of handlers to find, list and hide and show display-views.
*/

--> Variables
-
local LocalArray


--> Working on
-
function display_List pViewNames, pStackLabel
   # List open stacks with a UX
   put stack_ListOpen() into dStackNames
   -- put revLoadedStacks ("application") into loadedStackNames
   
   # Filter
   repeat for each line dStackName in dStackNames
      get the label of stack dStackName
      if (pStackLabel is not empty) AND (it is not pStackLabel) then
         next repeat
      end if
      -- 
      if exists (control 1 of card 1 of stack dStackName) then
         put the long id of control 1 of card 1 of stack dStackName into sView
         put the view_Name of sView into testViewName
         --
         if pViewNames is empty then
            switch
               case testViewName = "View|Data"
               case testViewName begins with "View|Array|"
               case testViewName begins with "View|Index|"
               case testViewName begins with "View|Tree|"
               case testViewName begins with "View|Display|"
                  put revRuggedID (sView) & CR after foundViews
                  break
               default
                  -- get testViewName
            end switch
         else
            if testViewName is among the items of pViewNames then
               put sView & CR after foundViews
            end if
         end if
      end if
   end repeat
   delete char -1 of foundViews
   return foundViews
end display_List

function display_FindView displayStackLabel, pDisplayViewTitle, pTypes
   put revLoadedStacks ("application") into dStackNames
   filter dStackNames with "Display *"
   repeat for each line dStackName in dStackNames
      -- could check for type of view
      
      if the label of stack dStackName = displayStackLabel then
         put the long id of group 1 of stack dStackName into displayView
         if pDisplayViewTitle is empty then
            return displayView
         else if the title_Text of displayView = pDisplayViewTitle then
            return displayView
         end if
      end if
   end repeat
   return empty
   
   -- Looks for Display Array, and Display Index views depending on pTypes
   if pTypes is empty then put "Display Index,Display Array" into pTypes
   
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      get word 1 to 2 of dStackName
      if it is not among the items of pTypes then next repeat
      if the label of stack dStackName = displayStackLabel then
         put the long id of group 1 of stack dStackName into displayView
         if pDisplayViewTitle is empty then
            return displayView
         else if the title_Text of displayView = pDisplayViewTitle then
            return displayView
         end if
      end if
   end repeat
   return empty
end display_FindView

function display_GetHidden pStackName
   put display_GetHiddenArray() into stackNameArray
   if pStackName is not empty then
      delete variable stackNameArray [pStackName]
   end if
   put keys (stackNameArray) into sNames
   sort sNames
   return sNames
end display_GetHidden

function display_GetHiddenArray
   put LocalArray ["Hidden"] into stackNameArray
   return stackNameArray
end display_GetHiddenArray

command display_SetHidden pBoolean, pNotStackNames, pStackNames
   put pBoolean is false into isVisible
   if pStackNames is empty then
      put display_ListStackNames() into pStackNames
   end if
   
   repeat for each line stackName in pStackNames
      if stackName is among the items of pNotStackNames then
         next repeat
      end if
      set the visible of stack stackName to isVisible
      display_AddHidden stackName, (isVisible is false)
   end repeat
end display_SetHidden

command display_AddHidden stackName, pBoolean
   if pBoolean is false then
      delete variable LocalArray ["Hidden"][stackName]
   else
      put the loc of stack stackName into LocalArray ["Hidden"][stackName]["loc"]
      put the rect of stack stackName into LocalArray ["Hidden"][stackName]["rect"]
   end if
end display_AddHidden

command display_ShowHidden
   put display_GetHiddenArray() into stackNameArray
   repeat for each key stackName in stackNameArray
      put stackNameArray [stackName]["loc"] into stackLoc
      put stackNameArray [stackName]["rect"] into stackRect
      --
      set the rect of stack stackName to stackRect
      set the visible of stack stackName to true
   end repeat
end display_ShowHidden

command display_HideViews isHidden
   put isHidden is true into isHidden
   --
   display_SetHidden isHidden
end display_HideViews

function stack_NamesFromObjects sObjects
   repeat for each line sObject in sObjects
      put the stack_Name of sObject & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return stackNames
end stack_NamesFromObjects

command display_Gather
   put display_ListStackNames() into stackNames
   repeat for each line stackName in stackNames
      set the cursor to busy
      set the loc of stack stackName to the screenloc
      show stack stackName
   end repeat
end display_Gather


--> Display | List
-
function display_ListStackNames pSearchStackLabel, pSearchViewTitle
   if pSearchStackLabel is empty then
      put display_List() into dViews
      put stack_NamesFromObjects (dViews) into stackNames
      return stackNames
   end if
   
   # Old way?
   put display_FindStackNameArray (pSearchStackLabel, pSearchViewTitle) into displayViewArray
   --
   put keys (displayViewArray) into displayStackNames
   sort displayStackNames
   return displayStackNames
end display_ListStackNames

function display_ListViews pSearchStackLabel, pSearchViewTitle
   put display_FindStackNameArray (pSearchStackLabel, pSearchViewTitle) into displayViewArray
   repeat for each key stackLabel in displayViewArray
      put displayViewArray [stackLabel]["displayView"] into dView
      put dView & CR after displayViews
   end repeat
   delete char -1 of displayViews
   return displayViews
end display_ListViews

function display_ListIndexStackNames
   put the openstacks into indexStackNames
   -- filter indexStackNames with "Display Index *"
   sort indexStackNames by word -1 of each
   return indexStackNames
end display_ListIndexStackNames


--> Display | Find | One
-
function display_FindCloned vName, displayStackLabel, pDisplayViewTitle
   -- only one
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      put the label of stack dStackName into testLabel
      if testLabel = displayStackLabel then
         if exists (control 1 of stack dStackName) is false then next repeat
         put the long id of control 1 of stack dStackName into dView
         
         put the view_Name of dView into testViewName
         put the title_Text of dView into testTitle 
         --
         switch
            case testViewName is not vName
               next repeat
            case testTitle = pDisplayViewTitle
            case pDisplayViewTitle is empty
               return dView
            default
               next repeat
         end switch
      end if
   end repeat
   return empty
end display_FindCloned

function display_FindStackNameArray pSearchStackLabel, pSearchViewTitle, pPretty
   -- looks for Dispay Array, and Display Index views
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      get word 1 to 2 of dStackName
      if it is not among the items of "Display Index,Display Array" then next repeat
      
      put the long id of group 1 of stack dStackName into displayView
      --
      put the title_text of displayView into titleText
      put the label of stack dStackName into stackLabel
      
      -- skip unless the following conditions are met
      if pSearchStackLabel is empty then
         put displayView into displayViewArray [dStackName]["displayView"]
         put stackLabel into displayViewArray [dStackName]["stackLabel"]
         put titleText into displayViewArray [dStackName]["titleText"]
      else if stackLabel = pSearchStackLabel then
         if pSearchViewTitle is empty then
            put displayView into displayViewArray [dStackName]["displayView"]
            put stackLabel into displayViewArray [dStackName]["stackLabel"]
            put titleText into displayViewArray [dStackName]["titleText"]
         else if titleText = pSearchViewTitle then
            put displayView into displayViewArray [dStackName]["displayView"]
            put stackLabel into displayViewArray [dStackName]["stackLabel"]
            put titleText into displayViewArray [dStackName]["titleText"]
         end if
      end if
   end repeat
   --
   if pPretty is true then
      put _MakeStackNameArrayPretty (displayViewArray) into prettyArray
      return prettyArray
   else
      return displayViewArray
   end if
end display_FindStackNameArray


--> Display | Find
-
function display_ViewExists displayStackLabel, pDisplayViewTitle
   put display_FindView (displayStackLabel, pDisplayViewTitle) into displayView
   put exists (displayView) into displayViewExists
   return displayViewExists
end display_ViewExists

function display_FindProjectView projectName
   -- this is the new array based view
   put display_FindView ("Project", projectName) into displayView
   return displayView
end display_FindProjectView

function display_FindArrayView displayStackLabel, pDisplayViewTitle
   return display_FindView (displayStackLabel, pDisplayViewTitle, "Display Array")
end display_FindArrayView

function display_FindIndexView displayStackLabel, pDisplayViewTitle
   return display_FindView (displayStackLabel, pDisplayViewTitle, "Display Index")
end display_FindIndexView

function display_FirstOpenView viewName, pStackLabel, pViewTitle
   view_NormalizeName viewName
   put "|" after viewName
   --
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      # Check exists
      if exists (control 1 of card 1 of stack dStackName) is false then next repeat
      put the long id of control 1 of card 1 of stack dStackName into displayView
      put _ViewName (displayView) into testViewName
      put "|" after testViewName
      
      # Check viewName is stem of text view name
      if testViewName begins with viewName is false then next repeat
      
      # Refine test
      put the label of stack dStackName into stackLabel
      if stackLabel is empty then
         put dStackName into stackLabel
      end if
      switch
         case pStackLabel is empty
            return displayView
         case stackLabel begins with pStackLabel
            if pViewTitle is empty then
               return displayView
            else if the title_Text of displayView = pViewTitle then
               return displayView
            else
               next repeat
            end if
         default
            -- next repeat
      end switch
   end repeat
   return empty
end display_FirstOpenView

function display_FindStackNameArray pSearchStackLabel, pSearchViewTitle, pPretty
   -- looks for Dispay Array, and Display Index views
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      get word 1 to 2 of dStackName
      if it is not among the items of "Display Index,Display Array" then next repeat
      
      put the long id of group 1 of stack dStackName into displayView
      --
      put the title_text of displayView into titleText
      put the label of stack dStackName into stackLabel
      
      -- skip unless the following conditions are met
      if pSearchStackLabel is empty then
         put displayView into displayViewArray [dStackName]["displayView"]
         put stackLabel into displayViewArray [dStackName]["stackLabel"]
         put titleText into displayViewArray [dStackName]["titleText"]
      else if stackLabel = pSearchStackLabel then
         if pSearchViewTitle is empty then
            put displayView into displayViewArray [dStackName]["displayView"]
            put stackLabel into displayViewArray [dStackName]["stackLabel"]
            put titleText into displayViewArray [dStackName]["titleText"]
         else if titleText = pSearchViewTitle then
            put displayView into displayViewArray [dStackName]["displayView"]
            put stackLabel into displayViewArray [dStackName]["stackLabel"]
            put titleText into displayViewArray [dStackName]["titleText"]
         end if
      end if
   end repeat
   --
   if pPretty is true then
      put _MakeStackNameArrayPretty (displayViewArray) into prettyArray
      return prettyArray
   else
      return displayViewArray
   end if
end display_FindStackNameArray


--> Stack | List
-
function stack_ListNames pWhichOrFilter
   switch pWhichOrFilter
      case empty
         return stack_ListOpen()
      case "open"
         return the openstacks
      case "loaded"
         return revLoadedStacks ("application")
      default
         -- assume it is a filter for "loaded"
         put revLoadedStacks ("application") into stackNames
         filter stackNames with pWhichOrFilter
         return stackNames
   end switch
end stack_ListNames

function stack_ListNamedViews nameStem
   put stack_FindNames (nameStem) into sNames
   repeat for each line sName in sNames
      if exists (control 1 of card 1) is false then next repeat
      --
      put the long id of control 1 of card 1 of stack sName into sView
      put revRuggedId (sView) & CR after namedViews
   end repeat
   return namedViews
end stack_ListNamedViews

function stack_FindNames nameStem
   -- could use filter
   put revLoadedStacks ("application") into loadedStackNames
   repeat for each line stackName in loadedStackNames
      if stackName begins with nameStem then
         put stackName & CR after foundStackNames
      end if
   end repeat
   delete char -1 of foundStackNames
   return foundStackNames
end stack_FindNames

function stack_ListOpen
   put the openstacks into stackNames
   repeat for each line stackName in stackNames
      switch
         case stackName = "Message Box"
         case char 1 to 3 of stackName = "rev"
         case char 1 to 4 of stackName = "com."
         case the scriptonly of stack stackName is true
            next repeat
         default
            put stackName & CR after appStackNames
      end switch
   end repeat
   delete char -1 of appStackNames
   return appStackNames
end stack_ListOpen

function stack_ListLabeled sLabel
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      if the label of stack dStackName = sLabel then
         put dStackName & CR after foundStackNames
      end if
   end repeat
   delete char -1 of foundStackNames
   return foundStackNames
end stack_ListLabeled

function stack_FindNameData pSearchStackLabel, pTestProperty
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      if pTestProperty is not empty then
         if the pTestProperty of stack dStackName is not empty then
            next repeat
         end if
      end if
      
      put the label of stack dStackName into stackLabel
      switch
         case pSearchStackLabel is empty
         case stackLabel = pSearchStackLabel
            if word 1 to -1 of stackLabel is empty then put "Space" into stackLabel
            put displayView into stackNameData [dStackName]["displayView"]
            put stackLabel into stackNameData [dStackName]["stackLabel"]
            --
            if pTestProperty is not empty then
               put pTestProperty into stackNameData [dStackName]["prop"][pTestProperty]
            end if
            break
         default
            -- next repeat
      end switch
   end repeat
   return stackNameData
end stack_FindNameData

function stack_FindNameData pSearchStackLabel, pTestProperty
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      if pTestProperty is not empty then
         if the pTestProperty of stack dStackName is not empty then
            next repeat
         end if
      end if
      
      put the label of stack dStackName into stackLabel
      switch
         case pSearchStackLabel is empty
         case stackLabel = pSearchStackLabel
            if word 1 to -1 of stackLabel is empty then put "Space" into stackLabel
            put displayView into stackNameData [dStackName]["displayView"]
            put stackLabel into stackNameData [dStackName]["stackLabel"]
            --
            if pTestProperty is not empty then
               put pTestProperty into stackNameData [dStackName]["prop"][pTestProperty]
            end if
            break
         default
            -- next repeat
      end switch
   end repeat
   return stackNameData
end stack_FindNameData

function stack_FindNames nameStem
   -- could use filter
   put revLoadedStacks ("application") into loadedStackNames
   repeat for each line stackName in loadedStackNames
      if stackName begins with nameStem then
         put stackName & CR after foundStackNames
      end if
   end repeat
   delete char -1 of foundStackNames
   return foundStackNames
end stack_FindNames


--> Private
-
private function _ViewName tObject
   if the uRIP ["type"] of tObject is not "view" then return empty
   put the uRIP ["name"] of tObject into viewName
   return viewName
end _ViewName
