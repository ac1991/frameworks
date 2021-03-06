#
# Copyright (C) 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# usage: generate_vts_test.sh <tests>

VTS_PATH=`realpath ../`
function generate_one_testcase {
  # Generate one testcase
  BASENAME=`basename -s .mod.py $1`
  ../../../tools/test_generator/test_generator.py ./`basename $1`\
    --vts \
    -m $VTS_PATH/generated/vts_models/$BASENAME.model.cpp \
    -e $VTS_PATH/generated/examples/$BASENAME.example.cpp
  # Paste these lines into TestGenerated.cpp
  echo
  echo namespace $BASENAME {
  echo std::vector\<MixedTypedExample\> examples \= {
  echo // Generated $BASENAME test
  echo \#include \"examples/$BASENAME.example.cpp\"
  echo }\;
  echo // Generated model constructor
  echo \#include \"vts_models/$BASENAME.model.cpp\"
  echo }  // namespace $BASENAME
  echo TEST_F\(NeuralnetworksHidlTest\, $BASENAME\) {
  echo '    generated_tests::Execute'\(device,
  echo '                             '$BASENAME\:\:createTestModel\,
  echo '                             '$BASENAME\:\:is_ignored\,
  echo '                             '$BASENAME\:\:examples\)\;
  echo }
}

cd $ANDROID_BUILD_TOP/frameworks/ml/nn/runtime/test/specs
OUTFILE=$VTS_PATH/generated/all_generated_vts_tests.cpp
echo "// DO NOT EDIT;" > $OUTFILE
echo "// Generated by ml/nn/runtime/test/specs/generate_vts_test.sh" >> $OUTFILE
for f in *.mod.py;
do
  if [ $f = "mobilenet_quantized.mod.py" ]; then
    echo "Skipping mobilenet quantized"
    continue
  fi
  echo "Processing $f"
  generate_one_testcase $f >> $OUTFILE
done
echo "Generated file in $VTS_PATH/generated/"`basename $OUTFILE`

