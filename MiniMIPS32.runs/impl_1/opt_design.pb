
O
Command: %s
53*	vivadotcl2

opt_design2default:defaultZ4-113h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xc7a100t2default:defaultZ17-347h px� 
�
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xc7a100t2default:defaultZ17-349h px� 
n
,Running DRC as a precondition to command %s
22*	vivadotcl2

opt_design2default:defaultZ4-22h px� 
R

Starting %s Task
103*constraints2
DRC2default:defaultZ18-103h px� 
P
Running DRC with %s threads
24*drc2
62default:defaultZ23-27h px� 
U
DRC finished with %s
272*project2
0 Errors2default:defaultZ1-461h px� 
d
BPlease refer to the DRC report (report_drc) for more information.
274*projectZ1-462h px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:01 ; elapsed = 00:00:01 . Memory (MB): peak = 2086.004 ; gain = 48.023 ; free physical = 570 ; free virtual = 57342default:defaulth px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
8
Deriving generated clocks
2*timingZ38-2h px� 
a

Starting %s Task
103*constraints2&
Logic Optimization2default:defaultZ18-103h px� 
i

Phase %s%s
101*constraints2
1 2default:default2
Retarget2default:defaultZ18-101h px� 
u
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02default:default2
02default:defaultZ31-138h px� 
K
Retargeted %s cell(s).
49*opt2
02default:defaultZ31-49h px� 
;
&Phase 1 Retarget | Checksum: 79d40507
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.54 ; elapsed = 00:00:00.28 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57332default:defaulth px� 
�
.Phase %s created %s cells and removed %s cells267*opt2
Retarget2default:default2
02default:default2
12default:defaultZ31-389h px� 
u

