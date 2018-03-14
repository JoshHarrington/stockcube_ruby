admin_user = User.where(admin: true).first

picked_recipes = Recipe.all.sample(3)

shopping_list_1 = ShoppingList.create

admin_user.shopping_lists << shopping_list_1

shopping_list_1.recipes << picked_recipes
