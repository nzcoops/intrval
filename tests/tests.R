#devtools::install_github("psolymos/intrval")
## examples

## load library
library(intrval)

## run examples with \dontrun sections

help_pages <- c("%[]%", "%notin%")

for (i in help_pages) {
    cat("\n\n---------- intrval example:", i, "----------\n\n")
    eval(parse(text=paste0("example('", i,
        "', package = 'intrval', run.dontrun = TRUE)")))
}

## testing

test_fun <- function(xchr, achr, bchr, printout=TRUE, expect_NA=FALSE) {
    tab <- intrval_types(type=NULL)
    ex <- tab[,"Expression"]
    cond <- tab[,"Condition"]
    eval(parse(text=paste0("x <- ", xchr)))
    eval(parse(text=paste0("a <- ", achr)))
    eval(parse(text=paste0("b <- ", bchr)))
    for (i in seq_len(nrow(tab))) {
        xpt <- eval(parse(text=cond[i]))
        got <- eval(parse(text=ex[i]))
        if (printout) {
            cat("\n", rownames(tab)[i], "\n")
            mat <- rbind(Expect=xpt, Found=got)
            print(mat)
        }
        allOK <- if (expect_NA)
            all(is.na(got)) else all(xpt == got)
#        if (!allOK)
#            cat("----------------------------------problem", i, "\n")
        stopifnot(allOK)
    }
    invisible(NULL)
}

## integer
test_fun("1L:5L", "2L", "4L")
## numeric
test_fun("(1:5)+0.5", "2.5","4.5")
## character
test_fun("c('a','b','c','d','e')", "'b'","'d'")
## ordered
test_fun("as.ordered(c('a','b','c','d','e'))", "'b'","'d'")
## factor -- leads to NA
suppressWarnings(test_fun("as.factor(c('a','b','c','d','e'))", "'b'","'d'",
    expect_NA=TRUE))
## date
test_fun("as.Date(1:5,origin='2000-01-01')",
    "as.Date(2,origin='2000-01-01')", "as.Date(4,origin='2000-01-01')")
## NA
test_fun("c(NA, NA, NA, 1, 2)", "NA", "NA", expect_NA=TRUE)

## overlap
a1 <- 0:4
b1 <- 1:5
a2 <- rep(2,5)
b2 <- rep(3,5)
ab1 <- list(a1, b1)
ab2 <- list(a2, b2)

ex <- ab1 %[o]% ab2
cond <- a1 %[]% ab2 | b1 %[]% ab2
stopifnot(all(cond == ex))

