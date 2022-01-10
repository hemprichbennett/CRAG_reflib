
getname_path = './scripts/ref_library/bold_getnames.R'
getname_script = file(getname_path)

getdata_path = './scripts/ref_library/bold_getdata.R'
getdata_script = file(getdata_path)

process bold_getnames {

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
  input:
  file taxa from taxa_ch.flatten()
  file getdata_script
  output:
  stdout result

  """
  Rscript $getdata_script $taxa
  """
}
