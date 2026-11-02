## Shared timeline-event annotations for the RMS figures (see Appendix A).
## Provides:
##   events         - tibble of dated events (num, date, label)
##   event_caption  - a two-line caption mapping the numbers to events
##   event_layers(ymax) - dashed vlines + small numbered markers (single-panel)
##   event_vlines()     - dashed vlines only (for faceted plots)
suppressPackageStartupMessages(library(ggplot2))

events <- tibble::tibble(
  num   = 1:4,
  date  = as.Date(c("2019-09-01", "2019-11-01", "2020-02-01", "2020-09-01")),
  label = c("EVALI scare (fall 2019)",
            "JUUL pulls fruit/mint (Nov 2019)",
            "FDA flavored-cartridge enforcement (Feb 2020)",
            "PMTA deadline (Sep 2020)"))

event_caption <- paste0(
  "Events:  1 EVALI scare (fall 2019)   2 JUUL pulls fruit/mint (Nov 2019)\n",
  "3 FDA flavored-cartridge enforcement (Feb 2020)   4 PMTA deadline (Sep 2020)")

## single-panel: dashed lines + numbered markers at top (close 2019 pair staggered)
event_layers <- function(ymax) {
  ev <- dplyr::mutate(events, ytext = c(1.0, 0.90, 1.0, 1.0) * ymax)
  list(
    geom_vline(data = ev, aes(xintercept = date), inherit.aes = FALSE,
               linetype = "dashed", color = "grey45", linewidth = 0.4),
    geom_label(data = ev, aes(x = date, y = ytext, label = num), inherit.aes = FALSE,
               size = 2.8, color = "grey20", fill = "white",
               label.padding = unit(0.9, "pt"), linewidth = 0.2))
}

## faceted: dashed lines only (numbered labels don't place cleanly under free_y)
event_vlines <- function()
  geom_vline(data = events, aes(xintercept = date), inherit.aes = FALSE,
             linetype = "dashed", color = "grey45", linewidth = 0.35)
