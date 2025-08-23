script "model_Display"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Display
type: model
version: 0.1


--> Card | Model
-
function card_ListBehaviorNames
   put project_ListStackNames ("behaviors", "lcw_Display") into bNames
   filter bNames with "behavior_Card*"
   return bNames
end card_ListBehaviorNames
