module UsersHelper
  include StockHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 80 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
  def new_user(user)
    ### setup user with some fav stock for quick add
    @tomatoe_id = Ingredient.find_or_create_by(name: "Tomatoes").id
    @egg_id = Ingredient.find_or_create_by(name: "Egg").id
    @bread_id = Ingredient.find_or_create_by(name: "Bread (White)").id
    @milk_id = Ingredient.find_or_create_by(name: "Milk").id
    @onion_id = Ingredient.find_or_create_by(name: "Onion").id
    @cheese_id = Ingredient.find_or_create_by(name: "Cheese (Cheddar)").id

    units_to_check = ["Each", "Loaf", "Pint", "Gram"]
    units_to_check.each do |unit|
      model = Unit.where('lower(name) = ?', name.downcase).first
      model ||= Unit.create(:name => unit)
      if unit == "Each"
        @each_unit_id = model.id
      end
      if unit == "Loaf"
        @loaf_unit_id = model.id
      end
      if unit == "Pint"
        @pint_unit_id = model.id
        model.update_attributes(metric_ratio: 568.261, unit_type: "Volume")
      end
      if unit == "Gram"
        @gram_unit_id = model.id
      end
    end

    if CupboardInvitee.find_by(email: user.email).present?
      cupboard_invitee = CupboardInvitee.find_by(email: user.email)
      CupboardUser.create(
        user_id: user.id,
        cupboard_id: cupboard_invitee.cupboard_id
      )
    end

    UserFavStock.create(
      ingredient_id: @tomatoe_id,
      stock_amount: 4,
      unit_id: @each_unit_id,
      user_id: user.id,
      standard_use_by_limit: 5
    )
    UserFavStock.create(
      ingredient_id: @egg_id,
      stock_amount: 6,
      unit_id: @each_unit_id,
      user_id: user.id,
      standard_use_by_limit: 9
    )
    UserFavStock.create(
      ingredient_id: @bread_id,
      stock_amount: 1,
      unit_id: @loaf_unit_id,
      user_id: user.id,
      standard_use_by_limit: 4
    )
    UserFavStock.create(
      ingredient_id: @milk_id,
      stock_amount: 1,
      unit_id: @pint_unit_id,
      user_id: user.id,
      standard_use_by_limit: 8
    )
    UserFavStock.create(
      ingredient_id: @onion_id,
      stock_amount: 3,
      unit_id: @each_unit_id,
      user_id: user.id,
      standard_use_by_limit: 14
    )
    UserFavStock.create(
      ingredient_id: @cheese_id,
      stock_amount: 350,
      unit_id: @gram_unit_id,
      user_id: user.id,
      standard_use_by_limit: 28
    )


    ### setup user with default settings
    UserSetting.create(
      user_id: user.id
    )

    ### setup user with default cupboard
    new_cupboard = Cupboard.create(location: "Your first cupboard")
    CupboardUser.create(
      cupboard_id: new_cupboard.id,
      user_id: user.id,
      owner: true,
      accepted: true
    )

    water_id = Ingredient.where(name: "Water").map(&:id).first
    liter_id = Unit.where(name: "Liter").map(&:id).first
    Stock.create(
      hidden: false,
      always_available: true,
      ingredient_id: water_id,
      cupboard_id: new_cupboard[:id],
      unit_id: liter_id,
      amount: 9223372036854775807,
      use_by_date: Date.current + 100.years
    )

    update_recipe_stock_matches_core(nil, user.id)
  end
end