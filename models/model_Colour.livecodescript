script "model_Colour"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Colour
type: model
version: 0.1


--> Colour | Palette | Model
-
function kuler_XmlToPalleteData kulerXML, pInfoText, pTagItems
   put xml_ToArray (kulerXML) into kulerArray
   put kulerArray ["palette"] into pArray
   repeat with itemNum = 1 to 5
      put "color[" & itemNum & "]" into cKey
      put pArray [cKey]["@attributes"] into aArray
      put aArray ["name"] into cName
      put aArray ["r"] into cPaletteArray [itemNum][1]
      put aArray ["g"] into cPaletteArray [itemNum][2]
      put aArray ["b"] into cPaletteArray [itemNum][3]
   end repeat
   --
   replace "-" with space in cName
   delete word -1 of cName
   put text_InitialCaps (cName) into cTitle
   --
   if pTagItems is empty then put cName into pTagItems
   put colour_ConstructPaletteData (cTitle, cPaletteArray, pTagItems, pInfoText) into paletteData
   return paletteData
end kuler_XmlToPalleteData


--> ColourMind | Model
-
function colorMind_PaletteArrayToIndex cData
   repeat with itemNum = 1 to item 2 of the extents of cData
      put cData [itemNum] into rgbArray
      combine rgbArray using comma
      put rgbArray & CR after rgbColours
   end repeat
   delete char -1 of rgbColours
   return rgbColours
end colorMind_PaletteArrayToIndex

function colorMind_GetFromArray mindName, paletteArray
   put colorMind_NameToItemNum (mindName) into itemNum
   put paletteArray [itemNum] into someRGB
   combine someRGB using comma
   return someRGB
end colorMind_GetFromArray

command colorMind_AddToArray @paletteArray, mindName, someRGB
   put colorMind_NameToItemNum (mindName) into itemNum
   split someRGB using comma
   put someRGB into paletteArray [btnNum] 
   return itemNum
end colorMind_AddToArray

function colorMind_NameToItemNum mindName
   if mindName is a number then return mindName
   --
   switch mindName
      case "Light shades"
         return 1
      case "Light accent"
         return 2
      case "Main brand color"
         return 3
      case "Dark accent"
         return 4
      default -- `'Dark shades
         return 5
   end switch
end colorMind_NameToItemNum


--> ColorMind | Rest
-
function colorMind_FetchPaletteIndex pInputData
   put colorMind_FetchPaletteArray (pInputData) into paletteArray
   put colorMind_PaletteArrayToIndex (paletteArray) into rgbColours
   return rgbColours
end colorMind_FetchPaletteIndex

function colorMind_FetchPaletteArray pInputData
   put "http://colormind.io/api/" into restUrl
   if pInputData is not an array then
      put "default" into pInputData ["model"]
   end if
   --
   put jsonrpc_PostArray (pInputData, restUrl) into rData
   put rData ["result"] into paletteArray
   return paletteArray
end colorMind_FetchPaletteArray

function colorMind_ListModels
   put url "http://colormind.io/list/" into sJSON
   put json_ToArray (sJSON) into mData
   put mData ["result"] into rData
   combine rData by row
   return rData
end colorMind_ListModels


--> Colour | Palette | Model
-
function colour_ConstructPaletteData cTitle, cPaletteArray, pTagItems, pInfoText
   put cTitle into colourPaletteData ["title"]
   put cPaletteArray into colourPaletteData ["palette"]
   --
   if pInfoText is empty then
      put "Author: david@regovern.org" into pInfoText
      put CR & "Rating: 3" after pInfoText
      put CR & "Tags:" after pInfoText
   end if
   put pInfoText into colourPaletteData ["info"]
   put pTagItems into colourPaletteData ["tags"]
   return colourPaletteData
end colour_ConstructPaletteData

function colour_ListPaletteNames
   put colour_GetPaletteLibraryData() into colourPaletteData
   put keys (colourPaletteData) into paletteNames
   sort paletteNames
   return paletteNames
end colour_ListPaletteNames

function colour_GetPalette paletteTitle
   put colour_GetPaletteLibraryData() into colourPaletteData
   --
   put colourPaletteData [paletteTitle] into paletteData
   put paletteTitle into paletteData ["title"]
   return paletteData
end colour_GetPalette

command colour_SavePalette paletteData
   put colour_GetPaletteLibraryData() into colourPaletteData
   --
   put paletteData ["title"] into paletteTitle
   delete variable paletteData ["title"]
   put paletteData into colourPaletteData [paletteTitle]
   --
   colour_SetPaletteLibraryData colourPaletteData
   return colourPaletteData
end colour_SavePalette

function colour_GetPaletteLibraryData
   put the array_Data ["palette_library,colour"] of me into colourPaletteData
   return colourPaletteData 
end colour_GetPaletteLibraryData

command colour_SetPaletteLibraryData colourPaletteData
   set the array_Data ["palette_library,colour"] of me to colourPaletteData
   put the result into modelDataFile
   return modelDataFile
end colour_SetPaletteLibraryData


--> Display | Colour | Model
-
on mDoubleUp_ColourModel displayView, rgbColour
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_ColourModel

command display_ColourPalette pModelName, pInput
   put colorMind_FetchPaletteIndex() into rgbColours
   --
   display_Data rgbColours, "ColorMind Palette"
   put the result into displayView
   display_SetInteractions displayView, "Colour | Model", "mDoubleUp_ColourModel"
   --
   return displayView
   
   put "{'model':'default'}" into someJSON
   replace "'" with quote in someJSON
   --
   put jsonrpc_POST (someJSON, restUrl) into rJSON
   return rJSON
end display_ColourPalette

command display_ColourModels
   put colorMind_ListModels() into mData
   display_Data mData, "ColorMind"
   put the result into displayView
   display_SetInteractions displayView, "Colour | Model", "mDoubleUp_ColourModel"
   return displayView
end display_ColourModels
