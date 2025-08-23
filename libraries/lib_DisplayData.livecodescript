script "lib_DisplayData"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayData
type: library
version: 0.8
deps: module "View|Data"

/*
This stack should contain all teh required code for displaying data using teh "View|Data" module.
I think it shoud be either a behavior of or part of teh stack script which is now a library?
*/

--> Working on
-
getprop walk_Hierarchy
   put the name of stack "View|Data" into searchObjects
   --
   put CR & the name of stack "lib_MenuPop" after searchObjects
   put CR & the name of stack "lib_MenuText" after searchObjects
   --
   put CR & the name of stack "behavior_ViewData" after searchObjects
   put CR & the name of stack "behavior_DataTree" after searchObjects
   put CR & the name of stack "behavior_ViewDataPoly" after searchObjects
   put CR & the name of stack "behavior_ViewIndex" after searchObjects
   --
   return searchObjects
end walk_Hierarchy

getprop dep_Array
   put "View|Data" into depArray ["props"]["View|Data"]
end dep_Array

command display_Script newScript, pTitle
   display_Text newScript, pTitle
   -- display_Lines newscript, pTitle
   put the result into dView
   -- set the field_Style of dView to "text"
   return dView
end display_Script

command display_Text textOrUrl, pDisplayTitle, pStackLabel, pDisplayView, pPalette
   local textURL
   switch
      case char 1 of textOrUrl = "/"
         put textOrUrl into textFile
         -- put url ("file:" & textFile) into someText
         put url ("binfile:" & textFile) into utf8Text
         put textDecode (utf8Text, "UTF-8") into someText
         break
      case textOrUrl begins with "file:///"
         delete char 6 to 7 of textOrUrl
      case textOrUrl begins with "file:"
      case textOrUrl begins with "binfile:"
      case textOrUrl begins with "http:"
      case textOrUrl begins with "https:"
         put textOrUrl into textURL
         put url textURL into someText
         break
      case pDisplayTitle is "atom"
         breakpoint
         put textOrUrl into someText
         -- atom_DisplayText someText
         return the result
      default
         put textOrUrl into someText
   end switch
   
   display_Data someText, pDisplayTitle, pStackLabel, pDisplayView, pPalette
   put the result into indexView
   set the field_Style of indexView to "text"
   --
   switch
      case textURL is not empty
         set the uOPN ["displayed_URL"] of indexView to textURL
         break
      case textFile is not empty
         set the uOPN ["displayed_File"] of indexView to textFile
         break
   end switch
   --
   return indexView
end display_Text

command display_EnvironmentToggle
   put display_FindCloned ("View|Data", "Environment") into dView
   if exists (dView) then
      put the stack_Name of dView into sName
      put the visible of stack sName into isViz
      set the visible of stack sName to (isViz is false)
   else
      display_Environment
   end if
end display_EnvironmentToggle

command display_Environment pRefreshOnly, pProjectNames
   put display_FindView ("Environment") into dView
   --
   if pRefreshOnly is true AND dView is empty then return empty -- display is not open so do nothing
   if pProjectNames is empty then
      put env_ListLocalProjects() into pProjectNames
   end if
   
   lock screen
   --
   if exists (dView) is false then
      display_Tool pProjectNames, "Local Projects", "Environment", "simple", "40,80"
      put the result into dView
      --
      set the tool_Context of dView to "lcw_Tools"
      -- set the drop_Command of dView to empty
      -- set the field_Style of indexView to "click"
   else
      set the index_Data ["Local Projects"] of dView to pProjectNames
      stack_Show dView
   end if
   --
   put the index_View of dView into indexView
   if exists (indexView) then
      put env_ListStoppedProjects() into stoppedProjects
      set the coloured_Lines ["red"] of indexView to stoppedProjects
   end if
   unlock screen
   --
   return dView
end display_Environment


