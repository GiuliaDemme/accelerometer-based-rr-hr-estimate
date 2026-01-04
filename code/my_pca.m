function [Xpca, lambdas] = my_pca(signal)
    Sigma = cov(signal');

    % Solve the eigenvalue/eigenvector problem.
    [V, D] = eig(Sigma);
    lambdas = diag(D);
    lambdas = lambdas(:)';
    
    % Sort eigenvalues and eigenvectors in descending order
    V = fliplr(V);
    lambdas = fliplr(lambdas);

    % Set the W matrix.
    W = V';

    % Estimate the sources.
    Xpca = W * signal;    
end 
