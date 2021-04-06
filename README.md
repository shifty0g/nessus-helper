Nessus Helper 
================
v1
06/04/21

A simple script that will make changes and revert them to get a Nessus authenticated scan working on Windows

Features:
----------
* Backup and Restore Reg keys, Windows firewall 
* Creates a local admin users
* Enables File and Printer sharing on Windows Firewall 
* Start Remote Registry Service 
* Start WMI Service
* 

Useage:
-----------
Make sure you can run powershell scripts - you may need to enable Execution Policy

./nessus-helper enable      # open things up to allow you to scan via port 445
./nessus-helper disable     # when you are done and want to revert changed
