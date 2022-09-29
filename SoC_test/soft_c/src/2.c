#include "soc_io.h"

#define N 100
int temp=0;
int A[N] = {81, 37, 64, 23, 38, 65, 56, 15, 8, 33, 85, 39, 71, 12, 77, 6, 82, 89, 80, 35, 0, 59, 73, 4, 61, 30, 74, 69, 13, 42, 68, 63, 9, 29, 47, 36, 99, 25, 21, 14, 60, 3, 2, 18, 26, 83, 53, 5, 43, 67, 88, 70, 76, 92, 94, 48, 34, 49, 66, 95, 78, 62, 32, 52, 16, 72, 27, 28, 22, 40, 84, 91, 96, 57, 87, 51, 98, 1, 10, 11, 24, 20, 19, 31, 7, 97, 50, 86, 79, 17, 75, 55, 93, 44, 58, 54, 45, 41, 90, 46};
void Bubblesort(int A[N])
{
    int exchange=1;
    int i;
    for(i=0;i<N&&exchange;i++)
    {
        exchange=0;
	int j;
        for(j=0;j<N-i-1;j++)
        {
            if(A[j]>A[j+1])
            {
                temp=A[j];
                A[j]=A[j+1];
                A[j+1]=temp;
                exchange=1;
            }
        }
    }
}
int BinarySearch(int A[N])
{
    int low,high,mid;
    low=0;
    high=N-1;
    while(low<=high)
    {
        mid=(low+high)/2;
        if(A[mid]==23)
        {
            return mid;
        }
        if(A[mid]>23)
            high=mid-1;
        if(A[mid]<23)
            low=mid+1;
    }
    return -1;
}
int main()
{
    init();

    int flag=1;
    Bubblesort(A);
    int ans=BinarySearch(A);
    if(ans!=23)
        flag=0;
    print_result(flag);

    while(1);

    return 0;
}
