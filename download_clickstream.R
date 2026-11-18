library(tidyverse)

needed_months <- readRDS("data/processed/needed_months.rds")
dir.create("data/raw/clickstream", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed/clickstream", recursive = TRUE, showWarnings = FALSE)
options(timeout = 3600)

get_clicks <- function(ym, file, url, source_page) {
  out_path <- paste0("data/processed/clickstream/", ym, ".rds")
  if (file.exists(out_path)) return(invisible(NULL))
  
  t0 <- Sys.time()
  raw_path <- file.path("data/raw/clickstream", file)
  download.file(url, destfile = raw_path, mode = "wb", quiet = TRUE)
  t1 <- Sys.time()
  
  # filter raw text lines BEFORE parsing; far faster than read_tsv_chunked
  con <- gzcon(file(raw_path, "rb"))
  prefix <- paste0(source_page, "\t")
  keep <- character()
  repeat {
    lines <- readLines(con, n = 1e6)
    if (length(lines) == 0) break
    keep <- c(keep, lines[startsWith(lines, prefix)])
  }
  close(con)
  
  result <- read_tsv(I(keep), col_names = c("prev", "curr", "type", "n"),
                     col_types = "cccd", quote = "") |>
    mutate(month = ymd(paste0(ym, "-01")))
  
  saveRDS(result, out_path)
  file.remove(raw_path)
  message(ym, ": download ", round(difftime(t1, t0, units = "mins"), 1),
          " min, filter ", round(difftime(Sys.time(), t1, units = "mins"), 1), " min")
}

for (i in seq_len(nrow(needed_months))) {
  m <- needed_months[i, ]
  message("[", i, "/", nrow(needed_months), "] starting ", m$ym)
  tryCatch(
    get_clicks(m$ym, m$file, m$url, m$source_page),
    error = function(e) message("FAILED ", m$ym, ": ", conditionMessage(e))
  )
}
message("DONE")