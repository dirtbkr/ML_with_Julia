# Assignment 3
---
#### Contents:
- #### [MultiDual & Jacobian](/multi_dual_jacobian.jl)
- #### [Polynomial Regression (With/Without Zygote)](/polynomial_regression.ipynb)

### MultiDual & Jacobian
---
##### MultiDual
We define a MultiDual structure here, which has two member variables : 
the value of the function and the derivatives(Derivatives are resolved into components, so this is an array)

Next we overload the commonly used arithmetic operators and other functions for MultiDual - MultiDual operations :
+ \+ , \- , * , \\ , ^ , > , < , ==
+ sin, cos, log, exp, abs

To deal with MultiDual and Number operations, we define a `promote_rule` function, which makes Julia call the `promote` function, And thereby converting one of the types as defined in the rule.
In our case, `promote_rule` defines that when we encounter a `MultiDual` and `Number` types, we promote the `Number` type to a `MultiDual`. This is done by calling the `convert` function defined by us.
An important thing to note is that, Some fucntions do not perform the promotion automatically, For eg. When we overload the '>' & '<' operators, You will have to call the `promote` funciton EXPLICITLY!
On the other hand , other operators like +,-,*,/ call the `promote` function by themselves as mentioned in the docs [here](https://docs.julialang.org/en/v1/manual/conversion-and-promotion/")

##### Jacobian

The goal here is to calculate the Jacobian Matrix from a given function, and input.

![An image explaining Jacobian](/jacobian.svg "Jacobian Matrix")

So given a function : `f(X) = [ f1(X) , f2(X) , f3(X) , ... , fn(x) ]` where `X` is the input  vector. We will iterate over the output of the function, i.e we choose an `fi(X)`, now we know the gradient of this component constitutes the corresponding row in the jacobian matrix. So we will make use of the `gradient` function to find the gradient w.r.t. each of the independent variables of each `fi(X)`. And then return the resultant 2D Matrix, which is our Jacobian Matrix.

### Polynomial Regression
---
Here we will be approximating a two degree polynomial, using gradient descent
