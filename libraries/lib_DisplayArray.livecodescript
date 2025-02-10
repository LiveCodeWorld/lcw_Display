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
private function _DisplayView cloneStackName
   put the long id of cd 1 of stack cloneStackName into firstCard
   
   -- hacky (change to view_Object or displayed_Object of card?)
   put the long id of control 1 of firstCard into displayView
   return displayView
end _DisplayView

command display_SetInteractions displayView, menuBit, pDoubleUp, pLibName
   -- old use "set the tool_MenuBit of dView"
   put "Global |" && menuBit && "| Menu" into titleMenu
   put "Global |" && menuBit && "| Line | Menu" into lineMenu
   --
   set the title_Menu of displayView to titleMenu
   set the line_Menu of displayView to lineMenu
   --
   -- put display_GetLibObject (pLibName, 2) into libObject
   ask_CreateMenuFromObject titleMenu, pLibName
   ask_CreateMenuFromObject lineMenu, pLibName
   --
   set the mouse_DoubleUp of displayView to pDoubleUp
   if pDoubleUp is empty then return displayView
   
   -- put menu_GetGlobalController (titleMenu) into titleController
   put menu_GetGlobalController (lineMenu) into lineController
   if exists (lineController) then
      set the mouse_Target of displayView to lineController
      -- ask_CreateMouseDoubleUpHandler pDoubleUp, displayView
   end if
   return displayView
end display_SetInteractions


--> Old
-
command display_SetToolMenus menuBit, dView, pLibName
   -- old
   get "Global |" && menuBit
   put it && "| Menu" into titleMenu
   put it && "| Line | Menu" into lineMenu
   --
   replace "|" with empty in menuBit
   replace space with empty in menuBit
   put "mDoubleUp_" & menuBit into pDoubleUp
   
   # Create menus if needed
   ask_CreateMenuFromObject titleMenu, pLibName
   ask_CreateMenuFromObject lineMenu, pLibName
   
   # Create mDoubleUp handler if needed
   put menu_GetGlobalController (titleMenu) into mController
   ask_CreateMouseDoubleUpHandler pDoubleUp, dView
   set the mouse_Target of dView to mController
   
   # Set menus and mouse
   set the title_Menu of dView to titleMenu
   set the line_Menu of dView to lineMenu
   set the mouse_DoubleUp of dView to pDoubleUp
   --
   return it
end display_SetToolMenus

command display_SetMenu displayView, gMenuTitle, pMenuProp, pLibName
   -- put word 1 to -1 of gMenuTitle into gMenuTitle
   if not (gMenuTitle begins with "Global | ") then 
      put "Global | " before gMenuTitle
   end if
   if not (gMenuTitle ends with " | Menu") then 
      put  " | Menu" after gMenuTitle
   end if
   --
   if pMenuProp is empty then put "menu_Title" into pMenuProp
   --
   set the pMenuProp of displayView to gMenuTitle
   ask_CreateMenuFromObject gMenuTitle, pLibName
   --
   return libObject
end display_SetMenu


--> Working on
-
command ask_CreateMouseDoubleUpHandler mDoubleUp, pDisplayView
   # Create mDoubleUp handler if needed 
   -- should set up menu to make it easy to find scripts
   
   if exists (pDisplayView) is false then
      put the display_View of the target into pDisplayView
      if exists (pDisplayView) is false then
         return "Error, cannot locate the display_View of the target:" && the params
      end if
   end if
   
   put the mouse_DoubleUp of pDisplayView into mDoubleUp
   put the mouse_Target of pDisplayView into mTarget
   if exists (mTarget) is false then
      put pDisplayView into mTarget
   end if
   --
   put "M" && mDoubleUp into shortHKey
   put the found_Hkey [shortHKey] of mTarget into foundHkey
   if foundHkey is not empty then
      lcw_Answer "Found existing double-click handler - [[var]]. Do you want to edit it?", pDisplayView, foundHkey
      hkey_Edit foundHkey
      return empty
   else
      put display_ConstructDoubleUpHandler (mDoubleUp) into mDoubleUpHandler
      display_Handler mDoubleUp, mDoubleUpHandler, "DoubleUp Handler"
      put the result into indexView
      --
      set the displayed_MouseTarget of indexView to mTarget
      set the displayed_MouseDoubleUp of indexView to mDoubleUp
      --
      edit the script of mTarget
      return indexView
   end if
end ask_CreateMouseDoubleUpHandler

function display_ConstructDoubleUpHandler mDoubleUp
   put "on" && mDoubleUp into mDoubleUpHandler
   put space & "displayView, someLine" after mDoubleUpHandler
   put CR & "    breakpoint" after mDoubleUpHandler
   put CR & "    put the title_Text of displayView into someTitle" after mDoubleUpHandler
   put CR & "end" && mDoubleUp after mDoubleUpHandler
   --
   return mDoubleUpHandler
end display_ConstructDoubleUpHandler


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
   object_GoTo pDisplayView, true
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


--> Private
-
command display_CloneInvisible pTitle, pStackLabel
   # Clone invisible
   stack_CloneInvisible "View|Tree|Widget with Title", "Display Array"
   put the result into stackName
   put display_ViewFromStackName (stackName) into dView
   
   # Title and stack label
   display_SetTitleAndLabel dView, pTitle, pStackLabel
   
   # Colour, styyle and position
   display_ColourTitle dView
   --
   return dView
end display_CloneInvisible

function display_ViewFromStackName cloneStackName
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   return displayView
end display_ViewFromStackName

command display_SetTitleAndLabel dView, pTitle, pStackLabel
   # Title
   if pTitle is empty then put "Array" into pTitle
   set the title_Text of dView to pTitle
   
   # Label
   if pStackLabel is not empty then
      put the stack_Name of dView into cloneStackName
      set the label of stack cloneStackName to pStackLabel
   end if
end display_SetTitleAndLabel

command display_ColourTitle dView
   set the card_Margin of dView to 0
   set the title_Colour of dView to "random"
   put the result into titleColour
   --
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of dView to titleTextColour
   return titleColour
end display_ColourTitle


--> Old | Create Invisible
-
private command _CreateInvisibleData someArray, pTitle, pStackLabel, pFoldedArray, pLocOrRect, pPalette
   put ArrayViewName into viewName
   if pTitle is empty then put "Array" into pTitle
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Array"
   put the result into cloneStackName
   if exists (stack cloneStackName) is false then return empty
   
   -- put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   put _DisplayView (cloneStackName) into displayView
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
   set the title_Text of displayView to pTitle
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
