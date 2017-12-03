library(itunesr)

gr1 <- getReviews(966758561, 'us', 1)
gr2 <- getReviews(966758561, 'us', 2)
gr3 <- getReviews(966758561, 'us', 3)
gr4 <- getReviews(966758561, 'us', 4)
gr5 <- getReviews(966758561, 'us', 5)
gr6 <- getReviews(966758561, 'us', 6)
gr8 <- getReviews(966758561, 'us', 8)
gr9 <- getReviews(966758561, 'us', 9)
gr10 <- getReviews(966758561, 'us', 10)

gr <- data.frame()
gr <- rbind(gr, gr1, gr2, gr3, gr4, gr5, gr6, gr8, gr9, gr10)
