library(rentrez)

#create search term
term<-c("Bovidae 16s")

term<-read.csv(file = "test1.csv", header=F)


#use the search term to find record numbers
p.snps <- sapply(term$V1, entrez_search, db = "nucleotide", usehistory = "y", simplify = FALSE, api_key ="28ad5b35e515c1371d7652a210c2784d7608", retmax=200 )


ids <- lapply(p.snps, "[[", "ids")
stackedids<-stack(ids)
names(ids) <- seq_along(ids)

ids<-as.vector(ids)
ids<-as.numeric(ids$`1`)



#pulling sequences from our ids
allrecs<- entrez_fetch(db="nuccore", id=ids, rettype="fasta", api_key ="28ad5b35e515c1371d7652a210c2784d7608")

class(allrecs)
nchar(allrecs)
cat(strwrap(substr(allrecs, 1, 500)), sep="\n")
allrecs







upload<-entrez_post(db="nuccore", id=ids)
allrecs
