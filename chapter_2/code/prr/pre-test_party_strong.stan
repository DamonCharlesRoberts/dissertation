// Title: pre-test party model with weakly informative priors

// Notes:
// * Description: Pre-test party model using weakly informative priors
// * Updated: 2023-03-13
// * Updated by: dcr

functions {
  /* cumulative-logit log-PDF for a single response
   * Args:
   *   y: response category
   *   mu: latent mean parameter
   *   disc: discrimination parameter
   *   thres: ordinal thresholds
   * Returns:
   *   a scalar to be added to the log posterior
   */
  real cumulative_logit_lpmf(int y, real mu, real disc, vector thres) {
    int nthres = num_elements(thres);
    if (y == 1) {
      return log_inv_logit(disc * (thres[1] - mu));
    } else if (y == nthres + 1) {
      return log1m_inv_logit(disc * (thres[nthres] - mu));
    } else {
      return log_diff_exp(log_inv_logit(disc * (thres[y] - mu)),
                          log_inv_logit(disc * (thres[y - 1] - mu)));
    }
  }
  /* cumulative-logit log-PDF for a single response and merged thresholds
   * Args:
   *   y: response category
   *   mu: latent mean parameter
   *   disc: discrimination parameter
   *   thres: vector of merged ordinal thresholds
   *   j: start and end index for the applid threshold within 'thres'
   * Returns:
   *   a scalar to be added to the log posterior
   */
  real cumulative_logit_merged_lpmf(int y, real mu, real disc, vector thres,
                                    array[] int j) {
    return cumulative_logit_lpmf(y | mu, disc, thres[j[1] : j[2]]);
  }
  /* ordered-logistic log-PDF for a single response and merged thresholds
   * Args:
   *   y: response category
   *   mu: latent mean parameter
   *   thres: vector of merged ordinal thresholds
   *   j: start and end index for the applid threshold within 'thres'
   * Returns:
   *   a scalar to be added to the log posterior
   */
  real ordered_logistic_merged_lpmf(int y, real mu, vector thres,
                                    array[] int j) {
    return ordered_logistic_lpmf(y | mu, thres[j[1] : j[2]]);
  }
}
data {
  int<lower=1> N; // total number of observations
  array[N] int<lower=1, upper=3> Y; // response variable
  int<lower=2> nthres; // number of thresholds
  int<lower=1> K; // number of population-level effects
  matrix[N, K] X; // population-level design matrix
  int prior_only; // should the likelihood be ignored?
}
transformed data {
  int Kc = K;
  matrix[N, Kc] Xc; // centered version of X
  vector[Kc] means_X; // column means of X before centering
  for (i in 1 : K) {
    means_X[i] = mean(X[ : , i]);
    Xc[ : , i] = X[ : , i] - means_X[i];
  }
}
parameters {
  vector[Kc] b; // population-level effects
  ordered[nthres] Intercept; // temporary thresholds for centered predictors
}
transformed parameters {
  real disc = 1; // discrimination parameters
  real lprior = 0; // prior contributions to the log posterior
  lprior += normal_lpdf(b | 1, 3);
  lprior += student_t_lpdf(Intercept | 3, 0, 2.5);
}
model {
  // likelihood including constants
  if (!prior_only) {
    // initialize linear predictor term
    vector[N] mu = rep_vector(0.0, N);
    mu += Xc * b;
    for (n in 1 : N) {
      target += ordered_logistic_lpmf(Y[n] | mu[n], Intercept);
    }
  }
  // priors including constants
  target += lprior;
}
generated quantities {
  // simulate data from the posterior
  vector[N] y_rep;
  vector[N] mu = rep_vector(0.0, N);
  mu += Xc * b;
  for (i in 1 : N) {
    y_rep[i] = ordered_logistic_rng(mu[i], Intercept);
  }
  // compute actual thresholds
  vector[nthres] b_Intercept = Intercept + dot_product(means_X, b);
}