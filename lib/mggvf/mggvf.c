/****************************************************************************
Copyright (c) 1999-2009 Jerry Prince, Xiao Han, and Chenyang Xu.

This software is copyrighted by Jerry Prince, Xiao Han, and Chenyang Xu. 
The following terms apply to all files associated with the software unless 
explicitly disclaimed in individual files. 

The authors hereby grant permission to use, copy, and distribute this
software and its documentation for any purpose, provided that existing
copyright notices are retained in all copies and that this notice is included
verbatim in any distributions. Additionally, the authors grant permission to
modify this software and its documentation for any purpose, provided that
such modifications are not distributed without the explicit consent of the
authors and that existing copyright notices are retained in all
copies. 

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE IS PROVIDED ON AN
"AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE
MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
****************************************************************************/

/* mggvf.c */
/* Multigrid method for computing Gradient Vector Flow in 2D */

#include "mex.h"
#include <stdlib.h>
#include <math.h>
#include <time.h>
#define JACOBI 0
#define IFLAG 1

static int mmax,nmax;
static int maxlevel; /* number of maxlevel */
static int n1,n2;
static double lamda = 1.0;
static double alpha = 0.6666; /*damping factor for jacobi iteration */
static double threshold = 0.00005;

double ** alloc_2D_array(int rows, int cols){
	double ** start;
	int i;
	start=(double **)malloc(rows*sizeof(double *));
	if(start==NULL) return NULL;

	for(i=0;i<(int)rows;i++)
	{
	 start[i]=(double *)malloc(cols*sizeof(double));
	 if(start[i]==NULL)
	 {
		for(--i;i>=0;i--) free(start[i]);
		free(start);
		return NULL;
	 }
	}
	return start;

}

void freememory(double ** array, int rows){
	int j;
	if(array==NULL) return;

	for(j=0;j<rows;j++)
		free(array[j]);
	free(array);
	array = NULL;
}



void rstrct(double **out, double **in, int MO, int NO, int mc, int nc){
  int ic, iif, jc,jf;
 

  int LX, HX, LY, HY;
  
  if(IFLAG){ 
  for(ic = 0; ic < MO; ic++){ 
    for(jc = 0; jc < NO; jc++){
        iif = ic <<1; jf = jc <<1;
		if(iif > (mc-2)) iif = mc -2;
		if(jf > (nc-2)) jf = nc -2;
		
		out[ic][jc] = 0.25*(in[iif][jf] + in[iif+1][jf] +in[iif][jf+1]+in[iif+1][jf+1]);
	}
  }

  }
  return; 
}

void interp(double **out, double ** in, int MO, int NO, int mc, int nc){
/* Nine-pts prolongation */  
  int ic,iif,jc,jf, next;

  /* Do elements that are copies */
  if(IFLAG){
  for(ic =0; ic <MO;ic++){
    for(jc = 0; jc < NO; jc++){
	     out[ic][jc] = in[ic>>1][jc>>1];
	  }
  }
  }else{
    for(ic =0; ic <mc;ic++){
    for(jc = 0,jf=0; jc < nc; jc++,jf += 2){
	     out[ic<<1][jf] = in[ic][jc];
	  }
  }
  
  for(iif=1;iif<MO; iif += 2){
     for(jf =0; jf<NO;jf += 2){ /*Do even-numbered columns, interpolating vertically */
        if(iif == (MO-1)) next = MO-2;
		else next = iif + 1;
	    out[iif][jf] = 0.5*(out[next][jf] + out[iif-1][jf]);
	  }
  }

  for(iif=0;iif < MO; iif++){
    for(jf=1;jf<NO;jf += 2){/* Do odd-numbered columns, interpolating horizontally */
		if(jf == (NO-1)) next = NO-2;
		else next = jf + 1;
	    out[iif][jf] = 0.5*(out[iif][next]+ out[iif][jf-1]);
	  
	  }
  }

  
  }

  return; 
}

