library(tidyverse)
library(data.table)


################################################################
# reference genome
rcrsRef <- read_delim("rCRSMagdaPrecision_oneLine.fa", 
                      delim = "\t", 
                      skip = 1,
                      col_names = F)

# convert to vector
rcrsRef %>% pull() %>% str_split("") %>% unlist()->rcrsRef_1

# create an empty data frame
dict_rcrsRef_df <- data.frame(col1=character(0))

# convert to data frame
for (i in seq_along(rcrsRef_1)){
  rbind( paste(i, rcrsRef_1[[i]]), dict_rcrsRef_df)->dict_rcrsRef_df
}

# separate seq col into seq and pos, convert pos to int
dict_rcrsRef_df_final <- as_tibble(dict_rcrsRef_df %>%
                                     rename("col1"="X.1.G.") %>%
                                     separate(col1, into=c("pos","bp")) %>%
                                     mutate(pos=as.integer(pos))) 
################################################################



# read in the sample files with two cols, first is sample name
# second col is snps with pos and bp (eg 73G)
samp<-fread("Sammed_mtDNA_data_for_FASTA_June05_2021.txt",sep = "\t")
#samp %>% filter(`sample ID`=="BDY074") -> x
samp %>% group_split(`sample ID`) -> samp_grp
# foo[[4]] -> foo2
# foo[[25]] -> foo2


####################################################################
# .f to process the sample files with reference and create fasta seq
create_fasta <- function(x, y=dict_rcrsRef_df_final){
  x %>% separate_rows(haplotype,sep = "\\s") %>%
  rename("SampleID"=`sample ID`) %>% 
  separate(haplotype, into = c("pos","bp"), sep = "(?<=[0-9.])(?=[A-Zdel])") %>%
  mutate(pos=as.integer(pos)) %>%
  group_by(SampleID, pos) %>%
  summarise(bp1=paste0(bp,collapse = ""))->tempx
  
  # full outer join with samples
  y %>% full_join(tempx, by = c("pos"="pos")) -> temp2gether
  
  # getting ref seq and snps in same col
  temp2gether %>% mutate(fasta=ifelse(is.na(bp1),bp,bp1))->temp2gether_1
  
  # getting the sample name
  samName<-temp2gether_1 %>% 
    filter(!is.na(SampleID)) %>% 
    distinct(SampleID) %>% pull(SampleID)
  
  # convert del to empty char and collapse the col into vector of seq  
  temp2gether_1 %>% mutate(fasta=ifelse(fasta=="del","",fasta)) %>%
    select(fasta) %>% 
    pull() %>% 
    paste(collapse = "") -> temp2gether_2
  
  #TODO: see https://stackoverflow.com/questions/32701021/write-a-list-of-character-vector-to-a-single-file-in-r
  # convert to dataframe and set col name as samplename
  temp2gether_final<- as.data.frame(temp2gether_2)
  colnames(temp2gether_final)<-c(paste0(">",samName))
  
  return(temp2gether_final)
  
}
####################################################################

map(samp_grp, create_fasta) -> create_fasta_out
#map_dfr(samp_grp, create_fasta) -> create_fasta_out_1

unlist(create_fasta_out, use.names = T)->create_fasta_out_final

# for (name in names(foo)){
#   browser()
#   write_lines()
#   print(foo[name])
# }
#write_lines(foo,file="foo.txt",sep = "\n")

write.table(create_fasta_out_final,file = "fasta_out_final.txt", quote=F, sep = "\n",col.names = F)

