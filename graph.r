
library(networkD3)
library(igraph)

# Load data
#source <- read.csv("data/win1997_source_edge_list.txt", header = FALSE)
#target <- read.csv("data/win1997_target_edge_list.txt", header = FALSE)

nodes <- read.csv("data/win1997_node_list.txt", header = TRUE)
edges <- read.csv("data/win1997_edge_list.txt", header = TRUE)

# Create Graphs

gg <- graph_from_edgelist(matrix(unlist(lapply(edges, as.character)), ncol = 2, byrow = TRUE), directed = TRUE)

members <- membership(cluster_optimal(gg))

btwn <- betweenness(gg, v = V(gg), directed = TRUE)

graph_d3 <- igraph_to_networkD3(gg,group = members)

graph_d3$nodes$degree <- as.character(degree(gg, v = V(gg)))

# Plot
forceNetwork(Links = graph_d3$links,
             Nodes = graph_d3$nodes,
             Source = "source",
             Target = "target",
             Group = "group",
             height = 800,
             width = 800,
             NodeID = "name", 
             Nodesize = "degree",
             arrows = FALSE,
             opacity = 0.8,
             fontFamily = "sans-serif",
             fontSize = 14,
             zoom = TRUE)