--> Display | Data
-
command display_Data sData, pTitle, pStackLabel, pDisplayView, pPalette, pTopLeft, pFoldedArray
   lock screen
   if sData is an array then      
      display_Array sData, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
      put the result into pDisplayView
   else
      if exists (pDisplayView) is false then
         switch
            case someContent is empty
               put display_FindView (pStackLabel, pTitle) into pDisplayView
               break
            case someContent is an array
               put display_FirstOpenView ("Tree", pStackLabel, pTitle) into pDisplayView
               break
            default
               put display_FirstOpenView ("Index", pStackLabel, pTitle) into pDisplayView
         end switch
      end if
      
      if exists (pDisplayView) then
         set the displayed_Index [pTitle] of pDisplayView to sData
         if pStackLabel is not empty then
            put the stack_Name of pDisplayView into stackName
            set the label of stack stackName to pStackLabel
         end if
      else
         display_Lines sData, pTitle, empty, pStackLabel, pPalette, pTopLeft
         put the result into pDisplayView
      end if
   end if
   unlock screen
   --
   object_GoTo pDisplayView, true
   return pDisplayView
end display_Data

command display_Array sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   if exists (pDisplayView) is true then
      -- assumes we do not want to change the folded state
      put empty into pFoldedArray
   else
      put display_FindView (pStackLabel, pTitle, "Display Array") into pDisplayView
      if exists (pDisplayView) is true then
         -- assumes we do not want to change the folded state
         put empty into pFoldedArray
      else
         -- change the foldState
      end if
   end if
   --
   display_InvisibleArray sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   put the result into displayView
   if exists (displayView) is false then return empty
   --
   put the stack_Name of displayView into stackName
   show stack stackName
   return displayView
end display_Array

command display_InvisibleArray sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pTopLeft, pPalette
   if exists (pDisplayView) then
      set the displayed_Array [pTitle] of pDisplayView to sArray
      if pFoldedArray is an array then set the fold_State of pDisplayView to pFoldedArray
      if pStackLabel is not empty then
         put the stack_Name of pDisplayView into stackName
         set the label of stack stackName to pStackLabel
      end if
      return pDisplayView
   else
      -- _CreateInvisibleData sArray, pTitle, pStackLabel, pFoldedArray, pPalette
      -- private command _CreateInvisibleData sArray, pTitle, pStackLabel, pFoldedArray, pLocOrRect, pPalette
      constant ArrayViewName = "View|Data"
      
      put ArrayViewName into viewName
      if pTitle is empty then put "Array" into pTitle
      
      # Clone invisible
      stack_CloneInvisible viewName, "Display Array"
      put the result into cloneStackName
      if exists (stack cloneStackName) is false then return empty
      
      # Hack for displayView (update)
      put the long id of cd 1 of stack cloneStackName into firstCard
      put the long id of control 1 of firstCard into displayView
      --
      set the displayed_Array [pTitle] of displayView to sArray
      if pFoldedArray is an array then
         set the fold_State of displayView to pFoldedArray -- sensitive to capitalisation
      end if
      
      # Title Colour
      display_SetTitleColour displayView
      --
      if line 1 of keys (sArray) is a number then
         set the tree_SortType of displayView to "numeric"
      end if
      --
      set the title_Text of displayView to pTitle
      if pStackLabel is not empty then
         set the label of stack cloneStackName to pStackLabel
      end if
      
      # Set position and style
      -- stack_Position cloneStackName, pTopLeft
      -- stack_SetStyle cloneStackName, pPalette
      --
      return displayView
   end if
end display_InvisibleArray

command display_Lines sIndex, pTitle, pDoubleUp, pStackLabel, pPalette, pTopLeft
   local pTitleMenu, pLineMenu, pMouseUp, pDragCommand
   
   if pStackLabel is empty then
      put space into pStackLabel
   else
      put comma & pStackLabel after pTitle
   end if
   
   # Clone Invisible and set index
   display_InvisibleIndex sIndex, pTitle, pStackLabel, pPalette
   put the result into dataView 
   put token -1 of dataView into cStackName
   
   put the index_View of dataView into indexView
   set the field_Style of indexView to "click"
   
   # Set Rect
   -- put the view_StackRect [oRect] of dataView into newRect
   -- stack_Position cStackName, newRect
   
   # Show
   -- send "stack_Show dataView" to dataView in 2 ticks -- stops flickr
   stack_Show dataView
   --
   return indexView
end display_Lines

