data {
  int<lower=1> K;
  int<lower=1> J;
  int<lower=0> N;
  array[N] vector[J] x;
  array[N] vector[K] y;
  
  // Priors
  int lkj;
  real sigma_sigma;
}
parameters {
  matrix[K, J] beta;
  cholesky_factor_corr[K] L_Omega;
  vector<lower=0>[K] L_sigma;
}

model {
  array[N] vector[K] mu;
  matrix[K, K] L_Sigma;

  for (n in 1:N) {
    mu[n] = beta * x[n];
  }

  L_Sigma = diag_pre_multiply(L_sigma, L_Omega);

  to_vector(beta) ~ std_normal();
  L_Omega ~ lkj_corr_cholesky(lkj);
  L_sigma ~ cauchy(0, sigma_sigma);
  
  //
    y ~ multi_normal_cholesky(mu, L_Sigma);
    
}
generated quantities {
  matrix[K, K] Omega;
  matrix[K, K] Sigma;
  Omega = multiply_lower_tri_self_transpose(L_Omega);
  Sigma = quad_form_diag(Omega, L_sigma); 
  
  
}