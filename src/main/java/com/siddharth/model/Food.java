package com.siddharth.model;

/**
 * Food - Model class representing a food item in the foods table.
 * Contains nutritional information per 100g.
 */
public class Food {

    private int    id;
    private String foodName;
    private String category;
    private double caloriesPer100g;
    private double proteinPer100g;
    private double carbsPer100g;
    private double fatsPer100g;

    // No-arg constructor
    public Food() {}

    // Full constructor with ID (for fetching from DB)
    public Food(int id, String foodName, String category,
                double caloriesPer100g, double proteinPer100g,
                double carbsPer100g, double fatsPer100g) {
        this.id              = id;
        this.foodName        = foodName;
        this.category        = category;
        this.caloriesPer100g = caloriesPer100g;
        this.proteinPer100g  = proteinPer100g;
        this.carbsPer100g    = carbsPer100g;
        this.fatsPer100g     = fatsPer100g;
    }

    // Constructor without ID (for inserting new food)
    public Food(String foodName, String category,
                double caloriesPer100g, double proteinPer100g,
                double carbsPer100g, double fatsPer100g) {
        this.foodName        = foodName;
        this.category        = category;
        this.caloriesPer100g = caloriesPer100g;
        this.proteinPer100g  = proteinPer100g;
        this.carbsPer100g    = carbsPer100g;
        this.fatsPer100g     = fatsPer100g;
    }

    // Getters
    public int    getId()              { return id; }
    public String getFoodName()        { return foodName; }
    public String getCategory()        { return category; }
    public double getCaloriesPer100g() { return caloriesPer100g; }
    public double getProteinPer100g()  { return proteinPer100g; }
    public double getCarbsPer100g()    { return carbsPer100g; }
    public double getFatsPer100g()     { return fatsPer100g; }

    // Setters
    public void setId(int id)                          { this.id              = id; }
    public void setFoodName(String foodName)           { this.foodName        = foodName; }
    public void setCategory(String category)           { this.category        = category; }
    public void setCaloriesPer100g(double calories)    { this.caloriesPer100g = calories; }
    public void setProteinPer100g(double protein)      { this.proteinPer100g  = protein; }
    public void setCarbsPer100g(double carbs)          { this.carbsPer100g    = carbs; }
    public void setFatsPer100g(double fats)            { this.fatsPer100g     = fats; }

    @Override
    public String toString() {
        return "Food{id=" + id +
               ", foodName='" + foodName + "'" +
               ", category='" + category + "'" +
               ", caloriesPer100g=" + caloriesPer100g +
               ", proteinPer100g="  + proteinPer100g  +
               ", carbsPer100g="    + carbsPer100g    +
               ", fatsPer100g="     + fatsPer100g     +
               "}";
    }
}