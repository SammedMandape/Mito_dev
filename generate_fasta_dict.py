# -*- coding: utf-8 -*-
"""
Created on Mon Jun 14 14:57:03 2021

@author: snm0205
"""
refDict={}
with open("rCRSMagdaPrecision_oneLine.fa", 'r') as fh:
    for line in fh:
        if line.startswith('>'):
            pass
        else:
            x=''.join(line.split())
            refDict={i:c for i,c in enumerate(x,1)}
            
with open("Sammed_mtDNA_data_for_FASTA_June05_2021.txt",'r') as fh1:
    for line in fh1:
        if line.startswith('sample ID'):
            pass
        else:
            y=line.strip().split('\t')
            z=y[1]
            print(z)