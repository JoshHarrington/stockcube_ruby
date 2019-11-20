class PlannerShoppingListsController < ApplicationController
  before_action :set_planner_shopping_list, only: [:show, :edit, :update, :destroy]

  # GET /planner_shopping_lists
  # GET /planner_shopping_lists.json
  def index
    @planner_shopping_lists = PlannerShoppingList.all
  end

  # GET /planner_shopping_lists/1
  # GET /planner_shopping_lists/1.json
  def show
  end

  # GET /planner_shopping_lists/new
  def new
    @planner_shopping_list = PlannerShoppingList.new
  end

  # GET /planner_shopping_lists/1/edit
  def edit
  end

  # POST /planner_shopping_lists
  # POST /planner_shopping_lists.json
  def create
    @planner_shopping_list = PlannerShoppingList.new(planner_shopping_list_params)

    respond_to do |format|
      if @planner_shopping_list.save
        format.html { redirect_to @planner_shopping_list, notice: 'Planner shopping list was successfully created.' }
        format.json { render :show, status: :created, location: @planner_shopping_list }
      else
        format.html { render :new }
        format.json { render json: @planner_shopping_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /planner_shopping_lists/1
  # PATCH/PUT /planner_shopping_lists/1.json
  def update
    respond_to do |format|
      if @planner_shopping_list.update(planner_shopping_list_params)
        format.html { redirect_to @planner_shopping_list, notice: 'Planner shopping list was successfully updated.' }
        format.json { render :show, status: :ok, location: @planner_shopping_list }
      else
        format.html { render :edit }
        format.json { render json: @planner_shopping_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /planner_shopping_lists/1
  # DELETE /planner_shopping_lists/1.json
  def destroy
    @planner_shopping_list.destroy
    respond_to do |format|
      format.html { redirect_to planner_shopping_lists_url, notice: 'Planner shopping list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_planner_shopping_list
      @planner_shopping_list = PlannerShoppingList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def planner_shopping_list_params
      params.fetch(:planner_shopping_list, {})
    end
end
