```bash
[root@router1 ~]# vtysh

Hello, this is FRRouting (version 7.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# sh ip osp nei

Neighbor ID     Pri State           Dead Time Address         Interface                        RXmtL RqstL DBsmL
10.20.0.2         1 Full/DROther      38.905s 10.0.0.2        eth1:10.0.0.1                        0     0     0
10.20.0.1         1 Full/DROther      33.016s 10.10.0.2       eth2:10.10.0.1                       0     0     0
```
```bash
                                                                  My traceroute  [v0.92]
router1 (10.0.0.1)                                                                                                                  2020-10-19T11:44:55+0000
Keys:  Help   Display mode   Restart statistics   Order of fields   quit
                                                                                                                    Packets               Pings
 Host                                                                                                             Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. 10.20.0.2                                                                                                      0.0%   326    0.7   0.7   0.5   5.9   0.3
```
```bash
```