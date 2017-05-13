/**
 * A best exemplar finder.  Scans over the entire image (using a
 * sliding window) and finds the exemplar which minimizes the sum
 * squared error (SSE) over the to-be-filled pixels in the target
 * patch. 
 *
 * @author Sooraj Bhat
 */
#include "mex.h"
#include <limits.h>

 void bestexemplarhelper(const int mm, const int nn, const int m, const int n, const int K,
 	const double *img, const double *Ip, 
 	const mxLogical *toFill, const mxLogical *sourceRegion,
 	double *best) 
 {
 	register int i,j,ii,jj,ii2,jj2,M,N,I,J,ndx,ndx2,mn=m*n,mmnn=mm*nn;
 	double patchErr=0.0,err=0.0;//bestErr=1000000000.0,secErr=1000000000.0,thirdErr=1000000000.0;
 	double* bestErr = (double*) malloc (sizeof(double) * K);
 	for (int ind = 0; ind < K; ind++) {
 		bestErr[ind] = 1000000000.0;
 	}
 	//double bestErr[3] = {1000000000.0,1000000000.0,1000000000.0}; 

  /* foreach patch */
 	N=nn-n+1;  M=mm-m+1;
 	for (j=1; j<=N; ++j) {
 		J=j+n-1;
 		for (i=1; i<=M; ++i) {
 			I=i+m-1;
      /*** Calculate patch error ***/
      /* foreach pixel in the current patch */
 			for (jj=j,jj2=1; jj<=J; ++jj,++jj2) {
 				for (ii=i,ii2=1; ii<=I; ++ii,++ii2) {
 					ndx=ii-1+mm*(jj-1);
 					if (!sourceRegion[ndx])
 						goto skipPatch;
 					ndx2=ii2-1+m*(jj2-1);
 					if (!toFill[ndx2]) {
 						err=img[ndx      ] - Ip[ndx2    ]; patchErr += err*err;
 						err=img[ndx+=mmnn] - Ip[ndx2+=mn]; patchErr += err*err;
 						err=img[ndx+=mmnn] - Ip[ndx2+=mn]; patchErr += err*err;
 					}
 				}
 			}
      /*** Update ***/
 			for (int ind = 0; ind < K; ind++) {
 				if (patchErr < bestErr[ind]) {
 					bestErr[ind] = patchErr;
 					best[4*ind] = i; best[4*ind+1] = I;
 					best[4*ind+2] = j; best[4*ind+3] = J;
 					break;
 				}
 			}


 			// if (patchErr < bestErr[0]) {
 			// 	bestErr[0] = patchErr; 
 			// 	best[0] = i; best[1] = I;
 			// 	best[2] = j; best[3] = J;
 			// } else if (patchErr < bestErr[1]) {
 			// 	bestErr[1] = patchErr;
 			// 	best[4] = i; best[5] = I;
 			// 	best[6] = j; best[7] = J;
 			// } else if (patchErr < bestErr[2]) {
 			// 	bestErr[2] = patchErr;
 			// 	best[8] = i; best[9] = I;
 			// 	best[10] = j; best[11] = J;
 			// }
      /*** Reset ***/
 			skipPatch:
 			patchErr = 0.0; 
 		}
 	}
 	free (bestErr);
 }

/* best = bestexemplarhelper(mm,nn,m,n,K,img,Ip,toFill,sourceRegion); */
 void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) 
 {
 	int mm,nn,m,n,K;
 	double *img,*Ip,*best;
 	mxLogical *toFill,*sourceRegion;

  /* Extract the inputs */
 	mm = (int)mxGetScalar(prhs[0]);
 	nn = (int)mxGetScalar(prhs[1]);
 	m  = (int)mxGetScalar(prhs[2]);
 	n  = (int)mxGetScalar(prhs[3]);
 	K  = (int)mxGetScalar(prhs[4]);
 	img = mxGetPr(prhs[5]);
 	Ip  = mxGetPr(prhs[6]);
 	toFill = mxGetLogicals(prhs[7]);
 	sourceRegion = mxGetLogicals(prhs[8]);

  /* Setup the output */
 	plhs[0] = mxCreateDoubleMatrix(4*K,1,mxREAL);
 	best = mxGetPr(plhs[0]);
 	for (int i = 0; i < K; i++) {
 		best[4*i]=best[4*i+1]=best[4*i+2]=best[4*i+3]=0.0;
 	}
 	// best[0]=best[1]=best[2]=best[3]=0.0;
 	// best[4]=best[5]=best[6]=best[7]=0.0;
 	// best[8]=best[9]=best[10]=best[11]=0.0;

  /* Do the actual work */
 	bestexemplarhelper(mm,nn,m,n,K,img,Ip,toFill,sourceRegion,best);
 }
