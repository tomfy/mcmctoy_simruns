set log

a = 1
d = 2

xmin = 0.01
xmax = 40

ymin = 0.01
ymax = 1

z = 400

plot [xmin:xmax][ymin:ymax]  'x' using 1:24:26 with errorbars, 0.5*(z*(exp(0.5*(a/x)**2)*(sqrt(2.0*3.14159)*x)**d)**(-1.0) + 1.0)**(-1.0)

pause -1
