library(tidyverse)
library(R.matlab)

res = readMat('test_RS04.mat')

dat = as.tibble(res$trials)
names(dat) = c('Duration', 'session','trlNo','blkNo','dur1','pdur','production','vrep','Reproduction')


mrep =  dat %>% group_by(session, Duration) %>%
  summarise(mRep = mean(Reproduction), n = n(), se = sd(Reproduction)/sqrt(n-1)) 

mrep$session = factor(mrep$session, labels = c("RWalk", "Random"))

mrep%>%
  ggplot(aes(Duration, mRep, color = session, group = session)) + 
  geom_point() + geom_line() + 
  geom_errorbar(aes(ymin = mRep - se, ymax = mRep +se), width = 0.05) + 
  theme_classic() + 
  geom_abline(slope = 1)

ggplot(dat, aes(trlNo, Duration)) + geom_line() + geom_point()
