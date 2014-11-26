class SearchRecipesController < ApplicationController

  # Search recipes by ingredients
  # The recipe must have all the ingredients given
  def search_by_ingredients
    ingredient_ids = params[:ingredients].split(',').map { |x| x.to_i }
    inputed_ingredients = get_ingredients(ingredient_ids)
    ingredients = get_all_ingredients_ids(inputed_ingredients)
    recipes = Recipe.joins(:recipe_ingredients)
                  .where(recipe_ingredients: {ingredient_id: ingredients})
                  .group('recipes.id').having('count(*) >= ?', inputed_ingredients.size)
    render json: recipes.as_json
  end

  def get_ingredients(ids)
    all_ingredients = Ingredient.where(id: ids)
    ingredients = []
    all_ingredients.each do |ingredient|
      skip = false
      all_ingredients.each do |other|
        if other != ingredient
          if other.is_child_of? ingredient
            skip = true
          end
        end
      end

      unless skip
        ingredients << ingredient
      end
    end
    ingredients
  end

  def get_all_ingredients_ids(ingredients)
    ids = if ingredients.is_a? Array
            ingredients.map(&:id)
          else

            ingredients.ids
          end
    ingredients.each do |ingredient|
      ids += get_all_ingredients_ids(ingredient.children)
    end
    ids
  end
end
