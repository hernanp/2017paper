from __future__ import print_function
from random import randint
import optparse, re, sys
from recordtype import recordtype

parser = optparse.OptionParser(usage='usage: %prog [options] arguments')

parser.add_option('-i', action='store', dest='inf', help='input file')
parser.add_option('-o', action='store', dest='outf', help='output file')
parser.add_option('-g', action='store_true', dest='graph', help='output graph format')

opts, args = parser.parse_args()

if not opts.inf:
    parser.error('input file is required')

if opts.outf:
    sys.stdout = open(opts.outf,'w')

# TODO need to fix these REs because right now they match any var name substring
# should consider that var names can only contain letters, numbers and underscore
# and update REs accordingly
re1 = r'(.*) : process\('
re2 = r'(.*)<=(.*) .*'
re3 = r'end process'
re4 = r'(.*) : (in|out) .*'
re5 = r'signal (.*:) .*' # TODO only matches if space after sig name

Ports = recordtype('Ports', 'i o')

ports = Ports(set(),set())
ps = [] # processes

signals = set()

Pcs = recordtype('Pcs', 'name start end readset writeset')

lines = []
sig_asmt_matches = []

unused = set() # unused signals

def main():
    cnt = 1

    with open(opts.inf,"r") as f:
        for l in f:
            l = l.rstrip('\n')
            lines.append(l)
            #print l

            # pcs start
            m1 = re.search(re1, l, re.I|re.M)
            if m1:
                #print 'line', str(cnt) + ': start', m1.group(1).strip()
                ps.append(Pcs(m1.group(1).strip(), cnt, 0, set(), set()))

            if ps:
                last = ps[-1]

            # write set
            m2 = re.search(re2, l, re.I|re.M)
            sig_asmt_matches.append(m2)
            if m2:
                #print 'line', str(cnt) + ':',  m2.group(1).strip()
                var = m2.group(1).strip()
                if (last and # some process p has been matched
                    last.start <= cnt and # current cnt is btwn start and end of p
                    (last.end == 0 or last.end >= cnt)) :
                    last.writeset.add(var)
                    unused.discard(var)
                # if not (var.endswith('_i') or
                #         var.endswith('_o')):
                #     signals.add(var)

            # end pcs
            m3 = re.search(re3, l, re.I|re.M)
            if m3:
                #print 'line', str(cnt) + ':', m3.group().strip()
                if last:
                    last.end = cnt

            # ports
            m4 = re.search(re4, l, re.I|re.M)
            if m4:
                port_re = r'port\(+(.*)'
                dir = m4.group(2).strip()
                m4b = re.search(port_re, m4.group(1).strip(), re.I)
                if m4b:
                    name = m4b.group(1).strip()
                else:
                    name = m4.group(1).strip()

                if dir == 'in':
                    ports.i.add(name)
                else:
                    ports.o.add(name)

                # add all ports as unused, will be removed if used
                unused.add(name)

            # signals
            m5 = re.search(re5, l, re.I|re.M)
            if m5:
                signals.update([s.strip() for s in m5.group(1)[:-1].split(',')])
                    
            cnt += 1
        # end lines loop
    # done with file

    #tot_lines = cnt-1

    # check if inputs being assigned and issue warning
    for m in sig_asmt_matches:
        if m and m.group(1).strip() in ports.i:
            print('#warning: input signal '+ m.group(1).strip() +' being assigned')

    cnt = 1
    unused.update(signals)
    for l in lines:
        # update inputs readsets
        for s in ports.i:
            if s in l:
                #print(l)
                if add2readset(cnt,s):
                    unused.discard(s)
        # update signals readsets
        for s in signals:
            if s in l:
                if add2readset(cnt,s):
                    unused.discard(s)
        cnt += 1

    #print(ps)
    print('#ports:', ports)
    print('#signals:', signals)
    print('#unused sigs:', unused)
    print('#ps:', ps)
    if opts.graph:
        print_graph(unused)

def add2readset(line, sig):
    for p in ps:
        if p.start <= line and p.end >= line:
            #print(line, sig)
            p.readset.add(sig)
            return True
    return False
    
def print_graph(unused) :
    for s in ports.i:
        if not s in unused:
            print('['+ s +'] {border:none;}')

    for s in ports.o:
        if not s in unused:
            print('['+ s +'] {border:none;}')

    for s in signals:
        if not s in unused:
            print('[' + s + '] {border: none;}')
    
    for p in ps:
        inputs = as_str([e for e in p.readset if e not in signals])
        outputs = as_str([e for e in p.writeset if e not in signals])
        #out_sigs = as_str([e for e in p.writeset if e in signals])

        # in edges
        for sig in [e for e in p.readset if e in ports.i]:
            print('['+ sig +'] -> [' + p.name + ']')
        for sig in [e for e in p.readset if e in signals]:
            print('[' + sig + '] -> {style:dotted;} ['+ p.name +']')

        # out edges
        for sig in [e for e in p.writeset if e in ports.o]:
            print('['+ p.name +'] -> [' + sig + ']')
        for sig in [e for e in p.writeset if e in signals]:
            print('['+ p.name +'] -> {style:dotted;} [' + sig + ']')

    
def as_str( s ) :
    str = ''
    for e in s:
        str = str + e + '\\n'
    return str

            
if __name__ == "__main__":
    main()
            
#print ps
#print signals
