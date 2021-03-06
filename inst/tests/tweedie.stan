// modified from
// https://gist.github.com/MatsuuraKentaro/952b3301686c10adcb13

// based on
// Dunn, P. K., and G. K. Smyth. 2005. Series evaluation of
// Tweedie exponential dispersion model densities. Statistics
// and Computing 15:267–280.

data {
  int N;
  int M;
  real<lower=0> Y[N];
  real X[N];
}
parameters {
  real<lower=0> B;
  real<lower=0> phi;
  real<lower=1,upper=2> theta;
}
model {
  real lambda;
  real alpha;
  real beta[N];
  real mu[N];


  B ~ cauchy(0, 5);
  phi ~ cauchy(0, 5);

  for (n in 1:N) {

    mu[n] = B;

    lambda = 1/phi*mu[n]^(2-theta)/(2-theta);
    alpha = (2-theta)/(theta-1);
    beta[n] = 1/phi*mu[n]^(1-theta)/(theta-1);


    if (Y[n] == 0) {
      target += -lambda;
    } else {
      vector[M] ps;
      for (m in 1:M) {
        ps[m] = poisson_lpmf(m | lambda) + gamma_lpdf(Y[n] | m*alpha, beta[n]);
      }
      target += log_sum_exp(ps);
    }
  }
}
