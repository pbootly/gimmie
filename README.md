# gimmie (give me my files)
Near OS native parallel http get requests using RFC 7233

*NOTE - this is a very loosely tested set (currently only one) of scripts, and I suggest you test your own downloads for data integrity*


# Bash with Curl
Requirements:
  * curl (testing on 7.61.1)
  
## Example
Relying on http://mirror.filearena.net/pub/speed/SpeedTest_1024MB.dat for initial testing as its far from my machine

## Standard curl get request:
```
time curl http://mirror.filearena.net/pub/speed/SpeedTest_1024MB.dat -o standard_curl.dat
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1024M  100 1024M    0     0  7613k      0  0:02:17  0:02:17 --:--:-- 8546k

real           2m17.746s
user           0m0.509s
```
## Concurrency of 20 (arbitrary choice)
```
time ./gimmie.sh http://mirror.filearena.net/pub/speed/SpeedTest_1024MB.dat 20 20_concurrent.dat
Chunk: 1
Chunk: 2
Chunk: 3
Chunk: 4
Chunk: 5
Chunk: 6
Chunk: 7
Chunk: 8
Chunk: 9
Chunk: 10
Chunk: 11
Chunk: 12
Chunk: 13
Chunk: 14
Chunk: 15
Chunk: 16
Chunk: 17
Chunk: 18
Chunk: 19
Chunk: 20
Getting last chunk
Lastchunk number: 21
Chunk: 21
Rebuilding chunks...

real           0m21.341s
user           0m1.314s
sys            0m5.865s
```

Confirm there hasn't been any dataloss (defeats objective if you have to download regularly anyway, but this is the extent of current testing)
```
sha512sum *.dat
c5041ae163cf0f65600acfe7f6a63f212101687d41a57a4e18ffd2a07a452cd8175b8f5a4868dd2330bfe5ae123f18216bdbc9e0f80d131e64b94913a7b40bb5  20_concurrent.dat
c5041ae163cf0f65600acfe7f6a63f212101687d41a57a4e18ffd2a07a452cd8175b8f5a4868dd2330bfe5ae123f18216bdbc9e0f80d131e64b94913a7b40bb5  standard_curl.dat
```
