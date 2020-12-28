args = commandArgs(TRUE)

eta=as.numeric(args[1])
max_depth=as.numeric(args[2])
gamma=as.numeric(args[3])
min_child_weight=as.numeric(args[4])
nrounds=as.numeric(args[5])
data_folder=as.character(args[6])
sex_split=try(as.logical(args[7]))


BrainAgeCV = function(eta, max_depth, gamma, min_child_weight, nrounds, data_folder, sex_split = F) {
  
  if(missing(sex_split)) { sex_split = F}
  
  basefolder="/cluster/projects/p274/projects/p024-modes_of_variation"
  data_folder=file.path(basefolder, data_folder)
  
  .libPaths()
  list.of.packages = c("dplyr", "xgboost", "caret")
  new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages, repos = "file://tsd/shared/R/cran")
  lapply(list.of.packages, require, character.only = T)
  
  load(file.path(data_folder, "all_TrainTest.Rda"))
  
  if(sex_split == T) {nfold = 5} else {nfold = 10}
  
  params = list(booster = "gbtree",
              objective = "reg:squarederror",
              eta = eta,
              max_depth=max_depth,
              gamma = gamma,
              min_child_weight = min_child_weight)

  train = Nrsme = rmse = c()
  
  for(j in 1:length(data.train)) {
    xgbcv <- xgb.cv( params = params,
                     data = data.train[[j]],
                     label = label.train[[j]],
                     nrounds = nrounds,
                     nfold = nfold,
                     showsd = T,
                     stratified = T,
                     print_every_n = 10,
                     early_stop_round = 10,
                     maximize = F,
                     prediction = T)
    
    if(sex_split == T) {
      save(xgbcv, file = file.path(data_folder, paste0("xgbcv.CV.", as.character(j-1), ".Rda")))  
    } else {
      save(xgbcv, file = file.path(data_folder, "xgbcv.CV.Rda"))  
    }
  }
}

BrainAgeCV(eta, max_depth, gamma, min_child_weight, nrounds, data_folder, sex_split)



