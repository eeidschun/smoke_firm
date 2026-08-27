## Simple labeled schematics of the three T2 e-cigarette form factors, tinted in
## the same colors used for each type elsewhere in the notes. Not photos, not to
## scale — a novice-oriented orientation figure.
rm(list = ls()); suppressPackageStartupMessages(library(tidyverse))
out_dir <- file.path("pr", "output", "prelim_analysis", "p_and_n_decomp_t2")
cols <- c("Closed pod" = "#3b528b", "Disposable" = "#21908c", "Open refill" = "#5ec962")

rects <- tibble::tribble(
  ~device,        ~part,    ~xmin, ~xmax, ~ymin, ~ymax,
  "Closed pod",   "body",   0.38,  0.62,  0.00,  0.52,   # reusable battery
  "Closed pod",   "pod",    0.42,  0.58,  0.52,  0.78,   # prefilled pod
  "Closed pod",   "tip",    0.46,  0.54,  0.78,  0.86,   # mouthpiece
  "Disposable",   "body",   0.40,  0.60,  0.00,  0.78,   # all-in-one
  "Disposable",   "tip",    0.45,  0.55,  0.78,  0.86,
  "Open refill",  "body",   0.26,  0.50,  0.00,  0.40,   # mod / battery
  "Open refill",  "pod",    0.31,  0.45,  0.40,  0.66,   # tank
  "Open refill",  "tip",    0.35,  0.41,  0.66,  0.74,
  "Open refill",  "bottle", 0.60,  0.74,  0.06,  0.42,   # e-liquid bottle
  "Open refill",  "cap",    0.635, 0.705, 0.42,  0.50
) %>% mutate(device = factor(device, levels = names(cols)),
             is_body = part == "body")

labels <- tibble::tribble(
  ~device,        ~txt,
  "Closed pod",   "reusable battery + prefilled pod\nnicotine set by manufacturer",
  "Disposable",   "all-in-one, single-use (thrown away)\nnicotine set by manufacturer",
  "Open refill",  "refillable tank filled from a bottle\nnicotine chosen / varied by the user"
) %>% mutate(device = factor(device, levels = names(cols)))

p <- ggplot(rects) +
  geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                fill = device, alpha = is_body), color = "grey25", linewidth = 0.4) +
  geom_text(data = labels, aes(x = 0.5, y = -0.10, label = txt),
            size = 3, lineheight = 0.95, vjust = 1, color = "grey15") +
  facet_wrap(~device, nrow = 1) +
  scale_fill_manual(values = cols, guide = "none") +
  scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.5), guide = "none") +
  coord_cartesian(xlim = c(0.18, 0.82), ylim = c(-0.40, 0.92)) +
  labs(title = "The three e-cigarette product types (schematic, not to scale)") +
  theme_void(base_size = 12) +
  theme(strip.text = element_text(face = "bold", size = 13),
        plot.title = element_text(hjust = 0.5, size = 13),
        panel.spacing = unit(1, "lines"))
ggsave(file.path(out_dir, "ecig_type_schematics.png"), p, width = 10, height = 4.2, dpi = 200)
cat("Wrote ecig_type_schematics.png\n")
