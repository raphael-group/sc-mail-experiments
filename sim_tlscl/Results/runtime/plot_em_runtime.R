setwd('/Users/gc3045/sc-mail-experiments/sim_tlscl/Results/runtime')

require(ggplot2)
library(dplyr)

# d = read.table("em_runtime_breakdown.txt",header=T,sep=',')
d = read.table("em_runtime_breakdown_v2_closedform.txt",header=T,sep=',')
d2 = read.table("em_runtime_breakdown_v2_nonconvex.txt", header=F, sep=",")
colnames(d2) <- colnames(d) 
d <- rbind(d, d2)

dim(d)
d$emiter <- as.numeric(d$emiter)
d$time <- as.numeric(d$time)
d$size <- as.numeric(d$size)

#d <- d[!is.na(d$size), ]

# drop the first emiter since it seems skewed!
d = d[d$emiter != 1,]

unique(d$size)
head(d)
dim(d) # 129488  X    6

lm_fit_mstep_convex <- lm(log10(time) ~ log10(size), data = subset(d, flag == "closed-form" & type == "mstep"))
slope_mstep_convex <- coef(lm_fit_mstep_convex)[2]
intercept_mstep_convex <- coef(lm_fit_mstep_convex)[1]

lm_fit_mstep_nonconvex <- lm(log10(time) ~ log10(size), data = subset(d, flag == "non-convex" & type == "mstep"))
slope_mstep_nonconvex <- coef(lm_fit_mstep_nonconvex)[2]
intercept_mstep_nonconvex <- coef(lm_fit_mstep_nonconvex)[1]

lm_fit_estep <- lm(log10(time) ~ log10(size), data = subset(d, type == "estep"))
slope_estep <- coef(lm_fit_estep)[2]
intercept_estep <- coef(lm_fit_estep)[1]

#median(d[d$size == 5000,]$estep, na.rm=TRUE)
install.packages("latex2exp")
library(latex2exp)

