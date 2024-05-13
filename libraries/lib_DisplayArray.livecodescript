script "lib_DisplayArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayArray
type: library
version: 0.3

/*
This library is designed to work with the index and array view to display data.
It tries to use the array view to displlay lines in some instances
but uses "display_Lines" for simple display of lines.

We probably want to bring these together into one view with the ability to display in a vield or a tree widget.
*/

--> Variables
-
constant ArrayViewName = "View|Tree|Widget with Title"


--> Working on
-
command ask_CreateMouseDoubleUpHandler mDoubleUp, titleController
   put "M" && mDoubleUp into shortHKey
   put the found_Hkey [shortHKey] of titleController is not empty into handlerExists
   if handlerExists is true then return empty
   
   put "on" && mDoubleUp into mDoubleUpHandler
   put space & "displayView, someLine" after mDoubleUpHandler
   put CR & "    breakpoint" after mDoubleUpHandler
   put CR & "    put the title_Text of displayView into someTitle" after mDoubleUpHandler
   put CR & "end" && mDoubleUp after mDoubleUpHandler
   --
   display_Handler mDoubleUp, mDoubleUpHandler, "DoubleUp Handler"
   put the result into indexView
   return indexView
end ask_CreateMouseDoubleUpHandler


--> Display | Tools
-
command display_Tools someData, pTitle, pToolPath, pStackLabel, pProjectName, pPalette, pTopLeft, pFoldedArray
   # Display data depending on ducktyping of content
   display_Data someData, pTitle, pStackLabel, "", pPalette, pTopLeft, pFoldedArray
   put the result into displayView
   
   # Set menus and mouse_DoubleUp
   set the data_MenuBit [pProjectName] of displayView to pToolPath
   return displayView
end display_Tools

command display_SetToolMenus menuBit, dView, pProjectName
   get "Global |" && menuBit
   put it && "| Menu" into titleMenu
   put it && "| Line | Menu" into lineMenu
   --
   replace "|" with empty in menuBit
   replace space with empty in menuBit
   put "mDoubleUp_" & menuBit into pDoubleUp
   
   # Create menus if needed
   if there is a stack pProjectName then
      put the name of stack pProjectName into libObject
   else
      -- breakpoint -- remove reliance on the executioncontexts
      put debug_CallingObject(2) into libObject
   end if
   ask_CreateMenuFromObject titleMenu, libObject
   ask_CreateMenuFromObject lineMenu, libObject
   
   # Create mDoubleUp handler if needed
   put menu_GetGlobalController (titleMenu) into mController
   ask_CreateMouseDoubleUpHandler pDoubleUp, mController
   set the mouse_Target of dView to mController
   
   # Set menus and mouse
   set the title_Menu of dView to titleMenu
   set the line_Menu of dView to lineMenu
   set the mouse_DoubleUp of dView to pDoubleUp
   --
   return it
end display_SetToolMenus


--> Display | Data
-
command display_Data someContent, pTitle, pStackLabel, pDisplayView, pPalette, pTopLeft, pFoldedArray
   lock screen
   if someContent is an array then      
      display_Array someContent, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
      put the result into pDisplayView
   else
      _NormalizeView pDisplayView, pStackLabel, pTitle
      
      if exists (pDisplayView) then
         set the displayed_Index [pTitle] of pDisplayView to someContent
         if pStackLabel is not empty then
            put the stack_Name of pDisplayView into stackName
            set the label of stack stackName to pStackLabel
         end if
      else
         display_Lines someContent, pTitle, empty, pStackLabel, pPalette, pTopLeft
         put the result into pDisplayView
      end if
   end if
   unlock screen
   --
   -- object_GoTo pDisplayView
   return pDisplayView
end display_Data

private command _NormalizeView @pDisplayView, pStackLabel, pTitle
   if exists (pDisplayView) is false then
      switch
         case someContent is empty
            put display_FindView (pStackLabel, pTitle) into pDisplayView
            break
         case someContent is an array
            put display_FirstOpenView ("Tree", pStackLabel, pTitle) into pDisplayView
            -- put display_FindView (pStackLabel, pTitle, "Display Array") into pDisplayView
            break
         default
            put display_FirstOpenView ("Index", pStackLabel, pTitle) into pDisplayView
            -- put display_FindView (pStackLabel, pTitle, "Display Index") into pDisplayView
      end switch
   end if
end _NormalizeView

private command _NormalizeArrayView @pDisplayView, @pFoldedArray, pStackLabel, pTitle
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
end _NormalizeArrayView


--> Display | Array
-
command display_Array sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   _NormalizeArrayView pDisplayView, pFoldedArray, pStackLabel, pTitle
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
   else
      _CreateInvisibleData sArray, pTitle, pStackLabel, pFoldedArray, pPalette
      put the result into pDisplayView
   end if
   return pDisplayView
end display_InvisibleArray


--> Display | FindView
-
function display_ViewExists displayStackLabel, pDisplayViewTitle
   put display_FindView (displayStackLabel, pDisplayViewTitle) into displayView
   put exists (displayView) into displayViewExists
   return displayViewExists
end display_ViewExists

function display_FindArrayView displayStackLabel, pDisplayViewTitle
   return display_FindView (displayStackLabel, pDisplayViewTitle, "Display Array")
end display_FindArrayView

function display_FindIndexView displayStackLabel, pDisplayViewTitle
   return display_FindView (displayStackLabel, pDisplayViewTitle, "Display Index")
end display_FindIndexView


--> Private
-
private command _CreateInvisibleData someArray, pDisplayTitle, pStackLabel, pFoldedArray, pLocOrRect, pPalette
   put ArrayViewName into viewName
   if pDisplayTitle is empty then put "Array" into pDisplayTitle
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Array"
   put the result into cloneStackName
   if exists (stack cloneStackName) is false then return empty
   
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   --
   set the displayed_Data of displayView to someArray
   if pFoldedArray is an array then
      -- sensitive to capitalisation
      set the fold_State of displayView to pFoldedArray
   end if
   
   -- custom stuff
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to "random"
   put the result into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   --
   if line 1 of keys (someArray) is a number then
      set the tree_SortType of displayView to "numeric"
   end if
   --
   set the title_Text of displayView to pDisplayTitle
   if pStackLabel is not empty then
      set the label of stack cloneStackName to pStackLabel
   end if
   --
   stack_Position cloneStackName, pLocOrRect
   --
   stack_SetStyle cloneStackName, pPalette
   --
   return displayView
end _CreateInvisibleData

private command stack_SetStyle cloneStackName, pPalette
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
end stack_SetStyle