void addin(double **uf, double **uc, double ** res, int MO, int NO, int mc, int nc){
 int i,j;

 interp(res,uc,MO, NO, mc, nc);
 
 for(i=0; i<MO;i++){
   for(j=0; j<NO; j++){
	   uf[i][j] += res[i][j];
	 }
 }

  return;
}

 
void resid(double **res, double **u, double **rhs, double **w, int M, int N, int lev){
 /* Returns minus the residual for the model problem */
/* r = rhs - w.*u + lamda*L(u)*h^(-2) */ 
/* w = ||\nabla f||^2; rhs = ||\nabla f||^2 f_x,y */
/* lev is the current level */
 
 int i,j;
 int h;
 double cmu;
 int prem, nextm, pren,nextn;

 h = 1<<(maxlevel-lev);
 h = h*h;
 cmu = lamda/h;

 for(i=0; i<M;i++){
	 prem = i-1;
	 if(prem == -1) prem = 0; /* Whole pt symmetric extension */
	 nextm = i+1;
     if(nextm == M) nextm = M-1; 

	 for(j=0;j<N;j++){
	   pren = j-1;
	   if(pren == -1) pren=0; /* Symmetric extension */
	   nextn = j+1;
	   if(nextn == N) nextn = N-1;

	   res[i][j] = rhs[i][j] - w[i][j]*u[i][j]+ cmu*(u[prem][j]+u[nextm][j]
		   + u[i][pren] + u[i][nextn] - 4*u[i][j]);
	 
	 }
 }

 
  return;

}


void copymem(double **out, double **in, int M, int N){
  int i,j;
  for(i=0; i<M;i++){
	  for(j=0; j<N; j++){
	   out[i][j] = in[i][j];
	  }
  }

}

void quarter(double **u, double **rhs, double **w, double cmu, int msize, int nsize, int ip, int jp){
/* A quarter Gauss_Seidel Step */
	int i,j, prem,nextm, pren,nextn;
	
	for(i = ip; i < msize; i += 2){
	
        prem = i-1;
		if(prem < 0) prem = 0;
		nextm = i+1;
		if(nextm >= msize) nextm = msize-1;
		for(j =jp; j < nsize; j += 2){

		   pren = j-1;
		   if(pren < 0) pren = 0;
		   nextn = j+1;
		   if(nextn >= nsize) nextn = nsize -1;

		   u[i][j] = ((u[prem][j]+u[nextm][j]
		   + u[i][pren] + u[i][nextn])*cmu 
		   + rhs[i][j])/(4*cmu + w[i][j]);
		
		} 
	} 


}

void Gauss_Seidel(double **u, double **rhs, double **weight, int lev, int M, int N, int iter){
/* Suppose signal is of squre shape */
int h,i,j;
double cmu;

h= 1<< (maxlevel - lev);
h = h*h;

cmu = lamda/h;

for(i=1;i<=iter; i++){
/* Dealing with all pts */
  quarter(u,rhs, weight, cmu,M,N,0,0);
  quarter(u,rhs, weight, cmu,M,N,1,1);
  quarter(u,rhs, weight, cmu,M,N,1,0);
  quarter(u,rhs, weight, cmu,M,N,0,1);
}	

return;
}

void jacobi(double **u, double **rhs, double **w, int lev, int M, int N, int iter){
/* u is the initial and final solustion, lev is the current level */
/* Iteration for solve PDE using damped Jacobi, the damping factor is 0.25 */ 
/* The PDE is (-lamda*L+W)u = rhs */ 
 int i,j,h, prem,nextm,pren,nextn,index;
 double cmu; /* current mu(lamda)  */
 double **tmp;

 int m,n;


 tmp = alloc_2D_array(M, N);

 h = 1<<(maxlevel-lev);
 h = h*h;
 cmu = lamda/h;

 
 
 for(index = 1; index <= iter; index ++){
 
   for(i=0; i<M;i++){

	 prem = i-1;
	 if(prem < 0) prem = 0; /*whole pt symmetric extension */
	 nextm = i+1;
     if(nextm >= M) nextm = M-1;

	 for(j=0;j<N;j++){
	   pren = j-1;
	   if(pren < 0) pren=0; /* Symmetric extension */
	   nextn = j+1;
	   if(nextn >= N) nextn = N - 1;

	   	tmp[i][j]	=   (1-alpha)* u[i][j] + alpha* ((u[prem][j]+u[nextm][j]
		   + u[i][pren] + u[i][nextn])*cmu 
		   + rhs[i][j])/(4*cmu + w[i][j]);

	 }
   }

   for(m=0; m<M; m++){
	   for(n=0; n<N; n++){
	      
		   u[m][n] = tmp[m][n];
		  
	   }
   } 
    
 }
 	
 
  freememory(tmp,M);

  return;
}

