#include "soc_io.h"

#define N 10
int a[N+1]={0,5,8,7,9,6,2,4,1,3,10};
int ans[N]={1,2,3,4,5,6,7,8,9,10};

void insertSort(int a[])
{
    int i;
    for(i=2;i<=10;++i)
    {
        if(a[i]<a[i-1])
        {
            a[0]=a[i];
            int j;
            for(j=i-1;a[0]<a[j];--j)
                a[j+1]=a[j];
            a[j+1]=a[0];
        }
    }
}

int main()
{
    init();

    int flag=1;
    insertSort(a);
    int k;
    for(k=1;k<=10;k++)
    {
        if(a[k]!=ans[k-1])
            flag=0;
    }

    print_result(flag);

    while(1);

    return 0;
}