Phase %s%s
101*constraints2
2 2default:default2(
Constant propagation2default:defaultZ18-101h px� 
u
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02default:default2
02default:defaultZ31-138h px� 
G
2Phase 2 Constant propagation | Checksum: 8deaa388
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.63 ; elapsed = 00:00:00.37 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57332default:defaulth px� 
�
.Phase %s created %s cells and removed %s cells267*opt2(
Constant propagation2default:default2
02default:default2
02default:defaultZ31-389h px� 
f

Phase %s%s
101*constraints2
3 2default:default2
Sweep2default:defaultZ18-101h px� 
9
$Phase 3 Sweep | Checksum: 113fcaf7f
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.73 ; elapsed = 00:00:00.47 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57332default:defaulth px� 
�
.Phase %s created %s cells and removed %s cells267*opt2
Sweep2default:default2
02default:default2
02default:defaultZ31-389h px� 
r

Phase %s%s
101*constraints2
4 2default:default2%
BUFG optimization2default:defaultZ18-101h px� 
E
0Phase 4 BUFG optimization | Checksum: 113fcaf7f
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.81 ; elapsed = 00:00:00.56 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57332default:defaulth px� 
�
.Phase %s created %s cells and removed %s cells267*opt2%
BUFG optimization2default:default2
02default:default2
02default:defaultZ31-389h px� 
|

Phase %s%s
101*constraints2
5 2default:default2/
Shift Register Optimization2default:defaultZ18-101h px� 
O
:Phase 5 Shift Register Optimization | Checksum: 113fcaf7f
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.85 ; elapsed = 00:00:00.60 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57342default:defaulth px� 
�
.Phase %s created %s cells and removed %s cells267*opt2/
Shift Register Optimization2default:default2
02default:default2
02default:defaultZ31-389h px� 
a

Starting %s Task
103*constraints2&
Connectivity Check2default:defaultZ18-103h px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.01 ; elapsed = 00:00:00.01 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57332default:defaulth px� 
J
5Ending Logic Optimization Task | Checksum: 113fcaf7f
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.94 ; elapsed = 00:00:00.68 . Memory (MB): peak = 2086.004 ; gain = 0.000 ; free physical = 569 ; free virtual = 57332default:defaulth px� 
a

Starting %s Task
103*constraints2&
Power Optimization2default:defaultZ18-103h px� 
s
7Will skip clock gating for clocks with period < %s ns.
114*pwropt2
2.002default:defaultZ34-132h px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
�
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2default:default2
 2default:default2
4.5102default:default2
0.0002default:defaultZ32-619h px� 
K
,Running Vector-less Activity Propagation...
51*powerZ33-51h px� 
P
3
Finished Running Vector-less Activity Propagation
1*powerZ33-1h px� 
=
Applying IDT optimizations ...
9*pwroptZ34-9h px� 
?
Applying ODC optimizations ...
10*pwroptZ34-10h px� 


*pwropth px� 
e

Starting %s Task
103*constraints2*
PowerOpt Patch Enables2default:defaultZ18-103h px� 
�
�WRITE_MODE attribute of %s BRAM(s) out of a total of %s has been updated to save power.
    Run report_power_opt to get a complete listing of the BRAMs updated.
129*pwropt2
02default:default2
312default:defaultZ34-162h px� 
d
+Structural ODC has moved %s WE to EN ports
155*pwropt2
02default:defaultZ34-201h px� 
�
CNumber of BRAM Ports augmented: %s newly gated: %s Total Ports: %s
65*pwropt2
02default:default2
02default:default2
622default:defaultZ34-65h px� 
N
9Ending PowerOpt Patch Enables Task | Checksum: 131d8d79e
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.09 ; elapsed = 00:00:00.09 . Memory (MB): peak = 2378.148 ; gain = 0.000 ; free physical = 535 ; free virtual = 56992default:defaulth px� 
J
5Ending Power Optimization Task | Checksum: 131d8d79e
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:06 ; elapsed = 00:00:03 . Memory (MB): peak = 2378.148 ; gain = 292.145 ; free physical = 544 ; free virtual = 57082default:defaulth px� 
Z
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
342default:default2
02default:default2
02default:default2
02default:defaultZ4-41h px� 
\
%s completed successfully
29*	vivadotcl2

opt_design2default:defaultZ4-42h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2 
opt_design: 2default:default2
00:00:092default:default2
00:00:052default:default2
2378.1482default:default2
340.1682default:default2
5442default:default2
57082default:defaultZ17-722h px� 
D
Writing placer database...
1603*designutilsZ20-1893h px� 
=
Writing XDEF routing.
211*designutilsZ20-211h px� 
J
#Writing XDEF routing logical nets.
209*designutilsZ20-209h px� 
J
#Writing XDEF routing special nets.
210*designutilsZ20-210h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2)
Write XDEF Complete: 2default:default2
00:00:00.032default:default2
00:00:00.012default:default2
2378.1482default:default2
0.0002default:default2
5442default:default2
57102default:defaultZ17-722h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2default:default2e
Q/home/zhang/Desktop/MiniMIPS32_lab3/MiniMIPS32.runs/impl_1/MiniMIPS32_SYS_opt.dcp2default:defaultZ17-1381h px� 
�
%s4*runtcl2�
|Executing : report_drc -file MiniMIPS32_SYS_drc_opted.rpt -pb MiniMIPS32_SYS_drc_opted.pb -rpx MiniMIPS32_SYS_drc_opted.rpx
2default:defaulth px� 
�
Command: %s
53*	vivadotcl2�
oreport_drc -file MiniMIPS32_SYS_drc_opted.rpt -pb MiniMIPS32_SYS_drc_opted.pb -rpx MiniMIPS32_SYS_drc_opted.rpx2default:defaultZ4-113h px� 
P
Running DRC with %s threads
24*drc2
62default:defaultZ23-27h px� 
�
#The results of DRC are in file %s.
168*coretcl2�
W/home/zhang/Desktop/MiniMIPS32_lab3/MiniMIPS32.runs/impl_1/MiniMIPS32_SYS_drc_opted.rptW/home/zhang/Desktop/MiniMIPS32_lab3/MiniMIPS32.runs/impl_1/MiniMIPS32_SYS_drc_opted.rpt2default:default8Z2-168h px� 
\
%s completed successfully
29*	vivadotcl2

report_drc2default:defaultZ4-42h px� 


End Record