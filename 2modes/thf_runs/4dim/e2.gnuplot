a=0.5
d=4
x=1
unset log
set key top left
set log x
set style data points

max(u,v) = (u>v)? u : v
f(x,a,n) = a/x**(1.0/n)
h(x,b,c) = max(0, b*(x-c))
g(x,a,b,c,k,n) = (f(x,a,n)**k + h(x,b,c)**k)**(1.0/k)



plot [1:25000][*:*] \
        './2T/x' using x:(a**2*d/$24 - 2.0):(a**2*d/$24**2*$26) with errorbars t'2T' pt 5, \
        './4T/x' using x:(a**2*d/$24 - 4.0):(a**2*d/$24**2*$26) with errorbars t'4T' pt 7, \
        './8T/x' using x:(a**2*d/$24 - 8.0):(a**2*d/$24**2*$26) with errorbars t'8T' pt 8, \
        './16T/x' using x:(a**2*d/$24 - 16.0):(a**2*d/$24**2*$26) with errorbars t'16T' pt 9, \
        './32T/x' using x:(a**2*d/$24 - 32.0):(a**2*d/$24**2*$26) with errorbars t'32T' pt 13

pause -1

