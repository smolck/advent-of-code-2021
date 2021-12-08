#include <metal_stdlib>
using namespace metal;

struct Result {
    int totalGas;
    int align;
    int totalGasPartTwo;
};

kernel void sanders(device const int* nums [[buffer(0)]],
                    device const int* aligns [[buffer(1)]],
                    device const int &lengthOfNums [[buffer(2)]],
                    device Result* result [[buffer(3)]],
                    uint index [[thread_position_in_grid]])
{
    int align = aligns[index];

    int sum = 0;
    int sumPartTwo = 0;
    for (int i = 0; i < lengthOfNums; i++) {
        int n = abs(nums[i] - align);

        sum += n;
        sumPartTwo += (n * (n + 1)) / 2; // Thanks @seandewar, how did I forget this formula exists.
    }

    result[index].totalGas = sum;
    result[index].align = align;
    result[index].totalGasPartTwo = sumPartTwo;
}
