data {
  int<lower=0> N; // number of observations
  int<lower=1> K; // number of population-level effects
  vector[N] red;
  vector[N] blue;
  vector[N] pid;
  array[N] int<lower=0, upper=1> Y;
}
//transformed data {
//    // interaction
//    vector[N] inter_1 = red .* pid;
//    vector[N] inter_2 = blue .* pid;
//    matrix[N, K] x = [red', blue', pid', inter_1', inter_2']';
//}
parameters {
  real Intercept;
  //vector[K] beta;
  real beta_1;
  real beta_2;
  real beta_3;
  real beta_4;
  real beta_5;
}
model {
  Y ~ bernoulli_logit(Intercept + beta_1 * red + beta_2 * blue + beta_3 * pid + beta_4 * red .* pid + beta_5 * blue .* pid);
}
//generated quantities {
//  array[N] int<lower=0, upper = 1> y_rep;
//  y_rep = bernoulli_logit_rng(Intercept + beta_1 * red + beta_2 * blue + beta_3 * pid + beta_4 * red .* pid + beta_5 * blue .* pid);
//}