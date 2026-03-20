local({
  # Get the directory of the current script
  dir_path <- this.path::this.dir()
  
  # Find all .R files in this directory except this one
  all_files <- list.files(dir_path, pattern = "\\.R$", full.names = TRUE)
  to_source <- all_files[!grepl("plots_plotly\\.R$", all_files)]
  
  # Source them
  invisible(lapply(to_source, source))
})