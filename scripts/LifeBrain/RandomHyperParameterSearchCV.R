args = commandArgs(TRUE)

eta=as.numeric(args[1])
max_depth=as.numeric(args[2])
gamma=as.numeric(args[3])
min_child_weight=as.numeric(args[4])
nrounds=as.numeric(args[5])
i=as.numeric(args[6])
idx=as.numeric(args[7])
data_folder=as.character(args[8])
sex_split=try(as.logical(args[9]))


HyperParameterSearchCV = function(eta, max_depth, gamma, min_child_weight, nrounds, i, idx, data_folder, sex_split) {
  
  if(missing(sex_split)) { sex_split = F}
  
  print(idx)
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
                       print_every_n = 30,
                       early_stop_round = 10,
                       maximize = F)
      
      rmse = c(rmse, min(xgbcv$evaluation_log$test_rmse_mean))
      Nrsme = c(Nrsme, which.min(xgbcv$evaluation_log$test_rmse_mean))
      train = c(train, min(xgbcv$evaluation_log$train_rmse_mean))
      
   }
      
    
  print("loading file")
  load(file.path(data_folder,"RandomHyperParameterSearchCV.Rda"))
  print("including output in data.frame")
  print(dim(xgb_grid_1))
  print(xgb_grid_1[1,])
  xgb_grid_1$rmse[idx]=mean(rmse)
  xgb_grid_1$Nrmse[idx]=mean(Nrsme)
  xgb_grid_1$idx[idx] = i
  xgb_grid_1$train[idx]=mean(train)
  print("saving file")
  Sys.sleep(1)
  print(xgb_grid_1[idx,])
  save("xgb_grid_1", 
       file = file.path(data_folder,"RandomHyperParameterSearchCV.Rda"))
  Sys.sleep(1)
}

HyperParameterSearchCV(eta, max_depth, gamma, min_child_weight, nrounds, i,idx, data_folder, sex_split)