ex <- ab1 %)o(% ab2
cond <- !(a1 %[]% ab2 | b1 %[]% ab2)
stopifnot(all(cond == ex))

ex <- ab1 %[<o]% ab2
cond <- pmax(a1, b1) < pmin(a2, b2)
stopifnot(all(cond == ex))

ex <- ab1 %[o>]% ab2
cond <- pmin(a1, b1) > pmax(a2, b2)
stopifnot(all(cond == ex))

## ensuring that a <= b, a1 <= b1, a2 <= b2
stopifnot(identical(1:5 %[)% c(2,4), 1:5 %[)% c(4,2)))
stopifnot(identical(c(1,3) %[o]% c(2,4), c(3,1) %[o]% c(4,2)))

## --- motivating examples from example(lm) ---

## Annette Dobson (1990) "An Introduction to Generalized Linear Models".
## Page 9: Plant Weight Data.
ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
weight <- c(ctl, trt)

lm.D9 <- lm(weight ~ group)
## compare 95\% confidence intervals with 0
(CI.D9 <- confint(lm.D9))
0 %[]% CI.D9

lm.D90 <- lm(weight ~ group - 1) # omitting intercept
## compare 95\% confidence of the 2 groups to each other
(CI.D90 <- confint(lm.D90))
CI.D90[1,] %[o]% CI.D90[2,]

DATE <- as.Date(c("2000-01-01","2000-02-01", "2000-03-31"))
DATE %[<]% as.Date(c("2000-01-151", "2000-03-15"))
DATE %[]% as.Date(c("2000-01-151", "2000-03-15"))
DATE %[>]% as.Date(c("2000-01-151", "2000-03-15"))

## --- not so motivating but still useful examples ---

## simple case with integers
1:5 %[]% c(2,4)
1:5 %[)% c(2,4)
1:5 %(]% c(2,4)
1:5 %()% c(2,4)

1:5 %][% c(2,4)
1:5 %](% c(2,4)
1:5 %)[% c(2,4)
1:5 %)(% c(2,4)

## interval formats
x <- rep(4, 5)
a <- 1:5
b <- 3:7
cbind(x=x, a=a, b=b)
x %[]% cbind(a, b) # matrix
x %[]% data.frame(a=a, b=b) # data.frame
x %[]% list(a, b) # list

## NULL
NULL %[]% c(1,2)
NULL %[]% NULL
NULL %[]% list(NULL, NULL)

## logical
c(TRUE, FALSE) %[]% c(TRUE, TRUE)
c(TRUE, FALSE) %[]% c(FALSE, FALSE)
c(TRUE, FALSE) %[]% c(TRUE, FALSE)
c(TRUE, FALSE) %[]% c(FALSE, TRUE)

## NA values
1:5 %[]% c(NA,4)
1:5 %[]% c(2,NA)
c(1:5, NA) %[]% c(2,4)
NA %[]% c(1,2)
NA %[]% c(NA,NA)

## numeric
((1:5)+0.5) %[]% (c(2,4)+0.5)

## character
c('a','b','c','d','e') %[]% c('b','d')

## ordered
as.ordered(c('a','b','c','d','e')) %[]% c('b','d')

## factor -- leads to NA with warnings
as.factor(c('a','b','c','d','e')) %[]% c('b','d')

## dates
as.Date(1:5,origin='2000-01-01') %[]% as.Date(c(2,4),origin='2000-01-01')

## helper functions
print_intrval()
plot_intrval()

## recycling values
1:10 %[]% list(1:5, 6)

## overlap: simple interval comparisons

c(2:3) %[o]% c(0:1)
c(2:3) %[o]% c(1:2)
c(2:3) %[o]% c(2:3)
c(2:3) %[o]% c(3:4)
c(2:3) %[o]% c(4:5)

c(0:1) %[o]% c(2:3)
c(1:2) %[o]% c(2:3)
c(2:3) %[o]% c(2:3)
c(3:4) %[o]% c(2:3)
c(4:5) %[o]% c(2:3)

## overlap: vectorized versions
c(2:3) %[o]% list(0:4, 1:5)
c(2:3) %[o]% cbind(0:4, 1:5)
c(2:3) %[o]% data.frame(a=0:4, b=1:5)
list(0:4, 1:5) %[o]% c(2:3)
cbind(0:4, 1:5) %[o]% c(2:3)
data.frame(a=0:4, b=1:5) %[o]% c(2:3)

list(0:4, 1:5) %[o]% cbind(rep(2,5), rep(3,5))
cbind(rep(2,5), rep(3,5)) %[o]% list(0:4, 1:5)

## directional relations

1:4 %[]% c(2,3)
1:4 %[>]% c(2,3)
1:4 %[<]% c(2,3)

1:4 %[)% c(2,3)
1:4 %[>)% c(2,3)
1:4 %[<)% c(2,3)

1:4 %(]% c(2,3)
1:4 %(>]% c(2,3)
1:4 %(<]% c(2,3)

1:4 %()% c(2,3)
1:4 %(>)% c(2,3)
1:4 %(<)% c(2,3)

(ab1 <- cbind(rep(3,5),rep(4,5)))
(ab2 <- cbind(1:5, 2:6))
ab1 %[o]% ab2
ab1 %)o(% ab2
ab1 %[<o]% ab2
ab1 %[o>]% ab2


## timings

set.seed(1)
n <- 10^6
x <- runif(n)
a1 <- runif(n)
b1 <- runif(n)
a2 <- runif(n)
b2 <- runif(n)

system.time(x %[]% list(a1, b1))
system.time(x %)(% list(a1, b1))
system.time(x %[<]% list(a1, b1))
system.time(x %[>]% list(a1, b1))

system.time(x %[)% list(a1, b1))
system.time(x %)[% list(a1, b1))
system.time(x %[<)% list(a1, b1))
system.time(x %[>)% list(a1, b1))

system.time(x %(]% list(a1, b1))
system.time(x %](% list(a1, b1))
system.time(x %(<]% list(a1, b1))
system.time(x %(>]% list(a1, b1))

system.time(x %()% list(a1, b1))
system.time(x %][% list(a1, b1))
system.time(x %(<)% list(a1, b1))
system.time(x %(>)% list(a1, b1))

system.time(list(a2, b2) %[o]% list(a1, b1))
system.time(list(a2, b2) %)o(% list(a1, b1))
system.time(list(a2, b2) %[<o]% list(a1, b1))
system.time(list(a2, b2) %[o>]% list(a1, b1))