e1 <- expression(Mstep:~nu==0)
e2 <- expression(Mstep:~nu>0)
e3 <- expression(Estep)
cbPalette <- c("#000000", "#E69F00", "gray", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
sizes <- sort(unique(d$size))
# I want to add std deviation lines for each one
p <- ggplot(d, aes(x = size)) + #, color=flag)) +
  #stat_summary(data = subset(d, type=="estep"), fun="mean", geom="point", aes(y = time, color="e-step"), size=2) + 
  geom_point(data = subset(d, type=="estep"), aes(y = time, color="e-step"), stat = "summary", size=2) + 
  geom_point(data = subset(d, flag == "closed-form" & type=="mstep"), aes(y = time, color=flag), stat = "summary", size=2) + 
  geom_point(data = subset(d, flag == "non-convex" & type=="mstep"), aes(y = time, color=flag), stat = "summary", size=2) + 
  #stat_summary(aes(y=time)) + 
  geom_smooth(data = subset(d, type == "estep"), aes(y = time, color = "e-step"), method = "lm", se = FALSE) + 
  geom_smooth(data = subset(d, flag == "closed-form" & type == "mstep"), aes(y = time, color = flag), method = "lm", se = FALSE) + 
  geom_smooth(data = subset(d, flag == "non-convex" & type == "mstep"), aes(y = time, color = flag), method = "lm", se = FALSE) + 
  labs(x = "N*k", y = "runtime (s)", title = "Average EM Runtime Log-log Breakdown") + 
  guides(color = guide_legend(nrow = 2), shape = guide_legend(nrow = 2, override.aes = list(color = c("black", "black")))) + 
  theme_bw() +
  scale_colour_manual(name = "Cases", values = cbPalette, labels = c(e1, e3, e2)) + 
  scale_x_continuous(expand = c(0.05, 0.1), trans='log10', labels = function(x) paste(x,"*", "30", "=", x*30) ) +
  scale_y_continuous(trans='log10') + 
  theme(legend.position = "bottom") +
  geom_text(aes(x=250, y=0.015, label=sprintf("y=%.2fx%.2f", slope_mstep_convex, intercept_mstep_nonconvex)), color="black") +
  geom_text(aes(x=250, y=0.3, label=sprintf("y=%.2fx%.2f", slope_estep, intercept_estep)), color="#E69F00") +
  geom_text(aes(x=250, y=1.0, label=sprintf("y=%.2fx%.2f", slope_mstep_nonconvex, intercept_mstep_nonconvex)), color="grey") 
p
ggsave("simtlscl_em_runtime_comparison.pdf", p, width=7, height=4)


# plot total time vs number of cells

d_meta = read.table("meta_total_varycells.txt",header=T,sep=',')
head(d_meta)

lm_fit_noheritable <- lm(log10(totaltime) ~ log10(size), data = subset(d_meta, flag == "closed-form"))
slope_noheritable <- coef(lm_fit_noheritable)[2]
intercept_noheritable <- coef(lm_fit_noheritable)[1]

lm_fit_heritable <- lm(log10(totaltime) ~ log10(size), data = subset(d_meta, flag == "non-convex"))
slope_heritable <- coef(lm_fit_heritable)[2]
intercept_heritable <- coef(lm_fit_heritable)[1]

p1 <- ggplot(d_meta, aes(x=size, y=totaltime)) +
  stat_summary(data=subset(d_meta, flag=="closed-form"), aes(color=flag)) + 
  geom_smooth(data = subset(d_meta, flag == "closed-form"), aes(color=flag), method = "lm", se = FALSE) +
  geom_smooth(data = subset(d_meta, flag == "non-convex"), aes(color=flag), method = "lm", se = FALSE) + 
  #stat_summary(data=subset(d_meta, flag=="closed-form"), aes(color=flag), geom="line") + 
  stat_summary(data=subset(d_meta, flag=="non-convex"), aes(color=flag)) +
  #stat_summary(data=subset(d_meta, flag=="non-convex"), aes(color=flag), geom="line") +
  scale_color_manual(values = c("#1f78b4", "#33a02c"), labels=c(expression(nu==0), expression(nu>0))) +  # Blue and green
  scale_y_continuous(trans='log10') + scale_x_continuous(trans='log10') + 
  geom_text(aes(x=500, y=1000, label=sprintf("y=%.2fx%.2f", slope_heritable, intercept_heritable)), color= "#33a02c") +
  geom_text(aes(x=500, y=10, label=sprintf("y=%.2fx%.2f", slope_noheritable, intercept_noheritable)), color="#1f78b4") +
  ylab("Runtime of Branch Length Estimation (s)") +
  xlab("# Cells") +
  labs(color = "Cases") +
  theme_bw() +   theme(legend.position = "bottom")
p1

p2 <-ggplot(d_meta, aes(x=size, y=totalnumiter,color=flag)) + # as.factor(size)
  #stat_summary(data=subset(d_meta, flag=="closed-form"), aes(color=flag)) + 
  #stat_summary(data=subset(d_meta, flag=="closed-form"), aes(color=flag), geom="line") + 
  #stat_summary(data=subset(d_meta, flag=="non-convex"), aes(color=flag)) +
  #stat_summary(data=subset(d_meta, flag=="non-convex"), aes(color=flag), geom="line") +
  #stat_summary(geom="line") +
  stat_summary() + 
  stat_summary(geom="line") + 
  #geom_boxplot() + 
  #stat_summary(position=position_dodge(width=0.8)) + 
  scale_color_manual(values = c("#1f78b4", "#33a02c"), labels=c(expression(nu==0), expression(nu>0))) +  # Blue and green
  #scale_y_continuous(trans='log10') + 
  scale_x_log10() + scale_y_log10() + 
  ylab("# EM Iterations") +
  xlab("# Cells") +
  labs(color = "Cases") +
  theme_bw() +   theme(legend.position = "bottom")
p2
library(ggpubr)
combined_plot <- ggarrange(p1, p2, common.legend=TRUE, legend="bottom", ncol = 2)

#install.packages('Cairo')
#library(Cairo)

ggsave("simtlscl_em_meta.pdf", combined_plot, width=7, height=4) #, type="cairo")


