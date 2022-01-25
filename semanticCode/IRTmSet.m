function SETTINGS = IRTmSet();
%Acquire default SETTINGS structure
% SETTINGS = IRTmSet()
% Field Names and related contents of the SETTINGS structure
% input	string containing path to datafile or alternatively a MATLAB matrix containing the data
% I:	vector with item column numbers
% J:	vector with covariate column numbers (empty vector [] when not applicable)
% Sel:	vector with persons to be included in the analysis (empty vector [] for whole sample)
% delim:	specifies the delimiter between columns when reading in a datafile (default is space)
% alg:	algorithm to be used : 0 for quasi-newton and 1 for generalized EM
% qp:	number of quadrature points to be used when integrating out the latent trait
% iter:	maximum number of iterations the algorithm is allowed to run
% func:	maximum number of likelihood evaluation an algorithm is allowed to run for one iteration
% crit:	value for the stopping criterion of the generalized EM algorithm (no influence on quasi-newton)
% display:	string (‘on’ or ‘off’) regulating display of the optimization procedure’s progress on screen
% con:	optimization type: 0 for regular unconstrained and 1 for constrained 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SETTINGS = struct('input','', 'I', [], 'J', [], 'Sel', [], 'delim', ' ','alg', 0, 'qp', 15, 'iter', 5000, 'func', 50000, 'crit', 0.0001, 'display', 'off', 'con', 0);