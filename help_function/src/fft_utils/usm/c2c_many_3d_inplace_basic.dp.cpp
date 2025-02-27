// ===--- c2c_many_3d_inplace_basic.dp.cpp --------------------*- C++ -*---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// ===---------------------------------------------------------------------===//

#include <sycl/sycl.hpp>
#include <dpct/dpct.hpp>
#include <oneapi/mkl.hpp>
#include <dpct/fft_utils.hpp>
#include "common.h"
#include <cstring>
#include <iostream>

bool c2c_many_3d_inplace_basic() {
  dpct::device_ext &dev_ct1 = dpct::get_current_device();
  sycl::queue &q_ct1 = dev_ct1.default_queue();
  dpct::fft::fft_engine *plan_fwd;
  plan_fwd = dpct::fft::fft_engine::create();
  sycl::float2 forward_idata_h[2 /*n0*/ * 3 /*n1*/ * 4 /*n2*/ * 2 /*batch*/];
  set_value((float*)forward_idata_h, 48);
  set_value((float*)forward_idata_h + 48, 48);

  sycl::float2 *data_d;
  data_d = sycl::malloc_device<sycl::float2>(48, q_ct1);
  q_ct1.memcpy(data_d, forward_idata_h, sizeof(sycl::float2) * 48).wait();

  int n[3] = {2 ,3, 4};
  size_t workSize;
  plan_fwd->commit(&q_ct1, 3, n, nullptr, 0, 0, nullptr, 0, 0,
                   dpct::fft::fft_type::complex_float_to_complex_float, 2,
                   nullptr);
  plan_fwd->compute<sycl::float2, sycl::float2>(
      data_d, data_d, dpct::fft::fft_direction::forward);
  dev_ct1.queues_wait_and_throw();
  sycl::float2 forward_odata_h[48];
  q_ct1.memcpy(forward_odata_h, data_d, sizeof(sycl::float2) * 48).wait();

  sycl::float2 forward_odata_ref[48];
  forward_odata_ref[0] = sycl::float2{552, 576};
  forward_odata_ref[1] = sycl::float2{-48, 0};
  forward_odata_ref[2] = sycl::float2{-24, -24};
  forward_odata_ref[3] = sycl::float2{0, -48};
  forward_odata_ref[4] = sycl::float2{-151.426, -40.5744};
  forward_odata_ref[5] = sycl::float2{0, 0};
  forward_odata_ref[6] = sycl::float2{0, 0};
  forward_odata_ref[7] = sycl::float2{0, 0};
  forward_odata_ref[8] = sycl::float2{-40.5744, -151.426};
  forward_odata_ref[9] = sycl::float2{0, 0};
  forward_odata_ref[10] = sycl::float2{0, 0};
  forward_odata_ref[11] = sycl::float2{0, 0};
  forward_odata_ref[12] = sycl::float2{-288, -288};
  forward_odata_ref[13] = sycl::float2{0, 0};
  forward_odata_ref[14] = sycl::float2{0, 0};
  forward_odata_ref[15] = sycl::float2{0, 0};
  forward_odata_ref[16] = sycl::float2{0, 0};
  forward_odata_ref[17] = sycl::float2{0, 0};
  forward_odata_ref[18] = sycl::float2{0, 0};
  forward_odata_ref[19] = sycl::float2{0, 0};
  forward_odata_ref[20] = sycl::float2{0, 0};
  forward_odata_ref[21] = sycl::float2{0, 0};
  forward_odata_ref[22] = sycl::float2{0, 0};
  forward_odata_ref[23] = sycl::float2{0, 0};
  forward_odata_ref[24] = sycl::float2{552, 576};
  forward_odata_ref[25] = sycl::float2{-48, 0};
  forward_odata_ref[26] = sycl::float2{-24, -24};
  forward_odata_ref[27] = sycl::float2{0, -48};
  forward_odata_ref[28] = sycl::float2{-151.426, -40.5744};
  forward_odata_ref[29] = sycl::float2{0, 0};
  forward_odata_ref[30] = sycl::float2{0, 0};
  forward_odata_ref[31] = sycl::float2{0, 0};
  forward_odata_ref[32] = sycl::float2{-40.5744, -151.426};
  forward_odata_ref[33] = sycl::float2{0, 0};
  forward_odata_ref[34] = sycl::float2{0, 0};
  forward_odata_ref[35] = sycl::float2{0, 0};
  forward_odata_ref[36] = sycl::float2{-288, -288};
  forward_odata_ref[37] = sycl::float2{0, 0};
  forward_odata_ref[38] = sycl::float2{0, 0};
  forward_odata_ref[39] = sycl::float2{0, 0};
  forward_odata_ref[40] = sycl::float2{0, 0};
  forward_odata_ref[41] = sycl::float2{0, 0};
  forward_odata_ref[42] = sycl::float2{0, 0};
  forward_odata_ref[43] = sycl::float2{0, 0};
  forward_odata_ref[44] = sycl::float2{0, 0};
  forward_odata_ref[45] = sycl::float2{0, 0};
  forward_odata_ref[46] = sycl::float2{0, 0};
  forward_odata_ref[47] = sycl::float2{0, 0};

  dpct::fft::fft_engine::destroy(plan_fwd);

  if (!compare(forward_odata_ref, forward_odata_h, 48)) {
    std::cout << "forward_odata_h:" << std::endl;
    print_values(forward_odata_h, 48);
    std::cout << "forward_odata_ref:" << std::endl;
    print_values(forward_odata_ref, 48);

    sycl::free(data_d, q_ct1);

    return false;
  }

  dpct::fft::fft_engine *plan_bwd;
  plan_bwd = dpct::fft::fft_engine::create();
  plan_bwd->commit(&q_ct1, 3, n, nullptr, 0, 0, nullptr, 0, 0,
                   dpct::fft::fft_type::complex_float_to_complex_float, 2,
                   nullptr);
  plan_bwd->compute<sycl::float2, sycl::float2>(
      data_d, data_d, dpct::fft::fft_direction::backward);
  dev_ct1.queues_wait_and_throw();
  sycl::float2 backward_odata_h[48];
  q_ct1.memcpy(backward_odata_h, data_d, sizeof(sycl::float2) * 48).wait();

  sycl::float2 backward_odata_ref[48];
  backward_odata_ref[0] = sycl::float2{0, 24};
  backward_odata_ref[1] = sycl::float2{48, 72};
  backward_odata_ref[2] = sycl::float2{96, 120};
  backward_odata_ref[3] = sycl::float2{144, 168};
  backward_odata_ref[4] = sycl::float2{192, 216};
  backward_odata_ref[5] = sycl::float2{240, 264};
  backward_odata_ref[6] = sycl::float2{288, 312};
  backward_odata_ref[7] = sycl::float2{336, 360};
  backward_odata_ref[8] = sycl::float2{384, 408};
  backward_odata_ref[9] = sycl::float2{432, 456};
  backward_odata_ref[10] = sycl::float2{480, 504};
  backward_odata_ref[11] = sycl::float2{528, 552};
  backward_odata_ref[12] = sycl::float2{576, 600};
  backward_odata_ref[13] = sycl::float2{624, 648};
  backward_odata_ref[14] = sycl::float2{672, 696};
  backward_odata_ref[15] = sycl::float2{720, 744};
  backward_odata_ref[16] = sycl::float2{768, 792};
  backward_odata_ref[17] = sycl::float2{816, 840};
  backward_odata_ref[18] = sycl::float2{864, 888};
  backward_odata_ref[19] = sycl::float2{912, 936};
  backward_odata_ref[20] = sycl::float2{960, 984};
  backward_odata_ref[21] = sycl::float2{1008, 1032};
  backward_odata_ref[22] = sycl::float2{1056, 1080};
  backward_odata_ref[23] = sycl::float2{1104, 1128};
  backward_odata_ref[24] = sycl::float2{0, 24};
  backward_odata_ref[25] = sycl::float2{48, 72};
  backward_odata_ref[26] = sycl::float2{96, 120};
  backward_odata_ref[27] = sycl::float2{144, 168};
  backward_odata_ref[28] = sycl::float2{192, 216};
  backward_odata_ref[29] = sycl::float2{240, 264};
  backward_odata_ref[30] = sycl::float2{288, 312};
  backward_odata_ref[31] = sycl::float2{336, 360};
  backward_odata_ref[32] = sycl::float2{384, 408};
  backward_odata_ref[33] = sycl::float2{432, 456};
  backward_odata_ref[34] = sycl::float2{480, 504};
  backward_odata_ref[35] = sycl::float2{528, 552};
  backward_odata_ref[36] = sycl::float2{576, 600};
  backward_odata_ref[37] = sycl::float2{624, 648};
  backward_odata_ref[38] = sycl::float2{672, 696};
  backward_odata_ref[39] = sycl::float2{720, 744};
  backward_odata_ref[40] = sycl::float2{768, 792};
  backward_odata_ref[41] = sycl::float2{816, 840};
  backward_odata_ref[42] = sycl::float2{864, 888};
  backward_odata_ref[43] = sycl::float2{912, 936};
  backward_odata_ref[44] = sycl::float2{960, 984};
  backward_odata_ref[45] = sycl::float2{1008, 1032};
  backward_odata_ref[46] = sycl::float2{1056, 1080};
  backward_odata_ref[47] = sycl::float2{1104, 1128};

  sycl::free(data_d, q_ct1);
  dpct::fft::fft_engine::destroy(plan_bwd);

  if (!compare(backward_odata_ref, backward_odata_h, 48)) {
    std::cout << "backward_odata_h:" << std::endl;
    print_values(backward_odata_h, 48);
    std::cout << "backward_odata_ref:" << std::endl;
    print_values(backward_odata_ref, 48);
    return false;
  }
  return true;
}

#ifdef DEBUG_FFT
int main() {
#define FUNC c2c_many_3d_inplace_basic
  bool res = FUNC();
  cudaDeviceSynchronize();
  if (!res) {
    std::cout << "Fail" << std::endl;
    return -1;
  }
  std::cout << "Pass" << std::endl;
  return 0;
}
#endif