command display_InvisibleIndex sIndex, pTitle, pLabel, pPalette
   # Clone invisible
   stack_CloneInvisible "View|Data", "Display Index"
   put the result into cStackName   
   put the long id of control 1 of cd 1 of stack cStackName into dView
   
   # Data
   set the displayed_Data [pTitle] of dView to sIndex
   
   # Set Geometry
   set the card_Margin of dView to 0
   -- revIdeEnsureOnscreen cStackName
   
   # Set Title Colour
   set the title_Colour of dView to "random"
   put the result into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of dView to titleTextColour
   
   set the label of stack cStackName to pLabel
   set the title_Text of dView to pTitle
   set the multiple_Hilites of dView to false
   --
   switch pPalette
      case "system"
         set the systemWindow of stack cStackName to true
         break
      case false
         break
      default
         set the style of stack cStackName to "palette"
   end switch
   --
   return dView
end display_InvisibleIndex

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

function display_ListIndexStackNames
   put the openstacks into indexStackNames
   -- filter indexStackNames with "Display Index *"
   sort indexStackNames by word -1 of each
   return indexStackNames
end display_ListIndexStackNames

command display_SetTitleColour displayView, pTitleColour
   if pTitleColour is empty then put "random" into pTitleColour
   
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to pTitleColour
   put the result into titleColour
   
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   return titleColour
end display_SetTitleColour


--> Deps | display_Environment
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

command display_InvisibleTool someData, pTitle, pStackLabel, pFoldedArray, pStyle
   constant ArrayViewName = "View|Data"
   
   # Clone name
   put stack_CleanName ("Display" && pTitle) into cloneName
   
   # Ducktype
   put someData is an array into isArray
   put there is a stack cloneName into stackExisted
   
   # Display data
   if stackExisted then
      put cloneName into cloneStackName
   else
      stack_CloneInvisible ArrayViewName, cloneName
      put the result into cloneStackName
      if pStackLabel is not empty then
         set the label of stack cloneStackName to pStackLabel
      end if
      
      # Default stack style
      set the style of stack cloneStackName to "palette"
   end if
   
   if exists (control 1 of cd 1 of stack cloneStackName) then
      put the long id of control 1 of cd 1 of stack cloneStackName into dView
   else
      breakpoint
      show stack cloneStackName
      go to stack cloneStackName
      return "Error, could not find dView:" && cloneStackName
   end if
   
   # ShowHow
   if pStyle is not empty then
      set the dataView_Style of dView to pStyle
   end if
   
   # Display And Show
   if isArray is true then
      set the displayed_Data [pTitle] of dView to someData
      if pFoldedArray is an array then
         set the fold_State of dView to pFoldedArray
      end if
   else
      set the displayed_Data [pTitle] of dView to someData
      --
      put the index_View of dView into indexView
      set the field_Style of indexView to "click"
      set the drop_Command of indexView to empty
   end if
   
   # Title Colour
   display_SetTitleColour dView
   
   return dView
end display_InvisibleTool

command display_StandardTool someData, pTitle, pStackLabel, pStyle, pRectHow, pFoldedArray, pToolContext
   display_InvisibleTool someData, pTitle, pStackLabel, pFoldedArray, pStyle
   put the result into dView
   
   if pFoldedArray is an array then
      -- pFoldedArray
   end if
   
   if someData is not an array then
      put the formatted_Rect [pRectHow] of dView into sRect
      set the stack_Rect of dView to sRect
   end if
   
   # Show
   put the stack_Name of dView into cStackName
   set the visible of stack cStackName to true
   
   if someData is an array then
      # Livecode bug
      -- doing this after show as formatted values and tree widget issue
      -- could set offscreen?
      wait 1 ticks
      put the formatted_Rect [pRectHow] of dView into sRect
      set the stack_Rect of dView to sRect
   end if
   
   set the tool_Context of dView to pToolContext
   return dView
end display_StandardTool

command display_Tool someData, pTitle, pStackLabel, pStyle, pRectHow, pToolContext, pFoldedArray
   if pTitle is empty then put "Data" into pTitle
   --
   display_StandardTool someData, pTitle, pStackLabel, pStyle, pRectHow, pFoldedArray, pToolContext
   put the result into dView
   
   if exists (dView) is false then
      breakpoint
      return empty
   end if
   
   # Guess menuBit from pStackLabel
   if pStackLabel is empty then
      put menu_Bit (pTitle) into pToolPath
      breakpoint
   else
      put pStackLabel into pToolPath
      replace space with " | " in pToolPath
   end if
   
   # Set menus and doubleClick_Message
   set the menu_TitleBit [pProjectName] of dView to pToolPath
   
   return dView
end display_Tool
