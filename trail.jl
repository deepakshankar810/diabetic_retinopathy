println("machine learning")

for i=1:20
    println(i)
end

#=
    learning
    starting with variables
=#
x = 13
typeof(x) # get the type of a variable

x = x+12
x= 13; y=12; z=24;

y=x^6+3*x

x= "google.com" #assign to variable

typeof(x) #string
w=3.14

typeof(w) #float

_xyz = 222
println(_xyz)

α = 3.14; β= 3.22  #\alpha TAB  #\beta TAB

β₀=88   #\beta_0 TAB
α¹=2.22 #\alpha^1 TAB

π #\pi TAB
ℯ #\e TAB

# Naming style conventions for varaible names


first_name = "deepak"
last_name = "shankar"

p, q, r= 1, 2, 3 #Assign values to multiple variables

#swap the values of two variables in onE line?
p,q = q,p #swap the values of p and q

function sum_two_numbers(x::Float64, y::Float64)
    return x+y
end

sum_two_numbers(3.14, 2.22)

((8+8)*2)::Int64 #::Int64 withoutdecimal point
((8+8)*2.0)::Float64 #::Float64 with decimal point


const MYHANDLE = "Gmail"