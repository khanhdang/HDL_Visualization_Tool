import re; # regular expression
import sys; # supporting I/O access
import pdb; # for debugging
import math


# regex definition
whitespace_at_begin = '^(\s)*'
signal_name = '[a-zA-Z0-9_\\\\\[\]\.\/]+'
parameter_label = whitespace_at_begin+'generic\s*\('
port_label = whitespace_at_begin+'port\s*\('
input_label = whitespace_at_begin+signal_name+'\s*:\s*in'
output_label = whitespace_at_begin+signal_name+'\s*:\sout'
always_process = whitespace_at_begin+'always(\s)*@(\s)*\(.*\)'
MODULE_START = whitespace_at_begin+'entity'
MODULE_END = whitespace_at_begin+'end\s+'+signal_name+'\;'

module_declare = MODULE_START+'\s*'+signal_name

# function to cut a module out of the source code
def module_cutter(lines):
    module = []
    module_append = False
    for line in lines:
        if re.match(MODULE_START,line):
            module_append = True
        if module_append:
            module.append(line)
        if re.match(MODULE_END,line):

            return module
    return module

module_label =''
parameter_dict = {}
input_dict = {}
output_dict = {}
p_name = ''
out = ''
if __name__ == '__main__':
    hdl = open(sys.argv[1], 'r')

    # svg = open(sys.argv[2], 'w')
    module = module_cutter(hdl);
    # print module
    read_mode = ''
    for line in module:
        l = line.split('--')
        line = l[0]
        # print line
        if re.match(module_declare, line):
            line = re.sub(MODULE_START,'',line); #remove module from the line
            label = re.search('(?P<label>'+signal_name+')', line); # match the label
            if (label):
                module_label=label.group('label')
                #print module_label
                table = open(module_label+'_tab.csv', 'w')
                table.write('type, label , index high, index low, data type,  init value\n')
            else:
                print "Failed: cannot find the label"
        if (re.match(parameter_label, line)):
            read_mode = 'generic'
            #print "reading generic.."
        elif (re.match(port_label, line)):
            read_mode = 'port'
            #print line
            #print "reading port..."
        if read_mode == 'generic':
            p = line.split(':'); # split the line
            if (len(p)>1):
                p_name = re.search('(?P<label>'+signal_name+')', p[0]); # match the label
                #print p_name.group('label')
                p_dt = re.search(signal_name, p[1])

                p_type = re.search('(?P<label>\(\s*[0-9]+\s*[a-z]+\s*[0-9]+\s*\))', p[1]); # match the label
                index = re.findall('[0-9]+',p_type.group('label'))
                #print index
            if (len(p)>2):
                p_val = re.search('\"*[0-9a-zA-Z]+\"*', p[2]);
                #print p_val.group(0)
            if (len(p)>1):
                out = 'parameter,'+p_name.group('label')+','+index[0]+','+index[1]+','+p_dt.group(0)+','+p_val.group(0)+'\n'
                table.write(out)
        elif read_mode == 'port':
            if (re.match(input_label, line)):
                # print line
                n = re.search(signal_name, line)
                out = 'input' + ',' + n.group(0)
                line = re.sub(input_label,'',line); #remove module from the line
                p = re.search('(?P<label>\(\s*[0-9]+\s*[a-z]+\s*[0-9]+\s*\))', line); # match the width
                if (p):
                    index = re.findall('[0-9]+',p.group('label'))
                else:
                    index = [0, 0]
                out = out + ',' + str(index[0]) + ',' + str(index[1])

                p = re.search(signal_name, line)
                out = out + ','+ p.group(0) +'\n'
                # print out
                table.write(out)
                input_dict[n.group(0)] = int(index[0])+1-int(index[1])
            if (re.match(output_label, line)):
                #print line
                n = re.search(signal_name, line)
                out = 'output' + ',' + n.group(0)
                line = re.sub(output_label,'',line); #remove module from the line
                p = re.search('(?P<label>\(\s*[0-9]+\s*[a-z]+\s*[0-9]+\s*\))', line); # match the width
                if (p):
                    index = re.findall('[0-9]+',p.group('label'))
                else:
                    index = [0, 0]
                out = out + ',' + str(index[0]) + ',' + str(index[1])

                p = re.search(signal_name, line)
                out = out + ','+ p.group(0) +'\n'
                # print out
                table.write(out)
                output_dict[n.group(0)] = int(index[0])+1-int(index[1])
    print input_dict
    print output_dict
    m1 = max(input_dict, key=input_dict.get)
    m2 = max(output_dict, key=output_dict.get)
    m = float(max (input_dict[m1], output_dict[m2]))
    hdl.close()
    table.close()

    text_h = 30
    text_w = 120
    stick_w = 30
    box_w = 200
    height = (max(len(input_dict), len(output_dict))+1)*text_h
    figure = open(module_label+'.svg', 'w')

    # export to svg file :)
    # it should be program using JINJA but i am lazy now
    figure.write('<?xml version="1.0" encoding="UTF-8" ?>\n')
    figure.write('<svg width="'+str(text_w*2+stick_w*2+box_w+10)+'" height="'+str(80+height)+'" xmlns="http://www.w3.org/2000/svg" version="1.1">\n')
    figure.write('<text x="10" y="'+str(text_h)+'" fill="black"> Module: '+str(module_label)+'</text>\n')
    figure.write('  <rect x="'+str(text_w+stick_w)+'" y="50" width="'+str(box_w)+'" height="'+str(height)+'" fill="white" stroke-width="1" stroke="black" />\n')
    # figure.write('  <line x1="50" y1="50" x2="200" y2="200" stroke="black" stroke-width="1" />\n')
    y_cor = 50+text_h
    for k in input_dict.keys():
        figure.write('<text x="10" y="'+str(y_cor)+'" fill="black" style="text-anchor:right" >'+str(k)+'</text>\n')
        if input_dict[k] == 1:
            figure.write('  <line x1="'+str(text_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="1" />\n')
        else:
            figure.write('  <line x1="'+str(text_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="'+str(math.ceil(int(input_dict[k])*8.0/m))+'" />\n')
        if 'clk' in k or 'clock' in k:
            figure.write('  <polygon points="'+str(text_w+stick_w)+','+str(y_cor-text_h/3)+' '+str(text_w+stick_w)+','+str(y_cor+text_h/3)+' '+str(text_w+stick_w+text_h/3)+','+str(y_cor)+'" stroke="black" fill="white" stroke-width="1" />\n')
        y_cor = y_cor + text_h
    y_cor = 50+text_h
    for k in output_dict.keys():
        figure.write('<text x="'+str(text_w+stick_w*2+box_w + 20)+'" y="'+str(y_cor)+'" fill="black" style="text-anchor:right" >'+str(k)+'</text>\n')
        if output_dict[k] == 1:
            figure.write('  <line x1="'+str(text_w+stick_w+box_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w+box_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="1" />\n')
        else:
            figure.write('  <line x1="'+str(text_w+stick_w+box_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w+box_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="'+str(math.ceil(int(output_dict[k])*8.0/m))+'" />\n')
        y_cor = y_cor + text_h
    figure.write('</svg>')
    figure.close()
