#!/usr/bin/env nextflow
getname_path = './scripts/bold_getnames.R'
getname_script = file(getname_path)

getdata_path = './scripts/bold_getdata.R'
getdata_script = file(getdata_path)

process bold_getnames {
  queue='short'
  memory = '1G'
  errorStrategy 'retry'
  maxRetries 15
  input:
  file getname_script

  output:
  file 'taxa_*' into taxa_ch
  shell:
  """
  Rscript $getname_script  ids.txt
  cat ids.txt | split -l 1 -a 4 - taxa_
  """
}


process query_bold {
  queue='long'
  memory = '1G'
  time= '2days'
  errorStrategy 'retry'
  maxRetries 15
  queueSize = 5
  input:
  file taxa from taxa_ch.flatten()
  file getdata_script
  output:
  stdout result

  """
  Rscript $getdata_script $taxa
  """
}
