library(bold)
library(taxize)
library(dplyr)
library(here)
library(lubridate)

args <- as.character(commandArgs(trailingOnly = TRUE))


taxa_file <- args[1]
print(taxa_file)

chosen_taxa <- read.table(taxa_file)
chosen_taxa <- chosen_taxa[1,1]

# script modified by DHB from Devons script at: https://osf.io/m5cgs/
# incorporated in his tutorial here https://forum.qiime2.org/t/building-a-coi-database-from-bold-references/16129/1

################################################################################
#### ---------------------- 0) The functions used ------------------------- ####
################################################################################

## filter bold data function:
gatherBOLDdat_function <- function(theboldlist){
  do.call(rbind.data.frame, theboldlist) %>%
    filter(markercode == "COI-5P") %>%
    select(sequenceID, processid, bin_uri, genbank_accession, nucleotides, country, institution_storing,
           phylum_name, class_name, order_name, family_name, genus_name, species_name)
}


## filtering a dataframe to get just the metadata function:
gatherBOLDmetadat_function <- function(thedataframe){
  thedataframe %>%
    select(sequenceID, processid, bin_uri, genbank_accession, country, institution_storing)
}


## generate fasta function:
makefasta_function <- function(thedataframe, kingdomname){
  x.taxon <- thedataframe %>% select(sequenceID, phylum_name, class_name, order_name, family_name, genus_name, species_name)
  x.taxon$kingdom_name <- paste0("k__",kingdomname)
  x.taxon$phylum_name <- x.taxon$phylum_name %>% replace(is.na(.), "") %>% sub("^", "p__", .)
  x.taxon$class_name <- x.taxon$class_name %>% replace(is.na(.), "") %>% sub("^", "c__", .)
  x.taxon$order_name <- x.taxon$order_name %>% replace(is.na(.), "") %>% sub("^", "o__", .)
  x.taxon$family_name <- x.taxon$family_name %>% replace(is.na(.), "") %>% sub("^", "f__", .)
  x.taxon$genus_name <- x.taxon$genus_name %>% replace(is.na(.), "") %>% sub("^", "g__", .)
  x.taxon$species_name <- x.taxon$species_name %>% replace(is.na(.), "") %>% sub("^", "s__", .)
  x.taxon$taxon <- paste(x.taxon$kingdom_name, x.taxon$phylum_name, x.taxon$class_name,
                         x.taxon$order_name, x.taxon$family_name, x.taxon$genus_name,
                         x.taxon$species_name, sep = ";")
  x.taxon <- x.taxon %>% select(sequenceID, taxon)
  x.fasta <- thedataframe %>% select(sequenceID, nucleotides)
  merge(x.taxon, x.fasta)
}


base_outdir <- paste0(here('data', 'tidybug', format(Sys.Date(), '%Y-%m')))
dir.create(base_outdir)
outdir <- paste0(base_outdir, '/bold_files')
dir.create(outdir)
logdir <- paste0(base_outdir, '/logs')
dir.create(logdir)
lendir <- paste0(base_outdir, '/seqlens')
dir.create(lendir)




bold_info <- bold_seqspec(chosen_taxa)


# if there were no records, skip it
if(!is.na(bold_info)){
  bold_df <- bold_info %>%
    filter(markercode == "COI-5P") %>%
    select(sequenceID, processid, bin_uri, genbank_accession, nucleotides, country, institution_storing,
           phylum_name, class_name, order_name, family_name, genus_name, species_name)
  
  # if there are no matching records, skip it
  if(nrow(bold_df) > 0 && ncol(bold_df) > 0){
  
  	alt_chosen_taxa_fasta <- makefasta_function(bold_df, "Animalia")
  write.csv(alt_chosen_taxa_fasta,
            file = paste0(outdir, "/boldCustom_", chosen_taxa, "_seqNtaxa.csv"),
            quote = FALSE, row.names = FALSE)   ## file used to create taxonomy and fasta files
  altchosen_taxa_meta <- gatherBOLDmetadat_function(bold_df)
  write.csv(altchosen_taxa_meta,
            file = paste0(outdir, "/boldCustom_", chosen_taxa, "_meta.csv"),
            quote = FALSE, row.names = FALSE)
  
  
  # for easier processing with qiime later, get the max seq length for this iteration
  write.csv(data.frame(max_len = max(nchar(bold_df$nucleotides))),
            file = paste0(lendir, '/', chosen_taxa, '.csv'),
            quote = FALSE, row.names = FALSE)
  }
  
  
}

