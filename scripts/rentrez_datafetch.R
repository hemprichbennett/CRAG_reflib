# https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html#precise-queries-using-mesh-terms
https://jennybc.github.io/purrr-tutorial/ls01_map-name-position-shortcuts.html

library(rentrez)
library(purrr)
library(magrittr)

arthropod_taxa <- entrez_search(db = 'taxonomy',
                                term = 'arthropoda[ORGN]', retmax = 40)
ntaxa <- arthropod_taxa$count # the number of matches

taxa_summary <- entrez_summary(db='taxonomy', id = arthropod_taxa$ids)


arthropod_taxa$ids # the ids given from our query (we used retmax)

#
# all_the_links <- entrez_link(dbfrom='taxonomy', id = arthropod_taxa$ids, db='nucleotide')
#
#
# # possibly the seq ids to download?
# to_query <- all_the_links$links$taxonomy_nuccore
#
# all_recs <- entrez_fetch(db="nucleotide", id=to_query, rettype="fasta")
# class(all_recs)
# all_recs
#
# all_ida <- entrez_link(dbfrom="gene", id=gene_ids, db="nuccore")
#
#
# search_results <- entrez_search(db="nucleotide",
#                                 term="drosophila melanogaster[ORGN] AND barcode[KYWD]", retmax=40)
# search_results$ids
# entrez_db_searchable('nucleotide')



# try getting just the families of arthropods
arth_fams <- entrez_search(db = 'taxonomy',
                           term = 'Arthropoda[ORGN] AND family[RANK]', retmax = 40)

summary_list <- entrez_summary(db = 'taxonomy', id = arth_fams$ids)

# here's a dataframe of the uids of the families and their scientific names
families <- map_dfr(summary_list, extract, c('uid', 'scientificname'))
searchterm <- paste0('(', families$scientificname[2], '[ORGN]) AND (CO1|COI|cytochrome oxidase[GENE])')

all_the_links <- entrez_link(dbfrom='taxonomy', id = searchterm, db='nucleotide')
