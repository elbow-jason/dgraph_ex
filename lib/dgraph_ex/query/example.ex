
# defmodule ImageMenuItems do
#   #model definitition here

#   def new_assoc(%ImageItem{id: image_item_id}, menu_item) do
#     new_assoc(image_item_id, menu_item)
#   end
#   def new_assoc(image_item, %MenuItem{id: menu_item_id}) do
#     new_assoc(image_item, menu_item_id)
#   end
#   def new_assoc(image_item_id, menu_item_id) when is_integer(image_item_id) and is_integer(menu_item_id) do
#     new_assoc(%{
#       image_item_id: image_item_id,
#       menu_item_id: menu_item_id,
#     })
#   end
#   def new_assoc(%{image_item_id: _, menu_item_id: _,} = changes) do
#     %ImageMenuItems{}
#     |> changeset(changes)
#     |> Repo.insert!
#   end

# end