void slvsml(double **u, double **rhs, double **weight, int M, int N){
/* Solve the PDE at the coarset level 9 pts, which are all of the same value */
/* Due to the neumman condition, the nublacian of u is zero at the center of this small area */
	int i,j;
    int h;
	double sum;
	
	/*
	h = 1<<(maxlevel-1); 
	h= h*h;

	cmu = lamda/h; 
	*/

    
   for(i=0; i<M;i++){
	   for(j=0;j<N;j++){
	     u[i][j] = 0; /**/
	   }
   }
  
   if(JACOBI)
	   jacobi(u, rhs, weight, 1, M, N, 2);
   else
	   Gauss_Seidel(u, rhs, weight, 1, M, N, 2); /* */


   return;
}


void mg_gvf(double **u0, double **x2, double **weight) /* multigrid method */
{

   int m,n,mf,nf;
   int iters;
   int Offset;
   int *mo, *no;
   float maxErr, tmpv;

   
   int j,jcycle,jj,jpost,jpre,mn,nn;

   int msize,nsize;

   double ***ires, ***irho, ***irhs, ***iu, ***iwei;


   /* For these pointers, since the index is the level number, which begins from 1, the zeroindex is never used */
   ires = (double ***)malloc((maxlevel+1)*sizeof(double **));
   irho = (double ***)malloc((maxlevel+1)*sizeof(double **));
   irhs = (double ***)malloc((maxlevel+1)*sizeof(double **));
   iu = (double ***)malloc((maxlevel+1)*sizeof(double **));
   iwei = (double ***)malloc((maxlevel+1)*sizeof(double **));
   mo = (int *)malloc((maxlevel+1)*sizeof(int));
   no = (int *)malloc((maxlevel+1)*sizeof(int));

   msize = mmax;
   nsize = nmax;
   
   for(j=maxlevel;j>=1;j--){
      ires[j] = (double **)alloc_2D_array(msize,nsize); 
      irho[j] = (double **)alloc_2D_array(msize,nsize); 
	  irhs[j] = (double **)alloc_2D_array(msize,nsize); 
	  iu[j] = (double **)alloc_2D_array(msize,nsize); 
      iwei[j] = (double **)alloc_2D_array(msize,nsize); 

	  mo[j] = msize;
	  no[j] = nsize;
	  msize = (msize+1)>>1;
	  nsize = (nsize + 1)>>1;
   }

   

   /*Convert the 1D data to a 2D array */
   for(m=0; m < mmax; m++){ /*loop over image */
	   for(n=0;n< nmax;n++){
		   /* Offset = n*mmax + m; 
		   x2[m][n] = x[Offset]; */
           iwei[maxlevel][m][n] = weight[m][n]; /* This is the original weight */

		   /* u0[m][n] = 0.0; /* Very first initial guess */
	   }
   }

   
   for(j = maxlevel-1; j >= 1; j--){
	  rstrct(iwei[j],iwei[j+1],mo[j],no[j], mo[j+1], no[j+1]);
   } 

   
   /* Now start multigrid processing */
   for(iters = 1; iters <= 10; iters++){

   /* Several iterations of fmgv */
   resid(irho[maxlevel], u0, x2, iwei[maxlevel], mmax,nmax,maxlevel); 
     maxErr = 0.0;
     for(m=0; m < mmax; m++){ /*loop over image */
	   for(n=0;n< nmax;n++){
	      tmpv = irho[maxlevel][m][n];
		  if(tmpv < 0) tmpv = -tmpv;
		  if(maxErr < tmpv) maxErr = tmpv;
	   }
   }

	 if(iters == 1){
		/* threshold = 0.001*maxErr; */
	    /* mexPrintf("Error is %g, threshold = %g\n", maxErr, threshold); */

	 }else{
	 if(maxErr < threshold){
	   /* mexPrintf("Converged after %d iterations, residue = %g\n", iters-1,maxErr); */
	   break;
	 }else
     {
	    /* mexPrintf("Error is %g\n", maxErr); */
	 }

     }

  
   for(j = maxlevel-1; j >= 1; j--){
      rstrct(irho[j],irho[j+1],mo[j],no[j], mo[j+1], no[j+1]); /* mn, nn are the size of the first parameter */
   } 

   
   
   /*Now solve the PDE at level 1, the coarsest level */
   /* No initialization is needed at the coarest level */
  
   slvsml(iu[1], irho[1], iwei[1], mo[1], no[1]); /* Initial solution on coarest grid */

   
   /* Now start Full-Multigrid V or W cycle */
   for(j=2; j<= maxlevel;j++){

	  interp(iu[j],iu[j-1], mo[j],no[j],mo[j-1],no[j-1]); /* Get the initial guess of the solution of the original eq */
      
	  copymem(irhs[j], irho[j], mo[j],no[j]); /* Set up right hand side */

	  /* Now begin mgv.m 12-9-03 */
	  /* gama should only be one or two */

	  for(jcycle = 1; jcycle <= 1; jcycle ++){
		for(jj=j; jj>=2; jj--){ /* Down stroke of the V */
			if(JACOBI)
		   jacobi(iu[jj], irhs[jj], iwei[jj], jj, mo[jj],no[jj], n1); /* presmoothing */
			else
           Gauss_Seidel(iu[jj], irhs[jj], iwei[jj], jj, mo[jj],no[jj], n1); /* */
		  
		   resid(ires[jj], iu[jj], irhs[jj], iwei[jj], mo[jj],no[jj],jj); /* Defect */
           
		   		   
		   mf = mo[jj-1];
		   nf = no[jj-1];

     	   for(m=0; m < mf; m++){ /*loop over image */
		    for(n=0;n< nf;n++){
	    	  iu[jj-1][m][n] = 0; /* Initial value for errors at levels from j-1 to 1 which are iu[j-1] ~ iu[1] and are zeros */
			}
		   }

		   rstrct(irhs[jj-1], ires[jj], mo[jj-1],no[jj-1],mo[jj],no[jj]); /* mf, nf is the size of the first parameter */
        /*	mexPrintf("jj = %d\n",jj); */
	 
		}


        slvsml(iu[1], irhs[1], iwei[1],mo[1],no[1]); /* Bottom of the V */
										/* Now iu[1] stores the solution of the error at the coarest level */	

		for(jj=2; jj <=j; jj++){ /*Upard stroke of V */
			addin(iu[jj], iu[jj-1], ires[jj],mo[jj],no[jj],mo[jj-1],no[jj-1]); /* mf nf are the size of the first parameter */
			/*ires[jj] is used for temporary storage inside addint */
			if(JACOBI)
			jacobi(iu[jj], irhs[jj],iwei[jj], jj,mo[jj],no[jj], n2);/*post-smoothing */
			else
			Gauss_Seidel(iu[jj], irhs[jj], iwei[jj], jj,mo[jj],no[jj], n2); /* */ 
		}

	  }
   
   }

   /* Update solution */
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   
		   u0[m][n] += iu[maxlevel][m][n];
	   }
   }

   
   } /* endof for (iters) */

  
   for(j=maxlevel;j>=1;j--){
      msize = mo[j];
      freememory(ires[j], msize); 
      freememory(irhs[j], msize); 
	  freememory(irho[j], msize); 
	  freememory(iu[j], msize); 
	  freememory(iwei[j], msize);
   }

   /* freememory(x2,mmax); */

   free(iu);
   free(ires);
   free(irho);
   free(irhs);
   free(iwei);

   free(mo); free(no);
}


