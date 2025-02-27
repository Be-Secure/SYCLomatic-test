// ====------------ math-ext-double.cu---------- *- CUDA -* -------------===////
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

__global__ void _erfcinv(double *const DeviceResult, double Input) {
  *DeviceResult = erfcinv(Input);
}

void testErfcinv(double *const DeviceResult, double Input) {
  _erfcinv<<<1, 1>>>(DeviceResult, Input);
  cudaDeviceSynchronize();
  // TODO: Need test host side.
}

void testErfcinvCases(const vector<pair<double, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  // Boundary values.
  testErfcinv(DeviceResult, 0);
  cout << "erfcinv(" << 0 << ") = " << *DeviceResult << " (expect inf)";
  check(*DeviceResult > 999999.9);
  testErfcinv(DeviceResult, 2);
  cout << "erfcinv(" << 2 << ") = " << *DeviceResult << " (expect -inf)";
  check(*DeviceResult < -999999.9);
  // Other test values.
  for (const auto &TestCase : TestCases) {
    testErfcinv(DeviceResult, TestCase.first);
    checkResult("erfcinv", {TestCase.first}, TestCase.second.first,
                *DeviceResult, TestCase.second.second);
  }
}

__global__ void _erfinv(double *const DeviceResult, double Input) {
  *DeviceResult = erfinv(Input);
}

void testErfinv(double *const DeviceResult, double Input) {
  _erfinv<<<1, 1>>>(DeviceResult, Input);
  cudaDeviceSynchronize();
  // Call from host.
}

void testErfinvCases(const vector<pair<double, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  // Boundary values.
  testErfinv(DeviceResult, -1);
  cout << "erfinv(" << -1 << ") = " << *DeviceResult << " (expect -inf)";
  check(*DeviceResult < -999999.9);
  testErfinv(DeviceResult, 1);
  cout << "erfinv(" << 1 << ") = " << *DeviceResult << " (expect inf)";
  check(*DeviceResult > 999999.9);
  // Other test values.
  for (const auto &TestCase : TestCases) {
    testErfinv(DeviceResult, TestCase.first);
    checkResult("erfinv", {TestCase.first}, TestCase.second.first,
                *DeviceResult, TestCase.second.second);
  }
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
  // Call from host.
}

void testNormCases(const vector<pair<d_vector, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
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
  for (const auto &TestCase : TestCases) {
    testNormcdf(DeviceResult, TestCase.first);
    checkResult("normcdf", {TestCase.first}, TestCase.second.first,
                *DeviceResult, TestCase.second.second);
  }
}

__global__ void _normcdfinv(double *const DeviceResult, double Input) {
  *DeviceResult = normcdfinv(Input);
}

void testNormcdfinv(double *const DeviceResult, double Input) {
  _normcdfinv<<<1, 1>>>(DeviceResult, Input);
  cudaDeviceSynchronize();
  // Call from host.
}

void testNormcdfinvCases(const vector<pair<double, di_pair>> &TestCases) {
  double *DeviceResult;
  cudaMallocManaged(&DeviceResult, sizeof(*DeviceResult));
  // Boundary values.
  testNormcdfinv(DeviceResult, 0);
  cout << "normcdfinv(" << 0 << ") = " << *DeviceResult << " (expect -inf)";
  check(*DeviceResult < -999999.9);
  testNormcdfinv(DeviceResult, 1);
  cout << "normcdfinv(" << 1 << ") = " << *DeviceResult << " (expect inf)";
  check(*DeviceResult > 999999.9);
  // Other test values.
  for (const auto &TestCase : TestCases) {
    testNormcdfinv(DeviceResult, TestCase.first);
    checkResult("normcdfinv", {TestCase.first}, TestCase.second.first,
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

int main() {
  testErfcinvCases({
      {0.3, {0.732869077959217, 15}},
      {0.5, {0.4769362762044698, 16}},
      {0.8, {0.1791434546212916, 16}},
      {1.6, {-0.595116081449995, 15}},
  });
  testErfinvCases({
      {-0.3, {-0.2724627147267544, 16}},
      {-0.5, {-0.4769362762044698, 16}},
      {0, {0, 37}},
      {0.5, {0.4769362762044698, 16}},
  });
  testNormCases({
      {{-0.3, -0.34, -0.98}, {1.079814798935447, 15}},
      {{0.3, 0.34, 0.98}, {1.079814798935447, 15}},
      {{0.5}, {0.5, 16}},
      {{23, 432, 23, 456, 23}, {629.4020972319682, 13}},
  });
  testNormcdfCases({
      {-5, {0.0000002866515718791939, 22}},
      {-3, {0.00134989803163009458, 20}},
      {0, {0.5, 16}},
      {1, {0.841344746068543, 15}},
      {5, {0.9999997133484281, 16}},
  });
  testNormcdfinvCases({
      {0.3, {-0.524400512708041, 15}},
      {0.5, {0, 37}},
      {0.8, {0.841621233572915, 15}},
  });
  testRnormCases({
      {{-0.3, -0.34, -0.98}, {0.926084733220795, 15}},
      {{0.3, 0.34, 0.98}, {0.926084733220795, 15}},
      {{0.5}, {2, 16}},
      {{23, 432, 23, 456, 23}, {0.001588809450108087, 18}},
  });
  cout << "passed " << passed << "/" << passed + failed << " cases!" << endl;
  if (failed) {
    cout << "failed!" << endl;
  }
  return failed;
}
