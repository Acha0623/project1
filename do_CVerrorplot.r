data <- read.table('CVerror.txt', sep = '', header = T)
png('CVerror.png', width =480, height = 480, res=100)
plot(data[,1], data[,2], type = 'o', pch = 19, xlab = 'k', ylab = 'CVerror', ylim = c(0.4,1))
print("Done CVerror plotting")