void mexFunction(int nlhs,mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* [u,v] = mggvf(f,mu,v1,v2, threshold); */

   double *f;
   double **x2, **w2, **u2, **f2, **fx2, **fy2;
   double *resultu, *resultv;
   int m,n, mlevel, nlevel, index;
   int Offset;
   double maxV, minV,tmpV, tmpV2;
   clock_t start_t, finish_t;

   int LX, HX, LY, HY;

   int outsize[2];
   int nn;
   
   if (nrhs<2)
      mexErrMsgTxt("Not enough input arguments!");

   mmax=mxGetM(prhs[0]);
   nmax=mxGetN(prhs[0]);

   mlevel = 0;
   nn = mmax-1;
   while(nn >>= 1) mlevel++;

   nlevel = 0;
   nn = nmax-1;
   while(nn >>= 1) nlevel++;

   /* mexPrintf("mmax=%d, mlevel=%d, nmax = %d, nlevel = %d\n",mmax, mlevel, nmax, nlevel); */

   if(mlevel > nlevel) maxlevel = nlevel;
   else maxlevel = mlevel;
    
   /* if(mmax != (1 + (1<<maxlevel))) mexErrMsgTxt("Signal_size - 1 must be a power of 2"); */

   if (nrhs<2){
      lamda = 0.1;
   }else 
	  lamda = (double)mxGetScalar(prhs[1]);
   
   if(nrhs < 3){
      n1 = 1;
   }else
	   n1 = (int)mxGetScalar(prhs[2]);

   if(nrhs < 4) n2 = 2;
   else n2 = (int)mxGetScalar(prhs[3]);
    

   if(nrhs < 5) threshold = 0.00005;
   else threshold = (double)mxGetScalar(prhs[4]);

   
   outsize[0] = mmax;
   outsize[1] = nmax;

   plhs[0] = mxCreateNumericArray(2, outsize, mxDOUBLE_CLASS, mxREAL);
   resultu = (double *)mxGetPr(plhs[0]);

   plhs[1] = mxCreateNumericArray(2, outsize, mxDOUBLE_CLASS, mxREAL);
   resultv = (double *)mxGetPr(plhs[1]);;
   
   f=(double *)mxGetData(prhs[0]);

   x2 = (double **)alloc_2D_array(mmax,nmax);
   u2 = (double **)alloc_2D_array(mmax,nmax);
   f2 = (double **)alloc_2D_array(mmax,nmax);
   fx2 = (double **)alloc_2D_array(mmax,nmax);
   fy2 = (double **)alloc_2D_array(mmax,nmax);
   w2 = (double **)alloc_2D_array(mmax,nmax);
 
   maxV = 0.0; minV = 1000.0;
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   Offset = n*mmax + m;
		   /* fx[Offset] = u0[m][n]; */
		   tmpV = f[Offset];
		   f2[m][n] = tmpV;
		   if(maxV < tmpV) maxV = tmpV;
		   if(minV > tmpV) minV = tmpV;
	   }
   }

   if(maxV <= 0 || minV < 0){
	   mexPrintf("input edge map is illegal. Exit!\n");
	   return;
   }

   tmpV = 1.0/(maxV - minV);
   /* Normalize f */
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   f2[m][n] = tmpV*(f2[m][n] - minV);
	   }
   }
   start_t = clock();
   /* Deal with corners */
   fx2[0][0] = fy2[0][0] = fx2[0][nmax-1] = fy2[0][nmax-1] = 0;
   fx2[mmax-1][nmax-1] = fy2[mmax-1][nmax-1] = fx2[mmax-1][0] = fy2[mmax-1][0] = 0;

   /* Deal with left and right column */
   for (m=1; m< mmax-1; m++) {
      fx2[m][0] = fx2[m][nmax-1] = 0;
      fy2[m][0] = 0.5 * (f2[m+1][0] - f2[m-1][0]);
      fy2[m][nmax-1] = 0.5 * (f2[m+1][nmax-1] - f2[m-1][nmax-1]);
   }

   /* Deal with top and bottom row */
   for (n=1; n < nmax-1; n++) {
      fy2[0][n] = fy2[mmax-1][n] = 0;
      fx2[0][n] = 0.5 * (f2[0][n+1] - f2[0][n-1]);
      fx2[mmax-1][n] = 0.5 * (f2[mmax-1][n+1] - f2[mmax-1][n-1]);
   }
   
   /* I.2: Compute interior derivative using central difference */
   for(m=1; m < mmax-1; m++){
	   for(n=1;n< nmax-1;n++){

		 tmpV = 0.5*(f2[m][n+1] - f2[m][n-1]);
		 tmpV2 = 0.5*(f2[m+1][n] - f2[m-1][n]);

         fx2[m][n] = tmpV; fy2[m][n] = tmpV2;
	
	   }
   }

   mexPrintf("Compute the u(x)-component of GVF force \n");
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   tmpV = fx2[m][n]; tmpV2 = fy2[m][n];
		   w2[m][n] = tmpV*tmpV + tmpV2*tmpV2;
		   u2[m][n] = 0.0;
           x2[m][n] = w2[m][n]*tmpV; 
	  }
   }

   mg_gvf(u2,x2, w2);
  
   /* Assign to output */
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   Offset = n*mmax + m;
		   resultu[Offset] = u2[m][n];
	   }
   }

   freememory(f2, mmax); 
   freememory(fx2, mmax);
   
   mexPrintf("Compute the v(y)-component of GVF force \n");
  
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   u2[m][n] = 0.0;
           x2[m][n] = w2[m][n]*fy2[m][n]; 
	  }
   }
   
     mg_gvf(u2,x2, w2);
  
   /* finish_t = clock();
   printf("%f seconds passed\n",((double)(finish_t - start_t))/CLOCKS_PER_SEC);
   */
   /* Assign to output */
   for(m=0; m < mmax; m++){
	   for(n=0;n< nmax;n++){
		   Offset = n*mmax + m;
		   resultv[Offset] = u2[m][n];
	   }
   }

   freememory(fy2, mmax); 
   freememory(x2, mmax); 
   freememory(w2, mmax); 
   freememory(u2, mmax); 
   return;
}


