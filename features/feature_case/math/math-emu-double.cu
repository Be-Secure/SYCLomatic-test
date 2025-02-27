// ====------------ math-emu-double.cu---------- *- CUDA -* -------------===////
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//
// ===---------------------------------------------------------------------===//

#include <iomanip>
#include <iostream>
#include <vector>

using namespace std;

typedef vector<double> d_vector;
typedef tuple<double, double, double> d_tuple3;
typedef tuple<double, double, double, double> d_tuple4;
typedef pair<double, int> di_pair;

int passed = 0;
int failed = 0;

void check(bool IsPassed) {
  if (IsPassed) {
    cout << " ---- passed" << endl;
    passed++;
  } else {
    cout << " ---- failed" << endl;
    failed++;
  }
}

template <typename T = double>
void checkResult(const string &FuncName, const vector<T> &Inputs,
                 const double &Expect, const double &DeviceResult,
                 const int precision) {
  cout << FuncName << "(" << Inputs[0];
  for (size_t i = 1; i < Inputs.size(); ++i) {
    cout << ", " << Inputs[i];
  }
  cout << ") = " << fixed << setprecision(precision) << DeviceResult
       << " (expect " << Expect - pow(10, -precision) << " ~ "
       << Expect + pow(10, -precision) << ")";
  cout.unsetf(ios::fixed);
  check(abs(DeviceResult - Expect) < pow(10, -precision));
}

__global__ void setVecValue(double *Input1, const double Input2) {
  *Input1 = Input2;
}

__global__ void _norm(double *const DeviceResult, int Input1,
                      const double *Input2) {
  *DeviceResult = norm(Input1, Input2);
}

void testNorm(double *const DeviceResult, int Input1, const double *Input2) {
  _norm<<<1, 1>>>(DeviceResult, Input1, Input2);
  cudaDeviceSynchronize();
  // TODO: Need test host side.
}

void testNormCases(const vector<pair<d_vector, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  // Other test values.
  for (const auto &TestCase : TestCases) {
    double *Input;
    cudaMallocManaged(&Input, TestCase.first.size() * sizeof(*Input));
    for (size_t i = 0; i < TestCase.first.size(); ++i) {
      // Notice: cannot set value from host!
      setVecValue<<<1, 1>>>(Input + i, TestCase.first[i]);
      cudaDeviceSynchronize();
    }
    testNorm(DeviceResult, TestCase.first.size(), Input);
    string arg = "&{";
    for (size_t i = 0; i < TestCase.first.size() - 1; ++i) {
      arg += to_string(TestCase.first[i]) + ", ";
    }
    arg += to_string(TestCase.first.back()) + "}";
    checkResult<string>("norm", {to_string(TestCase.first.size()), arg},
                        TestCase.second.first, *DeviceResult,
                        TestCase.second.second);
  }
}

__global__ void _norm3d(double *const DeviceResult, double Input1,
                        double Input2, double Input3) {
  *DeviceResult = norm3d(Input1, Input2, Input3);
}

void testNorm3d(double *const DeviceResult, double Input1, double Input2,
                double Input3) {
  _norm3d<<<1, 1>>>(DeviceResult, Input1, Input2, Input3);
  cudaDeviceSynchronize();
  // Call from host.
}

void testNorm3dCases(const vector<pair<d_tuple3, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  for (const auto &TestCase : TestCases) {
    testNorm3d(DeviceResult, get<0>(TestCase.first), get<1>(TestCase.first),
               get<2>(TestCase.first));
    checkResult("norm3d",
                {get<0>(TestCase.first), get<1>(TestCase.first),
                 get<2>(TestCase.first)},
                TestCase.second.first, *DeviceResult, TestCase.second.second);
  }
}

__global__ void _norm4d(double *const DeviceResult, double Input1,
                        double Input2, double Input3, double Input4) {
  *DeviceResult = norm4d(Input1, Input2, Input3, Input4);
}

void testNorm4d(double *const DeviceResult, double Input1, double Input2,
                double Input3, double Input4) {
  _norm4d<<<1, 1>>>(DeviceResult, Input1, Input2, Input3, Input4);
  cudaDeviceSynchronize();
  // Call from host.
}

void testNorm4dCases(const vector<pair<d_tuple4, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  for (const auto &TestCase : TestCases) {
    testNorm4d(DeviceResult, get<0>(TestCase.first), get<1>(TestCase.first),
               get<2>(TestCase.first), get<3>(TestCase.first));
    checkResult("norm4d",
                {get<0>(TestCase.first), get<1>(TestCase.first),
                 get<2>(TestCase.first), get<3>(TestCase.first)},
                TestCase.second.first, *DeviceResult, TestCase.second.second);
  }
}

__global__ void _normcdf(double *const DeviceResult, double Input) {
  *DeviceResult = normcdf(Input);
}

void testNormcdf(double *const DeviceResult, double Input) {
  _normcdf<<<1, 1>>>(DeviceResult, Input);
  cudaDeviceSynchronize();
  // Call from host.
}

void testNormcdfCases(const vector<pair<double, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  // Other test values.
  for (const auto &TestCase : TestCases) {
    testNormcdf(DeviceResult, TestCase.first);
    checkResult("normcdf", {TestCase.first}, TestCase.second.first,
                *DeviceResult, TestCase.second.second);
  }
}

__global__ void _rnorm(double *const DeviceResult, int Input1,
                       const double *Input2) {
  *DeviceResult = rnorm(Input1, Input2);
}

