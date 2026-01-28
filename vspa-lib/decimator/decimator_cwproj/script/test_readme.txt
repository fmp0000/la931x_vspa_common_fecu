=================================================
Steps to run the DECIMATOR module:
=================================================
1. Open the project in CodeWarrior IDE and build.
2. Choose the testing option by setting the "DBG" flag from "test_cfg.tcl" to:
    -> 0 for running the testcases
    -> 1 for debugging the first testcase in the specified range
3. Select the testvector range to run by setting the "TC_NUM_START" and "TC_NUM_END" variables from "test_cfg.tcl".
4. Open the CodeWarrior Debugger Shell and:
    4a. Change the directory with the "cd" command to the "project\script" folder
    4b. Enter the TCL command "source test_run.tcl"

Notes:
1. This project does for each testvector the following:
    1a. Changes a testing macro
    1b. Builds the project
    1c. Runs the code
    1d. Compares the output with the reference
2. Due to building the project for each testvector, running the entire test suite takes a lot of time. It is recommended 
to run only subsets of the entire test suite by choosing the "TC_NUM_START" and "TC_NUM_END" variables from "test_cfg.tcl".