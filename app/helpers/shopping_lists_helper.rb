module ShoppingListsHelper
	require 'set'
	def shoppingListIndex(shopping_list)
		userShoppingLists = current_user.shopping_lists
		zero_base_index = userShoppingLists.index(shopping_list)
		return zero_base_index + 1
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
		latest_shopping_list = current_user.shopping_lists.order('created_at DESC').first
		if shopping_list.id == latest_shopping_list.id
			return true
		else
			return false
		end
	end


	def shopping_list_portions_set(shopping_list)

    @recipes = shopping_list.recipes

    @portion_ids = []
		@ingredient_ids = Set[]
    @recipes.each do |recipe|
      recipe.portions.each do |portion|
				@portion_ids << portion.id
				@ingredient_ids.add(portion.ingredient.id)
      end
		end

		@portions = Portion.find(@portion_ids)

    @user_cupboard_ids = current_user.cupboards.map(&:id)

    @stock = Stock.where(cupboard_id: @user_cupboard_ids, ingredient_id: @ingredient_ids, hidden: false).where("use_by_date >= :date", date: Date.current - 2.days)
    @stock_ingredient_ids = @stock.map(&:ingredient_id)
		@not_in_stock_ingredient_ids = @ingredient_ids - @stock_ingredient_ids

		shopping_list.shopping_list_portions.delete_all

		@portions.each do |portion|

			shopping_list_portion = ShoppingListPortion.create(
				shopping_list_id: shopping_list.id,
				ingredient_id: portion.ingredient_id
			)

      portion_amount = 0

      portion_amount = portion.quantity.comparable_amount

      ingredient_unit_number = portion.ingredient.unit_id
      ingredient_unit = Unit.where(unit_number: ingredient_unit_number.to_i).first
			ingredient_unit_name = ingredient_unit.name

			similar_shopping_list_portion_all = shopping_list.shopping_list_portions.where(ingredient_id: portion.ingredient_id)
			similar_shopping_list_portion = similar_shopping_list_portion_all.first

			if similar_shopping_list_portion.id != shopping_list_portion.id && similar_shopping_list_portion_all.length != 0
				if similar_shopping_list_portion.unit_number != nil && ingredient_unit_number == similar_shopping_list_portion.unit_number.to_i
					portion_amount = similar_shopping_list_portion.portion_amount.to_f + portion_amount
				else
					similar_shli_portion_amount = similar_shopping_list_portion.portion_amount.to_f
          similar_shli_unit_number = similar_shopping_list_portion.unit_number.to_i
          unit_model = Unit.where(unit_number: similar_shli_unit_number)
          if unit_model.metric_ratio
            similar_shli_portion_amount = similar_shli_portion_amount * unit_model.metric_ratio
          end
          portion_amount = portion_amount + similar_shli_portion_amount
				end
			end

      if @stock_ingredient_ids.include?(portion.ingredient_id)
        shopping_list_portion.update_attributes(
					in_cupboard: true
				)
        matching_stocks = Stock.where(cupboard_id: @user_cupboard_ids, ingredient_id: portion.ingredient_id)
        stock_amount = 0

        matching_stocks.each do |stock|
          stock_amount += stock.quantity.comparable_amount
        end

        if ingredient_unit.metric_ratio
          stock_amount = stock_amount / ingredient_unit.metric_ratio
          portion_amount = portion_amount / ingredient_unit.metric_ratio
        end

        shopping_list_portion.update_attributes(
					stock_amount: stock_amount
				)
        if stock_amount >= portion_amount
          shopping_list_portion.update_attributes(
						enough_in_cupboard: true
					)
          if stock_amount > (portion_amount*1.5)
            shopping_list_portion.update_attributes(
							plenty_in_cupboard: true
						)
          end
        end
        percent_in_cupboard = number_with_precision((stock_amount.to_f / portion_amount.to_f) * 100, :precision => 0)
        shopping_list_portion.update_attributes(
					percent_in_cupboard: percent_in_cupboard
				)
      else
        shopping_list_portion.update_attributes(
					in_cupboard: false
				)
      end


      if portion_amount < 20
        portion_amount = portion_amount.ceil
      elsif portion_amount < 400
        portion_amount = (portion_amount / 10).ceil * 10
      elsif portion_amount < 1000
        portion_amount = (portion_amount / 20).ceil * 20
      else
        portion_amount = (portion_amount / 50).ceil * 50
      end

      shopping_list_portion.update_attributes(
				portion_amount: portion_amount
			)
      shopping_list_portion.update_attributes(
				unit_number: ingredient_unit_number
			)
    end


	end

end
