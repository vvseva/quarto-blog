# Script to fetch latest publications from Google Scholar and automatically format them into _publications_list.qmd
# Run this script whenever you have a new publication.
# In R / RStudio: source("scripts/update_publications.R")
# In Terminal: Rscript scripts/update_publications.R

options("R.cache.rootPath" = tempdir())
Sys.setenv(R_CACHE_ROOTPATH = tempdir())

scholar_id <- "TycFXMIAAAAJ"
data_file <- "publications_data.csv"
output_qmd <- "_publications_list.qmd"

cat("Fetching publications from Google Scholar (ID:", scholar_id, ")...\n")

if (!requireNamespace("scholar", quietly = TRUE)) {
  stop("The 'scholar' package is required. Install it using install.packages('scholar')")
}

pubs <- tryCatch({
  scholar::get_publications(scholar_id)
}, error = function(e) {
  cat("Warning: Could not connect to Google Scholar (", e$message, "). Using cached data if available.\n")
  if (file.exists(data_file)) read.csv(data_file, stringsAsFactors = FALSE) else NULL
})

if (is.null(pubs) || nrow(pubs) == 0) {
  stop("No publication data available.")
}

# Cache the raw data
write.csv(pubs, data_file, row.names = FALSE)
cat("Cached", nrow(pubs), "publications to", data_file, "\n")

# Order by year descending, then citations
pubs$year_num <- suppressWarnings(as.numeric(pubs$year))
pubs$year_num[is.na(pubs$year_num)] <- 0
pubs <- pubs[order(-pubs$year_num, -pubs$cites), ]

# Map of known pubid to local project/post writeup links
post_links <- list(
  "0EnyYjriUFMC" = list(url = "posts/17-multi100/index.html", label = "Reflections on Multi100"),
  "roLk4NBRz8UC" = list(url = "posts/14-EngagementApp/learning_app.html", label = "Project notes"),
  "LkGwnXOMwfcC" = list(url = "posts/12-I4R/I4R.html", label = "Replication walkthrough"),
  "W7OEmFMy1HYC" = list(url = "posts/3-CERES/ceres.html", label = "Project writeup"),
  "u5HHmVD_uO8C" = list(url = "posts/2-Dota/dota.html", label = "Dota 2 transfers post"),
  "u-x6o8ySG0sC" = list(url = "posts/2-Dota/dota.html", label = "Conference paper details")
)

lines <- c()
lines <- c(lines, '::: {.system-window}')
lines <- c(lines, '::: system-titlebar')
lines <- c(lines, '[Google Scholar Articles]{.system-title}')
lines <- c(lines, ':::')
lines <- c(lines, '')
lines <- c(lines, '::: system-content')
lines <- c(lines, '<ul class="system-publications-list" style="margin-top: 0.5rem;">')

for (i in seq_len(nrow(pubs))) {
  p <- pubs[i, ]
  title <- trimws(p$title)
  # Clean any em-dashes
  title <- gsub("—|--", "-", title)
  
  authors <- trimws(p$author)
  authors_formatted <- gsub("(V Suschevskiy|Vsevolod Suschevskiy|Suschevskiy, V\\.|Suschevskiy, Vsevolod)", "<strong>\\1</strong>", authors)
  
  venue <- trimws(p$journal)
  venue <- gsub("—|--", "-", venue)
  
  number <- trimws(p$number)
  number <- gsub("—|--", "-", number)
  
  year <- p$year
  year_str <- if (!is.na(year) && nchar(as.character(year)) > 0) as.character(year) else ""
  pubid <- p$pubid
  cites <- p$cites
  
  scholar_url <- paste0(
    "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=TycFXMIAAAAJ&citation_for_view=TycFXMIAAAAJ:",
    pubid
  )
  
  meta_parts <- c()
  if (nchar(venue) > 0) meta_parts <- c(meta_parts, venue)
  if (nchar(number) > 0) meta_parts <- c(meta_parts, number)
  if (nchar(year_str) > 0) meta_parts <- c(meta_parts, year_str)
  meta_str <- paste(meta_parts, collapse = ", ")
  
  is_last <- (i == nrow(pubs))
  border_style <- if (is_last) "" else "border-bottom: 1px dotted #ccc;"
  
  lines <- c(lines, sprintf('  <li style="margin-bottom: 1rem; padding-bottom: 0.8rem; %s">', border_style))
  lines <- c(lines, sprintf('    <span class="pub-title" style="font-size: 14px; margin-bottom: 4px;"><a href="%s" target="_blank">%s</a></span>', scholar_url, title))
  lines <- c(lines, sprintf('    <div style="font-size: 13px; color: #333; margin-bottom: 3px;">%s</div>', authors_formatted))
  if (nchar(meta_str) > 0) {
    lines <- c(lines, sprintf('    <div style="font-size: 12px; color: #666; margin-bottom: 6px;"><em>%s</em></div>', meta_str))
  }
  
  links <- c(sprintf('<a href="%s" target="_blank">Google Scholar</a>', scholar_url))
  if (!is.null(post_links[[pubid]])) {
    links <- c(links, sprintf('<a href="%s">%s</a>', post_links[[pubid]]$url, post_links[[pubid]]$label))
  }
  if (!is.na(cites) && cites > 0) {
    links <- c(links, sprintf('<span>%d citations</span>', cites))
  }
  
  lines <- c(lines, sprintf('    <div style="font-size: 12px; display: flex; gap: 10px; flex-wrap: wrap;">%s</div>', paste(links, collapse = ' <span style="color: #bbb;">|</span> ')))
  lines <- c(lines, '  </li>')
}

lines <- c(lines, '</ul>')
lines <- c(lines, ':::')
lines <- c(lines, ':::')

writeLines(lines, output_qmd, useBytes = TRUE)
cat("Successfully generated and formatted", output_qmd, "\n")
