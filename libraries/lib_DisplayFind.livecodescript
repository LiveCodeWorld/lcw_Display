script "lib_DisplayFind"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayFind
type: library
version: 0.1

/*Some help*/


--> Working on
-

--> Stack | List
-
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

function stack_ListNames pStackNames
   switch pStackNames
      case empty
         return stack_ListOpen()
      case "open"
         return the openstacks
      case "loaded"
         return revLoadedStacks ("application")
      default
         -- could check they exist
         return pStackNames
   end switch
end stack_ListNames


--> Display | Find | One
-
function display_FindCloned vName, displayStackLabel, pDisplayViewTitle
   -- only one
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      if the label of stack dStackName = displayStackLabel then
         if exists (control 1 of stack dStackName) is false then next repeat
         put the long id of control 1 of stack dStackName into dView
         --
         switch
            case the view_Name of dView is not vName
               next repeat
            case the title_Text of dView = pDisplayViewTitle
            case displayStackLabel is empty
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

function display_FindView displayStackLabel, pDisplayViewTitle, pTypes
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

function display_FirstOpenView viewName, pStackLabel, pViewTitle
   view_NormalizeName viewName
   put "|" after viewName
   --
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      # Check exists
      if exists (control 1 of card 1 of stack dStackName) is false then next repeat
      put the long id of control 1 of card 1 of stack dStackName into displayView
      put the view_Name of displayView into testViewName
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



--> Deps
-
