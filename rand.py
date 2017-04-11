from random import randint
import optparse

parser = optparse.OptionParser()

parser.add_option('-n', action='store', dest='tot', help='number of integers to generate', default='1000')
parser.add_option('-c', action='store', dest='ceil', help='range ceiling', default='9')

opts, args = parser.parse_args()

with open("rand_ints.txt","w") as f:
    #f.write(opts.tot + '\n');
    for i in range(int(opts.tot)):
        f.write(str(randint(0,int(opts.ceil))) + '\n')

