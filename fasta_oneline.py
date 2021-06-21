# -*- coding: utf-8 -*-
"""
Created on Mon Jun 14 14:30:50 2021

@author: snm0205
"""
input_file="rCRSMagdaPrecision.fa"
output_file="rCRSMagdaPrecision_oneLine.fa"
with open (input_file, 'r') as infile, open(output_file, 'w') as outfile:
        block = []
        #[print(line) for line in infile]
        for line in infile:
            if line.startswith('>'):
                if block:
                    outfile.write(''.join(block) + '\n')
                    block = []
                outfile.write(line)
            else:
                block.append(line.strip())
            
        if block:
            outfile.write(''.join(block) + '\n')
