script "behavior_View_Ascii"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_View_Ascii
type: behavior
version: 0.1

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Working on
-
-- getprop menu_Target
   -- return the long id of control 1 of cd 1 of stack "View|Camera"
   return the long id of me
end menu_Target


--> Events
-
on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   -- do your geometry here
   set the rect of me to pRect
   unlock screen
end LayoutControl


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object
