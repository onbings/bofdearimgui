/*
 * Copyright (c) 2024-2044, OnBings All rights reserved.
 *
 * THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
 * KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
 * PURPOSE.
 *
 * This module defines and implements the BofImgui unit tests
 *
 * Author:      Bernard HARMEL: b.harmel@evs.com
 *
 * History:
 * V 1.00  Feb 19 2024  BHA : Initial release
 */
#include "gtestrunner.h"
#include <bofimgui/bof_imgui.h>

class ut_imgui : public ::testing::Test
{
protected:
  void SetUp() override
  {
    // Initialize any common resources before each test
  }

  void TearDown() override
  {
    // Cleanup common resources after each test
  }
};


void RefreshGui()
{
  ImGui::Text("Hello, world!");
  ImGui::ShowDemoWindow();
}

TEST_F(ut_imgui, ShowImgui)
{

  HelloImGui::RunnerParams RunnerParam_X;
  RunnerParam_X.callbacks.ShowGui = RefreshGui;
  HelloImGui::Run(RunnerParam_X);
  //HelloImGui::Run([&]() { ImGui::Text("Hello, world!"); ImGui::ShowDemoWindow(); });
}
