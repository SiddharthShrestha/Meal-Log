package com.siddharth.model;

public class User {
    private int    id;
    private String fullName;
    private String email;
    private String password;

    public User() {}

    public User(int id, String fullName, String email, String password) {
        this.id       = id;
        this.fullName = fullName;
        this.email    = email;
        this.password = password;
    }

    // Constructor without id (for registration)
    public User(String fullName, String email, String password) {
        this.fullName = fullName;
        this.email    = email;
        this.password = password;
    }

    public int    getId()       { return id; }
    public String getFullName() { return fullName; }
    public String getEmail()    { return email; }
    public String getPassword() { return password; }

    public void setId(int id)             { this.id       = id; }
    public void setFullName(String name)  { this.fullName = name; }
    public void setEmail(String email)    { this.email    = email; }
    public void setPassword(String pass)  { this.password = pass; }

    @Override
    public String toString() {
        return "User{id=" + id + ", fullName='" + fullName + "', email='" + email + "'}";
    }
}