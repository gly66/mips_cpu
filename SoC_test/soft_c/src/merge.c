#include "soc_io.h"

#define N 10
int temp=0;
int A [N] = {7,5,2,3,1,4,6,9,10,8};
int ans[N] = {1,2,3,4,5,6,7,8,9,10};

void merge()
{
    int min=0;
    int flag = 0;
    int index = 0;
    int i;
    for(i=0;i<N-1;i++){
        min=A[i]; flag=0;
        int j;
        for(j=i;j<N;j++){
            if(min>A[j]){
                flag=1;
                min=A[j];
                index=j;
            }
        }
        if(flag){
            // swap(A[i],A[index]);
            int temp = A[i];
            A[i] = A[index];
            A[index] = temp;
        }
    }
}

int main()
{
    init();
    int flag1 =1 ;
    merge();
    int i = 0;
    for (i =0; i <N; i++ ){
        if (ans[i] != A[i]){
            flag1 = 0;
            break;
        }
    }
    // printf("%d", flag1);
    print_result(flag1);
    while(1);
    return 0;
}