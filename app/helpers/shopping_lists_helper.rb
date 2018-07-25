module ShoppingListsHelper
	include ActionView::Helpers::NumberHelper
	def shoppingListIndex(shopping_list)
		if current_user && current_user.shopping_lists.length > 0
			userShoppingLists = current_user.shopping_lists
			zero_base_index = userShoppingLists.index(shopping_list)
			return zero_base_index + 1
		else
			return 1
		end
	end

	def metric_transform(portion_obj, portion_unit_obj)
		metric_amount = portion_obj.amount * portion_unit_obj.metric_ratio

		if metric_amount < 20
			return metric_amount = metric_amount.ceil
		elsif metric_amount < 400
			return metric_amount = (metric_amount / 10).ceil * 10
		elsif metric_amount < 1000
			return metric_amount = (metric_amount / 20).ceil * 20
		else
			return metric_amount = (metric_amount / 50).ceil * 50
		end
	end

	def metric_transform_portion_update(shopping_list_portion, portion_unit_obj, portion_obj, ingredient_obj)
		if portion_unit_obj.metric_ratio

			metric_amount = portion_obj.amount * portion_unit_obj.metric_ratio
			metric_transform(portion_obj, portion_unit_obj)

			shopping_list_portion.update_attributes(
				:amount => metric_amount,
				:recipe_number => portion_obj.recipe_id
			)
			if portion_unit_obj.unit_type == "volume" && metric_amount < 1000
				## add unit number for milliliters
				shopping_list_portion.update_attributes(
					:unit_number => 11
				)
			elsif portion_unit_obj.unit_type == "volume" && metric_amount >= 1000
				metric_amount = metric_amount / 1000
				## convert to liters
				shopping_list_portion.update_attributes(
					:unit_number => 12,
					:amount => metric_amount
				)
			elsif portion_unit_obj.unit_type == "mass" && metric_amount < 1000
				## add unit number for grams
				shopping_list_portion.update_attributes(
					:unit_number => 8
				)
			elsif portion_unit_obj.unit_type == "mass" && metric_amount >= 1000
				metric_amount = metric_amount / 1000
				## convert to kilograms
				shopping_list_portion.update_attributes(
					:unit_number => 9,
					:amount => metric_amount
				)
			end
		else
			shopping_list_portion.update_attributes(
				:amount => portion_obj.amount,
				:unit_number => portion_obj.unit_number,
				:recipe_number => portion_obj.recipe_id
			)
		end
	end

	def latest_shopping_list_path
		latest_shopping_list = current_user.shopping_lists.order('created_at DESC').first
		return shopping_list_ingredients_path(latest_shopping_list)
	end

	def shopping_list_latest(shopping_list)
		if current_user && current_user.shopping_lists.length > 0
			latest_shopping_list = current_user.shopping_lists.order('created_at DESC').first
			if shopping_list.id == latest_shopping_list.id
				return true
			else
				return false
			end
		end
	end


	def shopping_list_portions_set(add_recipe_id, recipe_ids_to_delete, current_user_id, current_shopping_list_id)

		current_user_set = User.find(current_user_id)


		if current_shopping_list_id == nil
			if current_user_set.shopping_lists.length > 0 && current_user_set.shopping_lists.last.archived != true
				current_shopping_list = current_user_set.shopping_lists.last
				current_shopping_list_id = current_shopping_list.id
			else
				current_shopping_list = ShoppingList.create(user_id: current_user_set.id)
				current_shopping_list_id = current_shopping_list.id
			end
		else
			current_shopping_list = ShoppingList.find(current_shopping_list_id)
		end

		if add_recipe_id == nil
			ShoppingListRecipe.where(shopping_list_id: current_shopping_list_id, recipe_id: recipe_ids_to_delete).delete_all
		else
			ShoppingListRecipe.find_or_create_by(shopping_list_id: current_shopping_list_id, recipe_id: add_recipe_id)
		end


		@portions = Portion.where(recipe_id: current_shopping_list.recipes)
		@portion_ids = @portions.map(&:id)
		@uniq_ingredient_ids = @portions.map(&:ingredient_id).uniq

    @user_cupboard_ids = current_user_set.cupboards.where(hidden: false).where(setup: false).map(&:id)

    @stock = Stock.where(cupboard_id: @user_cupboard_ids, ingredient_id: @uniq_ingredient_ids, hidden: false).where("use_by_date >= :date", date: Date.current - 2.days)
    @stock_ingredient_ids = @stock.map(&:ingredient_id)
		@not_in_stock_ingredient_ids = @uniq_ingredient_ids - @stock_ingredient_ids


		## need to find a better way to do this than just deleting and rewriting every time
		## should be a way to check if the shopping list portion with
		## the same shopping list id and ingredient id already exists and update it
		## otherwise create it
		## and delete the ones that don't match the incoming shopping list portions
		current_shopping_list.shopping_list_portions.delete_all

		@portions.each do |portion|
			next if portion.ingredient.name.downcase == "water"

			shopping_list_portion = ShoppingListPortion.find_or_create_by(
				shopping_list_id: current_shopping_list_id,
				ingredient_id: portion.ingredient_id
			)

			set_portion_amount = 0

			### set ingredients unis to default metric names
			portion_unit = Unit.where(unit_number: portion.unit_number).first
			default_mass_unit = Unit.where(unit_number: 8).first
			default_volume_unit = Unit.where(unit_number: 11).first
			if portion_unit.metric_ratio != nil
				if portion_unit.unit_type == "mass"
					ingredient_unit_number = 8
					default_mass_unit.short_name ? ingredient_unit_name = default_mass_unit.short_name : ingredient_unit_name = default_mass_unit.name
				elsif portion_unit.unit_type == "volume"
					ingredient_unit_number = 11
					default_volume_unit.short_name ? ingredient_unit_name = default_volume_unit.short_name : ingredient_unit_name = default_volume_unit.name
				end
				set_portion_amount += portion.amount * portion_unit.metric_ratio
			else
				set_portion_amount += portion.amount
				ingredient_unit_number = portion.unit_number
				portion_unit.short_name ? ingredient_unit_name = portion_unit.short_name : ingredient_unit_name = portion_unit.name
			end


			similar_shopping_list_portion_all = current_shopping_list.shopping_list_portions.where(ingredient_id: portion.ingredient_id)
			if similar_shopping_list_portion_all.length > 0 && similar_shopping_list_portion_all.first.id != shopping_list_portion.id
				similar_shopping_list_portion = similar_shopping_list_portion_all.first

				similar_shopping_list_portion_unit = Unit.where(unit_number: similar_shopping_list_portion.unit_number).first

				if similar_shopping_list_portion_unit && similar_shopping_list_portion_unit.metric_ratio != nil && similar_shopping_list_portion.portion_amount
					set_portion_amount += similar_shopping_list_portion.portion_amount * similar_shopping_list_portion_unit.metric_ratio
				elsif similar_shopping_list_portion.portion_amount
					set_portion_amount += similar_shopping_list_portion.portion_amount
				end

			end

      if @stock_ingredient_ids.include?(portion.ingredient_id)
        shopping_list_portion.update_attributes(
					in_cupboard: true
				)
        matching_stocks = Stock.where(cupboard_id: @user_cupboard_ids, ingredient_id: portion.ingredient_id)
        stock_amount = 0

				matching_stocks.each do |stock|
					stock_unit = Unit.where(unit_number: stock.unit_number).first
					if stock_unit.metric_ratio
						stock_amount += stock.amount * stock_unit.metric_ratio
					else
						stock_amount += stock.amount
					end
        end

        shopping_list_portion.update_attributes(
					stock_amount: stock_amount
				)
        if stock_amount >= set_portion_amount
          shopping_list_portion.update_attributes(
						enough_in_cupboard: true
					)
          if stock_amount > (set_portion_amount*1.5)
            shopping_list_portion.update_attributes(
							plenty_in_cupboard: true
						)
          end
        end
        percent_in_cupboard = number_with_precision((stock_amount.to_f / set_portion_amount.to_f) * 100, :precision => 0)
        shopping_list_portion.update_attributes(
					percent_in_cupboard: percent_in_cupboard
				)
      else
        shopping_list_portion.update_attributes(
					in_cupboard: false
				)
      end


      if set_portion_amount < 20
        set_portion_amount = set_portion_amount.ceil
      elsif set_portion_amount < 400
        set_portion_amount = (set_portion_amount / 10).ceil * 10
      elsif set_portion_amount < 1000
        set_portion_amount = (set_portion_amount / 20).ceil * 20
      else
        set_portion_amount = (set_portion_amount / 50).ceil * 50
      end

      shopping_list_portion.update_attributes(
				portion_amount: set_portion_amount,
				unit_name: ingredient_unit_name.downcase
			)
    end


	end

end
