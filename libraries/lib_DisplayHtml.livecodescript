script "lib_DisplayHtml"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayHtml
type: library
version: 0.3

/*
This library is about displaying HTML and the browser view.
*/


--> Working on
-
function display_ListBrowsers pStackLabel
   put display_List ("View|Browser", pStackLabel) into browserViews
   return browserViews
end display_ListBrowsers


--> Display | Html
-
command display_Html someHTML, pCloneName, pStackStyle
   if pCloneName is empty then put "Browser" into pCloneName
   --
   display_Clone "View|Browser", pCloneName, someHTML, "browser_HtmlText", empty, pStackStyle
   put the result into displayView
   dispatch "LayoutControl" to displayView
   --
   display_ToolStack displayView
   return displayView
end display_Html

command display_Browser someURL, pBrowserView, pStackLabel, pStackStyle, pViewName
   if someURL is empty then put "https://google.com" into someURL
   if pViewName is empty then put "View|Browser" into pViewName
   if pStackLabel is empty then
      put someURL into pStackLabel
   end if
   
   # Display
   display_ModuleInstance pViewName, someURL, pStackLabel, pBrowserView, "browser_URL", pStackStyle
   put the result into browserView
   
   # Set Menus
   display_SetMenu browserView, "Browser"
   
   return browserView
end display_Browser


--> Display | Text
-
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
         put textOrUrl into someText
         atom_DisplayText someText
         --
         return the result
      default
         put textOrUrl into someText
   end switch
   
   -- display_Index 
   display_Data someText, pDisplayTitle, pStackLabel, pDisplayView, pPalette
   put the result into indexView
   set the field_Style of indexView to "text"
   --
   switch
      case textURL is not empty
         set the displayed_URL of indexView to textURL
         break
      case textFile is not empty
         set the displayed_File of indexView to textFile
         break
   end switch
   --
   return indexView
end display_Text

command display_ListDataViews
   put display_FindStackNameArray (empty, empty, true) into displayViewArray
   --
   display_Data displayViewArray, "Views", "Find Displays"
   put the result into displayView
   display_SetInteractions displayView, "Display | View", "mDoubleUp_LocateDisplayView"
   --
   return displayView
end display_ListDataViews

command display_Handler hName, someHandler, stackLabel
   display_Data someHandler, hName, stackLabel
   put the result into indexView
   set the field_Style of indexView to "text"
   return indexView
end display_Handler


--> Display | Html
-
command display_ScaffoldHtml htmlTemplateName, pLocOrRect, pStackStyle, pCloneName
   put scaffold_Get (htmlTemplateName) into someHTML
   --
   display_Html someHTML, pCloneName, pLocOrRect, pStackStyle
   put the result into displayView
   --
   return displayView
end display_ScaffoldHtml

command display_HtmlText someHTML, pTitle, pTreeMenuTitle
   put stack_GetLastRect () into oRect
   --
   display_InvisibleIndex empty, pTitle, pTreeMenuTitle, empty, empty, empty, empty, true
   put the result into displayView 
   set the displayed_HtmlText of displayView to someHTML
   --
   put the formatted_Rect of displayView into fRect
   put the screen_Rect of displayView into displayScreenRect
   put display_GetNewStackRect (oRect, fRect, displayScreenRect) into newRect
   --
   put token -1 of displayView into cloneStackName
   set the rect of stack cloneStackName to newRect --- this is not working in latest dp
   revIDEEnsureOnscreen cloneStackName
   --
   show stack cloneStackName
   go to stack cloneStackName
   --
   set the field_Style of displayView to "text"
   return displayView
end display_HtmlText
