
## gathering Fungi, Protist, and Animal COI records from Barcode of Life Database Systems (BOLD)

## Need to update this script to check if new taxa names are used, as I manually ...
## ... copied the non-Arthropod, non-Chordate Animal names directly from BOLD website...
## ... http://v4.boldsystems.org/index.php/TaxBrowser_Home

library(bold)
library(taxize)
library(dplyr)
library(here)
library(magrittr)

args <- as.character(commandArgs(trailingOnly = TRUE))


out_path <- args[1]
print(out_path)

# I'm interested to see what our IP is and if it's being blocked
system("ifconfig > ipinfo.txt", intern=TRUE)


otherAnmlNames <- c("Acanthocephala","Acoelomorpha","Brachiopoda",
                    "Bryozoa","Chaetognatha","Cnidaria","Ctenophora",
                    "Cycliophora","Echinodermata","Entoprocta","Gastrotricha",
                    "Gnathostomulida","Hemichordata","Kinorhyncha",
                    "Nematoda","Nematomorpha","Nemertea","Onychophora",
                    "Phoronida","Placozoa","Platyhelminthes","Porifera",
                    "Priapulida","Rhombozoa","Rotifera","Sipuncula",
                    "Tardigrada","Xenacoelomorpha")

fungiNames <- c('Ascomycota', 'Basidiomycota', 'Chytridiomycota',
                'Glomeromycota', 'Myxomycota', 'Zygomycota')

chordateNames <- downstream("Chordata", db = "bold", downto = "order")
chordateNames <- chordateNames$Chordata$name

allArthropod_names <- downstream("Arthropoda", db = "bold", downto = "order")
otherArth_names <- allArthropod_names$Arthropoda %>% filter(name != "Insecta") %>% pull(name)
excludeNames <- c("Annelida","Coleoptera","Diptera","Hymenoptera","Lepidoptera", "Mollusca")
allInsect_names <- downstream("Insecta", db = "bold", downto = "order")
otherInsects_names <- allInsect_names$Insecta %>% filter(!name %in% excludeNames) %>% pull(name)


bigtaxa_list <- downstream(excludeNames, db = "bold", downto = "family")
bigtaxa_names <- c(bigtaxa_list$Coleoptera$name, bigtaxa_list$Diptera$name,
                   bigtaxa_list$Hymenoptera$name, bigtaxa_list$Lepidoptera$name,
                   bigtaxa_list$Annelida$name, bigtaxa_list$Mollusca$name)


# now make one vector to rule them all, one vector to bind them
alltaxa <- c(otherAnmlNames, fungiNames, chordateNames, otherArth_names,
             otherInsects_names, bigtaxa_names)


write(alltaxa, file = out_path)
