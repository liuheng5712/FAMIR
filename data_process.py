import numpy as np
import scipy.io as sio
from math import ceil as ceil
from math import sqrt as sqrt


input = open('isolet.data','rb')
contents = input.read().splitlines()


for i in range(len(contents)):
	line = contents[i]
	temp = line.split(',')
	temp = map(float, temp)
	contents[i] = temp

content = np.array(contents)
x,y = content.shape	
	
for i in range(y-1):
		min = np.min(content[:, i])
		max = np.max(content[:, i])
		bins = np.linspace(min, max, 300)#ceil(sqrt(x)/2))
		content[:, i] = np.digitize(content[:, i], bins)


		
sio.savemat('isolet.mat',{'isolet':content})
print 'finished'
	


