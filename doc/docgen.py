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
re_pcs = r'(.*) : process\('
re_vars = r'variable (.*): .*'
re_pcs_body = r'begin'
re_sig_asmt = r'(.*)<=(.*)' # signal assignments 
re_var_asmt = r'(.*):=(.*)' # var assignments 
re_end_pcs = r'end process'

re_start_entity = r'entity'
re_pts = r'(.*) : (in|out)' # ports
re_end_entity = r'end'

re_start_arch = r'architecture'
re_sig = r'signal (.*:) .*'
re_start_arch_body = r'begin'

re_comments = r'(--.*)' # comments

in_entity = False
in_arch = False

Ports = recordtype('Ports', 'i o')

ports = Ports(set(),set())
ps = [] # processes

signals = set()

Pcs = recordtype('Pcs', 'name start end vars readset writeset')

Rwset = recordtype('Rwset', 'io sig var')

lines = []

unused = set() # unused signals

# pseudo enum type for current block
entity, arch, arch_body, pcs, pcs_body = enumerate(range(5), start=1)

def main():
    cnt = 1

    blk = 0

    with open(opts.inf,"r") as f:
        for l in f:
            l = l.rstrip('\n')

            # rm comments
            l = re.sub(re_comments,'',l)

            l = l.strip() # rm whitespace

            if l: # if line not empty
                lines.append(l)

            # find current block
            if (blk != entity) and re.search(re_start_entity, l, re.I|re.M):
                #print('start entity')
                blk = entity

            if (blk == entity) and re.search(re_end_entity, l, re.I|re.M):
                #print('end entity')
                blk = 0
                
            if (blk != arch) and re.search(re_start_arch, l, re.I|re.M):
                #print('in arch')
                blk = arch

            if (blk == arch) and re.search(re_start_arch_body, l, re.I|re.M):
                #print('end arch')
                blk = arch_body

            if blk == entity:
                # find ports
                m4 = re.search(re_pts, l, re.I|re.M)
                if m4:
                    dir = m4.group(2).strip()
                    m4b =  re.search(r'port\(+(.*)',m4.group(1),re.I|re.M)
                    if m4b:
                        name = [s.strip() for s in m4b.group(1).split(',')]
                    else:
                        name = [s.strip() for s in m4.group(1).split(',')]

                    for n in name:
                        if dir == 'in':
                            ports.i.add(n)
                        else:
                            ports.o.add(n)

                        # add all ports as unused, will be removed if used
                        unused.add(n)
                
            elif blk == arch:
                # find signals
                m5 = re.search(re_sig, l, re.I|re.M)
                if m5:
                    sigs = [s.strip() for s in m5.group(1)[:-1].split(',')]
                    signals.update(sigs)
                    unused.update(sigs)

            elif blk == arch_body:
                # find start pcs
                m1 = re.search(re_pcs, l, re.I|re.M)
                if m1:
                    ps.append(Pcs(m1.group(1).strip(), cnt, 0, set(),
                                  Rwset(set(), set(), set()),
                                  Rwset(set(), set(), set())))
                    last = ps[-1]
                    blk = pcs
                    #print('p:', str(cnt), l)

            elif blk == pcs:
                m_vars = re.search(re_vars, l, re.I|re.M)
                if m_vars:
                    #print(str(cnt),':',m_vars.group(1).strip())
                    last.vars.add(m_vars.group(1).strip())
                
                if re.search(re_pcs_body, l, re.I|re.M):
                    blk = pcs_body
                    #print('pb:', str(cnt), l)
                    
            if blk == pcs_body:
                # write set
                #signal asmts
                m_sig_asmt = re.search(re_sig_asmt, l, re.I|re.M)
                m_var_asmt = re.search(re_var_asmt, l, re.I|re.M)
                rhs = l # right hand side of asmt
                                
                if m_sig_asmt:
                    rhs = m_sig_asmt.group(2).strip()
                    #print 'line', str(cnt) + ':',  m2.group(1).strip()
                    sig = m_sig_asmt.group(1).strip()
                    # if (last and # some process p has been matched
                    #     last.start <= cnt and # current cnt is btwn start and end of p
                    #     (last.end == 0 or last.end >= cnt)) :
                    if sig in ports.o:
                        last.writeset.io.add(sig)
                    elif sig in ports.i:
                        print('warning: writing to input signal', sig, 'on line', cnt)
                    else:
                        last.writeset.sig.add(sig)
                        
                    unused.discard(sig)
                    # if not (var.endswith('_i') or
                    #         var.endswith('_o')):
                    #     signals.add(var)
                    
                elif m_var_asmt:
                    rhs = m_var_asmt.group(2).strip()
                    var = m_var_asmt.group(1).strip()
                    last.writeset.var.add(var)
                    unused.discard(var)

                #update readsets
                for s in ports.i:
                    if find_word(s)(rhs):
                        last.readset.io.add(s)
                        unused.discard(s)
                # for s in ports.o:
                #     if find_word(s)(rhs):
                #         print('warning: reading output signal', s, 'on line', cnt)
                for s in signals:
                    if find_word(s)(rhs):
                        last.readset.sig.add(s)
                        unused.discard(s)
                for s in last.vars:
                    if find_word(s)(rhs):
                        last.readset.var.add(s)
                        unused.discard(s)
                        
                # find end pcs
                if re.search(re_end_pcs, l, re.I|re.M):
                    last.end = cnt
                    blk = arch_body
                    #print('ep:',l)
                        
            cnt += 1
        # end lines loop
    # done with file

    #tot_lines = cnt-1

    #print(ps)
    if opts.graph:
        print('#ports:', ports)
        print('#signals:', signals)
        print('#unused sigs:', unused)
        print('#ps:', ps)
        print_graph(unused)
    else:
        print_layout1()

def find_word(w):
    return re.compile(r'\b({0})\b'.format(w), flags=re.IGNORECASE).search
        
def add2readset(lnum, sig):
    for p in ps:
        if (p.start <= lnum and p.end >= lnum and
            not (sig in p.vars)):
            #print(line, sig)
            if sig in ports.i:
                p.readset.io.add(sig)
            else:
                p.readset.sig.add(sig)
            return True
    return False

def print_layout1():
    print('file:', opts.inf)
    
    print('in:', ', '.join(ports.i))
    print('out:', ', '.join(ports.o))
    print('sig:', ', '.join(signals))
    print('~used:', ', '.join(unused))
    print()
    for p in ps:
        print('pcs:', p.name)
        print('io_rs:', ', '.join(p.readset.io))
        print('io_ws:', ', '.join(p.writeset.io))
        print('sig_rs:', ', '.join(p.readset.sig))
        print('sig_ws:', ', '.join(p.writeset.sig))
        #print('vars:', ', '.join(p.vars))
        #print('vrs:', ', '.join(p.vrs))
        #print('vws:', ', '.join(p.vws))
        print()
        
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
