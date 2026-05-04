package com.siddharth.model;

public class Meal {
    private int    id;
    private int    userId;
    private String mealType;
    private String mealName;
    private int    calories;
    private double protein;
    private double carbs;
    private double fats;
    private String mealDate;

    public Meal() {}

    public Meal(int id, int userId, String mealType, String mealName,
                int calories, double protein, double carbs, double fats, String mealDate) {
        this.id       = id;
        this.userId   = userId;
        this.mealType = mealType;
        this.mealName = mealName;
        this.calories = calories;
        this.protein  = protein;
        this.carbs    = carbs;
        this.fats     = fats;
        this.mealDate = mealDate;
    }

    // Constructor without id (for inserting new meals)
    public Meal(int userId, String mealType, String mealName,
                int calories, double protein, double carbs, double fats, String mealDate) {
        this.userId   = userId;
        this.mealType = mealType;
        this.mealName = mealName;
        this.calories = calories;
        this.protein  = protein;
        this.carbs    = carbs;
        this.fats     = fats;
        this.mealDate = mealDate;
    }

    public int    getId()       { return id; }
    public int    getUserId()   { return userId; }
    public String getMealType() { return mealType; }
    public String getMealName() { return mealName; }
    public int    getCalories() { return calories; }
    public double getProtein()  { return protein; }
    public double getCarbs()    { return carbs; }
    public double getFats()     { return fats; }
    public String getMealDate() { return mealDate; }

    public void setId(int id)             { this.id       = id; }
    public void setUserId(int userId)     { this.userId   = userId; }
    public void setMealType(String type)  { this.mealType = type; }
    public void setMealName(String name)  { this.mealName = name; }
    public void setCalories(int calories) { this.calories = calories; }
    public void setProtein(double protein){ this.protein  = protein; }
    public void setCarbs(double carbs)    { this.carbs    = carbs; }
    public void setFats(double fats)      { this.fats     = fats; }
    public void setMealDate(String date)  { this.mealDate = date; }

    @Override
    public String toString() {
        return "Meal{id=" + id + ", userId=" + userId + ", mealType='" + mealType +
               "', mealName='" + mealName + "', calories=" + calories +
               ", protein=" + protein + ", carbs=" + carbs + ", fats=" + fats +
               ", mealDate='" + mealDate + "'}";
    }
}