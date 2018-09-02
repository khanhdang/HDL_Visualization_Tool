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
  print parameter_dict
  print input_dict
  print output_dict
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

  text_h = 30
  text_w = 100
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
      figure.write('  <line x1="'+str(text_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="8" />\n')
    if 'clk' in k or 'clock' in k:
      figure.write('  <polygon points="'+str(text_w+stick_w)+','+str(y_cor-text_h/3)+' '+str(text_w+stick_w)+','+str(y_cor+text_h/3)+' '+str(text_w+stick_w+text_h/3)+','+str(y_cor)+'" stroke="black" fill="white" stroke-width="1" />\n')
    y_cor = y_cor + text_h
  y_cor = 50+text_h
  for k in output_dict.keys():
    figure.write('<text x="400" y="'+str(y_cor)+'" fill="black" style="text-anchor:right" >'+str(k)+'</text>\n')
    if output_dict[k] == 1:
      figure.write('  <line x1="'+str(text_w+stick_w+box_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w+box_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="1" />\n')
    else:
      figure.write('  <line x1="'+str(text_w+stick_w+box_w)+'" y1="'+str(y_cor)+'" x2="'+str(text_w+stick_w+box_w+stick_w)+'" y2="'+str(y_cor)+'" stroke="black" stroke-width="8" />\n')
    y_cor = y_cor + text_h
  figure.write('</svg>')
  figure.close()




