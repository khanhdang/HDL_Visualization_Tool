import re; # regular expression
import sys; # supporting I/O access
import pdb; # for debugging


# regex definition
whitespace_at_begin = '^(\s)*'
signal_name = '[a-zA-Z0-9_\\\\\[\]\.\/]+'
parameter_label = whitespace_at_begin+'parameter'
input_label = whitespace_at_begin+'input'
output_label = whitespace_at_begin+'output'
always_process = whitespace_at_begin+'always(\s)*@(\s)*\(.*\)'
MODULE_START = whitespace_at_begin+'module'
MODULE_END = whitespace_at_begin+'endmodule'

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
if __name__ == '__main__':
  hdl = open(sys.argv[1], 'r')
  # svg = open(sys.argv[2], 'w')
  module = module_cutter(hdl);
  for line in module:
      if re.match(module_declare, line):
        line = re.sub(MODULE_START,'',line); #remove module from the line
        label = re.search('(?P<label>'+signal_name+')', line); # match the label
        if (label):
          module_label=label.group('label')
        else:
          print "Failed: cannot find the label"
      if (re.match(parameter_label, line)):
        line = re.sub(parameter_label,'',line); #remove module from the line
        p = re.search('(?P<label>'+signal_name+')', line); # match the label
        if (p):
          line = re.sub(p.group('label'),'',line); #remove module from the line
        v = re.search('(?P<num>[0-9]+)', line); # match the label
        if (v):
          line = re.sub(v.group('num'),'',line); #remove module from the line
        parameter_dict[p.group('label')] = v.group('num')

      if (re.match(input_label, line)):
        line = re.sub(input_label,'',line); #remove module from the line
        p = re.search('(?P<label>\[.*:.*\])', line); # match the width
        if (p):
          w = p.group('label');
          w = re.sub('\[','',w)
          w = re.sub('\]','',w)
          wx= w.split(':')
          if wx[1] == '0':
            w = re.sub('-1','',wx[0])
          line = re.sub('\[.*:.*\]','',line); #remove width from the line
          l = re.search('(?P<label>'+signal_name+')', line); # match the label
          input_dict[l.group('label')] = w; #p.group('label')
        else:
          l = re.search('(?P<label>'+signal_name+')', line); # match the label
          while (l):
            input_dict[l.group('label')] = 1
            line = re.sub(l.group('label'),'',line); #remove signal from the line
            l = re.search('(?P<label>'+signal_name+')', line); # match the label
      if (re.match(output_label, line)):
        if 'reg' in line:
          line = re.sub('reg','', line)
        line = re.sub(output_label,'',line); #remove module from the line
        p = re.search('(?P<label>\[.*:.*\])', line); # match the width
        if (p):
          w = p.group('label');
          w = re.sub('\[','',w)
          w = re.sub('\]','',w)
          wx= w.split(':')
          if wx[1] == '0':
            w = re.sub('-1','',wx[0])
          line = re.sub('\[.*:.*\]','',line); #remove width from the line
          l = re.search('(?P<label>'+signal_name+')', line); # match the label
          output_dict[l.group('label')] =  w; #p.group('label')
        else:
          l = re.search('(?P<label>'+signal_name+')', line); # match the label
          while (l):
            output_dict[l.group('label')] = 1
            line = re.sub(l.group('label'),'',line); #remove signal from the line
            l = re.search('(?P<label>'+signal_name+')', line); # match the label
  print module_label
  print len(parameter_dict)
  print len(input_dict)
  print len(output_dict)
  table = open(module_label+'_tab.csv', 'w')
  table.write('type, label , value\n')
  for k in parameter_dict.keys():
    table.write('parameter,'+k+','+parameter_dict[k]+'\n')
  table.write('type, name , width/index\n')
  for k in input_dict.keys():
    table.write('input,'+k+','+str(input_dict[k])+'\n')
  for k in output_dict.keys():
    table.write('output,'+k+','+str(output_dict[k])+'\n')
  hdl.close()
  table.close()




