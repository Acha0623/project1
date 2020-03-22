data <- read.table('CVerror.txt', sep = '', header = T)
png('CVerror.png', width =600, height = 600, res=100)
plot(data[,1], data[,2], type = 'o', pch = 19, xlab = '', ylab = 'CV error', ylim = c(0.4,1.2))
mtext("k", side = 1, line = 2)
text(2.2, 0.74, '0.78928')
text(3.2, 0.69, '0.73464')
text(4.2, 0.76, '0.79344')
text(5.2, 0.87, '0.90706')
text(5.8, 0.99, '1.04354')
print("Done CVerror plotting")