void testRnorm(double *const DeviceResult, int Input1, const double *Input2) {
  _rnorm<<<1, 1>>>(DeviceResult, Input1, Input2);
  cudaDeviceSynchronize();
  // Call from host.
}

void testRnormCases(const vector<pair<d_vector, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  // Other test values.
  for (const auto &TestCase : TestCases) {
    double *Input;
    cudaMallocManaged(&Input, TestCase.first.size() * sizeof(*Input));
    for (size_t i = 0; i < TestCase.first.size(); ++i) {
      // Notice: cannot set value from host!
      setVecValue<<<1, 1>>>(Input + i, TestCase.first[i]);
      cudaDeviceSynchronize();
    }
    testRnorm(DeviceResult, TestCase.first.size(), Input);
    string arg = "&{";
    for (size_t i = 0; i < TestCase.first.size() - 1; ++i) {
      arg += to_string(TestCase.first[i]) + ", ";
    }
    arg += to_string(TestCase.first.back()) + "}";
    checkResult<string>("rnorm", {to_string(TestCase.first.size()), arg},
                        TestCase.second.first, *DeviceResult,
                        TestCase.second.second);
  }
}

__global__ void _rnorm3d(double *const DeviceResult, double Input1,
                         double Input2, double Input3) {
  *DeviceResult = rnorm3d(Input1, Input2, Input3);
}

void testRnorm3d(double *const DeviceResult, double Input1, double Input2,
                 double Input3) {
  _rnorm3d<<<1, 1>>>(DeviceResult, Input1, Input2, Input3);
  cudaDeviceSynchronize();
  // Call from host.
}

void testRnorm3dCases(const vector<pair<d_tuple3, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  for (const auto &TestCase : TestCases) {
    testRnorm3d(DeviceResult, get<0>(TestCase.first), get<1>(TestCase.first),
                get<2>(TestCase.first));
    checkResult("rnorm3d",
                {get<0>(TestCase.first), get<1>(TestCase.first),
                 get<2>(TestCase.first)},
                TestCase.second.first, *DeviceResult, TestCase.second.second);
  }
}

__global__ void _rnorm4d(double *const DeviceResult, double Input1,
                         double Input2, double Input3, double Input4) {
  *DeviceResult = rnorm4d(Input1, Input2, Input3, Input4);
}

void testRnorm4d(double *const DeviceResult, double Input1, double Input2,
                 double Input3, double Input4) {
  _rnorm4d<<<1, 1>>>(DeviceResult, Input1, Input2, Input3, Input4);
  cudaDeviceSynchronize();
  // Call from host.
}

void testRnorm4dCases(const vector<pair<d_tuple4, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  for (const auto &TestCase : TestCases) {
    testRnorm4d(DeviceResult, get<0>(TestCase.first), get<1>(TestCase.first),
                get<2>(TestCase.first), get<3>(TestCase.first));
    checkResult("rnorm4d",
                {get<0>(TestCase.first), get<1>(TestCase.first),
                 get<2>(TestCase.first), get<3>(TestCase.first)},
                TestCase.second.first, *DeviceResult, TestCase.second.second);
  }
}

int main() {
  testNormCases({
      {{-0.3, -0.34, -0.98}, {1.079814798935447, 15}},
      {{0.3, 0.34, 0.98}, {1.079814798935447, 15}},
      {{0.5}, {0.5, 16}},
      {{23, 432, 23, 456, 23}, {629.4020972319682, 13}},
  });
  testNorm3dCases({
      {{-0.3, -0.34, -0.98}, {1.079814798935447, 15}},
      {{0.3, 0.34, 0.98}, {1.079814798935447, 15}},
      {{0.5, 456, 23}, {456.5799491874342, 13}},
      {{23, 432, 23}, {433.222806417206, 13}},
  });
  testNorm4dCases({
      {{-0.3, -0.34, -0.98, 1}, {1.471733671558818, 15}},
      {{0.3, 0.34, 0.98, 1}, {1.471733671558818, 15}},
      {{0.5, 456, 23, 1}, {456.5810442845827, 13}},
      {{23, 432, 23, 1}, {433.2239605562001, 13}},
  });
  testNormcdfCases({
      {-5, {0.000000286651571879194, 21}},
      {-3, {0.001349898031630095, 18}},
      {0, {0.5, 16}},
      {1, {0.841344746068543, 15}},
      {5, {0.9999997133484281, 16}},
  });
  testRnormCases({
      {{-0.3, -0.34, -0.98}, {0.926084733220795, 15}},
      {{0.3, 0.34, 0.98}, {0.926084733220795, 15}},
      {{0.5}, {2, 15}},
      {{23, 432, 23, 456, 23}, {0.001588809450108087, 18}},
  });
  testRnorm3dCases({
      {{-0.3, -0.34, -0.98}, {0.926084733220795, 15}},
      {{0.3, 0.34, 0.98}, {0.926084733220795, 15}},
      {{0.5, 456, 23}, {0.002190196923407782, 18}},
      {{23, 432, 23}, {0.002308281062740199, 18}},
  });
  testRnorm4dCases({
      {{-0.3, -0.34, -0.98, 1}, {0.679470762492529, 15}},
      {{0.3, 0.34, 0.98, 1}, {0.679470762492529, 15}},
      {{0.5, 456, 23, 1}, {0.002190191670280358, 18}},
      {{23, 432, 23, 1}, {0.002308274913317669, 18}},
  });
  cout << "passed " << passed << "/" << passed + failed << " cases!" << endl;
  if (failed) {
    cout << "failed!" << endl;
  }
  return failed;
}
